# ServiceOps

ServiceOps is a Ruby on Rails service order management system for technical assistance businesses.

It helps teams manage customers, service orders, diagnostics, quotes, approvals, payments and status tracking in a simple operational backoffice.

## Purpose

This project was built to practice real-world backend development with Ruby on Rails.

The goal is not to create a generic CRUD app, but to model a real business workflow:

```txt
Customer request
→ Technical diagnosis
→ Quote generation
→ Customer approval
→ Service execution
→ Payment
→ Completion
```

## Main features

```txt
Customer management
Service category management
Service order creation
Technician assignment
Technical diagnosis
Quote generation
Quote items
Customer quote approval
Public service order tracking
Status history
File attachments
Email notifications
Simulated payments
Dashboard metrics
```

## Tech stack

```txt
Ruby
Ruby on Rails
PostgreSQL
Hotwire/Turbo
Tailwind CSS
Active Record
Active Storage
Active Job
Solid Queue
Docker
```

## Domain overview

Main entities:

```txt
User
Customer
ServiceCategory
ServiceOrder
Diagnostic
Quote
QuoteItem
StatusHistory
Payment
```

Main service order statuses:

```txt
opened
in_diagnosis
waiting_quote_approval
quote_approved
quote_rejected
in_progress
waiting_payment
done
cancelled
```

Main quote statuses:

```txt
draft
sent
approved
rejected
expired
```

## Business rules

```txt
A service order must belong to a customer.
A service order must have a service category.
A service order starts as opened.
A service order cannot jump to any random status.
Every status change must create a history record.
A quote total is calculated from its items minus discount.
A quote can only be approved when it is sent.
A service order can only move to in_progress after quote approval.
A service order can only be completed after payment.
Public tracking URLs must use tokens instead of internal IDs.
```

## Suggested workflow

```txt
1. Create a customer
2. Create a service category
3. Open a service order
4. Assign a technician
5. Register a diagnosis
6. Generate a quote
7. Send quote to customer
8. Customer approves quote through public tracking link
9. Move service order to execution
10. Register payment
11. Complete service order
```

## Getting started

### Requirements

```txt
Ruby 3.4+
Rails 8+
PostgreSQL
Docker and Docker Compose
```

### Clone the repository

```bash
git clone https://github.com/your-user/service-ops.git
cd service-ops
```

### Install dependencies

```bash
bundle install
```

### Setup the database

```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

### Run the server

```bash
bin/rails server
```

Open:

```txt
http://localhost:3000
```

## Docker database

Example `docker-compose.yml` for PostgreSQL:

```yaml
services:
  postgres:
    image: postgres:17
    container_name: service_ops_postgres
    environment:
      POSTGRES_USER: service_ops
      POSTGRES_PASSWORD: service_ops
      POSTGRES_DB: service_ops_development
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

Start PostgreSQL:

```bash
docker compose up -d
```

## Project structure

```txt
app/models
app/controllers
app/views
app/services
app/jobs
app/mailers
config/routes.rb
db/migrate
db/seeds.rb
```

Suggested service objects:

```txt
ServiceOrders::CreateService
ServiceOrders::UpdateStatusService
ServiceOrders::CancelService
Quotes::GenerateService
Quotes::ApproveService
Quotes::RejectService
Payments::SimulateService
Notifications::SendQuoteEmailService
```

## Roadmap

```txt
[ ] Initialize Rails app
[ ] Configure PostgreSQL
[ ] Add Docker Compose
[ ] Add customer CRUD
[ ] Add service category CRUD
[ ] Add authentication
[ ] Add user roles
[ ] Add service orders
[ ] Add technical diagnosis
[ ] Add quotes and quote items
[ ] Add quote approval workflow
[ ] Add status history
[ ] Add public tracking page
[ ] Add file attachments
[ ] Add email notifications
[ ] Add simulated payments
[ ] Add dashboard metrics
[ ] Add automated tests
[ ] Add seeds
[ ] Deploy
```

## Future improvements

```txt
Multi-company support
Inventory control for parts
Quote PDF generation
CSV export
Kanban board for service orders
Internal comments
Realtime notifications
WhatsApp integration
Real payment gateway integration
JSON API
Mobile app
```

## Learning goals

This project is intended to practice:

```txt
Ruby syntax
Rails MVC
Active Record associations
PostgreSQL modeling
Validations
Service objects
Status workflows
Background jobs
Email delivery
File uploads
Public token-based access
Automated tests
Production-ready README structure
```

## License

MIT
