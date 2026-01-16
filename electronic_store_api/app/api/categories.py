# app/api/categories.py
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.db.session import get_db
from app.db.models import Category
from app.schemas.categories import CategoryRead

router = APIRouter(prefix="/categories", tags=["Categories"])


@router.get("", response_model=list[CategoryRead])
async def get_all_categories(
    db: AsyncSession = Depends(get_db),
):
    res = await db.execute(select(Category))
    categories = res.scalars().all()
    return [CategoryRead.model_validate(c) for c in categories]


@router.get("/{category_id}", response_model=CategoryRead)
async def get_category_by_id(
    category_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    res = await db.execute(select(Category).where(Category.id == category_id))
    category = res.scalar_one_or_none()

    if category is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Категория не найдена")

    return CategoryRead.model_validate(category)