from uuid import UUID
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class ReviewCreate(BaseModel):
    rating: int = Field(ge=1, le=5)
    text: Optional[str] = None
    class Config:
        from_attributes = True

class ReviewRead(BaseModel):
    id: UUID
    user_id: UUID
    product_id: UUID
    rating: int
    text: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True