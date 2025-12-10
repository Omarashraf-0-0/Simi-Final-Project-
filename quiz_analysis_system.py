# ============================================================================
# QUIZ ANALYSIS SYSTEM FOR RECOMMENDATION ENGINE
# ============================================================================
# This file contains the backend code for saving and analyzing quiz results
# to power the recommendation system that suggests weak topics to students.
#
# APPROACH: Semantic Topic Clustering
# - OpenAI generates topic names based on actual PDF content (flexible)
# - Topics are stored as-is in the database (no forced consistency)
# - When analyzing, we cluster similar topics together using keyword matching
# - This works across ANY PDF format and course structure
# ============================================================================

import json
import traceback
import mysql.connector
from flask import jsonify, request
from difflib import SequenceMatcher  # For fuzzy string matching


# ============================================================================
# MODIFIED GENERATE_QUESTIONS FUNCTION
# ============================================================================
# This replaces your existing generate_questions function
# It includes the "topic" field in the prompt so OpenAI extracts topics
# ============================================================================

def generate_questions(text_chunks, lecture_number, num_questions, num_mcq, num_true_false):
    """
    Generate quiz questions from text chunks using OpenAI API.
    Now includes topic extraction for the recommendation system.
    
    Args:
        text_chunks: List of text chunks from the PDF
        lecture_number: The lecture number being processed
        num_questions: Total number of questions to generate
        num_mcq: Number of multiple choice questions
        num_true_false: Number of true/false questions
    
    Returns:
        List of question dictionaries with topic information
    """
    generated_questions = []
    questions_needed = num_questions
    mcq_needed = num_mcq
    tf_needed = num_true_false

    for chunk_index, chunk in enumerate(text_chunks):
        if questions_needed <= 0:
            break

        # Calculate how many questions to generate in this chunk
        chunk_num_mcq = min(mcq_needed, questions_needed)
        chunk_num_true_false = min(tf_needed, questions_needed - chunk_num_mcq)

        # If no questions are needed from this chunk, continue to next
        if chunk_num_mcq + chunk_num_true_false == 0:
            continue

        print(f"Lecture {lecture_number}, Chunk {chunk_index + 1}/{len(text_chunks)}:")
        print(f"  Questions needed: {questions_needed}")
        print(f"  MCQs needed: {mcq_needed}")
        print(f"  True/False needed: {tf_needed}")
        print(f"  Generating {chunk_num_mcq} MCQs and {chunk_num_true_false} True/False questions.")

        # ===== UPDATED PROMPT WITH TOPIC EXTRACTION =====
        prompt = f"""
You are an AI assistant that generates quiz questions based on the given text.

Instructions:
- Generate exactly {chunk_num_mcq + chunk_num_true_false} quiz questions from the text below.
- Include precisely {chunk_num_mcq} multiple-choice questions and {chunk_num_true_false} true/false questions.
- Do not include any questions of a different type.
- **It is crucial that you generate the exact number of each question type as specified.**
- For multiple-choice questions, provide 4 options labeled A, B, C, and D.
- Indicate the correct answer.
- Provide a brief explanation for each answer.
- **IMPORTANT: For each question, identify the main topic/concept being tested. Use a SHORT, clear phrase (2-5 words) that describes the specific concept. Examples: "Photosynthesis", "Cell Division", "DNA Replication", "Newton's Second Law", "Protein Synthesis".**
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
    "topic": "Brief Topic Name",
    "options": ["A. Option A", "B. Option B", "C. Option C", "D. Option D"],
    "answer": "A",
    "explanation": "Explanation text."
  }},
  {{
    "question": "Question text",
    "type": "True/False",
    "topic": "Brief Topic Name",
    "answer": "True",
    "explanation": "Explanation text."
  }},
  ...
]
"""

        try:
            # Call OpenAI API
            response = openai.ChatCompletion.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "user", "content": prompt}
                ],
                max_tokens=1500,
                temperature=0.7,
            )
            reply = response['choices'][0]['message']['content'].strip()
            print(f"AI Response:\n{reply}\n")

            # Parse the JSON response
            try:
                quiz_items = json.loads(reply)
            except json.JSONDecodeError as e:
                print(f"JSON decoding error: {e}")
                print("Skipping this chunk due to malformed JSON.")
                continue

            print(f"Received {len(quiz_items)} questions from OpenAI API.")

            # Process each question
            for item in quiz_items:
                question_text = item.get('question', '')
                question_type = item.get('type', '')
                correct_answer = item.get('answer', '')
                explanation_text = item.get('explanation', '')
                options = item.get('options', [])
                # ===== GET TOPIC FROM OPENAI RESPONSE =====
                topic = item.get('topic', 'General Topic')  # Default if OpenAI doesn't provide one

                # Check if we have capacity for this question type
                if question_type == 'MCQ':
                    if mcq_needed <= 0:
                        print("MCQ quota reached. Skipping this MCQ.")
                        continue  # Skip unwanted MCQ
                    # Process MCQ question
                    if not options or len(options) < 4:
                        options = generate_options(correct_answer)
                    question = {
                        'question': question_text,
                        'type': question_type,
                        'lecture': lecture_number,
                        'topic': topic,  # ===== INCLUDE TOPIC =====
                        'answer': correct_answer,
                        'explanation': explanation_text,
                        'options': options
                    }
                    mcq_needed -= 1
                elif question_type == 'True/False':
                    if tf_needed <= 0:
                        print("True/False quota reached. Skipping this True/False question.")
                        continue  # Skip unwanted True/False
                    # Process True/False question
                    question = {
                        'question': question_text,
                        'type': question_type,
                        'lecture': lecture_number,
                        'topic': topic,  # ===== INCLUDE TOPIC =====
                        'answer': correct_answer,
                        'explanation': explanation_text
                    }
                    tf_needed -= 1
                else:
                    print(f"Unrecognized question type: {question_type}. Skipping.")
                    continue  # Skip unrecognized question type

                generated_questions.append(question)
                questions_needed -= 1

                print(f"Question added. Remaining - Questions: {questions_needed}, MCQ: {mcq_needed}, True/False: {tf_needed}")

                if questions_needed <= 0 or (mcq_needed <= 0 and tf_needed <= 0):
                    print("Required number of questions generated for this lecture.")
                    break

        except Exception as e:
            print(f"Exception during OpenAI API call: {e}")
            traceback.print_exc()
            continue

    print(f"Total questions generated for lecture {lecture_number}: {len(generated_questions)}\n")
    return generated_questions


