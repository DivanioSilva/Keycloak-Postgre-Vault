VAULT_HEALTH_CHECK_ADDR="http://127.0.0.1:8200/v1/sys/health?perfstandbyok=true"


echo Wainting for HVault...
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' "${VAULT_HEALTH_CHECK_ADDR}")" != "200" ]]; do sleep 5; done
echo HVault is ready
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

vault write database/roles/dbuser db_name="keycloak" max_ttl="10m" creation_statements="CREATE USER \"{{name}}\" WITH SUPERUSER ENCRYPTED PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" revocation_statements="REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM \"{{name}}\"; DROP OWNED BY \"{{name}}\"; DROP ROLE \"{{name}}\";"

vault read database/creds/dbuser
