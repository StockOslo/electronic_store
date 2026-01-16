# Electronics Store — iOS Mobile Application

## Overview

**Electronics Store** is an iOS mobile application for an electronics online store.  
The project is an **educational coursework project** developed to demonstrate modern iOS development practices, clean architecture principles, and interaction with a backend service via a REST API.

The application implements a complete e-commerce user flow: product browsing, category-based navigation, dynamic filtering by specifications, shopping cart management, order placement, favorites handling, and product reviews.

---

## Project Purpose

The purpose of this project is to:
- demonstrate practical skills in iOS application development;
- apply modern Apple technologies and architectural patterns;
- separate client-side and server-side logic;
- implement scalable and maintainable application architecture;
- showcase unit testing of business logic.

The project is not intended for commercial use and was developed as part of an academic program.

---

## Key Features

### User Account
- User registration and authentication
- Token-based authorization (Bearer Token)
- Secure session handling

### Product Catalog
- Product listing with grid layout
- Category-based navigation
- Product detail screen
- Image gallery for products
- Product specifications display

### Dynamic Filtering System
- Automatic generation of filters based on selected category
- Display of relevant product specifications only
- Filter reset and reapplication
- Flexible architecture for future filter expansion

### Shopping Cart
- Adding and removing products
- Quantity management
- Real-time total price calculation
- Order creation from cart

### Orders
- Order placement
- Order history
- Display of purchased items

### Favorites
- Adding and removing products from favorites
- Separate favorites screen
- Backend synchronization

### Reviews
- Viewing product reviews
- Creating and deleting reviews
- Rating calculation and distribution

---

## Architecture

The application is built using **SwiftUI** and follows the **MVVM (Model–View–ViewModel)** architectural pattern.

### Architectural Principles
- UI logic is isolated in Views
- Business logic is handled by manager/view-model classes
- Models represent pure data structures
- Network communication is separated into service layers
- Asynchronous operations are implemented using `async/await`

### Core Managers
- `AuthManager` — user authentication and registration
- `UserManager` — user session and profile handling
- `ProductManager` — products, categories, filters, images
- `CartManager` — shopping cart logic
- `OrdersManager` — order creation and history
- `FavoritesManager` — favorites management

---

## Backend & API

The mobile application communicates with a backend server via a REST API.

### Backend Technologies
- **FastAPI**
- PostgreSQL
- REST architecture
- JSON data exchange
- JWT-based authentication

### API Status
The backend API is currently **under active development**.  
The server-side source code, API documentation, and database schema will be added to this repository in future updates.

---

## Image Loading & Caching

- Asynchronous image loading using `AsyncImage`
- Image prefetching to improve perceived performance
- URL-based caching using `URLCache`
- Support for multiple product images per item
- Main image prioritization

---

## Testing

The project includes **unit testing** focused on validating business logic independently of the user interface.

### Tested Components
- Authorization state logic
- Shopping cart quantity handling
- Favorites management
- Error handling and state validation

Unit tests are implemented using the built-in Xcode testing framework and are executed automatically within the development environment.  
Successful test execution results are presented in the project report (Figures 1–2).

---

## Technology Stack

### Client (iOS)
- Swift
- SwiftUI
- Combine
- async/await
- MVVM architecture
- AppStorage

### Server
- FastAPI
- PostgreSQL
- REST API
- JWT authentication

### Development Tools
- Xcode
- Git
- iOS Simulator
- Physical iOS devices

---

## System Requirements

### Client
- iOS 16.0 or later
- iPhone device
- Stable internet connection

### Server
- Operating System: Linux / macOS / Windows
- RAM: 2 GB or more
- Disk space: 5 GB or more
- PostgreSQL 13 or later
- HTTPS support (recommended)

---

## Future Improvements

- Combined multi-parameter filtering
- Product pagination
- Push notifications
- Online payment integration
- Localization
- Dark Mode support
- Offline catalog browsing

---

## Documentation

The repository will be expanded with additional documentation:
- REST API reference
- Database schema description
- Architecture diagrams
- Setup and deployment instructions

---

## Author

**Erik Antonov**  

GitHub: https://github.com/StockOslo

This project was developed as part of an academic coursework with a focus on real-world mobile application development practices and clean architecture principles.
