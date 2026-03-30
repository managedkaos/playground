all: build up logs

init:
	cp .env.example .env

build:
	docker compose build

up:
	docker compose up --detach

down:
	-docker compose down

logs:
	-docker compose logs -f

status:
	-docker compose ps

seed:
	docker compose run --rm seed

clean:
	-docker compose down -v --remove-orphans

.PHONY: all init build up down logs status seed clean