# ============================================================================
# NEW ENDPOINT: SAVE QUIZ ANALYSIS
# ============================================================================
# This endpoint saves detailed quiz results for the recommendation system
# Data format: [{"Lecture": "1", "Topic": "Photosynthesis", "Correct": 1}, ...]
# ============================================================================

@app.route('/save_quiz_analysis', methods=['POST'])
def save_quiz_analysis():
    """
    Save detailed quiz analysis data for the recommendation system.
    
    Expected JSON format:
    {
        "UserID": 123,
        "co_id": 456,
        "quiz_results": [
            {"Lecture": "1", "Topic": "Photosynthesis", "Correct": 1},
            {"Lecture": "1", "Topic": "Cell Respiration", "Correct": 0},
            ...
        ]
    }
    """
    try:
        data = request.get_json()
        
        # Extract data from request
        user_id = data.get('UserID')
        co_id = data.get('co_id')
        quiz_results = data.get('quiz_results')  # Array of {Lecture, Topic, Correct}
        
        # Validate required fields
        if not all([user_id, co_id, quiz_results]):
            return jsonify({'status': 'error', 'message': 'Missing required data'}), 400
        
        # Get database connection
        conn = get_connection()
        if not conn:
            return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500
        
        try:
            cursor = conn.cursor()
            
            # Create table if it doesn't exist
            # This table stores individual question results for analysis
            create_table_query = """
            CREATE TABLE IF NOT EXISTS quiz_analysis (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                co_id INT NOT NULL,
                lecture_num VARCHAR(10) NOT NULL,
                topic VARCHAR(255) NOT NULL,
                correct TINYINT(1) NOT NULL COMMENT '1 for correct, 0 for incorrect',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_user_course (user_id, co_id),
                INDEX idx_topic (topic),
                INDEX idx_correct (correct),
                INDEX idx_created (created_at)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            """
            cursor.execute(create_table_query)
            
            # Insert each quiz result
            insert_query = """
            INSERT INTO quiz_analysis (user_id, co_id, lecture_num, topic, correct)
            VALUES (%s, %s, %s, %s, %s)
            """
            
            for result in quiz_results:
                cursor.execute(insert_query, (
                    user_id,
                    co_id,
                    result['Lecture'],
                    result['Topic'],
                    result['Correct']
                ))
            
            conn.commit()
            cursor.close()
            conn.close()
            
            print(f"✅ Quiz analysis saved: {len(quiz_results)} results for user {user_id}, course {co_id}")
            return jsonify({'status': 'success', 'message': 'Quiz analysis saved successfully.'}), 200
            
        except mysql.connector.Error as err:
            print(f"❌ Database error: {err}")
            traceback.print_exc()
            return jsonify({'status': 'error', 'message': f'Database error: {str(err)}'}), 500
            
    except Exception as e:
        print(f"❌ Unexpected error in save_quiz_analysis: {e}")
        traceback.print_exc()
        return jsonify({'status': 'error', 'message': f'Server error: {str(e)}'}), 500


