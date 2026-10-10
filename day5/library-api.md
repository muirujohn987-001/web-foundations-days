# Library Books REST API

## 1. Overview

This API allows users to manage books in a library. It supports retrieving,
creating, updating, and deleting books.

**Base URL:** `https://api.example.com/v1`

### Book Resource

Each book contains the following fields:

- `id`: Unique identifier for the book.
- `title`: Title of the book.
- `author`: Name of the author.
- `publishedYear`: Year the book was published.
- `isbn`: International Standard Book Number.

---

## 2. API Endpoints

### Endpoint 1: List All Books

- **Method:** `GET`
- **Path:** `/books`
- **Description:** Retrieves a list of all books in the library.
- **Success Status:** `200 OK`

**Example Request:**

   http
GET /v1/books
