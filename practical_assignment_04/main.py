import random
import psycopg2
from psycopg2 import Error
import psycopg2.extras
from faker import Faker
from datetime import timedelta

# Ініціалізація Faker з британською локаллю для англійських імен/даних
fake = Faker('en_GB')

# --- Налаштування бази даних ---
HOST = 'localhost' # put your credentials here
USER = 'postgres'  # put your credentials here
PASSWORD = '1234'     # put your credentials here
DATABASE = 'practical_assignment_04'# put your credentials here
PORT = '5432'      # put your credentials here

# --- Константи кількості рядків ---
REGULAR_LIMIT = 30000
LARGE_LIMIT = 500000

# --- Вибірка з 15 значень, що стосуються Англії ---
ENGLISH_CITIES = [
    "London", "Manchester", "Liverpool", "Birmingham", "Leeds", 
    "Sheffield", "Newcastle", "Bristol", "Nottingham", "Leicester", 
    "Southampton", "Portsmouth", "Brighton", "Derby", "Wolverhampton"
]

TEAM_SUFFIXES = [
    "FC", "United", "City", "Rovers", "Wanderers", 
    "Albion", "Athletic", "Town", "North End", "Wednesday", 
    "Villa", "Palace", "Hotspur", "Rangers", "Sporting"
]

STADIUM_NAMES = [
    "Wembley", "Old Trafford", "Anfield", "Emirates", "Stamford Bridge",
    "Villa Park", "St James' Park", "Goodison Park", "Elland Road", "Hillsborough",
    "King Power", "St Mary's", "Bramall Lane", "Craven Cottage", "Selhurst Park"
]

TOURNAMENT_NAMES = [
    "Premier League", "FA Cup", "EFL Cup", "Championship", "League One",
    "League Two", "National League", "Community Shield", "FA Trophy", "EFL Trophy",
    "Super League", "Sunday League", "Regional Cup", "Charity Cup", "Winter Cup"
]

STAGES = [
    "Matchday 1", "Matchday 2", "Matchday 3", "Group Stage", "Round 1",
    "Round 2", "Round 3", "Round of 64", "Round of 32", "Round of 16",
    "Quarter-final", "Semi-final", "Final", "Play-off", "Relegation"
]

def create_connection():
    """Create a PostgreSQL database connection."""
    try:
        connection = psycopg2.connect(
            host=HOST,
            port=PORT,
            user=USER,
            password=PASSWORD,
            dbname=DATABASE,
        )
        print("Connection to PostgreSQL DB successful")
        return connection
    except Error as e:
        print(f"The error '{e}' occurred")
        return None

def execute_batch(connection, query, data):
    """Execute a batch query using execute_values for performance."""
    try:
        with connection.cursor() as cursor:
            psycopg2.extras.execute_values(cursor, query, data, page_size=10000)
        connection.commit()
        print(f"Batch query executed successfully. Inserted {len(data)} rows.")
    except Error as e:
        connection.rollback()
        print(f"The error '{e}' occurred")

