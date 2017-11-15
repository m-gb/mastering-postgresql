-- Every SQL query embeds some business logic.

-- fetches the list of tracks from a given album:
select name
from track
where albumid = 193
order by trackid;

-- join clause to fetch the genre of each track:
select track.name as track, genre.name as genre
from track
join genre using(genreid)
where albumid = 193
order by trackid;

-- a query with some level of computations on top of the data:
select name,
       milliseconds * interval '1 ms' as duration,
       pg_size_pretty(bytes) as bytes
from track
where albumid = 193
order by trackid;