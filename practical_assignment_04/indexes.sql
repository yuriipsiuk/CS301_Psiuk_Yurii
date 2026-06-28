create index indexdate  on  match_schedule(start);
create index indexcapacity on stadiums(capacity);


explain analyze
select concat(t.name,':',r.name),s.city,ms.stage
from match_schedule ms
join matches m on  ms.id=m.match_schedule_id  
join teams t on m.hometeam_id=t.team_id
join teams r on m.awayteam_id=r.team_id
join stadiums s on m.stadium_id=s.stadium_id 
where ms.start>='2025-01-01' and ms.start<'2026-01-01' and s.capacity>100

explain analyze
select concat(t.name,':',r.name),s.city,ms.stage
from match_schedule ms
join matches m on  ms.id=m.match_schedule_id   
join teams t on m.hometeam_id=t.team_id
join teams r on m.awayteam_id=r.team_id
join stadiums s on m.stadium_id=s.stadium_id 
where DATE_PART('year', ms."start")=2025 and s.capacity>10000/s.capacity 
