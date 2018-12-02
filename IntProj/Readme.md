# Projet 'Intégration des données'
\* Described steps supposed to be executed under OS linux
## Prerequisites:

* __Docker__  
`sudo apt-get install docker`  
`sudo apt-get install docker-compose`  
* __Console client for Postgresql__  
`sudo apt-get install postgresql-client`

## Reproducing steps:  
* Install utilities from [Prerequisites](
        Readme.md#prerequisites) section 
* Download data from [Home Credit Default Risk Competition](https://www.kaggle.com/c/home-credit-default-risk) unzip it and place to folder `~/Downloads/homeCreditData/to_db` on your local machine
* Download file [docker-compose.yml](../docker_ecam/docker-compose.yml)  
* Navigate to folder with [docker-compose.yml](../docker_ecam/docker-compose.yml) by terminal and type:  
`docker-compose up --bulid`
* Docker is up when you see following message in your terminal:  
`LOG:  database system is ready to accept connections`  
* Open another terminal and navigate to folder [IntProj](ecam_ds/IntProj) on your local machine
* Connect to PostgreSQL server by command:  
`psql postgresql://localhost:5432/postgres --username=postgres`
* Setup notification level to *WARNING* to reduce amount of info from db:  
`SET client_min_messages TO WARNING;`
* For database creation please execute scripts in following order:  
`\i ./IntProjCleanup.sql;` - perform initial cleanup   
`\i ./IntProjHelpers.sql;` - create functions and procedures  
`\i ./IntProjMain.sql;` - create and fill tables  
* To save results of queries from file [IntProjRequests.sql](IntProjRequests.sql) to file `result.txt` please run:  
`\o results.txt \i ./IntProjRequests.sql`
* To disconnect from database please type:    
`\q`
