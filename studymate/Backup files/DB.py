import base64
import hashlib
import os
import mysql.connector
from flask import Flask, request, jsonify
from datetime import datetime, timedelta
from datetime import datetime, timedelta
from flask import jsonify, request

app = Flask(__name__)


# Database connection helper
def get_connection():
    try:
        conn = mysql.connector.connect(
            host="AlyIbrahim.mysql.pythonanywhere-services.com",
            user="AlyIbrahim",
            password="I@ly170305",  # Use envi  ronment variables in production
            database="AlyIbrahim$StudyMate"
        )
        return conn
    except Exception as e:
        print(f"Database connection error: {e}")
        return None


# Function to hash a password
def hash_password(password):
    salt = os.urandom(32)  # Generate a random salt
    hashed_password = hashlib.pbkdf2_hmac(
        'sha256',
        password.encode('utf-8'),
        salt,
        100000
    )
    combined_password = base64.b64encode(salt + hashed_password).decode('utf-8')
    return combined_password


# Function to verify a password
def verify_password(stored_password, provided_password):
    decoded_password = base64.b64decode(stored_password.encode('utf-8'))
    salt = decoded_password[:32]
    hashed_password = hashlib.pbkdf2_hmac(
        'sha256',
        provided_password.encode('utf-8'),
        salt,
        100000
    )
    return decoded_password[32:] == hashed_password

# Registration endpoint
@app.route('/register', methods=['POST'])
def register_user():
    conn = get_connection()
    if not conn:
        return jsonify({'message': 'Database connection error'}), 500

    # Retrieve data from JSON body
    data = request.get_json()
    username = data.get('username', 'unknown')
    password = data.get('password', 'unknown')
    name = data.get('fullName', 'unknown')
    role = data.get('role', 'student')
    email = data.get('email', 'unknown')
    phone_number = data.get('phoneNumber', 'unknown')
    address = data.get('address', 'unknown')
    gender = data.get('gender', 'unknown')
    college = data.get('college', 'unknown')
    university = data.get('university', 'unknown')
    major = data.get('major', 'unknown')
    term_level = data.get('term_level', 0)
    profile_picture_link = data.get('pfp', 'unknown')
    experience_points = data.get('xp', 0)
    level = data.get('level', 0)
    title = data.get('title', 'unknown')
    registrationNumber = data.get('registrationNumber', 0)
    birthdate = data.get('birthDate', 'unknown')

    # Hash the password securely
    hashed_password = hash_password(password)

    # SQL Query to insert user
    query = """
    INSERT INTO user (
        username, password, name, role, email,
        phone_number, address, gender, college, university,
        major, term_level, profile_picture_link, experience_points, level, title, Registration_Number, BirthDate
    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
    """

    try:
        with conn.cursor() as cursor:
            # Execute the query with user-provided data
            cursor.execute(query, (
                username, hashed_password, name, role, email, phone_number, address, gender,
                college, university, major, term_level, profile_picture_link, experience_points,
                level, title, registrationNumber, birthdate
            ))
            conn.commit()

            # Check if user was inserted successfully
            if cursor.rowcount == 1:
                response = {'message': 'User registered successfully'}
            else:
                response = {'message': 'User not added'}

    except Exception as e:
        print(f"Error during registration: {e}")
        response = {'message': 'An error occurred during registration'}
    finally:
        conn.close()

    return jsonify(response)


