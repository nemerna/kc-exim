# kc-exim
KeyCloak user Export/Import tool

## how to run **docker-needed**

### build-docker
```
make build-docker
```

### build-podman
```
make build-podman
```

### EXPORT

1. prepare variables
   ```
      # export the following env variables
      export EXPORT_KEYCLOAK_SERVER=http://localhost:2020
      export EXPORT_REALM=kcm
      export EXPORT_TOKEN=xxxxx
   ```
2. start the EXPORT job
   ```
      make export
   ```


### IMPORT

1. prepare variables
   ```
      # export the following env variables
      IMPORT_KEYCLOAK_SERVER=http://localhost:1010
      IMPORT_REALM=kcm
      IMPORT_TOKEN=xxxxx      
   ```

2. start the IMPORT job
   ```
   make import
   ```



### obtaining a token

```
   export EXPORT_TOKEN=$(curl -X POST --location "https://your-keyclaok-server/realms/kcm/protocol/openid-connect/token" -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=password&username=your-user-name&password=no-one-knows&client_id=your-client-id"  | jq -r .access_token)
```
