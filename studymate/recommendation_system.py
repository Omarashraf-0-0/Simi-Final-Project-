import requests
from flask import Flask, jsonify, request

app = Flask(__name__)

# --- Configuration ---
EXTERNAL_API_URL = "https://alyibrahim.pythonanywhere.com/get_weak_topics"

# --- Main Route ---

@app.route('/Recommendation', methods=['POST']) 
def Recommendation_system():
    try:
        # 1. Get User Details from Request
        # The client must send UserID and co_id so we can query the external API
        req_data = request.get_json()
        
        if not req_data or 'UserID' not in req_data or 'co_id' not in req_data:
            return jsonify({'error': 'Missing UserID or co_id'}), 400

        user_id = req_data['UserID']
        co_id = req_data['co_id']
        threshold = req_data.get('threshold', 50) # Default to 50 if not sent

        # 2. Connect to External API
        # We ask the external database for the weak topics directly
        payload = {
            "UserID": user_id,
            "co_id": co_id,
            "threshold": threshold
        }
        
        try:
            external_response = requests.post(EXTERNAL_API_URL, json=payload)
            external_response.raise_for_status() # Raise error for bad status codes
            api_data = external_response.json()
        except requests.exceptions.RequestException as e:
            return jsonify({'error': f"Failed to connect to data source: {str(e)}"}), 502

        # 3. Process External Data
        # The external API already calculates accuracy, so we just format the output
        weak_topics = api_data.get('weak_topics', [])
        response_list = []

        for item in weak_topics:
            topic = item['topic']
            accuracy = item['accuracy']
            lectures = item['lectures'] # This is a list like ["1", "2"]
            
            # Join lectures into a string if there are multiple (e.g., "1 & 2")
            lecture_str = " & ".join(lectures)

            # Generate the recommendation message
            # Note: The external API gives accuracy as 0-100, not 0.0-1.0
            message = (
                f"Weak Point: '{topic}' in Lecture(s) {lecture_str} (Accuracy: {accuracy}%). "
                f"Action: Please review the lecture slides for {topic}."
            )
            
            response_list.append({
                'lecture': lecture_str,
                'topic': topic,
                'accuracy': accuracy / 100.0, # Convert back to decimal for consistency
                'accuracy_formatted': f"{accuracy}%",
                'recommendation': message
            })

        # 4. Return Final JSON
        return jsonify({
            'source': 'External API',
            'count': len(response_list),
            'recommendations': response_list
        }), 200

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)