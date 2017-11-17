select genre.name, count(*) as count
from genre
  left join track using(genreid)
group by genre.name
order by count desc;

-- Which gives us:
-- name  | count
-- Rock  |  1297
-- Latin | 579
-- Metal | 374