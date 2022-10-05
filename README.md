# Backend for Stroskovnik ui - Hasura Graphql engine

Requirements:
1. docker, docker-compose
2. hasura-cli

To configure: 
1. cp .env.example .env
2. Set variables in env
3. docker-compose up -d
4. Visit localhost:8080
5. Connect to databse - use environment variable PG_DATABASE_URL
6. In this folder run `hasura deploy`

