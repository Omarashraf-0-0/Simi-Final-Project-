import base64
import hashlib
import json
import os
import random
import re  # For extracting lecture numbers
import string
import tempfile
from datetime import datetime, timedelta
from urllib.parse import urlparse, urlunparse, parse_qs
import smtplib
from email.message import EmailMessage
import requests
import urllib.parse
from collections import defaultdict


from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
import mysql.connector
import requests
from flask import Flask, request, jsonify, Response, send_file , url_for
from werkzeug.utils import secure_filename
from dotenv import load_dotenv
from pdfminer.high_level import extract_text
import openai

app = Flask(__name__)


latex_template = """
\\documentclass[paper=letter,fontsize=11pt]{scrartcl}

\\usepackage[english]{babel}
\\usepackage[utf8x]{inputenc}
\\usepackage[protrusion=true,expansion=true]{microtype}
\\usepackage{amsmath,amsfonts,amsthm}
\\usepackage{graphicx}
\\usepackage[svgnames]{xcolor}
\\usepackage{geometry}
\\usepackage[colorlinks=true, linkcolor=blue, urlcolor=blue]{hyperref}
\\usepackage{float}
\\usepackage{etaremune}
\\usepackage{wrapfig}
\\usepackage{attachfile}

\\frenchspacing
\\pagestyle{empty}

\\setlength\\topmargin{0pt}
\\addtolength\\topmargin{-\\headheight}
\\addtolength\\topmargin{-\\headsep}
\\setlength\\oddsidemargin{0pt}
\\setlength\\textwidth{\\paperwidth}
\\addtolength\\textwidth{-2in}
\\setlength\\textheight{\\paperheight}
\\addtolength\\textheight{-2in}
\\usepackage{layout}

%%% Custom sectioning (sectsty package)
\\usepackage{sectsty}
\\sectionfont{
\t\\usefont{OT1}{phv}{b}{n}
\t\\sectionrule{0pt}{0pt}{-5pt}{1pt}
}

%%% Macros
\\newlength{\\spacebox}
\\settowidth{\\spacebox}{8888888888}
\\newcommand{\\sepspace}{\\vspace*{1em}}

\\newcommand{\\MyName}[1]{ % Name
\t\\Huge \\usefont{OT1}{phv}{b}{n} \\hfill #1
\t\\par \\normalsize \\normalfont
}

\\newcommand{\\MySlogan}[1]{ % Slogan (optional)
\t\\large \\usefont{OT1}{phv}{m}{n}\\hfill \\textit{#1}
\t\\par \\normalsize \\normalfont
}

\\newcommand{\\NewPart}[2]{\\section*{\\uppercase{#1} \\small \\normalfont #2}}

\\newcommand{\\NewParttwo}[1]{
\t\\noindent \\huge \\textbf{#1}
    \\normalsize \\par
}

\\newcommand{\\PersonalEntry}[2]{\\small
\t\\noindent\\hangindent=2em\\hangafter=0 % Indentation
\t\\parbox{\\spacebox}{\\textit{#1}}
\t\\small\\hspace{1.5em} #2 \\par
}

\\newcommand{\\SkillsEntry}[2]{
\t\\noindent\\hangindent=2em\\hangafter=0 % Indentation
\t\\parbox{\\spacebox}{\\textit{#1}}
\t\\hspace{1.5em} #2 \\par
}

\\newcommand{\\EducationEntry}[4]{
\t\\noindent \\textbf{#1} \\hfill
\t\\colorbox{White}{
\t\t\\parbox{6em}{
\t\t\\hfill\\color{Black}#2}}
\t\\par
\t\\noindent \\textit{#3} \\par
\t\\noindent\\hangindent=2em\\hangafter=0 \\small #4
\t\\normalsize \\par
}

\\newcommand{\\WorkEntry}[5]{
\t\\noindent \\textbf{#1}
    \\noindent \\small \\textit{#2}
    \\hfill
    \\colorbox{White}{
\t\t\\parbox{6em}{
\t\t\\hfill\\color{Black}#3}}
\t\\par
\t\\noindent \\textit{#4} \\par
\t\\noindent\\hangindent=2em\\hangafter=0 \\small #5
\t\\normalsize \\par
}

\\newcommand{\\Language}[2]{
\t\\noindent \\textbf{#1}
    \\noindent \\small \\textit{#2}
}

\\newcommand{\\Text}[1]{\\par
\t\\noindent \\small #1
\t\\normalsize \\par
}

\\newcommand{\\Textlong}[4]{
\t\\noindent \\textbf{#1} \\par
    \\sepspace
    \\noindent \\small #2
    \\par\\sepspace
\t\\noindent \\small #3
    \\par\\sepspace
\t\\noindent \\small #4
    \\normalsize \\par
}

\\newcommand{\\PaperEntry}[7]{
\t\\noindent #1, ``\\href{#7}{#2}'', \\textit{#3} \\textbf{#4}, #5 (#6).
}

\\newcommand{\\ArxivEntry}[3]{
\t\\noindent #1, ``\\href{http://arxiv.org/abs/#3}{#2}'', \\textit{cond-mat/#3}.
}

\\newcommand{\\BookEntry}[4]{
\t\\noindent #1, ``\\href{#3}{#4}'', \\textit{#3}.
}

\\newcommand{\\FundingEntry}[5]{
    \\noindent #1, ``#2'', \\$#3 (#4, #5).
}

\\newcommand{\\TalkEntry}[4]{
\t\\noindent #1, #2, #3 #4
}

\\newcommand{\\ThesisEntry}[5]{
\t\\noindent #1 -- #2 #3 ``#4'' \\textit{#5}
}

\\newcommand{\\CourseEntry}[3]{
\t\\noindent \\item{#1: \\textbf{#2} \\\\ #3}
}

\\begin{document}

\\MyName{{{{name}}}}    % Placeholder for name

\\sepspace
\\sepspace

%%% Personal details
\\NewPart{{}}{{}}    % Empty section

\\PersonalEntry{{Birth}}{{{{birth}}}}           % Placeholder for birth
\\PersonalEntry{{Address}}{{{{address}}}}       % Placeholder for address
\\PersonalEntry{{Phone}}{{{{phone}}}}           % Placeholder for phone
\\PersonalEntry{{Mail}}{{\\url{{{{email}}}}}}   % Placeholder for email
\\PersonalEntry{{Github}}{{\\href{{{{githubURL}}}}{{{{github}}}}}} % Placeholders for GitHub
\\PersonalEntry{{Linkedin}}{{\\href{{{{linkedinURL}}}}{{{{linkedin}}}}}} % Placeholders for LinkedIn

%%% Objective
\\NewPart{{Objective}}{{}}

{{{{objective}}}}    % Placeholder for objective

%%% Education
\\NewPart{{Education}}{{}}

{{{{education_section}}}}    % Placeholder for education section

%%% Skills
\\NewPart{{Skills}}{{}}

{{{{skills_section}}}}    % Placeholder for skills section

%%% Projects
\\NewPart{{Projects}}{{}}

{{{{projects_section}}}}    % Placeholder for projects section

%%% Experience
\\NewPart{{Experiences}}{{}}

{{{{experience_section}}}}    % Placeholder for experience section

\\end{document}
"""



