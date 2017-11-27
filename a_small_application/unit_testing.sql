-- Here’s an example of a query rewrite:
with artist_albums as
	(
		select albumid, title
		from 	 album
					 join artist using(artistid)
		where  artist.name = 'AC/DC'
	)
		select title, name, milliseconds
		from artist_albums
				 left join track
				 			using(albumid)
order by trackid; 

-- Same query with different run-time characteristics:
select title, name, milliseconds

select title, name, milliseconds
from   (
					select albumid, title
					from	 album
								 join artist using(artistid)
					where artist.name = 'AC/DC'
				)
					as artist_albums
					left join track
					using(albumid)
order by trackid;