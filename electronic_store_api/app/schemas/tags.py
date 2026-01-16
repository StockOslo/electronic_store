from uuid import UUID
from pydantic import BaseModel


class TagRead(BaseModel):
    id: UUID
    name: str

    class Config:
        from_attributes = True