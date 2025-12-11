# AboLayla & Quiz Generator Test Suite

Comprehensive test suite for the AboLayla chatbot and Quiz Generator API endpoints.

## Overview

This test suite runs **locally** against the remote PythonAnywhere server. No installation required on the server.

**Server URL:** `https://alyibrahim.pythonanywhere.com`

**Test Course IDs:** 27, 29, 32

## Test Structure

```
server_tests/
├── conftest.py              # Shared fixtures and configuration
├── test_abolayla_chat.py    # AboLayla chatbot tests (60+ tests)
├── test_quiz_generator.py   # Quiz Generator tests (60+ tests)
├── test_performance.py      # Performance and load tests (20+ tests)
├── test_security.py         # Security tests (50+ tests)
├── requirements.txt         # Python dependencies
└── README.md                # This file
```

## Installation

```bash
cd server_tests
pip install -r requirements.txt
```

## Running Tests

### Run All Tests
```bash
pytest -v
```

### Run Specific Test File
```bash
pytest test_abolayla_chat.py -v
pytest test_quiz_generator.py -v
pytest test_performance.py -v
pytest test_security.py -v
```

### Run Specific Test Class
```bash
pytest test_abolayla_chat.py::TestEnglishGreetings -v
pytest test_quiz_generator.py::TestLectureSelection -v
```

### Run Specific Test
```bash
pytest test_abolayla_chat.py::TestEnglishGreetings::test_hello_greeting -v
```

### Run Tests in Parallel (Faster)
```bash
pytest -n 4 -v  # Run with 4 workers
```

### Generate HTML Report
```bash
pytest --html=report.html --self-contained-html
```

### Run with Verbose Output
```bash
pytest -v -s  # -s shows print statements
```

## Test Categories

### 1. AboLayla Chat Tests (`test_abolayla_chat.py`)
- **Basic Functionality:** Endpoint existence, JSON responses, response structure
- **English Greetings:** hello, hi, hey, good morning, etc.
- **Arabic Greetings:** مرحبا, اهلا, السلام عليكم, صباح الخير, etc.
- **Normal Chat:** Questions, explanations, summaries
- **Preload Endpoint:** Cache warming functionality
- **Error Handling:** Missing fields, invalid data, malformed requests
- **Edge Cases:** Long messages, special characters, Unicode, emojis
- **Multiple Courses:** Testing with course IDs 27, 29, 32

### 2. Quiz Generator Tests (`test_quiz_generator.py`)
- **MCQ Generation:** Various question counts
- **True/False Generation:** Different naming conventions
- **Short Answer Generation:** Open-ended questions
- **Difficulty Levels:** Easy, medium, hard
- **Lecture Selection:** Single, multiple, non-consecutive, duplicates
- **Question Count Validation:** Min, max, invalid counts
- **Course ID Validation:** Valid, invalid, edge cases
- **Doctor Quiz Endpoint:** Separate endpoint testing
- **Error Handling:** Missing fields, invalid types
- **Legacy Support:** from_lecture/to_lecture format

### 3. Performance Tests (`test_performance.py`)
- **Greeting Speed:** Target <100ms for instant responses
- **Response Time Comparison:** Greetings vs. AI-generated
- **Preload Performance:** Cache warming speed
- **Quiz Generation Time:** Small, medium, large quizzes
- **Concurrent Requests:** Parallel request handling
- **Load Testing:** Sequential request performance
- **Connection Handling:** Session reuse benefits
- **Timeout Testing:** Reasonable timeout thresholds

### 4. Security Tests (`test_security.py`)
- **SQL Injection:** DROP TABLE, UNION SELECT, boolean-based, time-based
- **XSS Prevention:** Script tags, img onerror, svg onload
- **Prompt Injection:** Jailbreaks, role reversal, system overrides
- **Input Validation:** Null bytes, Unicode overflow, control characters
- **Data Sanitization:** HTML entities, JSON injection
- **Authentication Bypass:** Unauthorized course access attempts
- **Header Security:** Content-Type, server version disclosure
- **Rate Limiting:** Rapid request behavior

## Configuration

Edit `conftest.py` to change:

```python
# Server URL
BASE_URL = "https://alyibrahim.pythonanywhere.com"

# Test course IDs
TEST_COURSE_IDS = [27, 29, 32]
DEFAULT_COURSE_ID = 27
```

## Expected Results

- **Total Tests:** ~190 tests
- **Expected Pass Rate:** 100% for properly functioning server
- **Performance Targets:**
  - Greeting responses: <500ms (including network latency)
  - Quiz generation: <60s for 10 questions
  - Preload: <5s per course

## Troubleshooting

### Tests Timing Out
```bash
pytest --timeout=120  # Increase timeout to 120 seconds
```

### Connection Errors
- Check internet connectivity
- Verify server is running: https://alyibrahim.pythonanywhere.com
- Check if PythonAnywhere is having issues

### Rate Limiting (429 Errors)
- Add delays between tests:
```bash
pytest --timeout=5 -v  # Slower execution
```

## Continuous Integration

Add to your CI pipeline:

```yaml
- name: Run API Tests
  run: |
    cd server_tests
    pip install -r requirements.txt
    pytest --html=report.html --self-contained-html
  
- name: Upload Test Report
  uses: actions/upload-artifact@v3
  with:
    name: test-report
    path: server_tests/report.html
```

## Adding New Tests

1. Add fixtures to `conftest.py` if needed
2. Create new test class in appropriate file
3. Follow naming convention: `test_<description>`
4. Use fixtures from conftest for common data

Example:
```python
class TestNewFeature:
    def test_new_functionality(self, session, chat_endpoint, test_course_id):
        response = session.post(chat_endpoint, json={
            "message": "test message",
            "co_id": test_course_id
        })
        assert response.status_code == 200
```
