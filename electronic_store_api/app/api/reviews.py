from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, delete

from app.db.session import get_db
from app.db.models import Product, Review, User
from app.api.deps import get_current_user
from app.schemas.reviews import ReviewCreate, ReviewRead

router = APIRouter(prefix="/products", tags=["Reviews"])




@router.post("/{product_id}/reviews", response_model=ReviewRead, status_code=status.HTTP_201_CREATED)
async def create_or_update_review(
    product_id: UUID,
    data: ReviewCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    res = await db.execute(select(Product).where(Product.id == product_id))
    product = res.scalar_one_or_none()
    if product is None:
        raise HTTPException(status_code=404, detail="Товар не найден")

    res = await db.execute(
        select(Review).where(
            Review.user_id == current_user.id,
            Review.product_id == product_id,
        )
    )
    review = res.scalar_one_or_none()

    if review:
        review.rating = data.rating
        review.text = data.text
    else:
        review = Review(
            user_id=current_user.id,
            product_id=product_id,
            rating=data.rating,
            text=data.text,
        )
        db.add(review)


    await db.flush()

    res = await db.execute(
        select(
            func.avg(Review.rating).label("avg_rating"),
            func.count(Review.id).label("cnt"),
        ).where(Review.product_id == product_id)
    )
    avg_rating, cnt = res.one()
    # Обновляем поля товара
    product.rating = avg_rating or 0
    product.review_count = cnt or 0

    await db.commit()
    await db.refresh(review)

    return ReviewRead.model_validate(review)



@router.get("/{product_id}/reviews", response_model=list[ReviewRead])
async def get_reviews_for_product(
    product_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    res = await db.execute(select(Product.id).where(Product.id == product_id))
    if res.scalar_one_or_none() is None:
        raise HTTPException(status_code=404, detail="Товар не найден")

    res = await db.execute(
        select(Review).where(Review.product_id == product_id).order_by(Review.created_at.desc())
    )
    reviews = res.scalars().all()
    return [ReviewRead.model_validate(r) for r in reviews]




@router.delete("/{product_id}/reviews/me")
async def delete_my_review(
    product_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    res = await db.execute(
        select(Review).where(
            Review.product_id == product_id,
            Review.user_id == current_user.id,
        )
    )
    review = res.scalar_one_or_none()
    if review is None:
        raise HTTPException(status_code=404, detail="Отзыв не найден")

    await db.delete(review)

    await db.flush()
    res = await db.execute(
        select(
            func.avg(Review.rating).label("avg_rating"),
            func.count(Review.id).label("cnt"),
        ).where(Review.product_id == product_id)
    )
    avg_rating, cnt = res.one()

    # Обновляем товар
    res_prod = await db.execute(select(Product).where(Product.id == product_id))
    product = res_prod.scalar_one_or_none()
    if product:
        product.rating = avg_rating or 0
        product.review_count = cnt or 0

    await db.commit()

    return {"detail": "Отзыв удалён"}