# ============================================================================
# HELPER FUNCTION: CLUSTER SIMILAR TOPICS
# ============================================================================
# This function groups similar topic names together using fuzzy matching
# Example: "Photosynthesis" and "Photosynthesis Process" → same cluster
# ============================================================================

def cluster_topics(topics_list):
    """
    Cluster similar topic names together using fuzzy string matching.
    
    Args:
        topics_list: List of topic names (strings)
    
    Returns:
        Dictionary mapping representative topic to list of similar topics
    
    Example:
        Input: ["Photosynthesis", "Photosynthesis Process", "Cell Division"]
        Output: {"Photosynthesis": ["Photosynthesis", "Photosynthesis Process"],
                 "Cell Division": ["Cell Division"]}
    """
    if not topics_list:
        return {}
    
    clusters = {}
    used = set()
    
    # Sort topics by length (longer topics are more specific)
    sorted_topics = sorted(set(topics_list), key=len, reverse=True)
    
    for topic in sorted_topics:
        if topic in used:
            continue
        
        # This topic becomes a cluster representative
        cluster_key = topic
        cluster_members = [topic]
        used.add(topic)
        
        # Find similar topics
        for other_topic in sorted_topics:
            if other_topic in used:
                continue
            
            # Calculate similarity ratio
            similarity = SequenceMatcher(None, topic.lower(), other_topic.lower()).ratio()
            
            # Also check if one topic is contained in the other
            contains = (topic.lower() in other_topic.lower() or 
                       other_topic.lower() in topic.lower())
            
            # If similarity is high or one contains the other, cluster them
            if similarity > 0.7 or contains:
                cluster_members.append(other_topic)
                used.add(other_topic)
        
        clusters[cluster_key] = cluster_members
    
    return clusters


# ============================================================================
# NEW ENDPOINT: GET WEAK TOPICS FOR RECOMMENDATIONS
# ============================================================================
# This endpoint analyzes quiz performance and returns weak topics
# Uses semantic clustering to group similar topics together
# ============================================================================

@app.route('/get_weak_topics', methods=['POST'])
def get_weak_topics():
    """
    Get weak topics for a student based on their quiz performance.
    Uses semantic clustering to group similar topic names.
    
    Expected JSON format:
    {
        "UserID": 123,
        "co_id": 456,
        "threshold": 50  (optional, default 50%)
    }
    
    Returns topics where student's accuracy is below the threshold.
    """
    try:
        data = request.get_json()
        user_id = data.get('UserID')
        co_id = data.get('co_id')
        threshold = data.get('threshold', 50)  # Default: 50% accuracy threshold
        
        # Validate required fields
        if not all([user_id, co_id]):
            return jsonify({'status': 'error', 'message': 'Missing UserID or co_id'}), 400
        
        # Get database connection
        conn = get_connection()
        if not conn:
            return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500
        
        try:
            cursor = conn.cursor()
            
            # Get all quiz results for this user and course
            query = """
            SELECT topic, lecture_num, correct
            FROM quiz_analysis
            WHERE user_id = %s AND co_id = %s
            ORDER BY created_at DESC
            """
            
            cursor.execute(query, (user_id, co_id))
            results = cursor.fetchall()
            
            if not results:
                cursor.close()
                conn.close()
                return jsonify({
                    'status': 'success',
                    'weak_topics': [],
                    'message': 'No quiz data found for this user and course.'
                }), 200
            
            # Organize data by topic
            topic_data = {}
            all_topics = []
            
            for row in results:
                topic = row[0]
                lecture = row[1]
                correct = row[2]
                
                all_topics.append(topic)
                
                if topic not in topic_data:
                    topic_data[topic] = {
                        'lecture': lecture,
                        'correct_count': 0,
                        'total_count': 0
                    }
                
                topic_data[topic]['total_count'] += 1
                if correct == 1:
                    topic_data[topic]['correct_count'] += 1
            
            # ===== CLUSTER SIMILAR TOPICS =====
            topic_clusters = cluster_topics(all_topics)
            
            # Aggregate statistics for clustered topics
            clustered_stats = {}
            for cluster_key, cluster_members in topic_clusters.items():
                total_correct = 0
                total_questions = 0
                lectures = set()
                
                for member in cluster_members:
                    if member in topic_data:
                        total_correct += topic_data[member]['correct_count']
                        total_questions += topic_data[member]['total_count']
                        lectures.add(topic_data[member]['lecture'])
                
                if total_questions > 0:
                    accuracy = (total_correct / total_questions) * 100
                    clustered_stats[cluster_key] = {
                        'lectures': sorted(list(lectures)),
                        'correct_count': total_correct,
                        'total_count': total_questions,
                        'accuracy': round(accuracy, 2),
                        'related_topics': cluster_members  # Show what was grouped
                    }
            
            # Filter weak topics (below threshold)
            weak_topics = []
            for topic, stats in clustered_stats.items():
                if stats['accuracy'] < threshold:
                    weak_topics.append({
                        'topic': topic,
                        'lectures': stats['lectures'],
                        'correct_count': stats['correct_count'],
                        'total_count': stats['total_count'],
                        'accuracy': stats['accuracy'],
                        'related_topics': stats['related_topics']
                    })
            
            # Sort by accuracy (weakest first), then by total questions
            weak_topics.sort(key=lambda x: (x['accuracy'], -x['total_count']))
            
            cursor.close()
            conn.close()
            
            print(f"✅ Weak topics retrieved for user {user_id}, course {co_id}: {len(weak_topics)} topics")
            
            return jsonify({
                'status': 'success',
                'weak_topics': weak_topics,
                'total_weak_topics': len(weak_topics),
                'threshold': threshold
            }), 200
            
        except mysql.connector.Error as err:
            print(f"❌ Database error: {err}")
            traceback.print_exc()
            return jsonify({'status': 'error', 'message': f'Database error: {str(err)}'}), 500
            
    except Exception as e:
        print(f"❌ Unexpected error in get_weak_topics: {e}")
        traceback.print_exc()
        return jsonify({'status': 'error', 'message': f'Server error: {str(e)}'}), 500


