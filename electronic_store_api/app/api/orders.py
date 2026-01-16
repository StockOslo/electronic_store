from uuid import UUID
from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
from sqlalchemy.orm import selectinload

from app.db.session import get_db
from app.db.models import CartItem, Product, Order, OrderItem, User
from app.api.deps import get_current_user
from app.schemas.orders import OrderRead

router = APIRouter(prefix="/orders", tags=["Orders"])


@router.post("", response_model=OrderRead, status_code=status.HTTP_201_CREATED)
async def create_order_from_cart(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    res = await db.execute(
        select(CartItem, Product.price)
        .join(Product, CartItem.product_id == Product.id)
        .where(CartItem.cart_user_id == current_user.id)
    )
    rows = res.all()

    if not rows:
        raise HTTPException(status_code=400, detail="Корзина пуста")

    total_price = Decimal("0.00")
    items_data: list[tuple[CartItem, Decimal]] = []

    for cart_item, price in rows:
        total_price += price * cart_item.quantity
        items_data.append((cart_item, price))

    order = Order(
        user_id=current_user.id,
        total_price=total_price,
        status="created",
    )
    db.add(order)
    await db.flush()

    for cart_item, price in items_data:
        db.add(
            OrderItem(
                order_id=order.id,
                product_id=cart_item.product_id,
                quantity=cart_item.quantity,
                price_at_purchase=price,
            )
        )

    # Очистка корзины
    await db.execute(delete(CartItem).where(CartItem.cart_user_id == current_user.id))

    await db.commit()

    # ✅ ВАЖНО: заново загрузим заказ уже вместе с items (+ product)
    res = await db.execute(
        select(Order)
        .options(
            selectinload(Order.items).selectinload(OrderItem.product)
        )
        .where(Order.id == order.id, Order.user_id == current_user.id)
    )
    order_full = res.scalar_one()

    return OrderRead.model_validate(order_full)


@router.get("", response_model=list[OrderRead])
async def get_my_orders(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    res = await db.execute(
        select(Order)
        .options(
            selectinload(Order.items).selectinload(OrderItem.product)
        )
        .where(Order.user_id == current_user.id)
        .order_by(Order.created_at.desc() if hasattr(Order, "created_at") else Order.id.desc())
    )
    orders = res.scalars().all()
    return [OrderRead.model_validate(o) for o in orders]


@router.get("/{order_id}", response_model=OrderRead)
async def get_order_by_id(
    order_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    res = await db.execute(
        select(Order)
        .options(
            selectinload(Order.items).selectinload(OrderItem.product)
        )
        .where(Order.id == order_id, Order.user_id == current_user.id)
    )
    order = res.scalar_one_or_none()
    if order is None:
        raise HTTPException(status_code=404, detail="Заказ не найден")

    return OrderRead.model_validate(order)


@router.delete("/{order_id}")
async def delete_order(
    order_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    res = await db.execute(
        select(Order).where(
            Order.id == order_id,
            Order.user_id == current_user.id,
        )
    )
    order = res.scalar_one_or_none()
    if order is None:
        raise HTTPException(status_code=404, detail="Заказ не найден")

    await db.delete(order)
    await db.commit()
    return {"detail": "Заказ удалён"}