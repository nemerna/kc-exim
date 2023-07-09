# kc-exim
KeyCloak user Export/Import tool

## how to run **docker-needed**

### build
```
make build
```

### EXPORT

1. prepare variables
   ```
      # export the following env variables
      EXPORT_KEYCLOAK_SERVER=http://localhost:2020
      EXPORT_REALM=kcm
      EXPORT_TOKEN=xxxxx
      WORK_DIRECTORY=$(pwd)/some-dir
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
      WORK_DIRECTORY=$(pwd)/some-dir-that-contain-previous-export
      
   ```

2. start the IMPORT job
   ```
   make import
   ```



### obtaining a token

```
   export token=$(curl -X POST --location "https://your-keyclaok-server/realms/kcm/protocol/openid-connect/token" -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=password&username=your-user-name&password=no-one-knows&client_id=your-client-id"  | jq -r .access_token)
```