# 📊 Quiz Analysis API Endpoints for AI Recommendation System

## Overview
These endpoints provide quiz performance data for building a personalized recommendation system that suggests weak topics to students.

---

## 1. Save Quiz Analysis Data
**Endpoint:** `POST /save_quiz_analysis`  
**Server:** `https://alyibrahim.pythonanywhere.com/save_quiz_analysis`  
**Purpose:** Saves detailed quiz results after each quiz submission

### Request Format:
```json
{
  "UserID": 123,
  "co_id": 5,
  "quiz_results": [
    {
      "Lecture": "1",
      "Topic": "Photosynthesis",
      "Correct": 1
    },
    {
      "Lecture": "1",
      "Topic": "Cell Respiration",
      "Correct": 0
    },
    {
      "Lecture": "2",
      "Topic": "Genetics",
      "Correct": 1
    }
  ]
}
```

### Response:
```json
{
  "status": "success",
  "message": "Quiz analysis saved successfully."
}
```

### Data Structure:
- `UserID` (integer): Student's user ID
- `co_id` (integer): Course ID
- `quiz_results` (array): List of question results
  - `Lecture` (string): Lecture number
  - `Topic` (string): Topic name (extracted by OpenAI from PDF content)
  - `Correct` (integer): 1 for correct, 0 for incorrect

### Database Table: `quiz_analysis`
```sql
CREATE TABLE quiz_analysis (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    co_id INT NOT NULL,
    lecture_num VARCHAR(10) NOT NULL,
    topic VARCHAR(255) NOT NULL,
    correct TINYINT(1) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_course (user_id, co_id),
    INDEX idx_topic (topic),
    INDEX idx_correct (correct)
);
```

---

## 2. Get Weak Topics for Recommendations
**Endpoint:** `POST /get_weak_topics`  
**Server:** `https://alyibrahim.pythonanywhere.com/get_weak_topics`  
**Purpose:** Retrieves topics where student performance is below threshold

### Request Format:
```json
{
  "UserID": 123,
  "co_id": 5,
  "threshold": 50
}
```

### Parameters:
- `UserID` (integer, required): Student's user ID
- `co_id` (integer, required): Course ID
- `threshold` (integer, optional): Accuracy threshold percentage (default: 50%)

### Response:
```json
{
  "status": "success",
  "weak_topics": [
    {
      "topic": "Cell Respiration",
      "lectures": ["1", "2"],
      "correct_count": 2,
      "total_count": 8,
      "accuracy": 25.0,
      "related_topics": ["Cell Respiration", "Cellular Respiration"]
    },
    {
      "topic": "Mitosis",
      "lectures": ["3"],
      "correct_count": 0,
      "total_count": 3,
      "accuracy": 0.0,
      "related_topics": ["Mitosis", "Cell Division"]
    }
  ],
  "total_weak_topics": 2,
  "threshold": 50
}
```

### Features:
- **Semantic Topic Clustering**: Similar topics are automatically grouped together
  - Example: "Photosynthesis" + "Photosynthesis Process" → grouped as one
- **Accuracy Calculation**: (correct_count / total_count) * 100
- **Sorted by Weakness**: Lowest accuracy topics appear first

---

## 3. Get Topic Performance Summary (Optional)
**Endpoint:** `POST /get_topic_performance`  
**Server:** `https://alyibrahim.pythonanywhere.com/get_topic_performance`  
**Purpose:** Get overall performance statistics for all topics

### Request Format:
```json
{
  "UserID": 123,
  "co_id": 5
}
```

### Response:
```json
{
  "status": "success",
  "performance": [
    {
      "topic": "Photosynthesis",
      "total_questions": 10,
      "correct_answers": 8,
      "accuracy": 80.0,
      "lectures": ["1", "2"]
    },
    {
      "topic": "Cell Respiration",
      "total_questions": 8,
      "correct_answers": 2,
      "accuracy": 25.0,
      "lectures": ["1", "2"]
    }
  ],
  "total_topics": 2
}
```

