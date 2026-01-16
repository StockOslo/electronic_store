from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.db.session import get_db
from app.db.models import Tag
from app.schemas.tags import TagRead

router = APIRouter(prefix="/tags", tags=["Tags"])


@router.get("", response_model=list[TagRead])
async def get_all_tags(
    db: AsyncSession = Depends(get_db),
):
    res = await db.execute(select(Tag))
    tags = res.scalars().all()
    return [TagRead.model_validate(t) for t in tags]