# ============================================================================
# OPTIONAL: GET TOPIC PERFORMANCE SUMMARY
# ============================================================================
# Additional endpoint to get overall performance summary by topic
# ============================================================================

@app.route('/get_topic_performance', methods=['POST'])
def get_topic_performance():
    """
    Get overall performance summary for all topics in a course.
    Useful for displaying statistics and progress.
    
    Expected JSON format:
    {
        "UserID": 123,
        "co_id": 456
    }
    """
    try:
        data = request.get_json()
        user_id = data.get('UserID')
        co_id = data.get('co_id')
        
        if not all([user_id, co_id]):
            return jsonify({'status': 'error', 'message': 'Missing UserID or co_id'}), 400
        
        conn = get_connection()
        if not conn:
            return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500
        
        try:
            cursor = conn.cursor()
            
            # Get aggregated performance by topic
            query = """
            SELECT 
                topic,
                COUNT(*) as total_questions,
                SUM(correct) as correct_answers,
                (SUM(correct) / COUNT(*)) * 100 as accuracy,
                GROUP_CONCAT(DISTINCT lecture_num ORDER BY lecture_num) as lectures
            FROM quiz_analysis
            WHERE user_id = %s AND co_id = %s
            GROUP BY topic
            ORDER BY accuracy ASC, total_questions DESC
            """
            
            cursor.execute(query, (user_id, co_id))
            results = cursor.fetchall()
            
            performance_data = []
            for row in results:
                performance_data.append({
                    'topic': row[0],
                    'total_questions': row[1],
                    'correct_answers': row[2],
                    'accuracy': round(row[3], 2),
                    'lectures': row[4].split(',') if row[4] else []
                })
            
            cursor.close()
            conn.close()
            
            return jsonify({
                'status': 'success',
                'performance': performance_data,
                'total_topics': len(performance_data)
            }), 200
            
        except mysql.connector.Error as err:
            print(f"❌ Database error: {err}")
            traceback.print_exc()
            return jsonify({'status': 'error', 'message': f'Database error: {str(err)}'}), 500
            
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        traceback.print_exc()
        return jsonify({'status': 'error', 'message': f'Server error: {str(e)}'}), 500


# ============================================================================
# INTEGRATION NOTES
# ============================================================================
"""
TO INTEGRATE THIS INTO YOUR SERVER:

1. Replace your existing generate_questions() function with the one above

2. Add these three new routes to your Flask app:
   - /save_quiz_analysis  (saves quiz results)
   - /get_weak_topics     (gets recommendations)
   - /get_topic_performance (optional - for statistics)

3. Make sure you have these imports at the top of your server file:
   - from difflib import SequenceMatcher

4. Your Flutter app will call /save_quiz_analysis after each quiz submission

5. Later, you can call /get_weak_topics to get personalized recommendations

EXAMPLE USAGE IN YOUR RECOMMENDATION SYSTEM:
- Student takes quiz → Data saved via /save_quiz_analysis
- Student opens recommendations page → Call /get_weak_topics
- Show topics with low accuracy and suggest review materials
"""
