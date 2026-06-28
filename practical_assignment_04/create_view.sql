create or replace view current_matchday as
select concat(t.name,':',r.name) as match,s.city,ms.stage,ms.start
from match_schedule ms
join matches m on  ms.id=m.match_schedule_id  
join teams t on m.hometeam_id=t.team_id
join teams r on m.awayteam_id=r.team_id
join stadiums s on m.stadium_id=s.stadium_id 
where ms.start::date=current_date;
