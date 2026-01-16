from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete

from app.db.session import get_db
from app.db.models import Favorite, Product, User
from app.api.deps import get_current_user
from app.schemas.favorites import FavoriteRead

router = APIRouter(prefix="/favorites", tags=["Favorites"])


@router.post("/{product_id}", status_code=status.HTTP_201_CREATED)
async def add_to_favorites(
    product_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    # Проверяем, что товар существует
    res = await db.execute(select(Product.id).where(Product.id == product_id))
    if res.scalar_one_or_none() is None:
        raise HTTPException(status_code=404, detail="Товар не найден")

    # Проверяем, что уже в избранном
    res = await db.execute(
        select(Favorite).where(
            Favorite.user_id == current_user.id,
            Favorite.product_id == product_id,
        )
    )
    if res.scalar_one_or_none():
        return {"detail": "Товар уже в избранном"}

    fav = Favorite(user_id=current_user.id, product_id=product_id)
    db.add(fav)
    await db.commit()

    return {"detail": "Товар добавлен в избранное"}


@router.get("", response_model=list[FavoriteRead])
async def get_favorites(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    res = await db.execute(
        select(Favorite).where(Favorite.user_id == current_user.id)
    )
    favorites = res.scalars().all()

    return [FavoriteRead.model_validate(f) for f in favorites]


@router.delete("/{product_id}")
async def remove_from_favorites(
    product_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    stmt = delete(Favorite).where(
        Favorite.user_id == current_user.id,
        Favorite.product_id == product_id,
    )
    res = await db.execute(stmt)
    await db.commit()

    if res.rowcount == 0:
        raise HTTPException(status_code=404, detail="Товар не был в избранном")

    return {"detail": "Товар удалён из избранного"}