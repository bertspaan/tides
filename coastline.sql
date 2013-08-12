DROP INDEX IF EXISTS coastline_geom_idx;
CREATE INDEX coastline_geom_idx ON coastline
  USING gist (geom);

CREATE OR REPLACE FUNCTION dump() RETURNS VOID AS
$$
DECLARE
    _gid int;
BEGIN
	DROP TABLE IF EXISTS coastline_points CASCADE;
	CREATE TABLE IF NOT EXISTS coastline_points (
		gid    integer,
		i      integer,
		geom   geometry    
	);

	FOR _gid IN SELECT * FROM generate_series(1, (SELECT MAX(gid) FROM coastline)) LOOP
		INSERT INTO coastline_points
		SELECT _gid, path[2], geom FROM ST_DumpPoints((SELECT geom FROM coastline WHERE gid = _gid));
	END LOOP;

	CREATE INDEX ON coastline_points
		USING gist
		(geom);

END;
$$
LANGUAGE plpgsql;

SELECT dump();