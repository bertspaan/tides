shp2pgsql -s 4326 coastline/ne_50m_coastline.shp coastline | psql -h localhost -d tidalrange -U postgres
psql -h localhost -d tidalrange -U postgres < coastline.sql