# Login endpoint
@app.route('/login', methods=['POST'])
def login():
    data = request.json
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({'message': 'Invalid username or password'}), 400

    conn = get_connection()
    if not conn:
        return jsonify({'message': 'Database connection error'}), 500

    try:
        with conn.cursor(dictionary=True) as cursor:  # Use dictionary=True to fetch results as dict
            # Query to fetch the relevant user data from the database
            cursor.execute("""
                SELECT id, username, password, name, role, email, phone_number, address, gender,
                       college, university, major, term_level, profile_picture_link,
                       experience_points, level, title, registration_number, birthdate
                FROM user
                WHERE username = %s;
            """, (username,))
            user = cursor.fetchone()

            # If user exists in database
            if user:
                stored_password = user['password']
                if verify_password(stored_password, password):  # Compare hashed password
                    # Exclude sensitive data and prepare the response
                    user_data = {
                        'message': 'Login successful',
                        'success': True,
                        'id': user['id'],
                        'username': user['username'],
                        'name': user['name'],
                        'role': user['role'],
                        'email': user['email'],
                        'phone_number': user['phone_number'],
                        'address': user['address'],
                        'gender': user['gender'],
                        'college': user['college'],
                        'university': user['university'],
                        'major': user['major'],
                        'term_level': user['term_level'],
                        'pfp': user['profile_picture_link'],
                        'xp': user['experience_points'],
                        'level': user['level'],
                        'title': user['title'],
                        'registrationNumber': user['registration_number'],
                        'birthDate': user['birthdate']
                    }
                    app.logger.debug('Login successful: %s', user_data)  # Log the response
                    return jsonify(user_data), 200

            # If no valid user is found or password is incorrect
            return jsonify({'message': 'Invalid username or password'}), 401
    except Exception as e:
        app.logger.error(f"Error during login: {e}")
        return jsonify({'message': 'An error occurred during login'}), 500
    finally:
        conn.close()

# Debugging and testing endpoint
@app.route('/', methods=['GET'])
def home():
    return jsonify({'message': 'Welcome to the StudyMate API!'})

# POST: Create a new schedule
@app.route('/schedule', methods=['POST'])
def create_schedule():
    try:
        # Parse JSON payload
        data = request.json
        user_id = data['user_id']
        title = data['title']
        date = datetime.strptime(data['date'], '%Y-%m-%d')
        start_time = datetime.strptime(data['start_time'], '%H:%M:%S').time()
        end_time = datetime.strptime(data['end_time'], '%H:%M:%S').time()
        category = data.get('category')
        recurrence = data.get('recurrence', 'None')
        repeat_end_date = data.get('repeat_end_date')

        # Create Schedule Entry
        schedule = Schedule(
            user_id=user_id,
            title=title,
            date=date,
            start_time=start_time,
            end_time=end_time,
            category=category,
            recurrence=recurrence,
            repeat_end_date=repeat_end_date
        )
        db.session.add(schedule)
        db.session.commit()

        # Return success message
        return jsonify({"message": "Schedule created successfully!"}), 200
    except Exception as e:
        print(f"Error during schedule creation: {e}")
        return jsonify({"message": "An error occurred while creating the schedule"}), 500

# GET: Fetch user's schedules by date range
@app.route('/schedule', methods=['GET'])
def get_schedule():
    try:
        # Parse query parameters
        user_id = request.args.get('user_id')
        start_date_str = request.args.get('start_date')
        end_date_str = request.args.get('end_date')

        # Validate parameters
        if not user_id or not start_date_str or not end_date_str:
            return jsonify({"message": "Missing required query parameters"}), 400

        # Parse the dates
        try:
            start_date = datetime.strptime(start_date_str, '%Y-%m-%d').date()
            end_date = datetime.strptime(end_date_str, '%Y-%m-%d').date()
        except ValueError:
            return jsonify({"message": "Invalid date format"}), 400

        # Establish database connection
        conn = get_connection()
        if not conn:
            return jsonify({"message": "Database connection error"}), 500

        # Perform raw SQL query
        cursor = conn.cursor(dictionary=True)  # Use dictionary cursor
        query = """
        SELECT *
        FROM Schedule
        WHERE UserId = %s AND Date BETWEEN %s AND %s;
        """
        cursor.execute(query, (user_id, start_date, end_date))
        schedules = cursor.fetchall()
        cursor.close()
        conn.close()

        # Serialize datetime and timedelta objects into JSON-compatible strings
        serialized_schedules = []
        for schedule in schedules:
            serialized_schedules.append({
                "Sid": schedule["Sid"],
                "UserId": schedule["UserId"],
                "Title": schedule["Title"],
                "Date": schedule["Date"].strftime('%Y-%m-%d'),  # Convert date to string
                "StartTime": (datetime.min + schedule["StartTime"]).strftime('%H:%M:%S'),  # Convert timedelta to time string
                "EndTime": (datetime.min + schedule["EndTime"]).strftime('%H:%M:%S'),  # Convert timedelta to time string
                "Category": schedule["Category"],
                "Description": schedule["Description"],
                "Location": schedule["Location"],
                "ReminderBefore": schedule["ReminderBefore"],
                "Repeatance": schedule["Repeatance"],
                "RepeatEndDate": schedule["RepeatEndDate"].strftime('%Y-%m-%d') if schedule["RepeatEndDate"] else None,  # Convert date to string
                "CreatedAt": schedule["CreatedAt"].strftime('%Y-%m-%d %H:%M:%S')  # Convert datetime to string
            })

        return jsonify(serialized_schedules), 200

    except Exception as e:
        print(f"Error while fetching schedules: {e}")
        return jsonify({"message": "An error occurred while fetching the schedule"}), 500

