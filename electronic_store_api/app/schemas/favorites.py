from pydantic import BaseModel
from uuid import UUID
from datetime import datetime

class FavoriteRead(BaseModel):
    product_id: UUID


    class Config:
        from_attributes = True