#!/bin/sh

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"
echo " POINT DEBUG JBL  PG_HOST=$PG_HOST"
echo " POINT DEBUG JBL  PG_USER=$PG_USER"
echo " POINT DEBUG JBL  PG_PASSWORD=$PG_PASSWORD"
#echo " POINT DEBUG JBL  PG_"

# Create the 'template_postgis' template db
psql --dbname="$POSTGRES_DB" <<- 'EOSQL'
CREATE DATABASE template_postgis;
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_postgis';
EOSQL

# Load PostGIS into both template_database and $POSTGRES_DB
for DB in template_postgis "$POSTGRES_DB"; do
	echo "Loading PostGIS extensions into $DB"
	psql --dbname="$DB" <<-'EOSQL'
		CREATE EXTENSION postgis;
		CREATE EXTENSION postgis_topology;
		CREATE EXTENSION fuzzystrmatch;
		CREATE EXTENSION postgis_tiger_geocoder;
		CREATE EXTENSION hstore;
EOSQL
done

#import Melbourne city
osm2pgsql --style /openstreetmap-carto/openstreetmap-carto.style -d gis -U postgres -k --slim /Melbourne.osm.pbf

touch /var/lib/postgresql/data/DB_INITED
