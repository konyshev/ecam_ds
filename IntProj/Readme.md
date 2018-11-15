# Projet 'Intégration des données'

## Prerequisites:

* __Docker__  
`sudo apt-get install docker`  
`sudo apt-get install docker-compose`  
* __Console client for Postgresql__  
`sudo apt-get install postgresql-client`

## Connection string to local DB in docker  
`psql postgresql://localhost:5432/postgres --username=postgres`

## Order of execution scripts  
`\i ./create_helpers.sql`  
`\i ./create_tables.sql`

## Quit  
`\q`