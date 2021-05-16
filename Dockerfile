FROM hasura/graphql-engine:v1.3.3.cli-migrations-v2

# Enable the console
ENV HASURA_GRAPHQL_ENABLE_CONSOLE=true

# This has to be set or auto-applying migrations fails. Don't know why.
ENV HASURA_GRAPHQL_CLI_ENVIRONMENT=default

# Set the name of the env variabla that will be used for the database url.
# This has to be set for auto migrations to work on Heroku, as the app needs to
# know which database to apply the migrations to during deploy phase
ENV HASURA_GRAPHQL_MIGRATIONS_DATABASE_ENV_VAR=DATABASE_URL

# Copy the migration files into the docker image
COPY ./db/migrations /hasura-migrations/
COPY ./db/metadata /hasura-metadata/

# Change $DATABASE_URL to your heroku postgres URL if you're not using
# the primary postgres instance in your app
CMD graphql-engine \
    --database-url $DATABASE_URL \
    serve \
    --server-port $PORT

## Comment the command above and use the command below to
## enable an access-key and an auth-hook
## Recommended that you set the access-key as a environment variable in heroku
#CMD graphql-engine \
#    --database-url $DATABASE_URL \
#    serve \
#    --server-port $PORT \
#    --access-key XXXXX \
#    --auth-hook https://myapp.com/hasura-webhook 
#
# Console can be enable/disabled by the env var HASURA_GRAPHQL_ENABLE_CONSOLE
