from pydantic import BaseModel
from uuid import UUID

class ProductImageRead(BaseModel):
    id: UUID
    product_id: UUID
    url: str
    sort_order: int
    is_main: bool

    model_config = {
        "from_attributes": True
    }