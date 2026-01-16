from pydantic import BaseModel, Field



from uuid import UUID
from pydantic import BaseModel, EmailStr


class ChangePasswordRequest(BaseModel):
    current_password: str = Field(min_length=6, max_length=128)
    new_password: str = Field(min_length=6, max_length=128)


class ChangeLoginRequest(BaseModel):
    new_login: str = Field(min_length=3, max_length=64)