# JOB Finder Moel --------------------------------------------------
@app.route('/api/jobs', methods=['GET'])
def get_jobs():
    app_id = '33a454df'
    app_key = '1805cb4c51d733cbe670bcab85c8818f'
    job_type = request.args.get('job_type', 'internship')
    location = request.args.get('location', 'Egypt')

    api_url = f'https://api.adzuna.com/v1/api/jobs/eg/search/1?app_id={app_id}&app_key={app_key}&what={job_type}&where={location}'

    response = requests.get(api_url)
    if response.status_code == 200:
        return jsonify(response.json())
    else:
        return jsonify({'error': 'Failed to fetch jobs'}), 500




#End Of Job Finder --------------------------------------------------



#Python -> MODEL----------------------------------------------------


load_dotenv()  # Load environment variables from .env file


# Get the absolute path of the directory containing the script
BASE_DIR = os.path.abspath(os.path.dirname(__file__))

# Configuration
UPLOAD_FOLDER = os.path.join(BASE_DIR, 'uploads')
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 50 * 1024 * 1024  # 50 MB max upload size

# Ensure upload folder exists
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

# Allowed extensions
ALLOWED_EXTENSIONS = {'pdf'}

# OpenAI API configuration
api_key = os.getenv('OPENAI_API_KEY')
if api_key:
    print("API key is set.")
else:
    print("API key is not set.")
openai.api_key = api_key  # Set the API key for OpenAI

def allowed_file(filename):
    return '.' in filename and \
        filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def extract_lecture_number(filename):
    # Extract numbers from the filename using regex
    match = re.findall(r'\d+', filename)
    if match:
        return int(match[0])
    else:
        return None  # Return None if no number is found

def extract_text_from_pdfs(pdf_paths):
    combined_texts = {}
    for pdf_path, lecture_number in pdf_paths:
        print(f"Extracting text from {pdf_path} (Lecture {lecture_number})...")
        try:
            text = extract_text(pdf_path)
            if text:
                combined_texts[lecture_number] = combined_texts.get(lecture_number, '') + text + ' '
            else:
                print(f"No text extracted from {pdf_path}.")
        except Exception as e:
            print(f"Error extracting text from {pdf_path}: {e}")
    return combined_texts  # Returns a dictionary with lecture numbers as keys

def split_text_into_chunks(text, max_length=1000):
    # Adjust the chunk size as needed
    words = text.split()
    chunks = []
    for i in range(0, len(words), max_length):
        chunk = ' '.join(words[i:i + max_length])
        chunks.append(chunk)
    return chunks

def generate_options(correct_answer):
    options = [correct_answer]
    # Generate dummy distractors for simplicity
    for _ in range(3):
        option = ''.join(random.choices(string.ascii_uppercase + string.digits, k=5))
        options.append(option)
    options = options[:4]
    random.shuffle(options)
    return options

def generate_questions(text_chunks, lecture_number, num_questions, num_mcq, num_true_false):
    generated_questions = []
    questions_needed = num_questions

    for chunk in text_chunks:
        if questions_needed <= 0:
            break

        # Calculate how many questions to generate in this chunk
        chunk_num_mcq = min(num_mcq, questions_needed)
        chunk_num_true_false = min(num_true_false, questions_needed - chunk_num_mcq)

        # Prepare the messages for the chat completion
        prompt = f"""
You are an AI assistant that generates quiz questions based on the given text.

Instructions:
- Generate {chunk_num_mcq + chunk_num_true_false} quiz questions from the text below.
- Include {chunk_num_mcq} multiple-choice questions and {chunk_num_true_false} true/false questions.
- For multiple-choice questions, provide 4 options labeled A, B, C, and D.
- Indicate the correct answer.
- Provide a brief explanation for each answer.
- Vary the difficulty between easy, medium, and hard.

Text:
\"\"\"
{chunk}
\"\"\"

Please format your response as a JSON array with the following structure:
[
  {{
    "question": "Question text",
    "type": "MCQ",
    "options": ["A. Option A", "B. Option B", "C. Option C", "D. Option D"],
    "answer": "A",
    "explanation": "Explanation text."
  }},
  {{
    "question": "Question text",
    "type": "True/False",
    "answer": "True",
    "explanation": "Explanation text."
  }},
  ...
]
"""

        try:
            response = openai.ChatCompletion.create(
                model="gpt-4-turbo",
                messages=[
                    {"role": "user", "content": prompt}
                ],
                max_tokens=1500,
                temperature=0.7,
            )
            reply = response['choices'][0]['message']['content'].strip()
            # Parse the JSON response
            quiz_items = json.loads(reply)

            for item in quiz_items:
                question_text = item.get('question', '')
                question_type = item.get('type', '')
                correct_answer = item.get('answer', '')
                explanation_text = item.get('explanation', '')
                options = item.get('options', [])

                question = {
                    'question': question_text,
                    'type': question_type,
                    'lecture': lecture_number,  # Add lecture number here
                    'answer': correct_answer,
                    'explanation': explanation_text
                }

                if question_type == 'MCQ':
                    # Ensure we have options
                    if not options or len(options) < 4:
                        options = generate_options(correct_answer)
                    question['options'] = options
                    num_mcq -= 1
                elif question_type == 'True/False':
                    num_true_false -= 1
                else:
                    continue  # Skip if the question type is unrecognized

                generated_questions.append(question)
                questions_needed -= 1

                if questions_needed <= 0 or (num_mcq <= 0 and num_true_false <= 0):
                    break

        except Exception as e:
            print(f"Exception during OpenAI API call: {e}")
            continue

    if not generated_questions:
        print("No questions were generated by the API.")
        return []

    return generated_questions

