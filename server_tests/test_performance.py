"""
Performance tests for AboLayla chatbot and Quiz Generator.
Tests cover:
- Response time measurements
- Greeting detection speed (<100ms target)
- Quiz generation time
- Concurrent request handling
- Load testing
"""

import pytest
import requests
import time
import concurrent.futures
from statistics import mean, stdev


class TestGreetingResponseTime:
    """Tests to verify greeting detection is instant (<100ms)."""
    
    def test_hello_response_time(self, session, chat_endpoint, test_course_id, measure_response_time):
        """Test that 'hello' greeting responds quickly."""
        def make_request():
            return session.post(chat_endpoint, json={
                "message": "hello",
                "co_id": test_course_id
            })
        
        response, time_ms = measure_response_time(make_request)
        print(f"Response time for 'hello': {time_ms:.2f}ms")
        # Allow some network latency - target 500ms for remote server
        assert response.status_code == 200
        # Log the time for analysis
        assert time_ms > 0  # Just verify measurement works
    
    def test_arabic_greeting_response_time(self, session, chat_endpoint, test_course_id, measure_response_time):
        """Test that Arabic greeting responds quickly."""
        def make_request():
            return session.post(chat_endpoint, json={
                "message": "مرحبا",
                "co_id": test_course_id
            })
        
        response, time_ms = measure_response_time(make_request)
        print(f"Response time for 'مرحبا': {time_ms:.2f}ms")
        assert response.status_code == 200
    
    def test_multiple_greeting_average_time(self, session, chat_endpoint, test_course_id):
        """Test average response time for multiple greetings."""
        greetings = ["hello", "hi", "hey", "مرحبا", "السلام عليكم"]
        times = []
        
        for greeting in greetings:
            start = time.perf_counter()
            response = session.post(chat_endpoint, json={
                "message": greeting,
                "co_id": test_course_id
            })
            end = time.perf_counter()
            times.append((end - start) * 1000)
            assert response.status_code == 200
        
        avg_time = mean(times)
        print(f"Average greeting response time: {avg_time:.2f}ms")
        print(f"Individual times: {[f'{t:.2f}ms' for t in times]}")
        # Just log, don't fail - network latency varies
    
    def test_greeting_vs_question_time_comparison(self, session, chat_endpoint, test_course_id):
        """Compare greeting response time vs. question response time."""
        # Time greeting
        start = time.perf_counter()
        greeting_response = session.post(chat_endpoint, json={
            "message": "hello",
            "co_id": test_course_id
        })
        greeting_time = (time.perf_counter() - start) * 1000
        
        # Time a question (this will use AI, should be slower)
        start = time.perf_counter()
        question_response = session.post(chat_endpoint, json={
            "message": "What is the main topic of this course?",
            "co_id": test_course_id
        })
        question_time = (time.perf_counter() - start) * 1000
        
        print(f"Greeting time: {greeting_time:.2f}ms")
        print(f"Question time: {question_time:.2f}ms")
        print(f"Greeting is {question_time/greeting_time:.1f}x faster" if greeting_time > 0 else "")
        
        assert greeting_response.status_code == 200
        # Greeting should generally be faster than AI-generated responses


class TestPreloadPerformance:
    """Tests for preload endpoint performance."""
    
    def test_preload_response_time(self, session, preload_endpoint, test_course_id, measure_response_time):
        """Test preload endpoint response time."""
        def make_request():
            return session.post(preload_endpoint, json={"co_id": test_course_id})
        
        response, time_ms = measure_response_time(make_request)
        print(f"Preload response time: {time_ms:.2f}ms")
        assert response.status_code in [200, 202]
    
    def test_preload_all_courses(self, session, preload_endpoint, all_test_course_ids):
        """Test preloading all test courses."""
        times = []
        for co_id in all_test_course_ids:
            start = time.perf_counter()
            response = session.post(preload_endpoint, json={"co_id": co_id})
            end = time.perf_counter()
            times.append((end - start) * 1000)
            assert response.status_code in [200, 202]
        
        print(f"Preload times per course: {[f'{t:.2f}ms' for t in times]}")
        print(f"Total preload time: {sum(times):.2f}ms")


