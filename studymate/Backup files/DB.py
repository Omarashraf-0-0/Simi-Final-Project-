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
        return jsonify({'message': 'Invalid username or password 5555'}), 400

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
            return jsonify({'message': 'Invalid username or password 5555677896222111'}), 401
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


@app.route('/AddSchedule', methods=['POST'])
def add_schedule():
    data = request.get_json()

    # Extract data from the JSON body
    user_id = data.get('id')
    title = data.get('title')
    date = data.get('date')
    start_time = data.get('startTime')
    end_time = data.get('endTime')
    location = data.get('location')
    category = data.get('category')
    repeat = data.get('repeat')
    description = data.get('description')
    reminder_time = data.get('reminderTime')
    repeat_until = data.get('repeatUntil')

    try:
        # Establish connection to the database
        db = get_connection()
        cursor = db.cursor()

        # Prepare the SQL INSERT query
        insert_query = """
        INSERT INTO Schedule (UserId, Title, Date, StartTime, EndTime, Category, Description, Location, ReminderBefore, Repeatance, RepeatEndDate)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
        """

        # Execute the query with the data
        cursor.execute(insert_query, (user_id, title, date, start_time, end_time, category, description, location, reminder_time, repeat, repeat_until))

        # Commit the transaction
        db.commit()

        # Return a success response
        return jsonify({"message": "Schedule added successfully!"}), 200

    except Exception as e:
        db.rollback()  # Rollback in case of error
        return jsonify({"error": str(e)}), 500

    finally:
        cursor.close()  # Close the cursor
        db.close()  # Close the database connection



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


@app.route('/AddSchedule', methods=['POST'])
def add_schedule():
    data = request.get_json()

    # Extract data from the JSON body
    user_id = data.get('id')
    title = data.get('title')
    date = data.get('date')
    start_time = data.get('startTime')
    end_time = data.get('endTime')
    location = data.get('location')
    category = data.get('category')
    repeat = data.get('repeat')
    description = data.get('description')
    reminder_time = data.get('reminderTime')
    repeat_until = data.get('repeatUntil')

    try:
        # Establish connection to the database
        db = get_connection()
        cursor = db.cursor()

        # Prepare the SQL INSERT query
        insert_query = """
        INSERT INTO your_table_name (UserId, Title, Date, StartTime, EndTime, Category, Description, Location, ReminderBefore, Repeatance, RepeatEndDate)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
        """

        # Execute the query with the data
        cursor.execute(insert_query, (user_id, title, date, start_time, end_time, category, description, location, reminder_time, repeat, repeat_until))

        # Commit the transaction
        db.commit()

        # Return a success response
        return jsonify({"message": "Schedule added successfully!"}), 200

    except Exception as e:
        db.rollback()  # Rollback in case of error
        return jsonify({"error": str(e)}), 500

    finally:
        cursor.close()  # Close the cursor
        db.close()  # Close the database connection

@app.route('/delete_task', methods=['POST'])
def delete_Schedule():
    data = request.get_json()
    Sid = data.get('Sid')

    if not Sid:
        return jsonify({'error': 'Sid is required'}), 400  # Bad Request if Sid is missing

    try:
        db = get_connection()
        cursor = db.cursor()

        # Prepare SQL delete statement
        sql_delete_query = "DELETE FROM Schedule WHERE Sid = %s"
        cursor.execute(sql_delete_query, (Sid,))
        db.commit()

        # Check if any row was affected (i.e., deleted)
        if cursor.rowcount == 0:
            # No schedule found with the given Sid
            cursor.close()
            db.close()
            return jsonify({'error': 'No schedule found with the given Sid'}), 404

        cursor.close()
        db.close()
        return jsonify({'message': 'Schedule deleted successfully'}), 200

    except Exception as e:
        print("Error while deleting schedule:", e)
        return jsonify({'error': 'An error occurred while deleting the schedule.'}), 500


@app.route('/CourseContent', methods=['POST'])
def get_courses_Content():
    try:
        data = request.get_json()
        Cidx = data.get('courseIdx') # Use query parameters
        username = data.get('username')
        if not Cidx:
            return jsonify({'error': 'Missing username'}), 400

        db = get_connection()
        cursor = db.cursor(dictionary=True)
        cursor2 =db.cursor()
        cursor.execute(
            "SELECT  RFileURL , RName , CID , RId FROM Resources WHERE COId = %s",
            (Cidx,)
        )
        CourseInfo = cursor.fetchall()
        cursor2.execute(
                 "UPDATE Register SET recentEnter  = CURRENT_TIMESTAMP  WHERE ( COId = %s and username = %s ) ",
                (Cidx,username,)
        )
        db.commit();

        if not CourseInfo:
            return jsonify({'error': f'No courses found for Cidx: {Cidx}'}), 404

        subjects = []
        for info in CourseInfo:
            subject = {
                'RFileURL': info['RFileURL'],
                'RName': info['RName'],
                'RCat' : info['CID'],
                'RId' : info['RId'],
            }
            subjects.append(subject)
        cursor.close()
        cursor2.close()
        db.close()

        # return jsonify({'URL': subjects['RFileURL'], 'Name': subjects['RName']}), 200
        # return jsonify({'courses': [{'URL': subject['RFileURL'], 'Name': subject['RName']} for subject in subjects]}), 200
        return jsonify({'subInfo': subjects}), 200
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500



