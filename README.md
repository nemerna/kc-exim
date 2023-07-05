# kcum
key cloak user migrationr shell scripts

## about
this app contains the kcadm.sh and its dependincies script provided with the latest Keycloak distibution.
in addition a customized scripts that uses the kcadm.sh to export/import keycloak users from a server/realm into a target server/realm
it does export relevant user infor including attributes
it does export group paths
during the import, the same groups expected to pre-exist in the target server, and the newly migrated users will join the target groups according to the target server group ids, (automatically)

## how to run

1. clone
   
   ```

   git clone git@github.com:nemerna/kcum.git
   ```
2. move to the project dir directory
   
   ```
    cd kcum
   ```

3. add the bin to your PATH

   ```
    export PATH=$PATH:$(pwd)/bin
   ```

4. export relevant env vars
   
   ```

    #the work directory to proccess directory (always should be set)
    export WORK_DIRECTORY=./USERMANAGER_EXPORT

    # the source server url (copy from)
    export IMPORT_KEYCLOAK_SERVER=https://src-server.com

    # the realm of the source server (copy from)
    export IMPORT_REALM=src-realm

    # the client-id of the source server (copy from)
    export IMPORT_CLIENT=src-client

    # the client secret of the source server (copy from)
    export IMPORT_SECRET=src-secret


    # the target server url (create in)
    export EXPORT_KEYCLOAK_SERVER=https://target-server.com

    # the realm of the target server (create in)
    export EXPORT_REALM=target-realm

    # the client-id of the target server (create in)
    export EXPORT_CLIENT=target-client

    # the client secret of the target server (create in)
    export EXPORT_SECRET=target-secret

   ```
4. run the user manager
   
   ```
   ./user-manager.sh [export | import | migrate]
   ```
**NOTE: when you export, only export parameters needed, when import then only import parameters are needed, when igrate you need to specify both export and import related variables**