from uuid import UUID
from decimal import Decimal
from pydantic import BaseModel
from typing import Optional

class ProductRead(BaseModel):
    id: UUID
    category_id: UUID
    name: str
    description: Optional[str] = None
    price: Decimal
    rating: Decimal
    review_count: int

    class Config:
        from_attributes = True