# kc-exim
KeyCloak user Export/Import tool

## Building the Image

### Build
```
make build
```


### build with Docker
```
make build-docker
```


### build with Podman
```
make build-podman
```

---
---
## Variables Used By the Application

| Environment Variables    	|                                                      Description                                                      	|
|--------------------------	|:---------------------------------------------------------------------------------------------------------------------:	|
| `EXPORT_KEYCLOAK_SERVER` 	|                              The Keycloak Server that you would like to export Users from                             	|
| `EXPORT_REALM`           	|                       The Realm Name under the EXPORT Server you would like to export users from                      	|
| `EXPORT_TOKEN`           	| A Temporary Token you need to obtain (using curl or any other method)<br>used for authenticating to the EXPORT server 	|
| `IMPORT_KEYCLOAK_SERVER` 	|                              The Keycloak Server that you would like to Import Users into                             	|
| `IMPORT_REALM`           	|                       The Realm Name under the IMPORT Server you would like to IMPORT users into                      	|
| `IMPORT_TOKEN`           	| A Temporary Token you need to obtain (using curl or any other method)<br>used for authenticating to the IMPORT server 	|

---
---

## Running The Application


### EXPORT

1. prepare variables
   ```
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

---
---

## Help Commands

### obtaining an EXPORT_TOKEN token example

```
   export EXPORT_TOKEN=$(curl -X POST --location "https://$EXPORT_KEYCLOAK_SERVER/realms/$EXPORT_REALM/protocol/openid-connect/token" -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=password&username=$USER_NAME_PLACE_HOLDER&password=$PASSWORD_PLACE_HOLDER&client_id=$CLIENT_ID_PLACE_HOLDER"  | jq -r .access_token)
```

### obtaining an IMPORT_TOKEN token example

```
   export IMPORT_TOKEN=$(curl -X POST --location "https://$IMPORT_KEYCLOAK_SERVER/realms/$IMPORT_REALM/protocol/openid-connect/token" -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=password&username=$USER_NAME_PLACE_HOLDER&password=$PASSWORD_PLACE_HOLDER&client_id=$CLIENT_ID_PLACE_HOLDER"  | jq -r .access_token)
```


