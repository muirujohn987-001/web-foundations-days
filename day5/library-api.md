# Library Books REST API

## 1. Overview

The Library Books REST API allows clients to retrieve, create, update,
delete, and search for books in a library.

The API uses REST principles and JSON for exchanging data between clients
and the server.

**Base URL:** `https://api.example.com/v1`

### Book Resource Schema

Each book contains the following fields:

| Field | Data Type | Description |
|---|---|---|
| id | Integer | Unique identifier assigned to each book |
| title | String | Title of the book |
| author | String | Name of the book's author |
| publishedYear | Integer | Year the book was published |
| isbn | String | International Standard Book Number |

Example book resource:

```json
{
  "id": 1,
  "title": "Clean Code",
  "author": "Robert C. Martin",
  "publishedYear": 2008,
  "isbn": "9780132350884"
}
```

---

## 2. API Endpoints

### Endpoint 1: List All Books

**HTTP Method:** GET

**Path:** `/books`

**Description:** Retrieves a list of all books available in the library.

**Request Body:** None.

**Success Status Code:** `200 OK`

**Example Request:**

```http
GET /v1/books
```

**Example Response:**

```json
[
  {
    "id": 1,
    "title": "Clean Code",
    "author": "Robert C. Martin",
    "publishedYear": 2008,
    "isbn": "9780132350884"
  },
  {
    "id": 2,
    "title": "The Pragmatic Programmer",
    "author": "Andrew Hunt and David Thomas",
    "publishedYear": 1999,
    "isbn": "9780201616224"
  }
]
```

---

### Endpoint 2: Retrieve a Single Book

**HTTP Method:** GET

**Path:** `/books/{id}`

**Description:** Retrieves the details of a specific book using its unique
identifier. The `{id}` path parameter identifies the requested book.

**Request Body:** None.

**Success Status Code:** `200 OK`

**Example Request:**

```http
GET /v1/books/1
```

**Example Response:**

```json
{
  "id": 1,
  "title": "Clean Code",
  "author": "Robert C. Martin",
  "publishedYear": 2008,
  "isbn": "9780132350884"
}
```

If the specified book does not exist, the API returns `404 Not Found`.

---

### Endpoint 3: Create a New Book

**HTTP Method:** POST

**Path:** `/books`

**Description:** Creates a new book in the library. The server assigns a
unique ID to the new book.

**Request Content-Type:** `application/json`

**Success Status Code:** `201 Created`

**Example Request:**

```http
POST /v1/books
Content-Type: application/json
```

**Request Body:**

```json
{
  "title": "The Pragmatic Programmer",
  "author": "Andrew Hunt and David Thomas",
  "publishedYear": 1999,
  "isbn": "9780201616224"
}
```

**Example Response:**

```json
{
  "id": 2,
  "title": "The Pragmatic Programmer",
  "author": "Andrew Hunt and David Thomas",
  "publishedYear": 1999,
  "isbn": "9780201616224"
}
```

The response includes the newly created resource and its assigned ID.

If required fields are missing or contain invalid values, the API returns
`400 Bad Request`.

---

### Endpoint 4: Update an Existing Book

**HTTP Method:** PUT

**Path:** `/books/{id}`

**Description:** Replaces the details of an existing book identified by
its unique ID.

**Request Content-Type:** `application/json`

**Success Status Code:** `200 OK`

**Example Request:**

```http
PUT /v1/books/1
Content-Type: application/json
```

**Request Body:**

```json
{
  "title": "Clean Code",
  "author": "Robert C. Martin",
  "publishedYear": 2008,
  "isbn": "9780132350884"
}
```

**Example Response:**

```json
{
  "id": 1,
  "title": "Clean Code",
  "author": "Robert C. Martin",
  "publishedYear": 2008,
  "isbn": "9780132350884"
}
```

The response contains the updated book resource.

If the book does not exist, the API returns `404 Not Found`. If the request
contains invalid data, the API returns `400 Bad Request`.

---

### Endpoint 5: Delete a Book

**HTTP Method:** DELETE

**Path:** `/books/{id}`

**Description:** Deletes an existing book identified by its unique ID.

**Request Body:** None.

**Success Status Code:** `204 No Content`

**Example Request:**

```http
DELETE /v1/books/1
```

**Example Response:**

A successful deletion returns HTTP `204 No Content` with no response body.

If the requested book does not exist, the API returns `404 Not Found`.

---

### Endpoint 6: Search Books by Author

**HTTP Method:** GET

**Path:** `/books?author={author}`

**Description:** Retrieves books written by a specified author. The author
is provided through the `author` query parameter.

**Request Body:** None.

**Success Status Code:** `200 OK`

**Example Request:**

```http
GET /v1/books?author=Robert%20C.%20Martin
```

**Example Response:**

```json
[
  {
    "id": 1,
    "title": "Clean Code",
    "author": "Robert C. Martin",
    "publishedYear": 2008,
    "isbn": "9780132350884"
  }
]
```

If no books match the specified author, the API returns `200 OK` with an
empty array.

Example:

```json
[]
```

---

## 3. Error Handling

The API uses HTTP status codes to communicate the outcome of requests.
Error responses contain a JSON object with an error name and a message
describing the problem.

### Error 1: HTTP 400 Bad Request

**Status Code:** `400 Bad Request`

**Description:** Indicates that the server cannot process a request because
the submitted data is invalid, malformed, or missing required fields.

**Example Scenario:**

A client attempts to create a book without providing the required title
and author fields.

**Example Request:**

```http
POST /v1/books
Content-Type: application/json
```

**Request Body:**

```json
{
  "publishedYear": 2020,
  "isbn": "9781234567890"
}
```

**Example Error Response:**

```json
{
  "error": "Bad Request",
  "message": "The title and author fields are required."
}
```

The client should correct the request data before submitting it again.

Another example is providing a string instead of an integer for
`publishedYear` when the API requires an integer.

### Error 2: HTTP 404 Not Found

**Status Code:** `404 Not Found`

**Description:** Indicates that the requested resource does not exist.

**Example Scenario:**

A client requests a book with ID `99`, but the library contains no book
with that identifier.

**Example Request:**

```http
GET /v1/books/99
```

**Example Error Response:**

```json
{
  "error": "Not Found",
  "message": "Book with ID 99 was not found."
}
```

The client can respond by informing the user that the requested book
does not exist.

A `404 Not Found` response can also be returned when a client attempts
to update or delete a book that does not exist.

---

## 4. API Design Considerations

### HTTP Methods

- **GET:** Retrieves resources without modifying them.
- **POST:** Creates a new resource.
- **PUT:** Replaces the details of an existing resource.
- **DELETE:** Removes a resource.

### Path and Query Parameters

- `/books/{id}` uses a path parameter to identify a specific book.
- `/books?author={author}` uses a query parameter to filter books by author.

### Response Codes

- `200 OK`: The request succeeded.
- `201 Created`: A new book was created successfully.
- `204 No Content`: A book was deleted successfully, and no response body
  is returned.
- `400 Bad Request`: The request contains invalid data or is malformed.
- `404 Not Found`: The requested book does not exist.

### Data Format

The API accepts and returns JSON for requests and responses that contain
data. Clients submitting JSON request bodies should use the
`Content-Type: application/json` header.

### Validation

The server should validate required fields and data types before creating
or updating books. It should also verify that the requested book exists
before retrieving, updating, or deleting it.
