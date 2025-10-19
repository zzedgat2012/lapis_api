.PHONY: start stop restart migrate test logs shell clean

start:
	docker compose up -d

stop:
	docker compose down

restart:
	docker compose down
	docker compose up -d

migrate:
	docker compose exec web lapis migrate

test:
	docker compose exec web busted

logs:
	docker compose logs -f web

shell:
	docker compose exec web sh

clean:
	docker compose down -v