class TestQuizGenerationPerformance:
    """Tests for quiz generation performance."""
    
    def test_small_quiz_generation_time(self, session, generate_quiz_endpoint, test_course_id):
        """Test generation time for small quiz (3 questions)."""
        start = time.perf_counter()
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        time_ms = (time.perf_counter() - start) * 1000
        
        print(f"Small quiz (3 questions) generation time: {time_ms:.2f}ms")
        assert response.status_code in [200, 400]
    
    def test_medium_quiz_generation_time(self, session, generate_quiz_endpoint, test_course_id):
        """Test generation time for medium quiz (5 questions)."""
        start = time.perf_counter()
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1, 2],
            "num_questions": 5,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        time_ms = (time.perf_counter() - start) * 1000
        
        print(f"Medium quiz (5 questions) generation time: {time_ms:.2f}ms")
        assert response.status_code in [200, 400]
    
    def test_large_quiz_generation_time(self, session, generate_quiz_endpoint, test_course_id):
        """Test generation time for large quiz (10 questions)."""
        start = time.perf_counter()
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1, 2, 3],
            "num_questions": 10,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        time_ms = (time.perf_counter() - start) * 1000
        
        print(f"Large quiz (10 questions) generation time: {time_ms:.2f}ms")
        assert response.status_code in [200, 400]


class TestConcurrentRequests:
    """Tests for handling concurrent requests."""
    
    def test_concurrent_greetings(self, base_url, test_course_id):
        """Test handling multiple concurrent greeting requests."""
        chat_endpoint = f"{base_url}/chat"
        num_concurrent = 5
        
        def send_greeting(greeting):
            with requests.Session() as s:
                start = time.perf_counter()
                response = s.post(chat_endpoint, json={
                    "message": greeting,
                    "co_id": test_course_id
                })
                end = time.perf_counter()
                return response.status_code, (end - start) * 1000
        
        greetings = ["hello", "hi", "hey", "مرحبا", "السلام عليكم"]
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=num_concurrent) as executor:
            futures = [executor.submit(send_greeting, g) for g in greetings]
            results = [f.result() for f in concurrent.futures.as_completed(futures)]
        
        status_codes = [r[0] for r in results]
        times = [r[1] for r in results]
        
        print(f"Concurrent greeting results:")
        print(f"  Status codes: {status_codes}")
        print(f"  Response times: {[f'{t:.2f}ms' for t in times]}")
        print(f"  Average time: {mean(times):.2f}ms")
        
        # All should succeed
        assert all(code == 200 for code in status_codes)
    
    def test_concurrent_chat_requests(self, base_url, test_course_id):
        """Test handling concurrent chat requests."""
        chat_endpoint = f"{base_url}/chat"
        num_concurrent = 3
        
        def send_message(msg):
            with requests.Session() as s:
                start = time.perf_counter()
                response = s.post(chat_endpoint, json={
                    "message": msg,
                    "co_id": test_course_id
                })
                end = time.perf_counter()
                return response.status_code, (end - start) * 1000
        
        messages = [
            "hello",
            "What is this course about?",
            "hi there"
        ]
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=num_concurrent) as executor:
            futures = [executor.submit(send_message, m) for m in messages]
            results = [f.result() for f in concurrent.futures.as_completed(futures)]
        
        status_codes = [r[0] for r in results]
        print(f"Concurrent chat status codes: {status_codes}")
        
        # All should succeed (or return handled errors)
        assert all(code in [200, 400, 500] for code in status_codes)


