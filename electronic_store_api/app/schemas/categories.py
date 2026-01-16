from uuid import UUID
from pydantic import BaseModel
from typing import Optional


class CategoryRead(BaseModel):
    id: UUID
    name: str
    system_image_name: Optional[str] = None

    class Config:
        from_attributes = True