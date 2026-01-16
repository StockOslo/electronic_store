# Electronics Store — iOS Mobile Application

## Overview

**Electronics Store** is a mobile application for an electronics online store developed for the iOS platform.  
The project was created as part of an academic course work and is focused on demonstrating modern iOS development approaches, clean architecture, and interaction with a backend service via REST API.

The application covers the full user flow: browsing products, filtering by categories and specifications, managing a shopping cart, placing orders, working with favorites, and leaving reviews.

---

## Project Goals

The main goals of this project are:
- implementation of a real-world mobile e-commerce scenario;
- application of modern iOS technologies and architectural patterns;
- separation of client and server logic;
- ensuring scalability and maintainability of the codebase;
- demonstration of testing and validation of business logic.

---

## Key Features

### User Account
- User registration and authentication
- Secure token-based authorization (Bearer Token)
- User profile loading and management

### Product Catalog
- Product listing
- Category-based navigation
- Dynamic filters based on product specifications
- Product detail screen with image gallery
- Product specifications and reviews

### Filtering System
- Automatic generation of filters for a selected category
- Display of only relevant specifications
- Filter reset and reapplication
- Scalable logic for future filter expansion

### Shopping Cart
- Adding and removing products
- Quantity management
- Real-time total price calculation
- Order creation

### Orders
- Order placement
- Order history
- Display of purchased products

### Favorites
- Adding and removing products from favorites
- Separate favorites screen
- Synchronization with the backend

### Reviews
- Viewing product reviews
- Creating, editing, and deleting user reviews
- Average rating calculation and rating distribution

---

## Architecture

The application is built using **SwiftUI** and follows the **MVVM (Model–View–ViewModel)** pattern.

### Architectural Principles
- Views contain only UI logic
- Business logic is handled by manager classes
- Models represent pure data structures
- Network communication is isolated in managers
- Asynchronous operations use `async/await`

### Core Managers
- `AuthManager` — authentication and registration
- `UserManager` — user profile management
- `ProductManager` — products, categories, filters, images
- `CartManager` — shopping cart logic
- `OrdersManager` — order creation and history
- `FavoritesManager` — favorites management

---

## Backend & API

The mobile application communicates with a backend server via a REST API.

### Backend Technologies
- FastAPI
- PostgreSQL
- REST architecture
- JSON data format
- JWT-based authentication

### API Status
The backend API is under active development.  
A separate API documentation and server-side source code will be added to this repository in future updates.

---

## Image Loading & Caching

- Asynchronous image loading using `AsyncImage`
- Image prefetching to improve user experience
- URL-based caching with `URLCache`
- Support for multiple product images
- Main image prioritization and ordering

---

## Testing

The project includes **unit testing** focused on business logic validation.

### Covered Areas
- Authorization state handling
- Cart logic and quantity calculation
- Favorites logic
- Error handling and API state validation

Unit tests are implemented using the built-in Xcode testing framework and are executed automatically within the development environment.  
Test execution results and successful test runs are documented in the project report (Figures 1–2).

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

### Tools
- Xcode
- Git
- iOS Simulator and real devices

---

## System Requirements

### Client
- iOS 16.0 or later
- iPhone device
- Internet connection

### Server
- Operating System: Linux / macOS / Windows
- RAM: 2 GB or more
- Disk space: 5 GB or more
- PostgreSQL 13 or later
- HTTPS support (recommended)

---

## Future Improvements

- Combined multi-parameter filtering
- Product list pagination
- Push notifications
- Online payment integration
- Localization
- Dark Mode support
- Offline catalog browsing

---

## Documentation

Additional documentation will be added to this repository, including:
- API reference
- Database schema description
- Architecture diagrams
- Setup and deployment instructions

---

## Author

Erik Antonov  
iOS Developer (Junior)

The project was developed as part of an academic coursework with a focus on real-world mobile application development practices.