def insert_data():
    connection = create_connection()
    if connection is None:
        return

    # 1. Заповнення таблиці teams
    print("Generating teams...")
    teams_data = []
    for i in range(1, REGULAR_LIMIT + 1):
        city = random.choice(ENGLISH_CITIES)
        suffix = random.choice(TEAM_SUFFIXES)
        name = f"{city} {suffix} {i}" # Додаємо ID для унікальності
        teams_data.append((i, name, city))
    
    execute_batch(connection, "INSERT INTO teams (team_id, name, city) VALUES %s ON CONFLICT DO NOTHING", teams_data)

    # 2. Заповнення таблиці footballers
    print("Generating footballers...")
    footballers_data = []
    for i in range(1, REGULAR_LIMIT + 1):
        team_id = random.randint(1, REGULAR_LIMIT)
        full_name = fake.name_male()
        footballers_data.append((i, team_id, full_name))
    
    execute_batch(connection, "INSERT INTO footballers (footballer_id, team_id, full_name) VALUES %s ON CONFLICT DO NOTHING", footballers_data)

    # 3. Заповнення таблиці footballer_info
    print("Generating footballer_info...")
    footballer_info_data = []
    for i in range(1, REGULAR_LIMIT + 1):
        height = round(random.uniform(160.0, 205.0), 2)
        weight = round(random.uniform(60.0, 95.0), 2)
        dob = fake.date_of_birth(minimum_age=16, maximum_age=40)
        matches = random.randint(0, 500)
        goals = random.randint(0, 200)
        assists = random.randint(0, 150)
        footballer_info_data.append((i, height, weight, dob, matches, goals, assists))
    
    execute_batch(connection, "INSERT INTO footballer_info (id, height, weight, date_of_birth, matches, goals, assists) VALUES %s ON CONFLICT DO NOTHING", footballer_info_data)

    # 4. Заповнення таблиці stadiums
    print("Generating stadiums...")
    stadiums_data = []
    for i in range(1, REGULAR_LIMIT + 1):
        capacity = random.randint(5000, 90000)
        city = random.choice(ENGLISH_CITIES)
        stadium_name = random.choice(STADIUM_NAMES)
        have_lighting = random.choice([True, False])
        stadiums_data.append((i, capacity, city, have_lighting))
    
    execute_batch(connection, "INSERT INTO stadiums (stadium_id, capacity, city, have_lighting) VALUES %s ON CONFLICT DO NOTHING", stadiums_data)

    # 5. Заповнення таблиці referees
    print("Generating referees...")
    referees_data = []
    for i in range(1, REGULAR_LIMIT + 1):
        full_name = fake.name_male()
        nationality = random.choice(["English", "Scottish", "Welsh", "Irish", "French", "German"])
        referees_data.append((i, full_name, nationality))
    
    execute_batch(connection, "INSERT INTO referees (referee_id, full_name, nationality) VALUES %s ON CONFLICT DO NOTHING", referees_data)

    # 6. Заповнення таблиці tournaments
    print("Generating tournaments...")
    tournaments_data = []
    for i in range(1, REGULAR_LIMIT + 1):
        name = random.choice(TOURNAMENT_NAMES) + f" {random.randint(2000, 2025)}"
        start_date = fake.date_between(start_date='-5y', end_date='today')
        final_date = start_date + timedelta(days=random.randint(30, 300))
        tournaments_data.append((i, name, start_date, final_date))
    
    execute_batch(connection, "INSERT INTO tournaments (tournament_id, name, start_date, final_date) VALUES %s ON CONFLICT DO NOTHING", tournaments_data)

    # 7. Заповнення таблиці match_schedule (500,000)
    print("Generating match_schedule (500,000 rows)...")
    match_schedule_data = []
    for i in range(1, LARGE_LIMIT + 1):
        start_time = fake.date_time_this_decade()
        stage = random.choice(STAGES)
        tour_number = random.randint(1, 38)
        match_schedule_data.append((i, start_time, stage, tour_number))
    
    execute_batch(connection, "INSERT INTO match_schedule (id, start, stage, tour_number) VALUES %s ON CONFLICT DO NOTHING", match_schedule_data)

    # 8. Заповнення зв'язків (багато-до-багатьох)
    print("Generating stadium_tournament and referee_tournament...")
    stadium_tournament_data = []
    referee_tournament_data = []
    # Генеруємо по 30 000 зв'язків для простоти
    for _ in range(REGULAR_LIMIT):
        s_id = random.randint(1, REGULAR_LIMIT)
        t_id = random.randint(1, REGULAR_LIMIT)
        r_id = random.randint(1, REGULAR_LIMIT)
        stadium_tournament_data.append((s_id, t_id))
        referee_tournament_data.append((r_id, t_id))
    
    # Видаляємо дублікати пар, щоб не порушити Primary Key (id1, id2)
    stadium_tournament_data = list(set(stadium_tournament_data))
    referee_tournament_data = list(set(referee_tournament_data))

    execute_batch(connection, "INSERT INTO stadium_tournament (stadium_id, tournament_id) VALUES %s ON CONFLICT DO NOTHING", stadium_tournament_data)
    execute_batch(connection, "INSERT INTO referee_tournament (referee_id, tournament_id) VALUES %s ON CONFLICT DO NOTHING", referee_tournament_data)

    # 9. Заповнення таблиці matches (500,000)
    print("Generating matches (500,000 rows)...")
    matches_data = []
    for i in range(1, LARGE_LIMIT + 1):
        hometeam_id = random.randint(1, REGULAR_LIMIT)
        awayteam_id = random.randint(1, REGULAR_LIMIT)
        # Гарантуємо, що команди не грають самі з собою
        while awayteam_id == hometeam_id:
            awayteam_id = random.randint(1, REGULAR_LIMIT)
            
        stadium_id = random.randint(1, REGULAR_LIMIT)
        referee_id = random.randint(1, REGULAR_LIMIT)
        tournament_id = random.randint(1, REGULAR_LIMIT)
        match_schedule_id = i # 1 до 1 зв'язок з розкладом для простоти
        
        matches_data.append((i, hometeam_id, awayteam_id, stadium_id, referee_id, tournament_id, match_schedule_id))

    execute_batch(connection, "INSERT INTO matches (match_id, hometeam_id, awayteam_id, stadium_id, referee_id, tournament_id, match_schedule_id) VALUES %s ON CONFLICT DO NOTHING", matches_data)

    connection.close()
    print("Data insertion finished.")

if __name__ == "__main__":
    insert_data()