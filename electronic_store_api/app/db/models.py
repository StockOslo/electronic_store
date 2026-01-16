from sqlalchemy import (
    Column,
    Text,
    Integer,
    Numeric,
    Boolean,
    DateTime,
    ForeignKey,
    UniqueConstraint,
    CheckConstraint,
)
from sqlalchemy.orm import declarative_base, relationship
from sqlalchemy.sql import func, text
from sqlalchemy.dialects.postgresql import UUID, TSVECTOR

Base = declarative_base()


SCHEMA = "electronic_store_shema"

class User(Base):
    __tablename__ = "users"
    __table_args__ = {"schema": SCHEMA}

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    email = Column(Text, unique=True, nullable=False)
    password_hash = Column(Text, nullable=False)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    login = Column(Text, unique=True)

    favorites = relationship("Favorite", back_populates="user", cascade="all, delete-orphan")
    cart_items = relationship("CartItem",back_populates="user",cascade="all, delete-orphan",foreign_keys="CartItem.cart_user_id",
    )
    orders = relationship("Order", back_populates="user", cascade="all, delete-orphan")
    reviews = relationship("Review", back_populates="user", cascade="all, delete-orphan")
    user_roles = relationship("UserRole", back_populates="user", cascade="all, delete-orphan")
    refresh_tokens = relationship("RefreshToken", back_populates="user", cascade="all, delete-orphan")



    def __repr__(self) -> str:
        return f"<User id={self.id} email={self.email!r}>"


class Role(Base):
    __tablename__ = "roles"
    __table_args__ = {"schema": SCHEMA}

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    name = Column(Text, unique=True, nullable=False)

    user_roles = relationship("UserRole", back_populates="role", cascade="all, delete-orphan")


class UserRole(Base):
    __tablename__ = "user_roles"
    __table_args__ = {"schema": SCHEMA}

    # В дампе PK только по user_id
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey(f"{SCHEMA}.users.id", ondelete="CASCADE"),
        primary_key=True,
    )
    role_id = Column(
        UUID(as_uuid=True),
        ForeignKey(f"{SCHEMA}.roles.id", ondelete="RESTRICT"),
        nullable=False,
    )

    user = relationship("User", back_populates="user_roles")
    role = relationship("Role", back_populates="user_roles")



class Category(Base):
    __tablename__ = "categories"
    __table_args__ = {"schema": SCHEMA}

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    name = Column(Text, unique=True, nullable=False)
    system_image_name = Column(Text)

    products = relationship("Product", back_populates="category")


class Product(Base):
    __tablename__ = "products"
    __table_args__ = {"schema": SCHEMA}

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    category_id = Column(
        UUID(as_uuid=True),
        ForeignKey(f"{SCHEMA}.categories.id", ondelete="RESTRICT"),
        nullable=False,
    )
    name = Column(Text, nullable=False)
    description = Column(Text)
    price = Column(Numeric(12, 2), nullable=False)
    rating = Column(Numeric(3, 2), nullable=False, server_default=text("0"))
    review_count = Column(Integer, nullable=False, server_default=text("0"))
    search_vector = Column(TSVECTOR, server_default=text("''::tsvector"))
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

    category = relationship("Category", back_populates="products")
    images = relationship("ProductImage", back_populates="product", cascade="all, delete-orphan")
    specs = relationship("ProductSpec", back_populates="product", cascade="all, delete-orphan")
    product_tags = relationship("ProductTag", back_populates="product", cascade="all, delete-orphan")
    favorites = relationship("Favorite", back_populates="product", cascade="all, delete-orphan")
    cart_items = relationship("CartItem", back_populates="product", cascade="all, delete-orphan")
    order_items = relationship("OrderItem", back_populates="product", cascade="all, delete-orphan")
    reviews = relationship("Review", back_populates="product", cascade="all, delete-orphan")



    def __repr__(self) -> str:
        return f"<Product id={self.id} name={self.name!r}>"



class ProductImage(Base):
    __tablename__ = "product_images"
    __table_args__ = {"schema": SCHEMA}

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    product_id = Column(
        UUID(as_uuid=True),
        ForeignKey(f"{SCHEMA}.products.id", ondelete="CASCADE"),
        nullable=False,
    )
    url = Column(Text, nullable=False)
    sort_order = Column(Integer, nullable=False, server_default=text("0"))
    is_main = Column(Boolean, nullable=False, server_default=text("FALSE"))

    product = relationship("Product", back_populates="images")


# ---------------------------
# Характеристики и теги
# ---------------------------

class Spec(Base):
    __tablename__ = "specs"
    __table_args__ = {"schema": SCHEMA}

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    name = Column(Text, unique=True, nullable=False)

    product_specs = relationship("ProductSpec", back_populates="spec", cascade="all, delete-orphan")


class ProductSpec(Base):
    __tablename__ = "product_specs"
    __table_args__ = {"schema": SCHEMA}

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    product_id = Column(
        UUID(as_uuid=True),
        ForeignKey(f"{SCHEMA}.products.id", ondelete="CASCADE"),
        nullable=False,
    )
    spec_id = Column(
        UUID(as_uuid=True),
        ForeignKey(f"{SCHEMA}.specs.id", ondelete="CASCADE"),
        nullable=False,
    )
    value = Column(Text, nullable=False)

    product = relationship("Product", back_populates="specs")
    spec = relationship("Spec", back_populates="product_specs")


