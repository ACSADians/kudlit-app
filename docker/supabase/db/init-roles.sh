#!/usr/bin/env bash
set -euo pipefail

psql \
  --username "${POSTGRES_USER:-postgres}" \
  --dbname "${POSTGRES_DB:-postgres}" \
  --set postgres_password="${POSTGRES_PASSWORD}" \
  --set on_error_stop=1 <<'EOSQL'
CREATE ROLE anon NOLOGIN;
CREATE ROLE authenticated NOLOGIN;
CREATE ROLE service_role NOLOGIN BYPASSRLS;

CREATE ROLE authenticator NOINHERIT LOGIN PASSWORD :'postgres_password';
GRANT anon, authenticated, service_role TO authenticator;

CREATE ROLE supabase_admin NOINHERIT CREATEROLE CREATEDB LOGIN PASSWORD :'postgres_password';
CREATE ROLE supabase_auth_admin NOINHERIT CREATEROLE LOGIN PASSWORD :'postgres_password';
CREATE ROLE supabase_storage_admin NOINHERIT CREATEROLE LOGIN PASSWORD :'postgres_password';

CREATE SCHEMA IF NOT EXISTS auth AUTHORIZATION supabase_auth_admin;
CREATE SCHEMA IF NOT EXISTS storage AUTHORIZATION supabase_storage_admin;
CREATE SCHEMA IF NOT EXISTS _realtime AUTHORIZATION supabase_admin;

GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON SCHEMA storage TO supabase_storage_admin;
GRANT ALL ON SCHEMA _realtime TO supabase_admin;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT USAGE, SELECT ON SEQUENCES TO authenticated, service_role;
EOSQL
