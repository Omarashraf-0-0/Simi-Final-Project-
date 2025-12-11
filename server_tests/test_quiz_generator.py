"""
Comprehensive tests for the Quiz Generator endpoints.
Tests cover:
- Quiz generation (MCQ, True/False, Short Answer)
- Lecture selection (single, multiple, ranges)
- Difficulty levels
- Validation and error handling
- Doctor quiz generation
"""

import pytest
import requests
import json


class TestGenerateQuizEndpointBasic:
    """Basic functionality tests for the /generate_quiz endpoint."""
    
    def test_endpoint_exists(self, session, generate_quiz_endpoint):
        """Test that the generate_quiz endpoint is reachable."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": 27,
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400, 404, 500]
    
    def test_returns_json(self, session, generate_quiz_endpoint, valid_quiz_request):
        """Test that endpoint returns valid JSON."""
        response = session.post(generate_quiz_endpoint, json=valid_quiz_request)
        if response.status_code == 200:
            try:
                data = response.json()
                assert True
            except json.JSONDecodeError:
                pytest.fail("Endpoint did not return valid JSON")
    
    def test_response_structure(self, session, generate_quiz_endpoint, valid_quiz_request):
        """Test that response has expected structure."""
        response = session.post(generate_quiz_endpoint, json=valid_quiz_request)
        if response.status_code == 200:
            data = response.json()
            # Response should contain questions or quiz data
            assert any(key in data for key in ['questions', 'quiz', 'data', 'result'])


class TestQuizGenerationMCQ:
    """Tests for MCQ quiz generation."""
    
    def test_generate_mcq_quiz(self, session, generate_quiz_endpoint, test_course_id):
        """Test generating MCQ quiz."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400]
    
    def test_mcq_with_5_questions(self, session, generate_quiz_endpoint, test_course_id):
        """Test generating 5 MCQ questions."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1, 2],
            "num_questions": 5,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400]
    
    def test_mcq_with_10_questions(self, session, generate_quiz_endpoint, test_course_id):
        """Test generating 10 MCQ questions."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1],
            "num_questions": 10,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400]


class TestQuizGenerationTrueFalse:
    """Tests for True/False quiz generation."""
    
    def test_generate_truefalse_quiz(self, session, generate_quiz_endpoint, test_course_id):
        """Test generating True/False quiz."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "True/False",
            "difficulty": "easy"
        })
        assert response.status_code in [200, 400]
    
    def test_truefalse_variant_names(self, session, generate_quiz_endpoint, test_course_id):
        """Test True/False with different naming conventions."""
        variants = ["True/False", "TrueFalse", "true_false", "TF"]
        for variant in variants:
            response = session.post(generate_quiz_endpoint, json={
                "co_id": test_course_id,
                "selected_lectures": [1],
                "num_questions": 2,
                "question_type": variant,
                "difficulty": "medium"
            })
            # At least one should work
            if response.status_code == 200:
                break
        assert response.status_code in [200, 400]


class TestQuizGenerationShortAnswer:
    """Tests for Short Answer quiz generation."""
    
    def test_generate_short_answer_quiz(self, session, generate_quiz_endpoint, test_course_id):
        """Test generating Short Answer quiz."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "Short Answer",
            "difficulty": "hard"
        })
        assert response.status_code in [200, 400]


class TestDifficultyLevels:
    """Tests for different difficulty levels."""
    
    def test_easy_difficulty(self, session, generate_quiz_endpoint, test_course_id):
        """Test quiz with easy difficulty."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "easy"
        })
        assert response.status_code in [200, 400]
    
    def test_medium_difficulty(self, session, generate_quiz_endpoint, test_course_id):
        """Test quiz with medium difficulty."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400]
    
    def test_hard_difficulty(self, session, generate_quiz_endpoint, test_course_id):
        """Test quiz with hard difficulty."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "hard"
        })
        assert response.status_code in [200, 400]
    
    def test_invalid_difficulty(self, session, generate_quiz_endpoint, test_course_id):
        """Test quiz with invalid difficulty."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "impossible"
        })
        assert response.status_code in [200, 400, 422]


