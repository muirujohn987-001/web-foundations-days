// 1. Select HTML elements
const loadButton = document.querySelector("#load-users");
const filterInput = document.querySelector("#filter-input");
const statusMessage = document.querySelector("#status");
const usersList = document.querySelector("#users-list");

// 2. Store users received from the API
let users = [];

// 3. Fetch users from the API
async function loadUsers() {
    loadButton.disabled = true;
    statusMessage.textContent = "Loading users...";

    try {
        // Send a GET request to the API
        const response = await fetch(
            "https://jsonplaceholder.typicode.com/users"
        );

        // Handle unsuccessful HTTP responses
        if (!response.ok) {
            throw new Error(`HTTP error: ${response.status}`);
        }

        // Convert the JSON response into JavaScript data
        const data = await response.json();

        // Store the fetched users
        users = data;

        // Display users matching the current search
        filterUsers();

        statusMessage.textContent =
            `Successfully loaded ${users.length} users.`;

    } catch (error) {
        // Handle network errors and HTTP errors
        users = [];
        usersList.replaceChildren();

        statusMessage.textContent =
            "Failed to load users. Please try again.";

        console.error("Error loading users:", error);

    } finally {
        // Re-enable the button whether the request succeeds or fails
        loadButton.disabled = false;
    }
}

// 4. Display users on the webpage
function renderUsers(userList) {
    // Remove previously displayed users
    usersList.replaceChildren();

    // Display a message when there are no matching users
    if (userList.length === 0) {
        const message = document.createElement("li");
        message.textContent = "No users match your filter.";
        usersList.appendChild(message);
        return;
    }

    // Create a list item for each user
    userList.forEach(function (user) {
        const listItem = document.createElement("li");

        const name = document.createElement("h3");
        name.textContent = user.name;

        const email = document.createElement("p");
        email.textContent = `Email: ${user.email}`;

        const city = document.createElement("p");
        city.textContent = `City: ${user.address.city}`;

        const company = document.createElement("p");
        company.textContent = `Company: ${user.company.name}`;

        // Add the details to the user's list item
        listItem.append(name, email, city, company);

        // Add the completed item to the webpage
        usersList.appendChild(listItem);
    });
}

// 5. Filter users using the stored array
function filterUsers() {
    const searchTerm = filterInput.value.trim().toLowerCase();

    const filteredUsers = users.filter(function (user) {
        return user.name.toLowerCase().includes(searchTerm);
    });

    renderUsers(filteredUsers);
}

// 6. Load users when the button is clicked
loadButton.addEventListener("click", loadUsers);

// 7. Filter automatically as the user types
filterInput.addEventListener("input", filterUsers);
