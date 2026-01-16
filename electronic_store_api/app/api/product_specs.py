from typing import List
from uuid import UUID

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.db.session import get_db
from app.db.models import ProductSpec, Spec
from app.schemas.product_spec import ProductSpecRead, ProductSpecWithNameRead

router = APIRouter(prefix="/specs", tags=["Specs"])


@router.get("", response_model=List[ProductSpecRead])
async def get_all_specs(db: AsyncSession = Depends(get_db)):
    res = await db.execute(select(ProductSpec))
    specs = res.scalars().all()
    return [ProductSpecRead.model_validate(s) for s in specs]


@router.get("/by-product/{product_id}", response_model=List[ProductSpecWithNameRead])
async def get_specs_by_product(product_id: UUID, db: AsyncSession = Depends(get_db)):
    # JOIN чтобы достать Spec.name
    stmt = (
        select(ProductSpec, Spec.name)
        .join(Spec, Spec.id == ProductSpec.spec_id)
        .where(ProductSpec.product_id == product_id)
    )

    res = await db.execute(stmt)
    rows = res.all()  # [(ProductSpec, spec_name), ...]

    # собираем response вручную (потому что это не ORM-объект целиком)
    return [
        ProductSpecWithNameRead(
            id=ps.id,
            product_id=ps.product_id,
            spec_id=ps.spec_id,
            value=ps.value,
            spec_name=spec_name,
        )
        for ps, spec_name in rows
    ]