# Projet 'Intégration des données'

## Prerequisites:

* __Docker__  
`sudo apt-get install docker`  
`sudo apt-get install docker-compose`  
* __Console client for Postgresql__  
`sudo apt-get install postgresql-client`
* __GUI DB Manager__  
[DBeaver download](https://dbeaver.io/download/)

## Connection string to local DB in docker  
`psql postgresql://localhost:5432/postgres --username=postgres`

## Run sql script  
`\i ./create_tables.sql`

## Quit  
`\q`