
help: ## Prints help for targets with comments
	@grep -E '^[a-zA-Z0-9.\ _-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build:
	docker build -t kc-exim:latest .

export: ## run an export job, exports remote server users into local filesystem


	docker run -it \
	-e EXPORT_KEYCLOAK_SERVER=$(EXPORT_KEYCLOAK_SERVER) \
	-e EXPORT_REALM=$(EXPORT_REALM) \
	-e EXPORT_TOKEN=$(token) \
	-v $(WORK_DIRECTORY):/home/default/EXPORT_DIR \
	kc-exim:latest export

# export: ## run an export job, exports remote server users into local filesystem


# 	CONTAINER_ID=$$(docker run -d \
# 	-e EXPORT_KEYCLOAK_SERVER=$(EXPORT_KEYCLOAK_SERVER) \
# 	-e EXPORT_REALM=$(EXPORT_REALM) \
# 	-e EXPORT_TOKEN=$(token) \
# 	-v $(WORK_DIRECTORY):/home/default/EXPORT_DIR \
# 	kc-exim:latest export); \
# 	docker wait $${CONTAINER_ID}

import: ## run an import job, imports local users/groups into a remote server

	docker run -it \
	-e IMPORT_KEYCLOAK_SERVER=$(IMPORT_KEYCLOAK_SERVER) \
	-e IMPORT_REALM=$(IMPORT_REALM) \
	-e IMPORT_TOKEN=$(token) \
	-v $(WORK_DIRECTORY):/home/default/IMPORT_DIR \
	kc-exim:latest import