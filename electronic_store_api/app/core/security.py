from datetime import datetime, timedelta, timezone
from typing import Optional

from jose import jwt, JWTError
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.core import config
from app.db import  models



def create_access_token(
    subject: str,
    expires_delta: Optional[timedelta] = None,
) -> str:

    if expires_delta is None:
        expires_delta = timedelta(minutes=config.settings.ACCESS_TOKEN_EXPIRE_MINUTES)

    expire = datetime.now(timezone.utc) + expires_delta

    to_encode = {
        "sub": subject,
        "exp": expire,
    }

    encoded_jwt = jwt.encode(
        to_encode,
        config.settings.JWT_SECRET_KEY,
        algorithm=config.settings.JWT_ALGORITHM,
    )
    return encoded_jwt


def decode_access_token(token: str) -> Optional[str]:

    try:
        payload = jwt.decode(
            token,
            config.settings.JWT_SECRET_KEY,
            algorithms=[config.settings.JWT_ALGORITHM],
        )
        subject: str = payload.get("sub")
        if subject is None:
            return None
        return subject
    except JWTError:
        return None




async def authenticate_user(
    db: AsyncSession,
    login: str,
    password: str,
) -> Optional[models.User]:
    stmt = (
        select(models.User)
        .where(
            models.User.login == login,
            models.User.password_hash == func.electronic_store_shema.crypt(password, models.User.password_hash),
        )
    )
    result = await db.execute(stmt)
    return result.scalar_one_or_none()