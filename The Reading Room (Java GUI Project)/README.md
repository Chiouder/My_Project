# The Reading Room (Java GUI Project)

This project was developed as part of a Java course to practice object-oriented programming (OOP) principles and programming design patterns. It uses:
- **JavaFX 23.0.0** for the graphical interface
- **JDBC 3.46.1.3** for database connectivity
- **JUnit 5.11.2** for testing

## Project Features
Below is a brief overview of the main features of the project.
### Login Page
- Users can log in using a registered **username** (unique) and **password**, verified against database records.
- If the fields are empty or the credentials are incorrect, an error message prompts the user to re-enter valid information.
- A **Sign Up** option allows new users to create an account. Upon successful registration, a new shopping cart is automatically created for the user in the database.
![Login Page](https://github.com/Chiouder/My_Project/blob/main/The%20Reading%20Room%20(Java%20GUI%20Project)/LoginPage.png)

### Main Page
- Upon successful login, users are directed to the **main page**, which displays a personalized welcome message based on their username.
- The main page retrieves and displays the user’s **shopping cart** and **order history**.
- It also showcases the **top 7 best-selling books**. Users can select books and specify quantities to add to their cart.
- The quantity added to the cart cannot exceed the available **stock** for each book.
![Main Page](https://github.com/Chiouder/My_Project/blob/main/The%20Reading%20Room%20(Java%20GUI%20Project)/MainPage.png)

### Shopping Cart Page
- Each user has a unique shopping cart to track their activity during the session.
- Users can adjust item quantities, with the same restrictions as on the Main Page regarding stock limits.
- Items can be removed from the cart if the user no longer wishes to purchase them.
- When users click the checkout button, the system calculates the total price.
- After reviewing the price, users can choose to proceed to payment or cancel the transaction.
![ShoppingCart Page](https://github.com/Chiouder/My_Project/blob/main/The%20Reading%20Room%20(Java%20GUI%20Project)/ShoppingCartPage.png)

### Payment Page
- This page simulates a card payment process, validating the entered payment information.
  - **Card number** – Must be exactly 16 digits.
  - **Expiry date** – Requires two digits (01-12) for MM, and a four-digit year (YYYY) that must be in the future.
  - **CVC** – Must be three digits.
- Upon successful payment, the system generates an order number, updates stock quantities for the purchased items, and adjusts sales figures accordingly.

### Order History Page
- All completed checkout orders are displayed here for the user.
- Each order can be expanded or collapsed to view detailed information.
- Users can select specific orders and export them as a CSV file.
![OrderHistory Page](https://github.com/Chiouder/My_Project/blob/main/The%20Reading%20Room%20(Java%20GUI%20Project)/OrderHistoryPage.png)



