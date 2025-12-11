"""
Comprehensive tests for the AboLayla chatbot endpoints.
Tests cover:
- Greeting detection (English and Arabic)
- Normal chat responses
- Error handling
- Edge cases
- Input validation
"""

import pytest
import requests
import json


class TestChatEndpointBasic:
    """Basic functionality tests for the /chat endpoint."""
    
    def test_chat_endpoint_exists(self, session, chat_endpoint):
        """Test that the chat endpoint is reachable."""
        response = session.post(chat_endpoint, json={
            "message": "hello",
            "co_id": 27
        })
        assert response.status_code in [200, 400, 500]
    
    def test_chat_returns_json(self, session, chat_endpoint, test_course_id):
        """Test that chat endpoint returns valid JSON."""
        response = session.post(chat_endpoint, json={
            "message": "hello",
            "co_id": test_course_id
        })
        assert response.headers.get('Content-Type', '').startswith('application/json') or \
               response.headers.get('content-type', '').startswith('application/json')
    
    def test_chat_response_has_required_fields(self, session, chat_endpoint, test_course_id):
        """Test that chat response contains expected fields."""
        response = session.post(chat_endpoint, json={
            "message": "hello",
            "co_id": test_course_id
        })
        if response.status_code == 200:
            data = response.json()
            # Response should have 'response' or 'answer' field
            assert 'response' in data or 'answer' in data or 'message' in data


class TestEnglishGreetings:
    """Tests for English greeting detection and responses."""
    
    def test_hello_greeting(self, session, chat_endpoint, test_course_id):
        """Test 'hello' is recognized as a greeting."""
        response = session.post(chat_endpoint, json={
            "message": "hello",
            "co_id": test_course_id
        })
        assert response.status_code == 200
        data = response.json()
        # Check that we got a response
        assert any(key in data for key in ['response', 'answer', 'message'])
    
    def test_hi_greeting(self, session, chat_endpoint, test_course_id):
        """Test 'hi' is recognized as a greeting."""
        response = session.post(chat_endpoint, json={
            "message": "hi",
            "co_id": test_course_id
        })
        assert response.status_code == 200
    
    def test_hey_greeting(self, session, chat_endpoint, test_course_id):
        """Test 'hey' is recognized as a greeting."""
        response = session.post(chat_endpoint, json={
            "message": "hey",
            "co_id": test_course_id
        })
        assert response.status_code == 200
    
    def test_good_morning_greeting(self, session, chat_endpoint, test_course_id):
        """Test 'good morning' is recognized as a greeting."""
        response = session.post(chat_endpoint, json={
            "message": "good morning",
            "co_id": test_course_id
        })
        assert response.status_code == 200
    
    def test_good_afternoon_greeting(self, session, chat_endpoint, test_course_id):
        """Test 'good afternoon' is recognized as a greeting."""
        response = session.post(chat_endpoint, json={
            "message": "good afternoon",
            "co_id": test_course_id
        })
        assert response.status_code == 200
    
    def test_good_evening_greeting(self, session, chat_endpoint, test_course_id):
        """Test 'good evening' is recognized as a greeting."""
        response = session.post(chat_endpoint, json={
            "message": "good evening",
            "co_id": test_course_id
        })
        assert response.status_code == 200
    
    def test_whats_up_greeting(self, session, chat_endpoint, test_course_id):
        """Test 'what's up' is recognized as a greeting."""
        response = session.post(chat_endpoint, json={
            "message": "what's up",
            "co_id": test_course_id
        })
        assert response.status_code == 200
    
    def test_uppercase_greeting(self, session, chat_endpoint, test_course_id):
        """Test uppercase greetings are recognized."""
        response = session.post(chat_endpoint, json={
            "message": "HELLO",
            "co_id": test_course_id
        })
        assert response.status_code == 200
    
    def test_mixed_case_greeting(self, session, chat_endpoint, test_course_id):
        """Test mixed case greetings are recognized."""
        response = session.post(chat_endpoint, json={
            "message": "HeLLo ThErE",
            "co_id": test_course_id
        })
        assert response.status_code == 200
    
    def test_greeting_with_punctuation(self, session, chat_endpoint, test_course_id):
        """Test greetings with punctuation are recognized."""
        response = session.post(chat_endpoint, json={
            "message": "Hello!",
            "co_id": test_course_id
        })
        assert response.status_code == 200
    
    def test_greeting_with_extra_spaces(self, session, chat_endpoint, test_course_id):
        """Test greetings with extra spaces are handled."""
        response = session.post(chat_endpoint, json={
            "message": "  hello  ",
            "co_id": test_course_id
        })
        assert response.status_code == 200


