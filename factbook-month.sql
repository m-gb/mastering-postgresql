2010 1/4/2010 1,425,504,460 4,628,115 $38,495,460,645
2010 1/5/2010 1,754,011,750 5,394,016 $43,932,043,406
2010 1/6/2010 1,655,507,953 5,494,460 $43,816,749,660
2010 1/7/2010 1,797,810,789 5,674,297 $44,104,237,184

begin;

-- we use the PostgreSQL copy functionality to stream the data from the CSV file into our table.
create table factbook
 (
    year int,
    date date,
    shares text,
    trades text,
    dollars text
 );

\copy factbook from 'factbook.csv' with delimiter E'\t' null ''

alter table factbook
  alter shares
  type bigint
  using replace(shares, ',', '')::bigint,

  alter trades
  type bigint
  using replace(trades, ',', '')::bigint,

  alter dollars
  type bigint
  using substring(replace(dollars, ',', '') from 2)::numeric;

commit;

-- run by psql, which supports variables (such as "start").
-- lists all entries we have in the month of February 2017:
\set start '2017-02-01'

select date,
       to_char(shares, '99G999G999G999') as shares, -- converts a number to its text representation.
       to_char(trades, '99G999G999') as trades,
       to_char(dollars, 'L99G999G999G999') as dollars
from factbook
where date >= date :'start'
and date < date :'start' + interval '1 month'
order by date;

select cast(calendar.entry as date) as date, -- transforms the generated calendar.entry into the date data type.
       coalesce(shares, 0) as shares, -- COALESCE returns the first of its arguments that is not null.
       coalesce(trades, 0) as trades,
       to_char(
          coalesce(dollars, 0),
          'L99G999G999G999'
       ) as dollars
from /*
      * Generate the target month's calendar then LEFT JOIN
      * each day against the factbook dataset, so as to have
      * every day in the result set, wether or not we have a
      * book entry for the day.
      */
      generate_series(date : 'start',
                      date : 'start' + interval '1 month'
                                     - interval '1 day',
                      interval '1 day'
      )
      as calendar(entry)
      left join factbook
             on factbook.date = calendar.entry
order by date;

-- Computing weekly changes
with computed_data as -- fetches the extended data set we need, including the last_week_dollars computed column.
(
    select
      cast(date as date)   as date,
      to_char(date, 'Dy')  as day,
      coalesce(dollars, 0) as dollars,
      lag(dollars, 1)
      over (
        partition extract('isodow' from date) -- allows computing the Day Of Week following the ISO rules.
        order by date
        )
                           as last_week_dollars
    from /*
          * Generate the month calendar, plus a week before
          * so that we have values to compare dollars against
          * even for the first week of the month.
          */
          generate_series(date :'start' - interval '1 week',
                          date :'start' + interval '1 month'
                                 - interval '1 day',
                          interval '1 day'
          )
        as calendar(date)
      left join factbook using (date)
)
    select date, day,
           to_char(
               coalesce(dollars, 0),
               'L99G999G999G999'
           ) as dollars,
           case when dollars is not null
                and dollars <> 0
                then round(   100.0
                            * (dollars - last_week_dollars)
                            / dollars
                          , 2)
           end
           as "WOW %"
    from computed_data
    where date >= date :'start'
order by date;



)
