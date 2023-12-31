#!/bin/bash

if [ $# -eq 0 ]
then
	SERVER="localhost"
elif [ $# -eq 1 ]
then
	SERVER=$1
fi
echo $0
SERVER="localhost"


IP=`ip address | grep inet | head -n3 | tail -n 1 | cut -d " " -f 6 | cut -d "/" -f 1`
TIMEOUT=1
echo $IP


if [ $# -eq 2 ]
then
	echo "(-1) Reset"
	echo "RESET" | nc $SERVER $PORT
	sleep 2
fi


echo "(1) Send"

echo "cliente de EFTP"

echo "EFTP 1.0" | nc $SERVER 3333

echo "(2) Listen"

DATA=`nc -l -p 3333 -w $TIMEOUT`

echo $DATA

echo "(5) Test & Send"

if [ "$DATA" != "OK_HEADER" ]
then
	 echo "ERROR 1: BAD HEADER"
	 exit 1
fi

echo "BOOOM" 
sleep 1

echo "BOOOM" | nc $SERVER 3333

echo "(6) Listen"
DATA=`nc -l -p 3333 -w $TIMEOUT`

echo $DATA

echo "(9) Test"

if [ "$DATA" != "OK_HANDSHAKE" ]
then 
	echo "ERROR 2: BAD HANDSHAKE"
	exit 2
fi

echo "(9a) SEND NUM_FILES"
NUM_FILES=`ls img/ wc | -l`
sleep 1

echo "NUM_FILES $NUM_FILES" | nc $SERVER 3333

echo "(9b) LISTEN OK/KO_NUM_FILES"
DATA=`nc -l -p 3333 -w $TIMEOUT`

if [ "$DATA" != "OK_FILE_NUM" ]
then
	echo "ERROR 3a: WRONG FILE_NUM"
	exit 3
fi

for FILE_NAME in `ls img/`
do



	
echo "(10b) Send FILE_NAME"
FILE_NAME="farly1.txt"
sleep 1
#FILE_NAME="farly1.txt"
FILE_MD5=`echo $FILE_NAME | md5sum | cut -d " " -f 1`

echo "FILE_NAME farly1.txt" | nc $SERVER 3333

echo "(11) Listen" 
DATA=`nc -l -p 3333 -w $TIMEOUT`

echo "(14) Send"

if [ "$DATA" != "OK_FILE_NAME" ]
then 
	echo "ERROR 3: BAD FILE NAME PREFIX"
	exit 3
fi 

sleep 1
cat imgs/farly1.txt | nc $SERVER 3333

echo "(15) Listen"
DATA=`nc -l -p 3333 -w $TIMEOUT`


if [ "$DATA" != "OK_DATA" ]
then
	echo "ERROR 4: BAD DATA"
	exit 4

fi

echo "(18) Send"
FILE_MD5=`cat imgs/$FILE_NAME | md5sum | cut -d " " -f -1`
echo "FILE_MD5 $FILE_MD5" | nc $SERVER 3333

echo "(19) Listen"
DATA=`nc -l -p 3333 -w $TIMEOUT`

echo "(21) Test"
if [ "$DATA" != "OK_FILE_MD5" ]
exit 5

echo "FIN"
exit 0
