#!/usr/bin/env bash

sudo make start-keycloak
export MODE=keycloak
sudo make start-rabbitmq
