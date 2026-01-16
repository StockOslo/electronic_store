from typing import List
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.db.session import get_db
from app.db.models import Product, Category, Spec, ProductSpec, Tag, ProductTag
from app.schemas.products import ProductRead

router = APIRouter(prefix="/products", tags=["Products"])

@router.get("/by-category/{category_id}", response_model=list[ProductRead])
async def get_products_by_category(
    category_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    res = await db.execute(select(Category.id).where(Category.id == category_id))
    if res.scalar_one_or_none() is None:
        raise HTTPException(status_code=404, detail="Категория не найдена")

    res = await db.execute(
        select(Product).where(Product.category_id == category_id)
    )
    products = res.scalars().all()
    return [ProductRead.model_validate(p) for p in products]




@router.get("/by-spec", response_model=list[ProductRead])
async def get_products_by_spec(
    spec_name: str = Query(..., description="Имя характеристики, как в таблице specs.name"),
    value: str = Query(..., description="Строка для поиска в значении характеристики"),
    db: AsyncSession = Depends(get_db),
):
    # Находим spec по имени
    res = await db.execute(
        select(Spec).where(Spec.name == spec_name)
    )
    spec = res.scalar_one_or_none()
    if spec is None:
        raise HTTPException(status_code=404, detail="Характеристика не найдена")

    res = await db.execute(
        select(Product)
        .join(ProductSpec, ProductSpec.product_id == Product.id)
        .where(
            ProductSpec.spec_id == spec.id,
            ProductSpec.value.ilike(f"%{value}%"),
        )
    )
    products = res.scalars().all()
    return [ProductRead.model_validate(p) for p in products]

@router.get("/by-tags", response_model=list[ProductRead])
async def get_products_by_tags(
    tags: List[str] = Query(..., description="Список тегов, например ?tags=игровой&tags=ноутбук"),
    db: AsyncSession = Depends(get_db),
):
    res = await db.execute(
        select(Tag).where(Tag.name.in_(tags))
    )
    tag_rows = res.scalars().all()
    if not tag_rows:

        return []

    tag_ids = [t.id for t in tag_rows]

    res = await db.execute(
        select(Product)
        .join(ProductTag, ProductTag.product_id == Product.id)
        .where(ProductTag.tag_id.in_(tag_ids))
        .distinct()
    )
    products = res.scalars().all()
    return [ProductRead.model_validate(p) for p in products]

@router.get("/search", response_model=list[ProductRead])
async def search_products(
    q: str = Query(..., min_length=1, description="Поисковая строка"),
    db: AsyncSession = Depends(get_db),
):
    ts_query = func.plainto_tsquery("russian", q)

    res = await db.execute(
        select(Product)
        .where(Product.search_vector.op('@@')(ts_query))
        .order_by(Product.rating.desc(), Product.review_count.desc())
    )
    products = res.scalars().all()
    return [ProductRead.model_validate(p) for p in products]

@router.get("", response_model=list[ProductRead])
async def get_all_products(
    db: AsyncSession = Depends(get_db),
    limit: int = Query(50, ge=1, le=200, description="Максимум товаров за раз"),
    offset: int = Query(0, ge=0, description="Сколько товаров пропустить (для пагинации)"),
):
    res = await db.execute(
        select(Product)
        .offset(offset)
        .limit(limit)
    )
    products = res.scalars().all()
    return [ProductRead.model_validate(p) for p in products]

@router.get("/{product_id}", response_model=ProductRead)
async def get_product_by_id(
    product_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    res = await db.execute(select(Product).where(Product.id == product_id))
    product = res.scalar_one_or_none()

    if product is None:
        raise HTTPException(status_code=404, detail="Товар не найден")

    return ProductRead.model_validate(product)