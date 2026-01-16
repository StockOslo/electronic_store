# app/api/cart.py
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete

from app.db import session
from app.db.models import CartItem, Product, User
from app.api.deps import get_current_user
from app.schemas.cart import CartAddItemRequest, CartRead, CartItemRead

router = APIRouter(prefix="/cart", tags=["Cart"])


@router.post("/items", status_code=status.HTTP_201_CREATED)
async def add_to_cart(
    data: CartAddItemRequest,
    db: AsyncSession = Depends(session.get_db),
    current_user: User = Depends(get_current_user),
):

    res = await db.execute(select(Product.id).where(Product.id == data.product_id))
    if res.scalar_one_or_none() is None:
        raise HTTPException(status_code=404, detail="Товар не найден")


    res = await db.execute(
        select(CCartItem := CartItem).where(
            CCartItem.cart_user_id == current_user.id,
            CCartItem.product_id == data.product_id,
        )
    )
    item = res.scalar_one_or_none()

    if item:
        item.quantity += data.quantity
    else:
        item = CartItem(
            cart_user_id=current_user.id,
            product_id=data.product_id,
            quantity=data.quantity,
        )
        db.add(item)

    await db.commit()
    return {"detail": "Товар добавлен в корзину"}


@router.get("", response_model=CartRead)
async def get_cart(
    db: AsyncSession = Depends(session.get_db),
    current_user: User = Depends(get_current_user),
):
    res = await db.execute(
        select(CartItem).where(CartItem.cart_user_id == current_user.id)
    )
    items = res.scalars().all()

    return CartRead(
        user_id=current_user.id,
        items=[CartItemRead.model_validate(i) for i in items],
    )


@router.delete("/items/{product_id}")
async def remove_from_cart(
    product_id: UUID,
    db: AsyncSession = Depends(session.get_db),
    current_user: User = Depends(get_current_user),
):
    stmt = delete(CartItem).where(
        CartItem.cart_user_id == current_user.id,
        CartItem.product_id == product_id,
    )
    res = await db.execute(stmt)
    await db.commit()

    if res.rowcount == 0:
        raise HTTPException(status_code=404, detail="Товар не найден в корзине")

    return {"detail": "Товар удалён из корзины"}


@router.delete("/clear")
async def clear_cart(
    db: AsyncSession = Depends(session.get_db),
    current_user: User = Depends(get_current_user),
):
    stmt = delete(CartItem).where(CartItem.cart_user_id == current_user.id)
    await db.execute(stmt)
    await db.commit()
    return {"detail": "Корзина очищена"}