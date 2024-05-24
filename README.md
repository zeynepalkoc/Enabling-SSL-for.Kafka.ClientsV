# Enabling SSL for Kafka Clients

It is ensured that the necessary certificates are created to encrypt the traffic between Kafka Brokers and clients.

### Creating Certificates
* chmod +x creating_certificates_for_kafka.sh
* ./creating_certificates_for_kafka.sh

***NOTE:** Before running the script, the **SUBJECT** information in it must be updated.*

<img src="https://github.com/tolgaakkapulu/Enabling_SSL_for_Kafka_Clients/blob/main/creating_certificates_for_kafka.png"><br><br>

### Kafka Configs
```
listeners=PLAINTEXT://localhost:9092,SSL://localhost:9093
security.inter.broker.protocol=PLAINTEXT
ssl.client.auth=none
ssl.key.password=PASSWORD
ssl.keystore.location=/etc/kafka/certs/kafka.server.keystore.jks
ssl.keystore.password= PASSWORD
ssl.truststore.location=/etc/kafka/certs/kafka.server.truststore.jks
ssl.truststore.password= PASSWORD
port=9092
ssl.enabled.protocols=TLSv1.2
ssl.endpoint.identification.algorithm=HTTPS
ssl.keystore.type=JKS
ssl.truststore.type=JKS
```
***NOTE:** Instead of **PASSWORD** information, the password entered in the first step of the certificate creation process must be written.*
