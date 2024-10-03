#!/usr/bin/env bash

# Start Keycloak
#sudo make start-keycloak

# Start RabbitMQ
export MODE=keycloak
sudo make start-rabbitmq
