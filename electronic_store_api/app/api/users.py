from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.db.session import get_db
from app.db.models import User
from app.api.deps import get_current_user
from app.schemas.auth import UserRead
from app.schemas.users import ChangePasswordRequest, ChangeLoginRequest
from app.core.security import authenticate_user

router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/me", response_model=UserRead)
async def get_me(
    current_user: User = Depends(get_current_user),
):
    return UserRead(
        id=str(current_user.id),
        email=current_user.email,
        login=current_user.login
    )

@router.post("/me/change-password")
async def change_password(
    data: ChangePasswordRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    user = await authenticate_user(
        db,
        login=current_user.login,
        password=data.current_password,
    )
    if not user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Неверный текущий пароль",
        )


    current_user.password_hash = data.new_password
    db.add(current_user)
    await db.commit()

    return {"detail": "Пароль успешно изменён"}

@router.post("/me/change-login", response_model=UserRead)
async def change_login(
    data: ChangeLoginRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    res = await db.execute(
        select(User).where(
            User.login == data.new_login,
            User.id != current_user.id,
        )
    )
    if res.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Логин уже используется другим пользователем",
        )

    current_user.login = data.new_login
    await db.commit()
    await db.refresh(current_user)

    return current_user