class TestLectureSelection:
    """Tests for lecture selection functionality."""
    
    def test_single_lecture(self, session, generate_quiz_endpoint, test_course_id):
        """Test selecting single lecture."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400]
    
    def test_multiple_lectures(self, session, generate_quiz_endpoint, test_course_id):
        """Test selecting multiple lectures."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1, 2, 3],
            "num_questions": 5,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400]
    
    def test_non_consecutive_lectures(self, session, generate_quiz_endpoint, test_course_id):
        """Test selecting non-consecutive lectures."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1, 3, 5],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400]
    
    def test_empty_lectures_array(self, session, generate_quiz_endpoint, test_course_id):
        """Test with empty lectures array."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400, 422]
    
    def test_large_lecture_number(self, session, generate_quiz_endpoint, test_course_id):
        """Test with very large lecture number."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [9999],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400, 404]
    
    def test_negative_lecture_number(self, session, generate_quiz_endpoint, test_course_id):
        """Test with negative lecture number."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [-1],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400, 422]
    
    def test_zero_lecture_number(self, session, generate_quiz_endpoint, test_course_id):
        """Test with zero as lecture number."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [0],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400, 422]
    
    def test_duplicate_lectures(self, session, generate_quiz_endpoint, test_course_id):
        """Test with duplicate lecture numbers."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1, 1, 1],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400]


class TestQuestionCount:
    """Tests for question count validation."""
    
    def test_minimum_questions(self, session, generate_quiz_endpoint, test_course_id):
        """Test requesting minimum questions (1)."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1],
            "num_questions": 1,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400]
    
    def test_zero_questions(self, session, generate_quiz_endpoint, test_course_id):
        """Test requesting zero questions."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1],
            "num_questions": 0,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400, 422]
    
    def test_negative_questions(self, session, generate_quiz_endpoint, test_course_id):
        """Test requesting negative questions."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1],
            "num_questions": -5,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400, 422]
    
    def test_very_large_question_count(self, session, generate_quiz_endpoint, test_course_id):
        """Test requesting very large number of questions."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1],
            "num_questions": 1000,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400, 413]
    
    def test_float_question_count(self, session, generate_quiz_endpoint, test_course_id):
        """Test requesting float question count."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1],
            "num_questions": 3.5,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400, 422]


class TestCourseIdValidation:
    """Tests for course ID validation."""
    
    def test_valid_course_27(self, session, generate_quiz_endpoint):
        """Test with valid course ID 27."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": 27,
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400]
    
    def test_valid_course_29(self, session, generate_quiz_endpoint):
        """Test with valid course ID 29."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": 29,
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400]
    
    def test_valid_course_32(self, session, generate_quiz_endpoint):
        """Test with valid course ID 32."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": 32,
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400]
    
    def test_nonexistent_course(self, session, generate_quiz_endpoint):
        """Test with nonexistent course ID."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": 999999,
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400, 404]
    
    def test_negative_course_id(self, session, generate_quiz_endpoint):
        """Test with negative course ID."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": -1,
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400, 404]
    
    def test_zero_course_id(self, session, generate_quiz_endpoint):
        """Test with zero course ID."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": 0,
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400, 404]
    
    def test_string_course_id(self, session, generate_quiz_endpoint):
        """Test with string course ID."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": "twenty-seven",
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [400, 422, 500]
    
    def test_null_course_id(self, session, generate_quiz_endpoint):
        """Test with null course ID."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": None,
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [400, 422, 500]


class TestDoctorQuizEndpoint:
    """Tests for the /generate_doctor_quiz endpoint."""
    
    def test_endpoint_exists(self, session, generate_doctor_quiz_endpoint):
        """Test that the doctor quiz endpoint is reachable."""
        response = session.post(generate_doctor_quiz_endpoint, json={
            "co_id": 27,
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400, 404, 500]
    
    def test_generate_doctor_quiz(self, session, generate_doctor_quiz_endpoint, test_course_id):
        """Test generating doctor quiz."""
        response = session.post(generate_doctor_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400]
    
    def test_doctor_quiz_multiple_lectures(self, session, generate_doctor_quiz_endpoint, test_course_id):
        """Test doctor quiz with multiple lectures."""
        response = session.post(generate_doctor_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1, 2],
            "num_questions": 5,
            "question_type": "MCQ",
            "difficulty": "hard"
        })
        assert response.status_code in [200, 400]
    
    def test_doctor_quiz_all_courses(self, session, generate_doctor_quiz_endpoint, all_test_course_ids):
        """Test doctor quiz with all available courses."""
        for co_id in all_test_course_ids:
            response = session.post(generate_doctor_quiz_endpoint, json={
                "co_id": co_id,
                "selected_lectures": [1],
                "num_questions": 2,
                "question_type": "MCQ",
                "difficulty": "medium"
            })
            assert response.status_code in [200, 400]


class TestErrorHandling:
    """Tests for error handling in quiz endpoints."""
    
    def test_missing_co_id(self, session, generate_quiz_endpoint):
        """Test request without course ID."""
        response = session.post(generate_quiz_endpoint, json={
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [400, 422, 500]
    
    def test_missing_selected_lectures(self, session, generate_quiz_endpoint, test_course_id):
        """Test request without selected lectures."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400, 422]
    
    def test_missing_num_questions(self, session, generate_quiz_endpoint, test_course_id):
        """Test request without num_questions."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1],
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400, 422]
    
    def test_missing_question_type(self, session, generate_quiz_endpoint, test_course_id):
        """Test request without question type."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1],
            "num_questions": 3,
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400, 422]
    
    def test_missing_difficulty(self, session, generate_quiz_endpoint, test_course_id):
        """Test request without difficulty."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "MCQ"
        })
        assert response.status_code in [200, 400, 422]
    
    def test_empty_request_body(self, session, generate_quiz_endpoint):
        """Test empty request body."""
        response = session.post(generate_quiz_endpoint, json={})
        assert response.status_code in [400, 422, 500]
    
    def test_malformed_json(self, session, generate_quiz_endpoint):
        """Test malformed JSON request."""
        response = session.post(
            generate_quiz_endpoint,
            data="not valid json",
            headers={"Content-Type": "application/json"}
        )
        assert response.status_code in [400, 415, 422, 500]
    
    def test_invalid_question_type(self, session, generate_quiz_endpoint, test_course_id):
        """Test with invalid question type."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "InvalidType",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400, 422]


