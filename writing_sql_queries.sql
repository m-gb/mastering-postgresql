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

-- Stored procedures
-- This function accepts parameters. To run it: select * from get_all_albums(127);
create or replace function get_all_albums
  (
    in artistid bigint,
    out album text,
    out duration interval
  )
returns setof record
language sql
as $$
  select album.title as album,
         sum(milliseconds) * interval '1 ms' as duration
  from album
       join artist using(artistid)
       left join track using(albumid)
  where artist.artistid = get_all_albums.artistid
group by album
order by album;
$$;

-- If we only have the artist name:
select *
  from get_all_albums(
    (select artistid
      from artist
     where name = 'Red Hot Chili Peppers')
    );

-- Using the query in more complex use cases
-- Using the function get_all_albums in a join clause using lateral join.
select album, duration
  from artist,
    lateral get_all_albums(artistid)
where artist.name = 'Red Hot Chili Peppers';

-- Lists the albums (with durations) of the artists who have four albums
with four_albums as
(
  select artistid
  from album
  group by artistid
  having count(*) = 4
)
  select artist.name, album, duration
  from four_albums
       join artist using(artistid),
       lateral get_all_albums(artistid)
  order by artistid, duration desc;
-- Using stored procedure allows reusing SQL code in between use cases, on the server side.
-- Another advantage of using stored procedures is that you send even less data over the network,
-- as the query text is stored on the database server.