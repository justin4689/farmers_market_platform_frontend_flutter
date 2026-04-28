# Farmers Market App — XpertBot Technical Test (Flutter Frontend)

## Project context
Mobile POS operator app for an agricultural marketplace in Côte d'Ivoire.
Operators use this app at points of sale to manage farmer transactions,
record payments, and handle commodity repayments.

## Stack
- Flutter 3.41, Dart
- Riverpod (state management)
- Dio (HTTP client)
- go_router (navigation)
- flutter_secure_storage (token storage)
- shared_preferences (local cache)

## API Base URL
- Local: http://127.0.0.1:8000/api
- Production: [à ajouter après déploiement]

## Color scheme (from XpertBot logo)
- Primary: #1B5E20 (dark green)
- Accent: #F57C00 (orange)
- Background: #FFFFFF
- Surface: #F5F5F5
- Error: #D32F2F

## Architecture
lib/
├── core/
│   ├── constants/         ← colors, strings, api urls
│   ├── exceptions/        ← api exceptions
│   └── widgets/           ← shared widgets
├── features/
│   ├── auth/
│   │   ├── data/          ← repository + api calls
│   │   ├── domain/        ← models
│   │   └── presentation/  ← screens + notifiers
│   ├── farmers/
│   ├── products/
│   ├── transactions/
│   └── repayments/
├── services/
│   └── api_service.dart
└── main.dart

## Screens to build (in order)
1. Login screen
2. Home dashboard (operator menu)
3. Farmer search screen
4. Create farmer screen
5. Farmer profile screen (with debt summary)
6. Product browsing screen (nested categories)
7. Checkout screen (product selection + payment method)
8. Repayment screen (kg input + FCFA conversion)

## API endpoints used by the app
POST   /api/login
POST   /api/logout
GET    /api/farmers/search?q=
GET    /api/farmers/{id}
POST   /api/farmers
GET    /api/categories
GET    /api/products
POST   /api/transactions
GET    /api/farmers/{id}/debts
POST   /api/repayments

## Coding rules
- Always use Riverpod for state management
- Always use Dio via ApiService for HTTP calls
- Never call the API directly from a widget
- Always handle loading, error, and success states
- Always show user-friendly error messages in French
- Use go_router for all navigation
- Target both phone and tablet (responsive UI)

## Auth flow
- Token stored securely with flutter_secure_storage
- On app start: check if token exists → redirect to home or login
- On 401 response: clear token → redirect to login

## Demo credentials
- Operator: operator1@xpertbot.com / password
- Supervisor: supervisor1@xpertbot.com / password
- Admin: admin@xpertbot.com / password

## Deadline
Saturday, May 2, 2026

## Deliverables
1. Public GitHub repo with clean commit history + README
2. Flutter Web built and deployed on GitHub Pages
3. YouTube walkthrough video
4. Submission on https://xpertbotacademy.online/project-submission