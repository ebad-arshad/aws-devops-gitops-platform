# ecommerce-microservice

An ecommerce api with microservice architecture.

## Architecture

This project implements a microservices-based e-commerce application, encompassing user authentication, product management, and order processing. It emphasizes concurrency control, clustering for high availability, and database integration.

- Services:

  - Authentication Service: Manages user registration, login, and access control.
  - Product Service: Handles product creation, retrieval, updates, and deletion.
  - Order Service: Processes order placement, validation, and status updates.
  - API Gateway: Acts as a single entry point for all API requests, routing them to relevant services.

- Technology Stack:

  - Node with Express for microservices.
  - Docker for containerization and deployment.
  - Docker Compose for orchestration.
  - PostgreSQL databases for data storage.
  - RabbitMQ for asynchronous communication.
  - RESTful APIs for communication between services and clients.

### Concurrency Control

- Pessimistic Locking: Implemented pessimistic locking to maintain data integrity when multiple users try to order or update a product.

### Database Integration

- Databases: Three PostgreSQL databases (auth, product, order) for service-specific data.
- Schema Design: Normalized schema for each database ensures data integrity and efficient querying.

### APIs and Communication

- RESTful APIs: Each service exposes well-defined RESTful APIs (e.g., GET, POST, PUT, DELETE) for CRUD operations.
- Authentication: JWT-based authentication for secure access to protected endpoints.
- Authorization: Role-based access control (RBAC) restricts users to their relevant data.
- Communication:
  - Synchronous REST calls for immediate responses.
  - Asynchronous AMQP protocol using RabbitMQ for decoupled interactions.
  - Order service calls product service for details, creates order with pending status, and publishes to product queue for stock update.
  - Product service consumes the product queue, updates stock, and publishes to order queue for status update.

## Prerequisites

- [Docker](https://www.docker.com) installed with docker-compose enabled
- [Postman](https://www.postman.com/downloads/) (for API testing)

## Installation

### Using docker-compose

- Clone the repo
- Run `docker-compose build`
- Run `docker-compose up`.
- The APIs are running on http://localhost:5000

### Using local configuration

- Clone the repo
- Run `npm install` in each service folder (auth, product, order, api-gateway)
- Configure 3 postgres databases and rabbitmq locally
- Create .env file for each service according to .env.example and provide required variables
- Run all the services using `npm start`
- The APIs are running on http://localhost:5000

## Testing

Import the Postman collection in repo inside Postman. It contains all the API endpoints along with payload description.
