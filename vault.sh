#!/usr/bin/env bash

echo Applying Keycloak DB configurations on Vault

# Configure our access
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_TOKEN="myroot"

# verify the connection
vault status

# Enable the database secrets engine
vault secrets enable database

# Configure the engine to connect to our Postgres database using the user we created earlier.
vault write database/config/keycloak plugin_name=postgresql-database-plugin allowed_roles="dbuser" connection_url="postgresql://{{username}}:{{password}}@postgres:5432/keycloak?sslmode=disable" username="postgres" password="password"

vault write database/roles/dbuser db_name="keycloak" default_ttl="1m" max_ttl="2m" creation_statements="CREATE USER \"{{name}}\" WITH SUPERUSER ENCRYPTED PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"{{name}}\"; GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO \"{{name}}\"; GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO \"{{name}}\";"
#ALTER USER someone WITH NOLOGIN;
vault read database/creds/dbuser