from urllib.parse import urlparse, urlunparse, parse_qs

def convert_dropbox_url(url):
    """
    Convert a Dropbox shared link to a direct download link.
    Handles both old and new Dropbox URL formats.
    """
    parsed_url = urlparse(url)

    # Check if the URL is from Dropbox
    if 'dropbox.com' in parsed_url.netloc:
        # Replace 'www.dropbox.com' or 'dropbox.com' with 'dl.dropboxusercontent.com'
        netloc = parsed_url.netloc.replace('www.dropbox.com', 'dl.dropboxusercontent.com').replace('dropbox.com', 'dl.dropboxusercontent.com')
        # Remove query parameters
        new_url = urlunparse(('https', netloc, parsed_url.path, '', '', ''))
        return new_url
    # If it's not a Dropbox link, return it as is
    return url


@app.route('/submit_quiz', methods=['POST'])
def submit_quiz():
    try:
        data = request.get_json()

        # Print the received data for debugging
        print("Received data:", data)

        # Extract data from the request
        user_id = data.get('UserID')
        user_ans = data.get('UserAns')  # CSV string
        quiz_ans = data.get('QuizAns')  # CSV string
        lec_num = data.get('LecNum')    # CSV string
        co_id = data.get('co_id')       # Get co_id from data

        # Validate data
        if not all([user_id, user_ans, quiz_ans, lec_num, co_id]):
            print("Missing data in the request")
            return jsonify({'status': 'error', 'message': 'Missing data'}), 400

        # Connect to the database using get_connection()
        conn = get_connection()
        if not conn:
            print("Database connection failed")
            return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500

        try:
            cursor = conn.cursor()

            # Insert data into the Quiz table, including co_id
            # Insert data into the Quiz table, including co_id
            insert_query = """
            INSERT INTO Quiz (UserID, UserAns, QuizAns, LecNum, co_id)
            VALUES (%s, %s, %s, %s, %s)
            """
            cursor.execute(insert_query, (user_id, user_ans, quiz_ans, lec_num, co_id))
            conn.commit()

            # Close the connection
            cursor.close()
            conn.close()

            print("Quiz results saved successfully")
            return jsonify({'status': 'success', 'message': 'Quiz results saved.'}), 200

        except mysql.connector.Error as err:
            # Print detailed database error
            print(f"Database error: {err}")
            traceback.print_exc()
            return jsonify({'status': 'error', 'message': 'Database error'}), 500

    except Exception as e:
        # Print detailed exception information
        print(f"An unexpected error occurred: {e}")
        traceback.print_exc()
        return jsonify({'status': 'error', 'message': 'Server error'}), 500


