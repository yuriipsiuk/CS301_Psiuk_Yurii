create database practical_assignment_04;
create table teams(
	team_id int primary key,
	name varchar(127) not null,
	city varchar (127) not null
);
create table footballers(
	footballer_id int primary key,
	team_id int references teams(team_id),
	full_name varchar(255) not null
);
create table footballer_info(
	id int primary key references footballers(footballer_id),
	height numeric(5,2) not null check(height>100.00),
	weight numeric(5,2) not null check(weight>20.00),
	date_of_birth date default '1900-01-01',
	matches int default 0,
	goals int default 0,
	assists int default 0
);
create table stadiums(
	stadium_id int primary key,
	capacity int not null check(capacity>=0),
	city varchar (127) not null,
	have_lighting bool
);
create table referees (
	referee_id int primary key,
	full_name varchar(255) not null,
	nationality varchar(63)
);
create table tournaments(
	tournament_id int primary key,
	name varchar(127) not null ,
	start_date date not null,
	final_date date not null,
	check (start_date<=final_date)
);
create table match_schedule(
	id int primary key,
	start timestamp not null,
	stage varchar(127) not null,
	tour_number int
);
create table stadium_tournament(
	stadium_id int references stadiums(stadium_id) on delete cascade,
	tournament_id int references tournaments(tournament_id) on delete cascade,
	primary key(stadium_id,tournament_id)
);
create table referee_tournament(
	referee_id int references referees (referee_id) on delete cascade,
	tournament_id int references tournaments(tournament_id) on delete cascade,
	primary key(referee_id,tournament_id)
);
create table matches(
	match_id int primary key,
	hometeam_id int references teams(team_id),
	awayteam_id int references teams(team_id),
	stadium_id int references stadiums(stadium_id),
	referee_id int references referees(referee_id),
	tournament_id int references tournaments(tournament_id),
	match_schedule_id int references match_schedule(id),
	check (hometeam_id <> awayteam_id)
)