---

## Implementation Details

### Topic Extraction
- Topics are extracted by **OpenAI** during quiz generation
- OpenAI analyzes the PDF content and identifies the main concept for each question
- Topics are short phrases (2-5 words): "Photosynthesis", "DNA Replication", "Newton's Laws"

### Topic Clustering Algorithm
The system uses fuzzy string matching to group similar topics:
- **Similarity threshold**: 70%
- **Substring matching**: "Photosynthesis" matches "Photosynthesis Process"
- **Case-insensitive**: "DNA Replication" = "dna replication"

Example clustering:
```
Input topics: 
  - "Photosynthesis"
  - "Photosynthesis Process"  
  - "Cellular Respiration"
  - "Cell Respiration"

Clustered output:
  - "Photosynthesis" (2 questions)
  - "Cellular Respiration" (2 questions)
```

---

## Use Cases for AI Team

### 1. Personalized Study Recommendations
```python
# Get weak topics for a student
weak_topics = get_weak_topics(user_id=123, co_id=5, threshold=50)

# Recommend study materials for weakest topics
for topic in weak_topics[:3]:  # Top 3 weakest
    recommend_lectures(topic['lectures'])
    recommend_practice_questions(topic['topic'])
```

### 2. Adaptive Quiz Generation
```python
# Generate quiz focusing on weak areas
weak_topics = get_weak_topics(user_id=123, co_id=5)
generate_adaptive_quiz(
    topics=[t['topic'] for t in weak_topics],
    difficulty='easy'  # Start easy on weak topics
)
```

### 3. Progress Tracking
```python
# Track improvement over time
performance = get_topic_performance(user_id=123, co_id=5)
visualize_progress(performance)
```

### 4. Early Intervention
```python
# Alert students about struggling topics
weak_topics = get_weak_topics(user_id=123, co_id=5, threshold=30)
if len(weak_topics) > 5:
    send_notification("You're struggling with several topics. Let's review!")
```

---

## Data Flow

```
1. Student takes quiz
   ↓
2. Flutter app sends data to /save_quiz_analysis
   ↓
3. Data stored in quiz_analysis table
   ↓
4. AI system calls /get_weak_topics
   ↓
5. Backend clusters similar topics + calculates accuracy
   ↓
6. AI system receives weak topics list
   ↓
7. Generate personalized recommendations
   ↓
8. Display to student
```

---

## Testing

### Sample cURL Request:
```bash
# Save quiz analysis
curl -X POST https://alyibrahim.pythonanywhere.com/save_quiz_analysis \
  -H "Content-Type: application/json" \
  -d '{
    "UserID": 123,
    "co_id": 5,
    "quiz_results": [
      {"Lecture": "1", "Topic": "Photosynthesis", "Correct": 1},
      {"Lecture": "1", "Topic": "Cell Respiration", "Correct": 0}
    ]
  }'

# Get weak topics
curl -X POST https://alyibrahim.pythonanywhere.com/get_weak_topics \
  -H "Content-Type: application/json" \
  -d '{
    "UserID": 123,
    "co_id": 5,
    "threshold": 50
  }'
```

---

## Notes for AI Team

1. **Topic Consistency**: Topics may have slight variations (e.g., "Photosynthesis" vs "Photosynthesis Process"). The clustering algorithm handles this automatically.

2. **Minimum Data**: Recommendation accuracy improves with more quiz attempts. Consider requiring at least 3 quiz submissions before showing recommendations.

3. **Threshold Tuning**: The default 50% threshold can be adjusted per use case:
   - 30% for critical intervention
   - 50% for general recommendations
   - 70% for advanced optimization

4. **Real-time Updates**: Data is saved immediately after quiz submission. No batch processing needed.

5. **Privacy**: All data is user-specific. Implement proper authentication when calling these endpoints.

---

## Contact
- Backend Team: [Your team contact]
- Server Location: PythonAnywhere
- Implementation File: `quiz_analysis_system.py`
