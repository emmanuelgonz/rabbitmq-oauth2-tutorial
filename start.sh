#!/usr/bin/env bash

# Start Keycloak
#sudo make start-keycloak

# Start RabbitMQ
export MODE=keycloak
sudo make start-rabbitmq

# Start TCP relay
#sudo docker run -d -p 15670:15670 --net rabbitmq_net cloudamqp/websocket-tcp-relay --upstream tls://98.83.140.219:5671 --bind=98.83.140.219 --tls-cert=/conf/certs_private/basic/server_localhost/cert.pem --tls-key=/conf/certs_private/basic/server_localhost/key.pem