@app.route('/generate_quiz', methods=['POST'])
def generate_quiz():
    try:
        data = request.get_json()
        if data is None:
            return jsonify({'error': 'Invalid JSON sent in request'}), 400
        print('Received Data:', data)

        # Extract parameters from the request
        co_id = data.get('co_id')
        lecture_start = int(data.get('lecture_start', 1))
        lecture_end = int(data.get('lecture_end', 999))
        num_questions = int(data.get('number_of_questions', 5))
        num_mcq = int(data.get('num_mcq', 0))
        num_true_false = int(data.get('num_true_false', 0))

        if not co_id:
            return jsonify({'error': 'co_id is required.'}), 400

        # Convert co_id to integer if necessary
        co_id = int(co_id)
        print(f"co_id received: {co_id}")

        # Connect to the database to get course_name using co_id
        conn = get_connection()
        if not conn:
            print("Database connection failed")
            return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500

        try:
            cursor = conn.cursor()
            print("Database connection established. Executing query...")
            # Updated SQL query to use 'COName' instead of 'CName'
            cursor.execute("SELECT COName FROM Courses WHERE COId = %s", (co_id,))
            result = cursor.fetchone()
            cursor.close()
            conn.close()

            if not result:
                print("No course found with the provided co_id.")
                return jsonify({'error': 'Invalid co_id. Course not found.'}), 404
            course_name = result[0]
            print(f"Course name retrieved: {course_name}")
        except mysql.connector.Error as err:
            print(f"Database error: {err}")
            traceback.print_exc()
            return jsonify({'status': 'error', 'message': f'Database error: {err}'}), 500

        # Sanitize course_name if needed (e.g., remove spaces)
        course_name = course_name.strip().replace(' ', '')

        # Construct the path to the course directory
        course_dir = os.path.join(BASE_DIR, 'lectures', course_name)
        if not os.path.exists(course_dir):
            return jsonify({'error': f'Course directory not found: {course_dir}'}), 404

        # Get list of PDFs in the course directory
        all_files = os.listdir(course_dir)
        pdf_files = [f for f in all_files if allowed_file(f)]

        if not pdf_files:
            return jsonify({'error': 'No lecture files found for the course.'}), 400

        # Filter PDFs based on lecture range
        pdf_paths = []
        for filename in pdf_files:
            lecture_number = extract_lecture_number(filename)
            if lecture_number is None:
                print(f"No lecture number found in file name {filename}. Skipping this file.")
                continue  # Skip files without lecture numbers
            if lecture_start <= lecture_number <= lecture_end:
                file_path = os.path.join(course_dir, filename)
                pdf_paths.append((file_path, lecture_number))
            else:
                print(f"File {filename} is outside the specified lecture range. Skipping this file.")

        if not pdf_paths:
            return jsonify({'error': 'No valid files within the specified lecture range.'}), 400

        # Extract text from PDFs
        combined_texts = extract_text_from_pdfs(pdf_paths)

        if not combined_texts:
            return jsonify({'error': 'No text could be extracted from the PDFs.'}), 400

        all_questions = []

        # Generate questions for each lecture
        total_lectures = len(combined_texts)
        lecture_numbers = list(combined_texts.keys())
        for idx, lecture_number in enumerate(lecture_numbers):
            text = combined_texts[lecture_number]
            print(f"Processing Lecture {lecture_number}...")
            # Split text into chunks
            text_chunks = split_text_into_chunks(text)
            print(f"Number of text chunks for Lecture {lecture_number}: {len(text_chunks)}")

            # Distribute questions evenly among lectures
            lecture_num_questions = num_questions // total_lectures
            lecture_num_mcq = num_mcq // total_lectures
            lecture_num_true_false = num_true_false // total_lectures

            # Handle any remainder
            if idx == total_lectures - 1:
                # Add the remainder to the last lecture
                lecture_num_questions += num_questions % total_lectures
                lecture_num_mcq += num_mcq % total_lectures
                lecture_num_true_false += num_true_false % total_lectures

            # Generate questions
            print(f"Generating questions for Lecture {lecture_number}...")
            questions = generate_questions(
                text_chunks,
                lecture_number,
                lecture_num_questions,
                lecture_num_mcq,
                lecture_num_true_false
            )

            all_questions.extend(questions)

        if not all_questions:
            return jsonify({'error': 'No questions could be generated.'}), 500

        # Return the generated quiz as JSON
        response_data = {'questions': all_questions}
        return jsonify(response_data), 200

    except Exception as e:
        print(f"An error occurred: {e}")
        traceback.print_exc()
        return jsonify({'error': f'An internal error occurred: {e}'}), 500

#End of MODEL ------------------------------------------------------------


# app = Flask(__name__)


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
        cursor2 = db.cursor()
        # Prepare the SQL INSERT query
        insert_query = """
        INSERT INTO Schedule (UserId, Title, Date, StartTime, EndTime, Category, Description, Location, ReminderBefore, Repeatance, RepeatEndDate)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
        """
        query2 = """
        INSERT INTO notifications (title, body , user_id)
        VALUES(%s, %s, %s);
        """
        # Execute the query with the data
        cursor.execute(insert_query, (user_id, title, date, start_time, end_time, category, description, location, reminder_time, repeat, repeat_until))
        print("schedule added successfully")
        cursor2.execute(query2,(title, description , user_id,))
        print("notification added successfully")
        # Commit the transaction
        db.commit()

        # Return a success response
        return jsonify({"message": "Schedule added successfully!"}), 200

    except Exception as e:
        db.rollback()  # Rollback in case of error
        return jsonify({"error": str(e)}), 500

    finally:
        cursor.close()  # Close the cursor
        cursor2.close()
        db.close()  # Close the database connection

from flask import request, jsonify

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


@app.route('/get_recent_quizzes', methods=['GET'])
def get_recent_quizzes():
    user_id = request.args.get('user_id')
    if not user_id:
        return jsonify({'status': 'error', 'message': 'user_id parameter is required'}), 400
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # Fetch the most recent 2 quizzes for the user
        query = '''
        SELECT *
        FROM Quiz
        WHERE UserID = %s
        ORDER BY QID DESC
        LIMIT 2
        '''
        cursor.execute(query, (user_id,))
        quizzes = cursor.fetchall()

        # Process each quiz to calculate Score and TotalScore
        for quiz in quizzes:
            user_ans = quiz['UserAns']
            quiz_ans = quiz['QuizAns']

            # Convert the answers from strings to lists
            user_answers_list = user_ans.split(',')
            quiz_answers_list = quiz_ans.split(',')

            # Ensure both lists have the same length
            num_questions = min(len(user_answers_list), len(quiz_answers_list))

            # Compute the number of correct answers
            num_correct = sum(1 for ua, qa in zip(user_answers_list[:num_questions], quiz_answers_list[:num_questions]) if ua.strip() == qa.strip())

            # Set the Score and TotalScore for each quiz
            quiz['Score'] = num_correct
            quiz['TotalScore'] = num_questions

        cursor.close()
        conn.close()
        return jsonify({'status': 'success', 'quizzes': quizzes}), 200
    except Exception as e:
        app.logger.error(f"Error in get_recent_quizzes: {e}")
        return jsonify({'status': 'error', 'message': 'Internal server error'}), 500

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
# from flask import Flask, request, jsonify
# from flask import Flask, request, jsonify
@app.route('/get_courses_answered', methods=['POST'])
def get_courses_answered():
    data = request.get_json()
    id = data['ID']
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # SQL query to get the number of quizzes completed per course for the given student
        query = """
        select co_id, COName , count(*) as NumberOfQuizzes from Quiz q inner join Courses c on q.co_id = c.COID where q.userId = %s group by COName
        """

        cursor.execute(query, (id,))
        result = cursor.fetchall()

        cursor.close()
        conn.close()
        return jsonify(result), 200
    except Exception as e:
        # Handle exceptions, such as database errors
        return jsonify({'error': str(e)}), 500

