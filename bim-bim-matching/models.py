from typing import List, Dict, Optional

from pydantic import BaseModel, Field


class QuestionMatchingRequest(BaseModel):
    id: int
    content: str
    answerLeft: Optional[str] = None
    answerRight: Optional[str] = None


class UserMatchingRequest(BaseModel):
    id: int
    gender: str
    avatar: str
    username: str
    description: str
    answers: Dict[int, int]


class MatchingRequest(BaseModel):
    userId: int
    questions: List[QuestionMatchingRequest]
    users: List[UserMatchingRequest]


class MatchingResponse(BaseModel):
    id: int
    username: str
    avatar: Optional[str] = None
    similarity: float