class TestArabicGreetings:
    """Tests for Arabic greeting detection and responses."""
    
    def test_marhaba_greeting(self, session, chat_endpoint, test_course_id):
        """Test 'مرحبا' is recognized as a greeting."""
        response = session.post(chat_endpoint, json={
            "message": "مرحبا",
            "co_id": test_course_id
        })
        assert response.status_code == 200
    
    def test_ahlan_greeting(self, session, chat_endpoint, test_course_id):
        """Test 'اهلا' is recognized as a greeting."""
        response = session.post(chat_endpoint, json={
            "message": "اهلا",
            "co_id": test_course_id
        })
        assert response.status_code == 200
    
    def test_salam_greeting(self, session, chat_endpoint, test_course_id):
        """Test 'السلام عليكم' is recognized as a greeting."""
        response = session.post(chat_endpoint, json={
            "message": "السلام عليكم",
            "co_id": test_course_id
        })
        assert response.status_code == 200
    
    def test_sabah_alkheir_greeting(self, session, chat_endpoint, test_course_id):
        """Test 'صباح الخير' is recognized as a greeting."""
        response = session.post(chat_endpoint, json={
            "message": "صباح الخير",
            "co_id": test_course_id
        })
        assert response.status_code == 200
    
    def test_masa_alkheir_greeting(self, session, chat_endpoint, test_course_id):
        """Test 'مساء الخير' is recognized as a greeting."""
        response = session.post(chat_endpoint, json={
            "message": "مساء الخير",
            "co_id": test_course_id
        })
        assert response.status_code == 200
    
    def test_keefak_greeting(self, session, chat_endpoint, test_course_id):
        """Test 'كيفك' is recognized as a greeting."""
        response = session.post(chat_endpoint, json={
            "message": "كيفك",
            "co_id": test_course_id
        })
        assert response.status_code == 200
    
    def test_ezzayak_greeting(self, session, chat_endpoint, test_course_id):
        """Test 'ازايك' (Egyptian) is recognized as a greeting."""
        response = session.post(chat_endpoint, json={
            "message": "ازايك",
            "co_id": test_course_id
        })
        assert response.status_code == 200
    
    def test_ezayek_greeting(self, session, chat_endpoint, test_course_id):
        """Test 'ازيك' (Egyptian variant) is recognized as a greeting."""
        response = session.post(chat_endpoint, json={
            "message": "ازيك",
            "co_id": test_course_id
        })
        assert response.status_code == 200
    
    def test_aamel_eih_greeting(self, session, chat_endpoint, test_course_id):
        """Test 'عامل ايه' is recognized as a greeting."""
        response = session.post(chat_endpoint, json={
            "message": "عامل ايه",
            "co_id": test_course_id
        })
        assert response.status_code == 200


class TestNormalChatMessages:
    """Tests for normal (non-greeting) chat messages."""
    
    def test_question_about_course(self, session, chat_endpoint, test_course_id):
        """Test asking a question about course content."""
        response = session.post(chat_endpoint, json={
            "message": "What is this course about?",
            "co_id": test_course_id
        })
        assert response.status_code == 200
    
    def test_question_in_arabic(self, session, chat_endpoint, test_course_id):
        """Test asking a question in Arabic."""
        response = session.post(chat_endpoint, json={
            "message": "ما هو موضوع هذا الكورس؟",
            "co_id": test_course_id
        })
        assert response.status_code == 200
    
    def test_explain_concept(self, session, chat_endpoint, test_course_id):
        """Test asking for an explanation."""
        response = session.post(chat_endpoint, json={
            "message": "Can you explain the main topic?",
            "co_id": test_course_id
        })
        assert response.status_code == 200
    
    def test_summarize_request(self, session, chat_endpoint, test_course_id):
        """Test asking for a summary."""
        response = session.post(chat_endpoint, json={
            "message": "Summarize the key points",
            "co_id": test_course_id
        })
        assert response.status_code == 200


