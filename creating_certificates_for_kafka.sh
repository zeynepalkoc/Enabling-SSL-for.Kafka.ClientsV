#!/bin/bash

echo -e """\e[34m
============================================
|  Kafka Certificates Generating Password  |
============================================\e[0m"""
while true
do
        read -sep $'\e[33mEnter password    : \e[0m' PASSWORD
        read -sep $'\n\e[33mRe-enter password : \e[0m' PASSWORD_RETYPE

        if [ $PASSWORD == $PASSWORD_RETYPE ]; then
                echo -e "\n\e[32mPassword was created successfully.\e[0m"
                break
        else
                echo -e "\n\e[31mEntered passwords do not match. Please try again...\n\e[0m"
        fi
done

VALIDITY=1825
C="Country Name"
S="State or Province Name"
L="Locality Name"
O="Organization Name"
OU="Organizational Unit Name"
CN="Common Name (eg, your name or your server's hostname)"
emailAddress="Email Address"
SUBJECT="/C=$C/ST=$S/L=$L/O=$O/OU=$OU/CN=$CN/emailAddress=$emailAddress"

KAFKA_BROKERS=("kafka-broker1" "kafka-broker2" "kafka-broker3")

CERT_PATH="kafka-certs"
CA_PATH="ca-cert"

mkdir $CERT_PATH && cd $CERT_PATH
mkdir $CA_PATH

echo -e """\e[34m
===============================
|  Creating a CA certificate  |
===============================\e[0m"""
cd $CA_PATH

echo -e "\e[32mopenssl req -nodes -new -x509 -keyout ca-root.key -out ca-root.crt -days $VALIDITY -subj $SUBJECT\e[0m"
openssl req -nodes -new -x509 -keyout ca-root.key -out ca-root.crt -days $VALIDITY -subj $SUBJECT 2> /dev/null



echo -e """\e[34m
============================================
|  Kafka Brokers certificates are created  |
============================================\e[0m"""
for KAFKA_BROKER in "${KAFKA_BROKERS[@]}"
do
	echo -e "\e[33m$KAFKA_BROKER\e[0m"
	BROKER_PATH="../$KAFKA_BROKER-certs"
	mkdir $BROKER_PATH && cd $BROKER_PATH
	
	DNAME="CN=$KAFKA_BROKER,OU=$OU,O=$O,L=$L,S=$S,C=$C"
	
	echo -e "\e[32mkeytool -keystore kafka.server.keystore.jks -alias $KAFKA_BROKER -validity $VALIDITY -genkey -keyalg RSA -dname $DNAME -storepass PASSWORD\e[0m"
	echo "" | keytool -keystore kafka.server.keystore.jks -alias $KAFKA_BROKER -validity $VALIDITY -genkey -keyalg RSA -dname $DNAME -storepass $PASSWORD 2> /dev/null > tmp.file
	
	echo -e "\e[32mkeytool -keystore kafka.server.keystore.jks -alias $KAFKA_BROKER -certreq -file `echo $KAFKA_BROKER`_server.csr -storepass PASSWORD\e[0m"
	keytool -keystore kafka.server.keystore.jks -alias $KAFKA_BROKER -certreq -file `echo $KAFKA_BROKER`_server.csr -storepass $PASSWORD 2> /dev/null > tmp.file
	
	echo -e "\e[32mopenssl x509 -req -CA ../$CA_PATH/ca-root.crt -CAkey ../$CA_PATH/ca-root.key -in `echo $KAFKA_BROKER`_server.csr -out `echo $KAFKA_BROKER`_server.crt -days $VALIDITY -CAcreateserial\e[0m"
	openssl x509 -req -CA ../$CA_PATH/ca-root.crt -CAkey ../$CA_PATH/ca-root.key -in `echo $KAFKA_BROKER`_server.csr -out `echo $KAFKA_BROKER`_server.crt -days $VALIDITY -CAcreateserial 2> /dev/null > tmp.file
	
	echo -e "\e[32mkeytool -keystore kafka.server.keystore.jks -alias CARoot -import -noprompt -file ../$CA_PATH/ca-root.crt -storepass PASSWORD\e[0m"
	keytool -keystore kafka.server.keystore.jks -alias CARoot -import -noprompt -file ../$CA_PATH/ca-root.crt -storepass $PASSWORD 2> /dev/null > tmp.file
	
	echo -e "\e[32mkeytool -keystore kafka.server.keystore.jks -alias $KAFKA_BROKER -import -file `echo $KAFKA_BROKER`_server.crt -storepass PASSWORD\e[0m"
	keytool -keystore kafka.server.keystore.jks -alias $KAFKA_BROKER -import -file `echo $KAFKA_BROKER`_server.crt -storepass $PASSWORD 2> /dev/null > tmp.file
	
	echo -e "\e[32mkeytool -keystore kafka.server.truststore.jks -alias CARoot -import -file ../$CA_PATH/ca-root.crt -storepass PASSWORD\e[0m"
    echo "yes" | keytool -keystore kafka.server.truststore.jks -alias CARoot -import -file ../$CA_PATH/ca-root.crt -storepass $PASSWORD 2> /dev/null > tmp.file

	rm -rf tmp.file
done


echo -e """\e[33m\n
======================================
|  Certificate generation completed  |
======================================\e[0m
\e[34mThe created certificates are copied to the relevant kafka broker servers by following the below path.\e[0m"""

for KAFKA_BROKER in "${KAFKA_BROKERS[@]}"
do
    echo -e "\e[32m    rsync -a $CERT_PATH/$CA_PATH/* $CERT_PATH/$KAFKA_BROKER-certs/* $KAFKA_BROKER:/etc/kafka/certs/\e[0m"
done
echo ""