class Tag(Base):
    __tablename__ = "tags"
    __table_args__ = {"schema": SCHEMA}

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    name = Column(Text, unique=True, nullable=False)

    product_tags = relationship("ProductTag", back_populates="tag", cascade="all, delete-orphan")


class ProductTag(Base):
    __tablename__ = "product_tags"
    __table_args__ = {"schema": SCHEMA}

    product_id = Column(
        UUID(as_uuid=True),
        ForeignKey(f"{SCHEMA}.products.id", ondelete="CASCADE"),
        primary_key=True,
    )
    tag_id = Column(
        UUID(as_uuid=True),
        ForeignKey(f"{SCHEMA}.tags.id", ondelete="CASCADE"),
        primary_key=True,
    )

    product = relationship("Product", back_populates="product_tags")
    tag = relationship("Tag", back_populates="product_tags")




class Favorite(Base):
    __tablename__ = "favorites"
    __table_args__ = {"schema": SCHEMA}

    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey(f"{SCHEMA}.users.id", ondelete="CASCADE"),
        primary_key=True,
    )
    product_id = Column(
        UUID(as_uuid=True),
        ForeignKey(f"{SCHEMA}.products.id", ondelete="CASCADE"),
        primary_key=True,
    )

    user = relationship("User", back_populates="favorites")
    product = relationship("Product", back_populates="favorites")





class CartItem(Base):
    __tablename__ = "cart_items"
    __table_args__ = (
        UniqueConstraint("cart_user_id", "product_id", name="cart_items_cart_user_id_product_id_key"),
        CheckConstraint("quantity > 0", name="cart_items_quantity_check"),
        {"schema": SCHEMA},
    )

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    cart_user_id = Column(
        UUID(as_uuid=True),
        ForeignKey(f"{SCHEMA}.users.id", ondelete="CASCADE"),
        nullable=False,
    )
    product_id = Column(
        UUID(as_uuid=True),
        ForeignKey(f"{SCHEMA}.products.id", ondelete="CASCADE"),
        nullable=False,
    )
    quantity = Column(Integer, nullable=False)
    added_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

    user = relationship(
        "User",
        back_populates="cart_items",
        foreign_keys=[cart_user_id],
    )
    product = relationship(
        "Product",
        back_populates="cart_items",
        foreign_keys=[product_id],
    )


class Order(Base):
    __tablename__ = "orders"
    __table_args__ = (
        CheckConstraint(
            "status = ANY (ARRAY['created'::text, 'paid'::text, 'processing'::text, "
            "'shipped'::text, 'completed'::text, 'canceled'::text])",
            name="orders_status_check",
        ),
        CheckConstraint("total_price >= 0", name="orders_total_price_check"),
        {"schema": SCHEMA},
    )

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey(f"{SCHEMA}.users.id", ondelete="CASCADE"),
        nullable=False,
    )
    total_price = Column(Numeric(12, 2), nullable=False)
    status = Column(Text, nullable=False, server_default=text("'created'"))

    user = relationship("User", back_populates="orders")
    items = relationship("OrderItem", back_populates="order", cascade="all, delete-orphan")


class OrderItem(Base):
    __tablename__ = "order_items"
    __table_args__ = (
        CheckConstraint("quantity > 0", name="order_items_quantity_check"),
        CheckConstraint("price_at_purchase >= 0", name="order_items_price_at_purchase_check"),
        {"schema": SCHEMA},
    )

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    order_id = Column(
        UUID(as_uuid=True),
        ForeignKey(f"{SCHEMA}.orders.id", ondelete="CASCADE"),
        nullable=False,
    )
    product_id = Column(
        UUID(as_uuid=True),
        ForeignKey(f"{SCHEMA}.products.id", ondelete="CASCADE"),
        nullable=False,
    )
    quantity = Column(Integer, nullable=False)
    price_at_purchase = Column(Numeric(12, 2), nullable=False)

    order = relationship("Order", back_populates="items")
    product = relationship("Product", back_populates="order_items")


class Review(Base):
    __tablename__ = "reviews"
    __table_args__ = (
        UniqueConstraint("user_id", "product_id", name="reviews_user_id_product_id_key"),
        CheckConstraint("rating >= 1 AND rating <= 5", name="reviews_rating_check"),
        {"schema": SCHEMA},
    )

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey(f"{SCHEMA}.users.id", ondelete="CASCADE"),
        nullable=False,
    )
    product_id = Column(
        UUID(as_uuid=True),
        ForeignKey(f"{SCHEMA}.products.id", ondelete="CASCADE"),
        nullable=False,
    )
    rating = Column(Integer, nullable=False)
    text = Column(Text)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

    user = relationship("User", back_populates="reviews")
    product = relationship("Product", back_populates="reviews")


class RefreshToken(Base):
    __tablename__ = "refresh_tokens"
    __table_args__ = {"schema": SCHEMA}

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey(f"{SCHEMA}.users.id", ondelete="CASCADE"),
        nullable=False,
    )
    token = Column(Text, unique=True, nullable=False)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    revoked = Column(Boolean, nullable=False, server_default=text("FALSE"))
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

    user = relationship("User", back_populates="refresh_tokens")