@app.route('/get_course_insights', methods=['POST'])
def get_course_insights():
    data = request.get_json()
    user_id = data['ID']
    course_id = data['co_id']
    print(user_id)
    print(course_id)
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # Fetch total quizzes taken in the course
        query_total_quizzes = """
        SELECT COUNT(*) AS total_quizzes
        FROM Quiz g
        WHERE g.UserID = %s AND g.co_id = %s
        """
        cursor.execute(query_total_quizzes, (user_id, course_id))
        total_quizzes_result = cursor.fetchone()
        total_quizzes_taken = total_quizzes_result['total_quizzes']

        # Fetch average score in the course
        query_avg_score = """
        SELECT UserAns, QuizAns FROM Quiz WHERE UserID = %s and co_id = %s
        """
        cursor.execute(query_avg_score, (user_id, course_id))
        quizzes = cursor.fetchall()
        total_quizzes = len(quizzes)
        total_score = 0
        total_questions = 0
        solved_questions = 0

        for quiz in quizzes:
            user_ans = quiz['UserAns']
            quiz_ans = quiz['QuizAns']

            # Convert the answers from strings to lists
            user_answers_list = user_ans.split(',')
            quiz_answers_list = quiz_ans.split(',')

            # Ensure both lists have the same length
            num_questions = min(len(user_answers_list), len(quiz_answers_list))

            # Compute the number of correct answers
            num_correct = sum(1 for ua, qa in zip(user_answers_list, quiz_answers_list) if ua == qa)

            # Calculate score as a percentage
            percentage_score = (num_correct / num_questions) * 100 if num_questions > 0 else 0
            total_score += percentage_score
            total_questions += num_questions
            solved_questions += num_correct

        if total_quizzes > 0:
            average_score = total_score / total_quizzes
        else:
            average_score = 0


        # Build response
        response = {
            'total_quizzes_taken': total_quizzes_taken,
            'average_score': average_score,
            'solved_questions': solved_questions,
            'total_questions': total_questions,
            # Add more data as needed
        }

        cursor.close()
        conn.close()
        return jsonify(response), 200
    except Exception as e:
        print(f"An error occurred: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/get_insights', methods=['POST'])
def get_insights():
    data = request.get_json()
    if not data or 'ID' not in data:
        return jsonify({'error': 'User ID is missing in the request body.'}), 400

    userID = data.get('ID')
    try:
        conn = get_connection()

        # Use a dictionary cursor to fetch rows as dictionaries
        cursor = conn.cursor(dictionary=True)

        # Query to get all quizzes taken by the user
        query = '''
        SELECT UserAns, QuizAns FROM Quiz WHERE UserID = %s
        '''
        cursor.execute(query, (userID,))
        quizzes = cursor.fetchall()

        # Query to get streak information for the user
        query2 = "SELECT day_streak, max_streak FROM user WHERE id = %s"
        cursor.execute(query2, (userID,))
        streak = cursor.fetchone()

        # Handle case where user is not found
        if streak is None:
            streak = {'day_streak': 0, 'max_streak': 0}

        total_quizzes = len(quizzes)
        total_score = 0

        for quiz in quizzes:
            user_ans = quiz['UserAns']
            quiz_ans = quiz['QuizAns']

            # Convert the answers from strings to lists
            user_answers_list = user_ans.split(',')
            quiz_answers_list = quiz_ans.split(',')

            # Ensure both lists have the same length
            num_questions = min(len(user_answers_list), len(quiz_answers_list))

            # Compute the number of correct answers
            num_correct = sum(1 for ua, qa in zip(user_answers_list, quiz_answers_list) if ua == qa)

            # Calculate score as a percentage
            percentage_score = (num_correct / num_questions) * 100 if num_questions > 0 else 0
            total_score += percentage_score

        if total_quizzes > 0:
            average_score = total_score / total_quizzes
        else:
            average_score = 0

        # Return the total number of quizzes, average score, and streak information
        return jsonify({
            'total_quizzes': total_quizzes,
            'average_score': average_score,
            'day_streak': streak['day_streak'],
            'max_streak': streak['max_streak']
        }), 200

    except Exception as e:
        # Log the error (optional)
        print(f"Error retrieving insights for user {userID}: {e}")
        return jsonify({'error': 'An error occurred while fetching data.'}), 500

    finally:
        cursor.close()
        conn.close()
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


@app.route('/recentCourses', methods=['POST'])
def recentCourses():
    try:

        data = request.get_json()
        username = data.get('username') # Use query parameters
        if not username:
            return jsonify({'error': 'Missing username'}), 400

        db = get_connection()
        cursor = db.cursor(dictionary=True)
        query = """
                SELECT * FROM Register
                where username = %s
                ORDER BY recentEnter DESC;
        """

        cursor.execute(
            query,(username,)
        )
        course_ids = cursor.fetchall()

        if not course_ids:
            return jsonify({'error': f'No courses found for username: {username}'}), 404

        subjects = []
        i = 0
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
            i += 1
            if i == 2 :
                break
        cursor.close()
        db.close()

        return jsonify({'username': username, 'courses': subjects , 'CourseID' : course_ids}), 200

    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500


    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500




@app.route('/upload-image', methods=['POST'])
def upload_image():
    if 'image' not in request.files:
        return jsonify({'error': 'No image part in the request'}), 400

    image = request.files['image']
    username = request.form.get('username')

    if image.filename == '':
        return jsonify({'error': 'No image selected for uploading'}), 400

    # Get the current working directory
    current_dir = os.getcwd()

    # Print the current working directory
    print(f"Current directory: {current_dir}")
    # Save the file locally or process it
    image.save(f'../pfpImages/PFP_{username}')


    db = get_connection()  # Assuming get_connection() connects to your database
    cursor = db.cursor()

    update_query = """
    UPDATE user
    SET profile_picture_link = %s
    WHERE username = %s
    """
    cursor.execute(update_query, (f'../pfpImages/PFP_{username}', username))
    db.commit()

    if cursor.rowcount == 1:
        response = {'message': 'Image uploaded and profile updated successfully'}
    else:
        response = {'error': 'User not found or no changes made'}

    cursor.close()
    db.close()

    return jsonify({'message': response}), 200




def encode_image_to_base64(image_path):
    try:
        # Open the image file in binary mode
        with open(image_path, 'rb') as image_file:
            # Read the binary data
            binary_data = image_file.read()
            # Encode the binary data to Base64
            base64_encoded = base64.b64encode(binary_data).decode('utf-8')
        return base64_encoded
    except Exception as e:
        print(f"Error: {e}")
        return None



@app.route('/get_users',methods=['GET'])
def get_users():
    print('>>> \n')
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        query = "select * from user"
        cursor.execute(query)
        result = cursor.fetchall()

        serialized_users = []

        for user in result:
            serialized_users.append({
                'id': user['id'],
                'username': user['username'],
                'name': user['name'],
                'pfp': user['profile_picture_link'],
                'xp': user['experience_points'],
                'title': user['title'],
            })

        for user in serialized_users:
            user['pfp']=encode_image_to_base64(user['pfp'])
        cursor.close()
        conn.close()
        return jsonify(serialized_users), 200


    except Exception as e:
        print(f"Error: {str(e)}")
        return jsonify({'error': str(e)}), 500  # Return 500 in case of any exception




@app.route('/set_xp', methods=['POST'])
def set_xp():
    data = request.get_json()
    username = data.get('username')
    new_xp = data.get('xp')

    if not username or new_xp is None:
        return jsonify({'message': 'Username and xp are required'}), 400

    conn = get_connection()
    if not conn:
        return jsonify({'message': 'Database connection error'}), 500

    try:
        cursor = conn.cursor()
        query = "UPDATE user SET experience_points = %s WHERE username = %s"
        cursor.execute(query, (new_xp, username))
        conn.commit()

        if cursor.rowcount == 1:
            response = {'message': 'XP updated successfully'}
        else:
            response = {'message': 'User not found or no changes made'}

        cursor.close()
        conn.close()
        return jsonify(response), 200
    except Exception as e:
        conn.rollback()
        print(f"Error updating XP: {e}")
        return jsonify({'message': f'An error occurred: {str(e)}'}), 500

@app.route('/set_title', methods=['POST'])
def set_title():
    data = request.get_json()
    username = data.get('username')
    new_title = data.get('title')

    if not username or not new_title:
        return jsonify({'message': 'Username and title are required'}), 400

    conn = get_connection()
    if not conn:
        return jsonify({'message': 'Database connection error'}), 500

    try:
        cursor = conn.cursor()
        query = "UPDATE user SET title = %s WHERE username = %s"
        cursor.execute(query, (new_title, username))
        conn.commit()

        if cursor.rowcount == 1:
            response = {'message': 'Title updated successfully'}
        else:
            response = {'message': 'User not found or no changes made'}

        cursor.close()
        conn.close()
        return jsonify(response), 200
    except Exception as e:
        conn.rollback()
        print(f"Error updating title: {e}")
        return jsonify({'message': f'An error occurred: {str(e)}'}), 500

@app.route('/get-profile-image', methods=['POST'])
def get_profile_image():
    data = request.get_json()  # Receive JSON data from the request
    username = data.get('username')  # Extract the 'username' field from the request

    if not username:
        return jsonify({'error': 'Username is required'}), 400  # Error if no username is provided

    try:
        # Fetch the image path from the database
        db = get_connection()  # Assuming get_connection() connects to your database
        cursor = db.cursor()

        query = "SELECT profile_picture_link FROM user WHERE username = %s"
        cursor.execute(query, (username,))
        result = cursor.fetchone()

        cursor.close()
        db.close()

        if not result or not result[0]:
            return jsonify({'error': 'No profile picture found for this user'}), 404  # Return 404 if no image is found

        image_path = result[0]  # The image path fetched from the database

        print(image_path)

        # Check if the image file exists
        if not os.path.exists(image_path):
            return jsonify({'error': 'Image not found at the specified path'}), 404  # If the file is not found, return 404

        # Return the image file with proper MIME type (adjust MIME type as needed)
        return send_file(image_path, mimetype='image/jpeg')  # Assuming it's a JPEG, change the mimetype if needed

    except Exception as e:
        # Log the exception to understand what went wrong
        print(f"Error: {str(e)}")
        return jsonify({'error': str(e)}), 500  # Return 500 in case of any exception



@app.route('/getNotification', methods=['POST'])
def fetchOnNotifications():
    try:

        data = request.get_json()
        id = data.get('username') # Use query parameters
        if not id:
            return jsonify({'error': 'Missing username'}), 400

        db = get_connection()
        cursor = db.cursor(dictionary=True)

        cursor.execute(
            # distinct حل مؤقت لحد مشوف الفانكشن اللى فوق
            "SELECT title , body , id FROM notifications WHERE user_id = %s",
            (id,)
        )
        notifications = cursor.fetchall()

        if not notifications:
            return jsonify({'error': f'No courses found for username: {username}'}), 404
        cursor.close()
        db.close()

        return jsonify({'notifications': notifications}), 200

    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500


    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500

@app.route('/deleteNotification', methods=['POST'])
def deleteNotification():
    try:
        data = request.get_json()
        Midx = data.get('notificationId')
        if not Midx:
            return jsonify({'error': 'Missing Midx'}), 400

        db = get_connection()
        cursor2 =db.cursor()

        cursor2.execute(
                 "DELETE FROM notifications WHERE id = %s",
                (Midx,)
        )
        db.commit();
        cursor2.close()
        db.close()

        if cursor2.rowcount == 1:
                response = {'message': 'notification deleted successfully'}
        else:
                response = {'message': 'No changes made or notification not found'}

        # return jsonify({'URL': subjects['RFileURL'], 'Name': subjects['RName']}), 200
        # return jsonify({'courses': [{'URL': subject['RFileURL'], 'Name': subject['RName']} for subject in subjects]}), 200
        return jsonify(response), 200
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500

@app.route('/deleteAllNotifications', methods=['POST'])
def deleteAllNotifications():
    try:
        db = get_connection()
        cursor2 =db.cursor()
        cursor1 =db.cursor()
        cursor1.execute("SELECT COUNT(*) FROM notifications")
        total_rows = cursor1.fetchone()[0]

        cursor2.execute("TRUNCATE TABLE notifications;" )
        db.commit();
        cursor2.close()
        cursor1.close()
        db.close()
        if cursor2.rowcount == total_rows:
            response = {'message': 'All notifications deleted successfully'}
        elif cursor2.rowcount > 0:
            response = {'message': 'Some notifications deleted successfully'}
        else:
            response = {'message': 'No notifications found or no changes made'}
        # return jsonify({'URL': subjects['RFileURL'], 'Name': subjects['RName']}), 200
        # return jsonify({'courses': [{'URL': subject['RFileURL'], 'Name': subject['RName']} for subject in subjects]}), 200
        return jsonify(response), 200
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500






def sanitize_latex(text):
    if not text:
        return ''
    replacements = {
        '\\': r'\textbackslash{}',
        '&': r'\&',
        '%': r'\%',
        '$': r'\$',
        '#': r'\#',
        '_': r'\_',
        '{': r'\{',
        '}': r'\}',
        '~': r'\textasciitilde{}',
        '^': r'\textasciicircum{}',
    }
    for original, replacement in replacements.items():
        text = text.replace(original, replacement)
    return text



def Generate_CV(latex_code):
    # Encode the LaTeX code for inclusion in the URL
    encoded_latex = urllib.parse.quote(latex_code)
    print('Generating...')
    try :
        # API endpoint
        url = f'https://latexonline.cc/compile?text={encoded_latex}'

        # Send GET request
        response = requests.get(url)

        print("CV API Part")
        # Check the response
        if response.status_code == 200 and response.headers['Content-Type'] == 'application/pdf':
            with open('output.pdf', 'wb') as f:
                f.write(response.content)
            print("PDF generated successfully and saved as 'output.pdf'.")
        else:
            print("Failed to compile LaTeX code.")
            print("Status Code:", response.status_code)
            print("Response:", response.text)
    except Exception as error:
        print(error)




@app.route('/GenerateCV', methods=['POST'])
def generate_cv_latex():
    print("Generating CV")
    data = request.get_json()
    print(data)
    # Define the LaTeX template with placeholders

    # Helper function to escape LaTeX special characters

    print(latex_template)
    try :

        # Prepare personal details
        name = sanitize_latex(data.get('name', ''))
        birth = sanitize_latex(data.get('birth', ''))
        address = sanitize_latex(data.get('address', ''))
        phone = sanitize_latex(data.get('phone', ''))
        email = sanitize_latex(data.get('email', ''))
        github = sanitize_latex(data['github']['name'])
        githubURL = sanitize_latex(data['github']['githubURL'])
        linkedin = sanitize_latex(data['linkedin']['name'])
        linkedinURL = sanitize_latex(data['linkedin']['linkedinURL'])
        objective = sanitize_latex(data.get('objective', ''))



        # Prepare Education section
        education_entries = []
        for entry in data.get('education', []):
            degree = sanitize_latex(entry.get('degree', ''))
            years = sanitize_latex(entry.get('years', ''))
            institution = sanitize_latex(entry.get('institution', ''))
            description_lines = [sanitize_latex(line) for line in entry.get('descriptions', [])]
            description = r'\\'.join(description_lines)
            education_entry = r'\EducationEntry{{{}}}{{{}}}{{{}}}{{{}}} \sepspace'.format(degree, years, institution, description)
            education_entries.append(education_entry)
        education_section = '\n'.join(education_entries)

        print("1 ..............")
        # Prepare Skills section
        skills_entries = []
        print(data.get('skills', []))
        for skills in data.get('skills', []):
            print(skills)
            sanitized_category = sanitize_latex(skills['head'])
            sanitized_skills = ', '.join(sanitize_latex(skill) for skill in skills['skills'])
            # Create a LaTeX command or environment for each skill category
            skills_entry = r'\textbf{{{}}}: {} \\\\'.format(sanitized_category, sanitized_skills)
            skills_entries.append(skills_entry)
        skills_section = '\n'.join(skills_entries)


        print(f"2 .............. {skills_section}")

        # Prepare Projects section
        # Prepare Projects section
        projects_items = []
        for project_dict in data.get('projects', []):
            for title, description in project_dict.items():
                sanitized_title = sanitize_latex(title)
                sanitized_description = sanitize_latex(description)
                project_entry = r'\item \textbf{{{}}}: {}'.format(sanitized_title, sanitized_description)
                projects_items.append(project_entry)
        projects_section = r'\begin{itemize}' + '\n' + '\n'.join(projects_items) + '\n' + r'\end{itemize}'
        print("1.5 ........... {projects_section}")
        # Prepare Experience section
        experience_items = [r'\item {}'.format(sanitize_latex(exp)) for exp in data.get('experience', [])]
        print(f"2.5 .............. {experience_items}")
        experience_section = r'\begin{itemize}' + '\n\n' + ''.join(experience_items) + '\n' + r'\end{itemize}'


        print(f"3 .............. {experience_section}")


        # Replace placeholders in the template
        latex_code = latex_template.replace('{{{{name}}}}', name)
        latex_code = latex_code.replace('{{{{birth}}}}', birth)
        latex_code = latex_code.replace('{{{{address}}}}', address)
        latex_code = latex_code.replace('{{{{phone}}}}', phone)
        latex_code = latex_code.replace('{{{{email}}}}', email)
        latex_code = latex_code.replace('{{{{github}}}}', github)
        latex_code = latex_code.replace('{{{{githubURL}}}}', githubURL)
        latex_code = latex_code.replace('{{{{linkedin}}}}', linkedin)
        latex_code = latex_code.replace('{{{{linkedinURL}}}}', linkedinURL)
        latex_code = latex_code.replace('{{{{objective}}}}', objective)
        latex_code = latex_code.replace('{{{{education_section}}}}', education_section)
        latex_code = latex_code.replace('{{{{skills_section}}}}', skills_section)
        latex_code = latex_code.replace('{{{{projects_section}}}}', projects_section)
        latex_code = latex_code.replace('{{{{experience_section}}}}', experience_section)


        print(latex_code)

        Generate_CV(latex_code)
        return jsonify("Done"), 200
    except error:
        print("Error geerating CV")
        return jsonify(f"Error {error}") , 400



@app.route('/test')
def test():
    try:
        response = requests.get("https://latexonline.cc")
        # ret(response.status_code)
        return f"<pre>{response.status_code}</pre>"
    except Exception as e:
        print(f"Error: {e}")
        return f"<pre>{e}</pre>"
    return f"<pre>{latex_template}</pre>"

CORS(app)  # Configure CORS as needed

# Database Configuration
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://<AlyIbrahim>:<I@ly170305>@<AlyIbrahim.mysql.pythonanywhere-services.com>/<AlyIbrahim$StudyMate>'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
dbb = SQLAlchemy(app)

# Model
class User(dbb.Model):
    id = dbb.Column(dbb.Integer, primary_key=True)
    username = dbb.Column(dbb.String(50), nullable=False)
    email = dbb.Column(dbb.String(120), unique=True, nullable=False)
    experience_points = dbb.Column(dbb.Integer, nullable=False)

# Create tables (if not already created)

# Define the User model

# Route to fetch all users from the database


@app.route('/getUsersWeb', methods=['POST'])
def getUsersWeb():
    try:
        # Establish the database connection
        db = get_connection()
        cursor = db.cursor()

        # Execute the query to fetch all users
        cursor.execute("SELECT * FROM user;")
        users = cursor.fetchall()

        # Check if there are users
        if not users:
            return jsonify({'error': 'No users found'}), 404

        # Format users data for JSON response
        users_list = []
        for user in users:
            users_list.append({
                'id': user[0],  # Assuming 'id' is the first column
                'username': user[1],  # Assuming 'username' is the second column
                'email': user[5],  # Assuming 'email' is the third column
                'experience_points': user[14]  # Assuming 'experience_points' is the fourth column
            })

        cursor.close()
        db.close()

        # Return the users data as JSON
        return jsonify({'users': users_list}), 200

    except mysql.connector.Error as err:
        # Handle MySQL connection or query errors
        return jsonify({'error': str(err)}), 500







@app.route('/getInsightsWeb', methods=['POST'])
def getInsightsWeb():
    try:
        # Connect to the database
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)  # Adjust based on your DB connector

        # Fetch necessary data from Quiz table
        query = "SELECT UserAns, QuizAns, LecNum, co_id FROM Quiz"
        cursor.execute(query)
        quiz_insights = cursor.fetchall()

        # Data processing for the line chart (Quizzes per Lecture)
        quizzes_per_lecture = defaultdict(int)
        for row in quiz_insights:
            lec_num = row['LecNum']
            quizzes_per_lecture[lec_num] += 1

        # Sort the lectures numerically
        sorted_lectures = sorted(quizzes_per_lecture.keys())
        line_chart_data = {
            'labels': [str(lec) for lec in sorted_lectures],
            'counts': [quizzes_per_lecture[lec] for lec in sorted_lectures]
        }

        # Data processing for the doughnut chart (Quizzes per Course)
        quizzes_per_course = defaultdict(int)
        for row in quiz_insights:
            course_id = row['co_id']
            quizzes_per_course[course_id] += 1

        # Get the unique course IDs
        course_ids = list(quizzes_per_course.keys())

        # Fetch course names from Courses table for the given course IDs
        # Build the IN clause with placeholders
        placeholders = ','.join(['%s'] * len(course_ids))
        query2 = "SELECT COId, COName FROM Courses WHERE COId IN (%s)" % placeholders

        # Execute query2 to get course names
        cursor.execute(query2, course_ids)
        course_rows = cursor.fetchall()

        # Build the mapping from COId to COName
        course_names = { row['COId']: row['COName'] for row in course_rows }

        # Build the labels using course names
        labels = [course_names.get(co_id, str(co_id)) for co_id in quizzes_per_course.keys()]
        counts = list(quizzes_per_course.values())

        doughnut_chart_data = {
            'labels': labels,
            'counts': counts
        }

        # Prepare the combined data
        result = {
            'line_chart': line_chart_data,
            'doughnut_chart': doughnut_chart_data
        }

        # Close the connection
        conn.close()

        return jsonify(result), 200

    except Exception as e:
        print(f"Error in getInsightsWeb: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/deleteUserWeb', methods=['POST'])
def deleteuser():
    try:
        data = request.get_json()
        Midx = data.get('username')
        if not Midx:
            return jsonify({'error': 'Missing Midx'}), 400

        db = get_connection()
        cursor2 =db.cursor()

        cursor2.execute(
                 "DELETE FROM user WHERE username = %s",
                (Midx,)
        )
        db.commit();
        cursor2.close()
        db.close()

        if cursor2.rowcount == 1:
                response = {'message': 'user deleted successfully'}
        else:
                response = {'message': 'No changes made or user'}

        # return jsonify({'URL': subjects['RFileURL'], 'Name': subjects['RName']}), 200
        # return jsonify({'courses': [{'URL': subject['RFileURL'], 'Name': subject['RName']} for subject in subjects]}), 200
        return jsonify(response), 200
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500
# Run the app
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5003, debug=True, use_reloader=False)