@app.route('/register_courses', methods=['POST'])
def register_courses():
    data = request.get_json()
    username = data.get('username')
    courses = data.get('Courses',[])  # List of course names
    print(username)
    print(courses)
    if not username or not courses:
        return jsonify({'error': 'Missing username or courses'}), 400
    try:
        db = get_connection()
        cursor = db.cursor()

        # Prepare to fetch course IDs and insert into register table
        for course_name in courses:
            # Get the course ID from the courses table
            cursor.execute(
                "SELECT COId FROM Courses WHERE COName = %s",
                (course_name,)
            )
            result = cursor.fetchone()

            if result:
                course_id = result[0]
                print(course_id)
                # Insert into the register table
                cursor.execute(
                    "INSERT INTO Register (username, COId) VALUES (%s, %s)",
                    (username, course_id)
                )
            else:
                return jsonify({'error': f'Course not found: {course_name}'}), 404

        db.commit()  # Commit all changes
        cursor.close()
        db.close()
        return jsonify({'success': 'Courses registered successfully'}), 200

    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500

@app.route('/TakeCourses', methods=['POST'])
def get_courses_for_user():
    try:

        data = request.get_json()
        username = data.get('username') # Use query parameters
        if not username:
            return jsonify({'error': 'Missing username'}), 400

        db = get_connection()
        cursor = db.cursor(dictionary=True)

        cursor.execute(
            # distinct حل مؤقت لحد مشوف الفانكشن اللى فوق
            "SELECT distinct COId FROM Register WHERE username = %s",
            (username,)
        )
        course_ids = cursor.fetchall()

        if not course_ids:
            return jsonify({'error': f'No courses found for username: {username}'}), 404

        subjects = []
        for course in course_ids:
            cursor.execute(
                "SELECT COName FROM Courses WHERE COId = %s",
                (course['COId'],)
            )
            course_name = cursor.fetchone()
            if course_name:
                subjects.append(course_name['COName'])
            else:
                return jsonify({'error': f'Course ID not found in Courses table: {course["COId"]}'}), 404

        cursor.close()
        db.close()

        return jsonify({'username': username, 'courses': subjects , 'CourseID' : course_ids}), 200

    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500


    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500

@app.route('/CourseContent', methods=['POST'])
def get_courses_Content():
    try:
        data = request.get_json()
        Cidx = data.get('courseIdx') # Use query parameters
        if not Cidx:
            return jsonify({'error': 'Missing username'}), 400

        db = get_connection()
        cursor = db.cursor(dictionary=True)

        cursor.execute(
            "SELECT  RFileURL , RName , CID FROM Resources WHERE COId = %s",
            (Cidx,)
        )
        CourseInfo = cursor.fetchall()

        if not CourseInfo:
            return jsonify({'error': f'No courses found for Cidx: {Cidx}'}), 404

        subjects = []
        for info in CourseInfo:
            subject = {
                'RFileURL': info['RFileURL'],
                'RName': info['RName'],
                'RCat' : info['CID']
            }
            subjects.append(subject)

        cursor.close()
        db.close()

        # return jsonify({'URL': subjects['RFileURL'], 'Name': subjects['RName']}), 200
        # return jsonify({'courses': [{'URL': subject['RFileURL'], 'Name': subject['RName']} for subject in subjects]}), 200
        return jsonify({'subInfo': subjects}), 200
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500

# Run the app
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5003, debug=True, use_reloader=False)
