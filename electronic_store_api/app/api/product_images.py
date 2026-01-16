from typing import List
from uuid import UUID

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.db.session import get_db
from app.db.models import ProductImage
from app.schemas.product_image import ProductImageRead

router = APIRouter(prefix="/images", tags=["Product Images"])


@router.get("", response_model=List[ProductImageRead])
async def get_all_images(db: AsyncSession = Depends(get_db)):
    res = await db.execute(select(ProductImage))
    images = res.scalars().all()
    return [ProductImageRead.from_orm(img) for img in images]


@router.get("/by-product/{product_id}", response_model=List[ProductImageRead])
async def get_images_by_product(product_id: UUID, db: AsyncSession = Depends(get_db)):
    res = await db.execute(
        select(ProductImage).where(ProductImage.product_id == product_id).order_by(ProductImage.sort_order)
    )
    images = res.scalars().all()
    return [ProductImageRead.from_orm(img) for img in images]