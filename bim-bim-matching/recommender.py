from typing import List, Dict, Optional

import numpy as np
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import StandardScaler

from config import TEXT_EMBEDDING_MODEL
from models import UserMatchingRequest, MatchingRequest, MatchingResponse, QuestionMatchingRequest


class DynamicRecommendationSystem:
    def __init__(self):
        print("Initializing Dynamic Recommendation System...")
        print(f"Loading text embedding model: {TEXT_EMBEDDING_MODEL}...")
        self.text_embedder = SentenceTransformer(TEXT_EMBEDDING_MODEL)
        self.text_embedding_dim = self.text_embedder.get_sentence_embedding_dimension()
        print(f"Text embedding dimension: {self.text_embedding_dim}")
        self.scaler = StandardScaler()
        print("Dynamic Recommendation System Initialized.")

    def _get_ordered_question_ids(self, questions: List[QuestionMatchingRequest]) -> List[int]:
        """Возвращает упорядоченный список ID вопросов из запроса."""
        return [q.id for q in questions]

    def _get_ternary_vector(self,
                            user_answers: Dict[int, int],
                            ordered_question_ids: List[int]) -> np.ndarray:
        """
        Создает тернарный вектор на основе ответов пользователя и упорядоченного списка ID вопросов.
        """
        num_questions = len(ordered_question_ids)
        vector = np.zeros(num_questions)

        question_id_to_idx = {qid: i for i, qid in enumerate(ordered_question_ids)}

        for question_id, answer_val in user_answers.items():
            if question_id in question_id_to_idx:
                idx = question_id_to_idx[question_id]
                vector[idx] = answer_val
        return vector

    def _get_text_embedding(self, description: str) -> np.ndarray:
        if not description:
            return np.zeros(self.text_embedding_dim)
        return self.text_embedder.encode(description)

    def _create_combined_feature_vector(self,
                                        user_profile: UserMatchingRequest,
                                        ordered_question_ids: List[int]) -> np.ndarray:
        ternary_vec = self._get_ternary_vector(user_profile.answers, ordered_question_ids)
        text_emb_vec = self._get_text_embedding(user_profile.description)
        return np.concatenate([ternary_vec, text_emb_vec])

    def get_recommendations(self, request: MatchingRequest) -> List[MatchingResponse]:
        main_user_id = request.userId

        if not request.users:
            print("No users provided in the request.")
            return []
        if not request.questions:
            print("No questions provided in the request. Cannot generate ternary features.")
            return []

        ordered_question_ids = self._get_ordered_question_ids(request.questions)

        main_user_profile: Optional[UserMatchingRequest] = None
        candidate_profiles: List[UserMatchingRequest] = []

        for u_profile in request.users:
            if u_profile.id == main_user_id:
                main_user_profile = u_profile
            else:
                candidate_profiles.append(u_profile)

        if main_user_profile is None:
            print(f"Main user with ID {main_user_id} not found in the provided users list.")
            return []

        main_user_vec = self._create_combined_feature_vector(main_user_profile, ordered_question_ids)

        # if len(candidate_profiles) > 1: # Нужно хотя бы несколько векторов для обучения Scaler
        #     all_vectors_for_scaling = [main_user_vec] + \
        #                               [self._create_combined_feature_vector(c, ordered_question_ids) for c in candidate_profiles]
        #     all_vectors_np = np.array(all_vectors_for_scaling)
        #     # self.scaler.fit(all_vectors_np) # Обучаем на текущем батче
        #     # main_user_vec = self.scaler.transform(main_user_vec.reshape(1, -1))[0]
        #     # scaled_candidate_vectors = self.scaler.transform(
        #     #    np.array([self._create_combined_feature_vector(c, ordered_question_ids) for c in candidate_profiles])
        #     # )
        # else:
        #     # Недостаточно данных для масштабирования или только один кандидат
        #     scaled_candidate_vectors = np.array([self._create_combined_feature_vector(c, ordered_question_ids) for c in candidate_profiles])
        # --- Конец опционального масштабирования ---

        recommendations = []

        for i, candidate_profile in enumerate(candidate_profiles):
            if main_user_profile.gender and candidate_profile.gender == main_user_profile.gender:
                if main_user_profile.gender in ['male', 'female'] and candidate_profile.gender in ['male', 'female']:
                    continue

            candidate_vec = self._create_combined_feature_vector(candidate_profile, ordered_question_ids)

            similarity = cosine_similarity(main_user_vec.reshape(1, -1),
                                           candidate_vec.reshape(1, -1))[0][0]

            recommendations.append(
                MatchingResponse(
                    id=candidate_profile.id,
                    username=candidate_profile.username,
                    avatar=candidate_profile.avatar,
                    similarity=float(similarity)
                )
            )

        recommendations.sort(key=lambda x: x.similarity, reverse=True)
        return recommendations


dynamic_recommendation_system = DynamicRecommendationSystem()