@app.route('/update_user', methods=['POST'])
def update_user():
    data = request.get_json()
    username = data.get('username')

    # Ensure username is provided (it's required for identifying the user)
    if not username:
        return jsonify({'message': 'Username is required'}), 400

    # Fields to update
    fields = {
        'name': data.get('fullname'),
        'email': data.get('email'),
        'password': hash_password(data['password']) if data.get('password') else None,
        'phone_number': data.get('phone_number'),
        'birthDate': data.get('birthDate'),
        'address': data.get('address'),
        'college': data.get('college'),
        'university': data.get('university'),
        'major': data.get('major'),
        'term_level': data.get('term_level'),
        'Registration_Number' : data.get('Registration_Number'),
    }

    # Filter out None or empty values
    fields_to_update = {key: value for key, value in fields.items() if value}

    if not fields_to_update:
        return jsonify({'message': 'No data to update'}), 400

    # Build the query dynamically
    set_clause = ", ".join(f"{key} = %s" for key in fields_to_update.keys())
    values = list(fields_to_update.values()) + [username]

    query = f"UPDATE user SET {set_clause} WHERE username = %s"

    # Database connection
    conn = get_connection()
    if not conn:
        return jsonify({'message': 'Database connection error'}), 500

    try:
        with conn.cursor(dictionary=True) as cursor:
            cursor.execute(query, values)
            conn.commit()

            if cursor.rowcount == 1:
                response = {'message': 'User updated successfully'}
            else:
                response = {'message': 'No changes made or user not found'}

            return jsonify(response), 200
    except Exception as e:
        app.logger.error(f"Error during update_user: {e}")
        return jsonify({'message': f'An error occurred during update_user {e}'}), 500
    finally:
        if conn:
            conn.close()


@app.route('/updateMaterial', methods=['POST'])
def updateMaterial():
    try:
        data = request.get_json()
        Midx = data.get('materialIdx')
        MTitle = data.get('materialTitle')
        Mcat = data.get('materialMcat')
        if not Midx:
            return jsonify({'error': 'Missing Midx'}), 400

        db = get_connection()
        cursor2 =db.cursor()

        cursor2.execute(
                 "UPDATE Resources SET RName  = %s , CID = %s  WHERE RId = %s",
                (MTitle,Mcat,Midx,)
        )
        db.commit();
        cursor2.close()
        db.close()

        if cursor2.rowcount == 1:
                response = {'message': 'Resources updated successfully'}
        else:
                response = {'message': 'No changes made or Resources not found'}

        # return jsonify({'URL': subjects['RFileURL'], 'Name': subjects['RName']}), 200
        # return jsonify({'courses': [{'URL': subject['RFileURL'], 'Name': subject['RName']} for subject in subjects]}), 200
        return jsonify(response), 200
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500


@app.route('/deleteMaterial', methods=['POST'])
def deleteMaterial():
    try:
        data = request.get_json()
        Midx = data.get('materialIdx')
        if not Midx:
            return jsonify({'error': 'Missing Midx'}), 400

        db = get_connection()
        cursor2 =db.cursor()

        cursor2.execute(
                 "DELETE FROM Resources WHERE RId = %s",
                (Midx,)
        )
        db.commit();
        cursor2.close()
        db.close()

        if cursor2.rowcount == 1:
                response = {'message': 'Resourcses deleted successfully'}
        else:
                response = {'message': 'No changes made or Resources not found'}

        # return jsonify({'URL': subjects['RFileURL'], 'Name': subjects['RName']}), 200
        # return jsonify({'courses': [{'URL': subject['RFileURL'], 'Name': subject['RName']} for subject in subjects]}), 200
        return jsonify(response), 200
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500

@app.route('/addMaterial', methods=['POST'])
def addMaterial():
    try:
        data = request.get_json()
        Murl = data.get('materialUrl')
        MTitle = data.get('materialTitle')
        Mcat = data.get('materialMcat')
        SID = data.get('subid')
        if not Murl:
            return jsonify({'error': 'Missing Midx'}), 400

        db = get_connection()
        cursor2 =db.cursor()

        cursor2.execute(
                 "insert into Resources (Rname , RFileURL , CID ,COId ) values (%s , %s , %s, %s )  ",
                (MTitle,Murl,Mcat,SID,)
        )
        db.commit();
        cursor2.close()
        db.close()

        if cursor2.rowcount == 1:
                response = {'message': 'Resourcses Added successfully'}
        else:
                response = {'message': 'No changes made'}

        # return jsonify({'URL': subjects['RFileURL'], 'Name': subjects['RName']}), 200
        # return jsonify({'courses': [{'URL': subject['RFileURL'], 'Name': subject['RName']} for subject in subjects]}), 200
        return jsonify(response), 200
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500




# Run the app
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5003, debug=True, use_reloader=False)