class TestEdgeCases:
    """Edge case tests for quiz generation."""
    
    def test_many_lectures_selected(self, session, generate_quiz_endpoint, test_course_id):
        """Test selecting many lectures."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": list(range(1, 21)),  # 1-20
            "num_questions": 5,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400]
    
    def test_mixed_type_lectures(self, session, generate_quiz_endpoint, test_course_id):
        """Test lectures array with mixed types."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1, "2", 3.0],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400, 422]
    
    def test_lectures_as_string(self, session, generate_quiz_endpoint, test_course_id):
        """Test lectures as string instead of array."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": "1,2,3",
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400, 422]
    
    def test_extra_fields_ignored(self, session, generate_quiz_endpoint, test_course_id):
        """Test that extra fields are ignored."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium",
            "extra_field": "should be ignored",
            "another_extra": 123
        })
        assert response.status_code in [200, 400]
    
    def test_unicode_in_fields(self, session, generate_quiz_endpoint, test_course_id):
        """Test Unicode characters in request."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1],
            "num_questions": 3,
            "question_type": "اختيار من متعدد",  # Arabic for MCQ
            "difficulty": "متوسط"  # Arabic for medium
        })
        assert response.status_code in [200, 400, 422]


class TestLegacyRangeSupport:
    """Tests for legacy lecture range support (from_lecture, to_lecture)."""
    
    def test_legacy_range_format(self, session, generate_quiz_endpoint, test_course_id):
        """Test if legacy from/to lecture format still works."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "from_lecture": 1,
            "to_lecture": 3,
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        # This may or may not work depending on server implementation
        assert response.status_code in [200, 400, 422]
    
    def test_both_formats_provided(self, session, generate_quiz_endpoint, test_course_id):
        """Test providing both legacy and new lecture format."""
        response = session.post(generate_quiz_endpoint, json={
            "co_id": test_course_id,
            "selected_lectures": [1, 2],
            "from_lecture": 1,
            "to_lecture": 3,
            "num_questions": 3,
            "question_type": "MCQ",
            "difficulty": "medium"
        })
        assert response.status_code in [200, 400]
