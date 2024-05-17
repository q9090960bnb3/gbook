build:
	gbook build . docs
serve:
	gbook serve . docs
up: 
	docker compose up
down: 
	docker compose down
rmi:down
	-docker rmi gbook-gbook-doc