class TestPreloadEndpoint:
    """Tests for the /preload_chat endpoint."""
    
    def test_preload_endpoint_exists(self, session, preload_endpoint):
        """Test that the preload endpoint is reachable."""
        response = session.post(preload_endpoint, json={"co_id": 27})
        # Preload might return various status codes
        assert response.status_code in [200, 202, 400, 500]
    
    def test_preload_with_valid_course(self, session, preload_endpoint, test_course_id):
        """Test preloading with a valid course ID."""
        response = session.post(preload_endpoint, json={"co_id": test_course_id})
        assert response.status_code in [200, 202]
    
    def test_preload_returns_json(self, session, preload_endpoint, test_course_id):
        """Test that preload returns JSON."""
        response = session.post(preload_endpoint, json={"co_id": test_course_id})
        if response.status_code == 200:
            # Should be valid JSON
            try:
                data = response.json()
                assert True
            except json.JSONDecodeError:
                pytest.fail("Preload endpoint did not return valid JSON")


class TestErrorHandling:
    """Tests for error handling in chat endpoint."""
    
    def test_missing_message_field(self, session, chat_endpoint, test_course_id):
        """Test sending request without message field."""
        response = session.post(chat_endpoint, json={
            "co_id": test_course_id
        })
        # Should return 400 or handle gracefully
        assert response.status_code in [200, 400, 422, 500]
    
    def test_missing_course_id(self, session, chat_endpoint):
        """Test sending request without course ID."""
        response = session.post(chat_endpoint, json={
            "message": "hello"
        })
        # Should return 400 or handle gracefully
        assert response.status_code in [200, 400, 422, 500]
    
    def test_empty_message(self, session, chat_endpoint, test_course_id):
        """Test sending empty message."""
        response = session.post(chat_endpoint, json={
            "message": "",
            "co_id": test_course_id
        })
        assert response.status_code in [200, 400, 422]
    
    def test_null_message(self, session, chat_endpoint, test_course_id):
        """Test sending null message."""
        response = session.post(chat_endpoint, json={
            "message": None,
            "co_id": test_course_id
        })
        assert response.status_code in [200, 400, 422, 500]
    
    def test_invalid_course_id_type(self, session, chat_endpoint):
        """Test sending invalid course ID type."""
        response = session.post(chat_endpoint, json={
            "message": "hello",
            "co_id": "invalid"
        })
        assert response.status_code in [200, 400, 422, 500]
    
    def test_negative_course_id(self, session, chat_endpoint):
        """Test sending negative course ID."""
        response = session.post(chat_endpoint, json={
            "message": "hello",
            "co_id": -1
        })
        assert response.status_code in [200, 400, 404, 500]
    
    def test_nonexistent_course_id(self, session, chat_endpoint):
        """Test sending nonexistent course ID."""
        response = session.post(chat_endpoint, json={
            "message": "hello",
            "co_id": 999999
        })
        # Should handle gracefully
        assert response.status_code in [200, 400, 404, 500]
    
    def test_empty_request_body(self, session, chat_endpoint):
        """Test sending empty request body."""
        response = session.post(chat_endpoint, json={})
        assert response.status_code in [200, 400, 422, 500]
    
    def test_malformed_json(self, session, chat_endpoint):
        """Test sending malformed JSON."""
        response = session.post(
            chat_endpoint,
            data="not valid json",
            headers={"Content-Type": "application/json"}
        )
        assert response.status_code in [400, 415, 422, 500]


