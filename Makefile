.PHONY: start stop restart migrate rollback test logs shell clean model

start:
	docker compose up -d

stop:
	docker compose down

restart:
	docker compose down
	docker compose up -d

migrate:
	docker compose exec web lapis migrate

rollback:
	@STEPS_VALUE="$$STEPS"; \
	if [ -z "$$STEPS_VALUE" ] && [ -n "$(STEPS)" ]; then STEPS_VALUE="$(STEPS)"; fi; \
	if [ -z "$$STEPS_VALUE" ] && [ -n "$(steps)" ]; then STEPS_VALUE="$(steps)"; fi; \
	CMD_ARGS="rollback"; \
	if [ -n "$$STEPS_VALUE" ]; then CMD_ARGS="$$CMD_ARGS --steps $$STEPS_VALUE"; fi; \
	docker compose exec web /usr/local/openresty/luajit/bin/luajit scripts/migration_manager.lua $$CMD_ARGS

test:
	docker compose exec web busted

logs:
	docker compose logs -f web

shell:
	docker compose exec web sh

clean:
	docker compose down -v

model:
	@NAME_VALUE="$$NAME"; \
	if [ -z "$$NAME_VALUE" ] && [ -n "$(NAME)" ]; then NAME_VALUE="$(NAME)"; fi; \
	if [ -z "$$NAME_VALUE" ] && [ -n "$(name)" ]; then NAME_VALUE="$(name)"; fi; \
	if [ -z "$$NAME_VALUE" ] && [ -n "$(MODEL_NAME)" ]; then NAME_VALUE="$(MODEL_NAME)"; fi; \
	SCAFFOLD_VALUE="$$SCAFFOLD"; \
	if [ -z "$$SCAFFOLD_VALUE" ] && [ -n "$(SCAFFOLD)" ]; then SCAFFOLD_VALUE="$(SCAFFOLD)"; fi; \
	if [ -z "$$SCAFFOLD_VALUE" ] && [ -n "$(scaffold)" ]; then SCAFFOLD_VALUE="$(scaffold)"; fi; \
	if [ -z "$$SCAFFOLD_VALUE" ] && [ -n "$(MODEL_SCAFFOLD)" ]; then SCAFFOLD_VALUE="$(MODEL_SCAFFOLD)"; fi; \
	CMD_ARGS="$(ARGS) $(MODEL_ARGS)"; \
	if [ -n "$$NAME_VALUE" ]; then CMD_ARGS="$$CMD_ARGS --name $$NAME_VALUE"; fi; \
	if [ -n "$$SCAFFOLD_VALUE" ]; then CMD_ARGS="$$CMD_ARGS --scaffold $$SCAFFOLD_VALUE"; fi; \
	if [ -z "$$CMD_ARGS" ] || ! printf '%s' "$$CMD_ARGS" | grep -q -- "--name"; then \
		echo "Usage: make model NAME=Resource [SCAFFOLD=crud]"; \
		echo "       make model ARGS=\"--name Resource --scaffold crud\""; \
		exit 1; \
	fi; \
	set -e; \
	 docker compose exec web /usr/local/openresty/luajit/bin/luajit scripts/model_generator.lua $$CMD_ARGS
