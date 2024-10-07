#!/bin/bash

# sudo docker network create localtest
sudo docker-compose up -d
# sudo docker-compose logs certbot

# echo "0 3 * * * docker-compose -f /path/to/your/docker-compose.yml run --rm certbot renew --quiet" | sudo tee -a /etc/crontab
# sudo systemctl restart cron