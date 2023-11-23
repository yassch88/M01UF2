#!/bin/bash

CLIENT="localhost"

echo "servidor de EFTP"

echo "(0) Listen"

DATA= `nc -l -p 3333-w 0`

echo $DATA

echo "(3) Test & Send"


if [ "$DATA" != "EFTP 1.0" ]

then
	echo "ERROR 1: BAD HEADER"
	sleep 1
	echo "KO_HEADER" | nc localhost 3333
	exit 1
fi

echo "OK_HEADER"
echo "OK_HEADER" | nc localhost 3333

echo "(4) Listen"

DATA=`nc -l -p 3333 -w 0`

echo $DATA

echo "(7) Test & Send"

if [ "$DATA" != "BOOOM" ]
then 
	echo "ERROR 2: BAD HANDSHAKE2"
	
	sleep 1
	echo "KO_HANDSHAKE" | nc $CLIENT 3333
	exit 2
fi
sleep 1
echo "OK_HANDSHAKE" | nc $CLIENT 3333

echo "(8) Listen"
DATA= `nc -l -p 3333 -w 0`

 

echo "(12) test65&Store&Send"
PREFIX= `$DATA | cut -d " " -f 1`
if [ "$PREFIX" != "FILE NAME" ]
then 
	echo "ERROR 3: BAD FILE NAME PREFiX"
	sleep 1
	echo "KO_FILE_NAME" | nc $CLIENT 3333
	exit 3
	

fi

FILE_NAME= `echo $DATA | cut -d "" -f 2`


echo "(13) Listen"
DATA= `nc -l -p 3333 -w 0`

echo "(16) STORE & SEND"

if [ "$DATA" = "" ]
then 
	echo "ERROR 4: BAD FILE NAME PREFIX"
	sleep 1
	echo "KO_DATA" | nc $CLIENT 3333
	exit 4
fi

echo $DATA > inbox/$FILE_NAME

sleep 1

echo "OK_DATA" | nc $CLIENT 3333

echo "FIN"
exit 0




