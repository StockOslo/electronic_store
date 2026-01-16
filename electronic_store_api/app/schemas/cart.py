from pydantic import BaseModel, Field
from uuid import UUID


class CartAddItemRequest(BaseModel):
    product_id: UUID
    quantity: int = Field(gt=0, description="Количество товара > 0")


class CartItemRead(BaseModel):
    id: UUID
    product_id: UUID
    quantity: int

    class Config:
        from_attributes = True


class CartRead(BaseModel):
    user_id: UUID
    items: list[CartItemRead]