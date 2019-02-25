.ONESHELL:# single shell invocation for all lines in the recipe
SHELL = bash# we depend on bash expansion for e.g. queue patterns

.DEFAULT_GOAL = help


### TARGETS ###

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


install-uaa: ## Install UAA
	@wget https://github.com/cloudfoundry/uaa/archive/4.24.0.tar.gz
	@tar xvfz 4.24.0.tar.gz
	@rm 4.24.0.tar.gz
	@mv uaa-4.24.0 uaa

install-uaac: ## Install UAA Client
	@sudo gem install cf-uacc

uaa: install-uaa

start-uaa: uaa ## Run uaa
	@docker run -it -rm -v $(CURDIR)/uaa:/uaa -p 8080:8080 openjdk:8-jdk /uaa/gradlew run
	@curl -k  -H 'Accept: application/json' http://localhost:8080/uaa/info | jq .
	@uaac target  http://localhost:8080/uaa
	@uaac token client get admin -s adminsecret
	@uaac client update admin --authorities "clients.read clients.secret clients.write uaa.admin clients.admin scim.write scim.read uaa.resource"
	@./setup-uaa

get-plugin:
	@wget https://github.com/rabbitmq/rabbitmq-auth-backend-oauth2/archive/master.zip
	@rm -rf rabbitmq-auth-backend-oauth2-master
	@unzip master.zip
	@rm master.zip

build-plugin: get-plugin
	@cd rabbitmq-auth-backend-oauth2-master; \
		make; \
		make dist

rabbitmq-auth-backend-oauth2-master/plugins/rabbitmq_auth*.ez: build-plugin

build-docker-image: rabbitmq-auth-backend-oauth2-master/plugins/rabbitmq_auth*.ez ## Build RabbitMQ docker image
	@rm -rf plugin
	@mkdir plugin
	@cp rabbitmq-auth-backend-oauth2-master/plugins/rabbitmq_auth*.ez plugin
	@cp rabbitmq-auth-backend-oauth2-master/plugins/base64url-*.ez plugin
	@cp rabbitmq-auth-backend-oauth2-master/plugins/jose-*.ez plugin
	@docker build -t rabbitmq-oauth2 -f rabbitmq-Dockerfile .

start-rabbitmq:  ## Run RabbitMQ Server
	@cp rabbitmq.config plugin
	@cp enabled_plugins plugin
	@docker run -rm -it \
		--name rabbitmq \
		-v $(CURDIR)/plugin:/etc/rabbitmq \
		-p 15672:15672 \
		rabbitmq-oauth2


curl: ## Run curl with a JWT token. Syntax: make curl url=http://localhost:15672/api/overview as=rabbit_admin
	@./curl_url $(as) $(url)

open: ## Open the browser and login the user with the JWT Token. Syntax: make open as=rabbit_admin
	@./open_url $(as)
