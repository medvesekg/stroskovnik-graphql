# Backend for Stroskovnik ui - Hasura Graphql engine

Requirements:

1. docker, docker-compose
2. hasura-cli

To configure:

1. cp .env.example .env
2. Set variables in env
3. docker compose -f docker-compose.yml -f docker-compose-auth.yml up -d
4. Visit localhost:8080
5. Connect to databse - use environment variable PG_DATABASE_URL (Important: name the database `default`)
6. In this folder run `hasura deploy`

Import db:

1. `docker compose exec -T postgres bash -c "pg_restore -d postgres -U postgres" < path/to/dump/file`
