from pydantic import BaseModel
from uuid import UUID


class ProductSpecRead(BaseModel):
    id: UUID
    product_id: UUID
    spec_id: UUID
    value: str

    model_config = {"from_attributes": True}


class ProductSpecWithNameRead(ProductSpecRead):
    spec_name: str