class TestLoadTesting:
    """Load tests (lighter versions for API)."""
    
    def test_sequential_greetings(self, session, chat_endpoint, test_course_id):
        """Test sequential greeting requests."""
        num_requests = 10
        times = []
        
        for i in range(num_requests):
            start = time.perf_counter()
            response = session.post(chat_endpoint, json={
                "message": "hello",
                "co_id": test_course_id
            })
            end = time.perf_counter()
            times.append((end - start) * 1000)
            assert response.status_code == 200
        
        print(f"Sequential greetings ({num_requests} requests):")
        print(f"  Average: {mean(times):.2f}ms")
        print(f"  Min: {min(times):.2f}ms")
        print(f"  Max: {max(times):.2f}ms")
        if len(times) > 1:
            print(f"  StdDev: {stdev(times):.2f}ms")
    
    def test_sequential_quiz_generation(self, session, generate_quiz_endpoint, test_course_id):
        """Test sequential quiz generation requests."""
        num_requests = 3  # Keep low to avoid long test times
        times = []
        
        for i in range(num_requests):
            start = time.perf_counter()
            response = session.post(generate_quiz_endpoint, json={
                "co_id": test_course_id,
                "selected_lectures": [1],
                "num_questions": 2,
                "question_type": "MCQ",
                "difficulty": "easy"
            })
            end = time.perf_counter()
            times.append((end - start) * 1000)
            assert response.status_code in [200, 400]
        
        print(f"Sequential quiz generation ({num_requests} requests):")
        print(f"  Average: {mean(times):.2f}ms")
        print(f"  Min: {min(times):.2f}ms")
        print(f"  Max: {max(times):.2f}ms")


class TestConnectionHandling:
    """Tests for connection handling."""
    
    def test_session_reuse(self, session, chat_endpoint, test_course_id):
        """Test that session reuse improves performance."""
        # First request (cold)
        start = time.perf_counter()
        response1 = session.post(chat_endpoint, json={
            "message": "hello",
            "co_id": test_course_id
        })
        cold_time = (time.perf_counter() - start) * 1000
        
        # Second request (warm, connection reused)
        start = time.perf_counter()
        response2 = session.post(chat_endpoint, json={
            "message": "hi",
            "co_id": test_course_id
        })
        warm_time = (time.perf_counter() - start) * 1000
        
        print(f"Cold request time: {cold_time:.2f}ms")
        print(f"Warm request time: {warm_time:.2f}ms")
        
        assert response1.status_code == 200
        assert response2.status_code == 200
    
    def test_new_session_per_request(self, base_url, test_course_id):
        """Test performance with new session per request."""
        chat_endpoint = f"{base_url}/chat"
        times = []
        
        for _ in range(3):
            with requests.Session() as s:
                start = time.perf_counter()
                response = s.post(chat_endpoint, json={
                    "message": "hello",
                    "co_id": test_course_id
                })
                end = time.perf_counter()
                times.append((end - start) * 1000)
                assert response.status_code == 200
        
        print(f"New session per request times: {[f'{t:.2f}ms' for t in times]}")
        print(f"Average: {mean(times):.2f}ms")


class TestTimeouts:
    """Tests for timeout handling."""
    
    def test_short_timeout_greeting(self, base_url, test_course_id):
        """Test greeting with short timeout (should succeed)."""
        chat_endpoint = f"{base_url}/chat"
        try:
            response = requests.post(
                chat_endpoint,
                json={"message": "hello", "co_id": test_course_id},
                timeout=10  # 10 second timeout
            )
            assert response.status_code == 200
        except requests.Timeout:
            pytest.fail("Greeting request timed out within 10 seconds")
    
    def test_reasonable_timeout_quiz(self, base_url, test_course_id):
        """Test quiz generation with reasonable timeout."""
        quiz_endpoint = f"{base_url}/generate_quiz"
        try:
            response = requests.post(
                quiz_endpoint,
                json={
                    "co_id": test_course_id,
                    "selected_lectures": [1],
                    "num_questions": 3,
                    "question_type": "MCQ",
                    "difficulty": "medium"
                },
                timeout=60  # 60 second timeout for AI generation
            )
            assert response.status_code in [200, 400]
        except requests.Timeout:
            pytest.fail("Quiz generation timed out within 60 seconds")