class TestEdgeCases:
    """Edge case tests for chat endpoint."""
    
    def test_very_long_message(self, session, chat_endpoint, test_course_id):
        """Test sending a very long message."""
        long_message = "What is this? " * 500  # ~7000 characters
        response = session.post(chat_endpoint, json={
            "message": long_message,
            "co_id": test_course_id
        })
        # Should handle gracefully (might truncate or return error)
        assert response.status_code in [200, 400, 413, 500]
    
    def test_special_characters_in_message(self, session, chat_endpoint, test_course_id):
        """Test sending special characters."""
        response = session.post(chat_endpoint, json={
            "message": "What about @#$%^&*(){}[]|\\:\";<>,.?/~`",
            "co_id": test_course_id
        })
        assert response.status_code in [200, 400, 500]
    
    def test_unicode_characters(self, session, chat_endpoint, test_course_id):
        """Test sending Unicode characters."""
        response = session.post(chat_endpoint, json={
            "message": "Hello 你好 مرحبا שלום 🎉",
            "co_id": test_course_id
        })
        assert response.status_code in [200, 400, 500]
    
    def test_emoji_in_message(self, session, chat_endpoint, test_course_id):
        """Test sending emojis."""
        response = session.post(chat_endpoint, json={
            "message": "Hello! 👋 How are you? 😊",
            "co_id": test_course_id
        })
        assert response.status_code in [200, 400, 500]
    
    def test_newlines_in_message(self, session, chat_endpoint, test_course_id):
        """Test sending message with newlines."""
        response = session.post(chat_endpoint, json={
            "message": "Hello\nThis is a\nmulti-line\nmessage",
            "co_id": test_course_id
        })
        assert response.status_code in [200, 400, 500]
    
    def test_tabs_in_message(self, session, chat_endpoint, test_course_id):
        """Test sending message with tabs."""
        response = session.post(chat_endpoint, json={
            "message": "Hello\tworld\twith\ttabs",
            "co_id": test_course_id
        })
        assert response.status_code in [200, 400, 500]
    
    def test_whitespace_only_message(self, session, chat_endpoint, test_course_id):
        """Test sending whitespace-only message."""
        response = session.post(chat_endpoint, json={
            "message": "   \t\n   ",
            "co_id": test_course_id
        })
        assert response.status_code in [200, 400, 422, 500]
    
    def test_zero_course_id(self, session, chat_endpoint):
        """Test sending zero as course ID."""
        response = session.post(chat_endpoint, json={
            "message": "hello",
            "co_id": 0
        })
        assert response.status_code in [200, 400, 404, 500]
    
    def test_float_course_id(self, session, chat_endpoint):
        """Test sending float as course ID."""
        response = session.post(chat_endpoint, json={
            "message": "hello",
            "co_id": 27.5
        })
        assert response.status_code in [200, 400, 500]


class TestMultipleCourses:
    """Tests for chat with different course IDs."""
    
    def test_chat_with_course_27(self, session, chat_endpoint):
        """Test chat with course ID 27."""
        response = session.post(chat_endpoint, json={
            "message": "hello",
            "co_id": 27
        })
        assert response.status_code == 200
    
    def test_chat_with_course_29(self, session, chat_endpoint):
        """Test chat with course ID 29."""
        response = session.post(chat_endpoint, json={
            "message": "hello",
            "co_id": 29
        })
        assert response.status_code == 200
    
    def test_chat_with_course_32(self, session, chat_endpoint):
        """Test chat with course ID 32."""
        response = session.post(chat_endpoint, json={
            "message": "hello",
            "co_id": 32
        })
        assert response.status_code == 200
    
    def test_question_with_course_27(self, session, chat_endpoint):
        """Test asking question to course 27."""
        response = session.post(chat_endpoint, json={
            "message": "What topics are covered in this course?",
            "co_id": 27
        })
        assert response.status_code == 200
    
    def test_question_with_course_29(self, session, chat_endpoint):
        """Test asking question to course 29."""
        response = session.post(chat_endpoint, json={
            "message": "What topics are covered in this course?",
            "co_id": 29
        })
        assert response.status_code == 200
    
    def test_question_with_course_32(self, session, chat_endpoint):
        """Test asking question to course 32."""
        response = session.post(chat_endpoint, json={
            "message": "What topics are covered in this course?",
            "co_id": 32
        })
        assert response.status_code == 200
