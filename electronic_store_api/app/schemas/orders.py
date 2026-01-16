from pydantic import BaseModel
from uuid import UUID
from decimal import Decimal


class ProductBrief(BaseModel):
    id: UUID
    name: str
    price: Decimal  # текущая цена в каталоге (не обязательно равна price_at_purchase)

    class Config:
        from_attributes = True


class OrderItemRead(BaseModel):
    id: UUID
    product_id: UUID
    quantity: int
    price_at_purchase: Decimal


    product: ProductBrief | None = None

    class Config:
        from_attributes = True


class OrderRead(BaseModel):
    id: UUID
    total_price: Decimal
    status: str


    items: list[OrderItemRead] = []

    class Config:
        from_attributes = True