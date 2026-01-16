from fastapi import FastAPI

from app.api.auth import router as auth_router
from app.api.cart import router as cart_router
from app.api.orders import router as orders_router
from app.api.favorites import router as favorites_router
from app.api.users import router as users_router
from app.api.products import router as products_router
from app.api.reviews import router as reviews_router
from app.api.categories import router as categories_router
from app.api.tags import router as tags_router
from app.api.product_images import router as product_images_router  # ← новый роут
from app.api.product_specs import  router as specs_router  # ← новый роут


app = FastAPI(title="Electronics Shop API")

# Подключаем роутеры
app.include_router(auth_router, prefix="/auth", tags=["Auth"])
app.include_router(cart_router, prefix="/cart", tags=["Cart"])
app.include_router(orders_router, prefix="/orders", tags=["Orders"])
app.include_router(favorites_router, prefix="/favorites", tags=["Favorites"])
app.include_router(users_router, prefix="/users", tags=["Users"])
app.include_router(products_router, prefix="/products", tags=["Products"])
app.include_router(reviews_router, prefix="/reviews", tags=["Reviews"])
app.include_router(categories_router, prefix="/categories", tags=["Categories"])
app.include_router(tags_router, prefix="/tags", tags=["Tags"])
app.include_router(product_images_router, prefix="/product-images", tags=["ProductImages"])  # ← новый
app.include_router(specs_router, prefix="/specs", tags=["Specs"])  # ← новый


@app.get("/")
async def root():
    return {"message": "API is working!"}