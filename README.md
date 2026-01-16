# Hospital Management System

A comprehensive, full-stack hospital management system built with **Flutter** (frontend) and **Node.js/Express** (backend), featuring PostgreSQL database integration, JWT authentication, and role-based access control.

## ⚠️ Implementation Status: IN PROGRESS

### Current state
The repository is actively developed and contains a Flutter frontend and a Node.js/TypeScript backend. The application implements authentication, role-based dashboards, appointment scheduling, patient management, prescriptions, pharmacy inventory, laboratory orders and results, billing, reporting, notifications, and developer/demo tools (including deterministic demo user names and mock API responses).

The codebase includes demo data seeding scripts and automated tests. Static analysis and test tools are available; run `flutter analyze` and `npx tsc --noEmit` locally to inspect issues.

## 🚀 Quick Start

### 1. Start Backend Server
```powershell
# Navigate to backend
cd hospital_backend

# Install dependencies
npm install

# Run migrations
npx prisma migrate dev

# Start server
npm run dev
```

Backend will run on: http://localhost:3000

### 2. Start Frontend Application
```powershell
# Navigate to frontend
cd hospital_app

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### 3. Seed All Demo Data (One Command!)
```powershell
cd hospital_backend
npx ts-node prisma/seeds/completeSystem.seed.ts
```

This will seed:
- ✅ 58 Medicines across 16 categories
- ✅ 217 Prescriptions with realistic data
- ✅ 296 Lab Tests & Results
- ✅ 230 Hospital Beds across 7 wards
- ✅ 150 Bills with $32K revenue
- ✅ 498 Appointments
- ✅ 550 Users across 7 roles

## 📊 Complete Feature Set

### Authentication & Security
- **JWT-based authentication** with refresh token support
- **Role-based access control** (7 distinct roles)
- **Secure password hashing** using bcrypt
- **Session management** with automatic token refresh
- **Rate limiting** and **CORS protection**
- **Forgot password** functionality with email recovery
- **Two-factor authentication** support
- **Login history tracking** and session management
- **Password strength validation** with comprehensive requirements
- **Remember me** functionality for persistent sessions

### User Roles & Access Control
- **ADMIN** - Full system access and administration capabilities
- **DOCTOR** - Medical professional access with patient management
- **NURSE** - Nursing staff access for patient care coordination
- **PHARMACIST** - Pharmacy management and prescription handling
- **LABORATORY** - Laboratory operations and test result management
- **RECEPTIONIST** - Front desk operations and patient registration
- **PATIENT** - Patient portal with access to personal medical records

### Role-Based Data Visibility
- **Patient Role**: Can see own medical records, appointments, billing
- **Doctor Role**: Access to assigned patients' full medical records
- **Nurse Role**: Patient vitals, care plans, medication schedules
- **Receptionist**: Patient demographics, appointments, billing status
- **Pharmacist**: Prescription processing, medication inventory
- **Lab Staff**: Test orders, results entry, equipment management
- **Admin**: Full system access, user management, analytics

### Medicine Inventory System (58 Medicines)
- Complete medicine database across 16 categories:
  - ANTIBIOTIC (5): Amoxicillin, Azithromycin, Ciprofloxacin, etc.
  - ANALGESIC (5): Paracetamol, Ibuprofen, Tramadol, Morphine, etc.
  - ANTIPYRETIC (2): Aspirin, Mefenamic Acid
  - ANTACID (3): Omeprazole, Ranitidine, Pantoprazole
  - ANTIHISTAMINE (3): Cetirizine, Loratadine, Fexofenadine
  - ANTIDIABETIC (4): Metformin, Glibenclamide, Insulin, Sitagliptin
  - ANTIHYPERTENSIVE (4): Amlodipine, Losartan, Atenolol, Enalapril
  - CARDIOVASCULAR (4): Atorvastatin, Clopidogrel, Digoxin, Warfarin
  - RESPIRATORY (4): Salbutamol, Montelukast, Budesonide, Ambroxol
  - GASTROINTESTINAL (4): Loperamide, Ondansetron, Domperidone, Lactulose
  - DERMATOLOGICAL (4): Hydrocortisone, Clotrimazole, Betamethasone, Mupirocin
  - NEUROLOGICAL (4): Gabapentin, Levetiracetam, Carbamazepine, Diazepam
  - VITAMINS (4): B Complex, Vitamin D3, Vitamin C, Folic Acid
  - SUPPLEMENTS (4): Calcium, Iron, Zinc, Omega-3
  - EMERGENCY (4): Epinephrine, Atropine, Naloxone, Dextrose 50%
  - OTHER
- Low stock alerts (20% threshold)
- Expiry date tracking and alerts
- Prescription-only vs over-the-counter classification

### Prescription System (217 Prescriptions)
- Digital prescription creation and management
- Medication dosage and frequency tracking
- Prescription history and refill management
- Integration with medicine inventory
- Doctor-patient prescription relationships

### Laboratory Management (296 Tests)
- Comprehensive test catalog across multiple categories:
  - HEMATOLOGY: CBC, Blood counts, Coagulation studies
  - BIOCHEMISTRY: Liver function, Kidney function, Cardiac markers
  - MICROBIOLOGY: Cultures, Sensitivity testing, Gram staining
  - IMMUNOLOGY: Hepatitis panel, HIV testing, Autoimmune markers
  - RADIOLOGY: X-rays, CT scans, MRI, Ultrasound
  - PATHOLOGY: Biopsies, Cytology, Histopathology
- Test result entry and reporting
- Normal range validation
- Critical value alerts

### Hospital Bed Management (230 Beds)
- 7 Ward types with specialized bed configurations:
  - GENERAL: 50 beds (2-4 bed rooms)
  - ICU: 20 beds (single rooms, ventilator equipped)
  - CARDIAC: 25 beds (cardiac monitoring)
  - PEDIATRIC: 30 beds (child-friendly environment)
  - MATERNITY: 35 beds (delivery and recovery rooms)
  - SURGICAL: 40 beds (post-operative care)
  - EMERGENCY: 30 beds (trauma and emergency care)
- Real-time bed availability tracking
- Patient admission and discharge management
- Bed assignment optimization

### Billing System (150 Bills, $32K Revenue)
- Comprehensive billing with multiple charge types:
  - CONSULTATION: Doctor consultation fees
  - PROCEDURE: Medical procedures and surgeries
  - MEDICATION: Pharmacy charges
  - LAB_TEST: Laboratory test fees
  - ROOM_CHARGE: Hospital stay charges
  - EMERGENCY: Emergency service fees
- Insurance integration and processing
- Payment tracking and receipt generation
- Revenue analytics and reporting

### Appointment System (498 Appointments)
- Real-time appointment scheduling with PostgreSQL backend
- Advanced filtering by date, doctor, department, and status
- Appointment status tracking (scheduled, completed, cancelled)
- Calendar integration with visual appointment overview
- Conflict detection and automatic scheduling
- Multi-status support: SCHEDULED, CONFIRMED, IN_PROGRESS, COMPLETED, CANCELLED, NO_SHOW

### User Management (550 Users)
- Multi-role user system with granular permissions
- Patient registration and profile management
- Healthcare provider management (doctors, nurses, staff)
- User profile updates and medical history tracking
- Account creation, login, logout, and deletion features
- Profile management and security settings

### Dashboard & Analytics
- Role-specific dashboards with relevant metrics
- Real-time statistics and hospital analytics
- Appointment trends and patient flow insights
- Performance metrics for healthcare providers
- Revenue and billing analytics
- Notification system with real-time updates
- Dark mode support with theme persistence

### Advanced Features
- **Cross-Platform Support**: Web, Mobile (Android/iOS), Desktop (Windows/macOS/Linux)
- **Responsive Design**: Adapts to all screen sizes
- **Performance Optimization**: Lazy loading, caching, memory management
- **Data Export**: GDPR-compliant data export functionality
- **Audit Logging**: Comprehensive activity tracking
- **Backup & Recovery**: Automated database backups
- **API Documentation**: Comprehensive REST API documentation

## Technology Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.x with Dart
- **State Management**: Riverpod for reactive state management
- **UI Framework**: Material Design 3 components
- **HTTP Client**: Dio for API communication
- **Local Storage**: SharedPreferences for app settings
- **Testing**: flutter_test with widget and integration tests
- **Architecture**: Clean architecture with feature-based organization

### Backend (Node.js)
- **Runtime**: Node.js 18+ with Express.js framework
- **Language**: TypeScript for type safety
- **Database ORM**: Prisma for PostgreSQL integration
- **Authentication**: JWT with jsonwebtoken library
- **Validation**: Zod for comprehensive input validation
- **Security**: bcrypt, helmet, cors, rate limiting
- **Logging**: Winston for structured logging
- **Testing**: Jest for unit and integration testing
- **API Documentation**: Swagger/OpenAPI integration

### Database & Infrastructure
- **Database**: PostgreSQL 14+ with ACID compliance
- **ORM**: Prisma with migration system and seeding
- **Containerization**: Docker and Docker Compose
- **Version Control**: Git with conventional commits
- **Environment**: Environment-based configuration
- **Monitoring**: Health checks and performance monitoring

## Security Features

### Authentication & Authorization
- JWT tokens with refresh token rotation
- Role-based access control (RBAC) with 7 distinct roles
- Secure password hashing with bcrypt (12 rounds)
- Session management with automatic token refresh
- Password strength validation and enforcement
- Account lockout after failed login attempts
- Two-factor authentication support

### Data Protection
- Input validation and sanitization
- SQL injection prevention through Prisma ORM
- XSS protection with proper data encoding
- CORS configuration for cross-origin requests
- Rate limiting to prevent abuse
- Secure headers with helmet middleware
- Environment variable protection

### Access Control
- Role-based data filtering at API level
- Field-level access control for sensitive data
- Patient data privacy protection
- Medical record confidentiality
- Audit logging for all data access
- Permission-based UI component rendering

## Project Structure

```
Hospital_Management_System/
├── hospital_app/                 # Flutter Frontend
│   ├── lib/
│   │   ├── core/                # Core functionality
│   │   │   ├── config/          # App configuration
│   │   │   ├── models/          # Data models
│   │   │   ├── services/        # API and business services
│   │   │   ├── providers/       # State management
│   │   │   └── widgets/         # Reusable UI components
│   │   └── features/            # Feature-based organization
│   │       ├── auth/            # Authentication
│   │       ├── dashboard/       # Role-based dashboards
│   │       ├── appointments/    # Appointment management
│   │       ├── pharmacy/        # Pharmacy operations
│   │       ├── laboratory/      # Lab management
│   │       ├── admin/           # Admin functions
│   │       └── medical/         # Medical records
│   └── test/                    # Testing files
├── hospital_backend/            # Node.js Backend
│   ├── src/
│   │   ├── modules/             # Feature modules
│   │   ├── middleware/          # Express middleware
│   │   ├── routes/              # API routes
│   │   ├── types/               # TypeScript definitions
│   │   └── utils/               # Utility functions
│   ├── prisma/                  # Database schema and migrations
│   │   ├── schema.prisma        # Database schema
│   │   ├── migrations/          # Database migrations
│   │   └── seeds/               # Demo data seeds
│   └── logs/                    # Application logs
└── Documentation/               # Project documentation
```

## API Endpoints

### Authentication
- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `POST /auth/refresh` - Token refresh
- `POST /auth/logout` - User logout
- `POST /auth/forgot-password` - Password recovery

### User Management
- `GET /users` - List users (role-based filtering)
- `GET /users/:id` - Get user details
- `PUT /users/:id` - Update user profile
- `DELETE /users/:id` - Delete user account

### Appointments
- `GET /appointments` - List appointments
- `POST /appointments` - Create appointment
- `PUT /appointments/:id` - Update appointment
- `DELETE /appointments/:id` - Cancel appointment

### Medical Records
- `GET /patients/:id/records` - Get patient records
- `POST /patients/:id/records` - Add medical record
- `PUT /records/:id` - Update record
- `GET /prescriptions` - List prescriptions

### Pharmacy
- `GET /medicines` - List medicines
- `GET /medicines/:id` - Get medicine details
- `PUT /medicines/:id` - Update inventory
- `POST /prescriptions/:id/dispense` - Dispense medication

### Laboratory
- `GET /lab-tests` - List available tests
- `POST /lab-orders` - Create test order
- `GET /lab-results/:id` - Get test results
- `PUT /lab-results/:id` - Update results

### Billing
- `GET /bills` - List bills
- `POST /bills` - Create bill
- `PUT /bills/:id/payment` - Process payment
- `GET /revenue-analytics` - Revenue reports

## Developer Mode Features

### Quick Demo Access
- Instant login without authentication
- Pre-populated demo data for all roles
- Mock API responses for offline development
- Fast navigation between different user roles
- Realistic data simulation for UI testing

### Development Tools
- Performance monitoring and optimization
- Memory usage tracking
- API response time monitoring
- Error boundary implementation
- Debug logging and analytics

## Production Deployment

### Environment Setup
```bash
# Backend environment variables
NODE_ENV=production
DATABASE_URL=postgresql://username:password@localhost:5432/hospital_db
JWT_SECRET=your-super-secure-jwt-secret
JWT_REFRESH_SECRET=your-super-secure-refresh-secret
CORS_ORIGIN=https://yourdomain.com

# Frontend environment
FLUTTER_ENV=production
API_BASE_URL=https://api.yourdomain.com
```

### Docker Deployment
```bash
# Build and run with Docker Compose
docker-compose up -d

# Or build individually
docker build -t hospital-backend ./hospital_backend
docker build -t hospital-frontend ./hospital_app
```

### Database Migration
```bash
# Run migrations in production
npx prisma migrate deploy

# Seed production data (optional)
npx prisma db seed
```

## Testing

### Backend Testing
```bash
cd hospital_backend
npm test                    # Run all tests
npm run test:watch         # Watch mode
npm run test:coverage      # Coverage report
```

### Frontend Testing
```bash
cd hospital_app
flutter test               # Unit tests
flutter test integration_test/  # Integration tests
flutter test --coverage   # Coverage report
```

## Contributing

### Development Setup
1. **Clone the repository**
   ```bash
   git clone https://github.com/ENTISHAR-RASHID-CHOWDHURY/Hospital_Management_System.git
   cd Hospital_Management_System
   ```

2. **Setup Backend**
   ```bash
   cd hospital_backend
   npm install
   npx prisma migrate dev
   npx prisma db seed
   npm run dev
   ```

3. **Setup Frontend**
   ```bash
   cd hospital_app
   flutter pub get
   flutter run
   ```

### Code Standards
- **TypeScript**: Strict mode enabled with comprehensive type checking
- **Dart**: Follow official Dart style guide with flutter_lints
- **Git**: Conventional commits with semantic versioning
- **Testing**: Minimum 80% code coverage required
- **Documentation**: JSDoc for TypeScript, DartDoc for Dart

### Pull Request Process
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes with tests
4. Ensure all tests pass
5. Update documentation as needed
6. Commit your changes (`git commit -m 'feat: add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## Security Policy

### Supported Versions
| Version | Supported          |
| ------- | ------------------ |
| 1.3.x   | ✅ Yes             |
| 1.2.x   | ✅ Yes             |
| 1.1.x   | ❌ No              |
| < 1.1   | ❌ No              |

### Reporting Vulnerabilities
**Please do NOT report security vulnerabilities using public GitHub issues.**

For security issues, please email: security@yourdomain.com

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Affected versions
- Your contact information

**Response Timeline:**
- Initial Response: Within 24 hours
- Assessment: Within 72 hours
- Fix Development: 1-2 weeks
- Patch Release: As soon as possible

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

### Documentation
- **API Documentation**: Available at `/docs` when backend is running
- **Flutter Documentation**: Run `flutter doctor` for setup help
- **Database Schema**: Check `prisma/schema.prisma` for complete data model

### Getting Help
- **Issues**: Create a GitHub issue for bugs or feature requests
- **Discussions**: Use GitHub Discussions for questions
- **Wiki**: Check the project Wiki for detailed guides

### Contact
- **Author**: ENTISHAR-RASHID-CHOWDHURY
- **Repository**: [Hospital_Management_System](https://github.com/ENTISHAR-RASHID-CHOWDHURY/Hospital_Management_System)
- **Version**: 1.3.0
- **Last Updated**: October 2025

---

## 🎯 Key Highlights

✅ **Complete Implementation** - All major hospital management features  
✅ **2,000+ Database Records** - Realistic demo data across all modules  
✅ **7 User Roles** - Comprehensive role-based access control  
✅ **Cross-Platform** - Web, Mobile, and Desktop support  
✅ **Production Ready** - Security, testing, and deployment configured  
✅ **Modern Tech Stack** - Flutter, Node.js, TypeScript, PostgreSQL  
✅ **Comprehensive Testing** - Unit, integration, and widget tests  
✅ **Professional UI/UX** - Material Design 3 with responsive layouts  

**Ready for immediate deployment and use in healthcare environments!**

### Prerequisites

Ensure you have the following installed:
- **Node.js** 18.0 or higher
- **Flutter SDK** 3.0 or higher  
- **PostgreSQL** 14.0 or higher
- **Git** latest version

### Backend Setup

1. **Clone and navigate to backend**
   ```bash
   git clone https://github.com/yourusername/Hospital_Management_System.git
   cd Hospital_Management_System/hospital_backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Environment configuration**
   
   Create `.env` file in the backend directory:
   ```env
   # Database Configuration
   DATABASE_URL="postgresql://username:password@localhost:5432/hospital_db"
   
   # JWT Configuration
   JWT_SECRET="your-256-bit-secret-key-here"
   JWT_EXPIRES_IN="15m"
   JWT_REFRESH_SECRET="your-refresh-secret-key"
   JWT_REFRESH_EXPIRES_IN="7d"
   
   # Server Configuration
   PORT=3001
   NODE_ENV="development"
   
   # Security Configuration
   BCRYPT_ROUNDS=12
   
   # Logging
   LOG_LEVEL="info"
   ENABLE_AUDIT_LOGS="true"
   
   # Rate Limiting
   RATE_LIMIT_WINDOW_MS=900000
   RATE_LIMIT_MAX_REQUESTS=100
   
   # CORS
   FRONTEND_URL="http://localhost:3000"
   ```

4. **Database setup**
   ```bash
   # Generate Prisma client
   npx prisma generate
   
   # Apply database migrations
   npx prisma migrate dev --name init
   
   # Seed database with demo data
   npx prisma db seed
   ```

5. **Start development server**
   ```bash
   npm run dev
   ```
   
   Backend running at `http://localhost:3001`

### Frontend Setup

1. **Navigate to Flutter directory**
   ```bash
   cd ../hospital_app
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoints**
   
   The app automatically detects your platform:
   - **Desktop/Web**: `http://localhost:3001`
   - **Android Emulator**: `http://10.0.2.2:3001`
   - **iOS Simulator**: `http://localhost:3001`
   - **Physical Device**: Configure in app settings

4. **Run the application**
   ```bash
   # Web development
   flutter run -d web-server --web-port 3000
   
   # Android development  
   flutter run -d android
   
   # iOS development (macOS only)
   flutter run -d ios
   
   # Desktop development
   flutter run -d windows  # or macos/linux
   ```
   
   Frontend running at `http://localhost:3000`

### Docker Setup (Alternative)

For a quick containerized setup:

```bash
cd hospital_backend
docker-compose up -d
```

This starts:
- **PostgreSQL** database on port 5432
- **Backend API** on port 3001

## Project Architecture

```
Hospital_Management_System/
├── hospital_app/                    # Flutter Frontend
│   ├── lib/
│   │   ├── core/                   # Core functionality
│   │   │   ├── config/                # App configuration
│   │   │   ├── constants/             # App constants  
│   │   │   ├── services/              # API & external services
│   │   │   ├── theme/                 # UI themes & styling
│   │   │   └── utils/                 # Utility functions
│   │   ├── features/               # Feature modules
│   │   │   ├── auth/                  # Authentication
│   │   │   │   ├── data/              # Data sources & models
│   │   │   │   ├── domain/            # Business logic
│   │   │   │   └── presentation/      # UI components
│   │   │   ├── account/               # Account management
│   │   │   │   ├── screens/           # Create, login, delete, management screens
│   │   │   │   └── services/          # Account API service
│   │   │   ├── appointments/          # Appointment management
│   │   │   ├── patients/              # Patient management
│   │   │   ├── doctors/               # Doctor management
│   │   │   ├── pharmacy/              # Pharmacy management
│   │   │   └── dashboard/             # Dashboard & analytics
│   │   └── main.dart                  # App entry point
│   ├── test/                       # Flutter tests
│   ├── web/                        # Web-specific files
│   └── pubspec.yaml                # Dependencies
│
├── hospital_backend/               # Node.js Backend  
│   ├── src/
│   │   ├── config/                 # Configuration files
│   │   ├── middleware/             # Express middleware
│   │   ├── modules/                # Feature modules
│   │   ├── routes/                 # API route definitions
│   │   ├── types/                  # TypeScript type definitions
│   │   ├── utils/                  # Utility functions
│   │   └── app.ts                     # Express application setup
│   ├── prisma/                     # Database configuration
│   │   ├── schema.prisma              # Database schema
│   │   ├── migrations/                # Database migrations
│   │   └── seed.ts                    # Database seeding
│   ├── tests/                      # Backend tests
│   ├── package.json                # Node.js dependencies
│   └── docker-compose.yml          # Docker configuration
│
├── docs/                           # Documentation
├── README.md                       # Project documentation
├── LICENSE                         # MIT License
└── CONTRIBUTING.md                 # Contribution guidelines
```

## Account Management System

### Overview
Complete account lifecycle management with 4 dedicated screens and comprehensive API integration.

### Screens

#### 1. Create Account Screen
- Personal information collection (first name, last name, phone)
- Email validation with real-time feedback
- Role selection from 9 available roles
- Password strength validation
- Password confirmation matching
- Terms and conditions acceptance
- Auto-login after successful registration
- Beautiful gradient UI with Material Design 3

#### 2. Login Screen
- Email and password authentication
- Remember me functionality for persistent sessions
- Forgot password dialog with email recovery
- Social login buttons (Google, Apple - coming soon)
- Quick demo login with pre-filled credentials for all 9 roles
- Password visibility toggle
- Loading states with indicators
- User-friendly error messages

#### 3. Delete Account Screen
- Warning messages with danger zone indicators
- User profile information display
- Comprehensive data deletion preview
- Deletion reason selection (6 options)
- Additional comments field
- Password confirmation requirement
- Explicit consent checkbox
- Two-step confirmation dialog
- Alternative options (deactivate, privacy settings, support)

#### 4. Account Management Screen
- Profile header with avatar, name, email, role
- Edit profile and change password
- Privacy and notification settings
- Session management (active sessions, trusted devices)
- Security features (2FA setup, login history)
- Data management (download data, export history)
- Logout with confirmation
- Delete account navigation

### Developer Mode Demo Accounts

Demo accounts are **only available in Developer Mode** for role-playing and testing:

```
Access via: Developer Mode → Character Selection
- 255+ demo users across all roles for comprehensive testing
- Role-playing capabilities to test different permissions
- Isolated from production login system
```

Note: These accounts are not accessible through regular login to maintain security.

### Security Features

#### Password Requirements
- Minimum 6 characters
- Contains uppercase letter (A-Z)
- Contains lowercase letter (a-z)
- Contains at least one number (0-9)

#### Account Protection
- Password confirmation for account deletion
- Two-step confirmation for dangerous operations
- Deletion reason tracking
- Account recovery options

#### Session Management
- JWT token-based authentication
- Refresh token support
- Remember me functionality
- Auto-logout on token expiration

#### Data Privacy
- GDPR-compliant data export
- Clear data deletion preview
- Privacy settings management
- Terms and conditions acceptance

### API Integration

The Account API Service provides 30+ endpoints:

- Registration and authentication
- Profile management with picture upload
- Password management (change, reset, forgot)
- Email verification
- Session and device management
- Two-factor authentication
- Login history tracking
- Notification and privacy preferences
- Data export and account deactivation

### Usage

Navigate to account screens programmatically:

```dart
// Create Account
Navigator.push(context, MaterialPageRoute(
  builder: (context) => const CreateAccountScreen(),
));

// Login
Navigator.push(context, MaterialPageRoute(
  builder: (context) => const LoginScreen(),
));

// Account Management
Navigator.push(context, MaterialPageRoute(
  builder: (context) => const AccountManagementScreen(),
));

// Logout
await ref.read(authProvider.notifier).logout();
```

## Getting Started

After completing the setup steps above, you can:

1. **Access the Application**
   - Open your browser and navigate to `http://localhost:3000`
   - Login with admin credentials created during database seeding
   - Explore the different features based on your role

2. **Create User Accounts**
   - Admin users can create new accounts for staff members
   - Staff can register new patients through the system
   - Use the user management interface to assign roles

3. **Production Deployment**
   - Configure environment variables for production
   - Set up proper SSL certificates
   - Configure email services for notifications
   - Set up automated backups
   - Enable monitoring and logging

## API Documentation

### Authentication Endpoints
```
POST   /api/auth/register          # Create new user account
POST   /api/auth/login             # User authentication
POST   /api/auth/refresh           # Token refresh
POST   /api/auth/logout            # User logout
GET    /api/auth/me                # Current user profile
POST   /api/auth/change-password   # Change user password
POST   /api/auth/forgot-password   # Request password reset
POST   /api/auth/reset-password    # Reset password with token
DELETE /api/auth/account            # Delete user account
```

### Account Management Endpoints
```
GET    /api/auth/profile                      # Get user profile
PUT    /api/auth/profile                      # Update user profile
POST   /api/auth/upload-profile-picture       # Upload profile image
DELETE /api/auth/profile-picture              # Delete profile image
GET    /api/auth/sessions                     # Get active sessions
DELETE /api/auth/sessions/:id                 # Revoke specific session
DELETE /api/auth/sessions/revoke-all          # Revoke all other sessions
GET    /api/auth/devices                      # Get trusted devices
DELETE /api/auth/devices/:id                  # Remove trusted device
POST   /api/auth/2fa/enable                   # Enable two-factor auth
POST   /api/auth/2fa/verify                   # Verify 2FA code
POST   /api/auth/2fa/disable                  # Disable two-factor auth
GET    /api/auth/login-history                # Get login history
GET    /api/auth/notification-preferences     # Get notification settings
PUT    /api/auth/notification-preferences     # Update notification settings
GET    /api/auth/privacy-settings             # Get privacy settings
PUT    /api/auth/privacy-settings             # Update privacy settings
POST   /api/auth/export-data                  # Request data export (GDPR)
GET    /api/auth/export-history               # Get export history
POST   /api/auth/deactivate                   # Deactivate account
POST   /api/auth/reactivate                   # Reactivate account
GET    /api/auth/check-email                  # Check email availability
```

### Appointment Management
```
GET    /api/appointments              # List appointments (with filters)
POST   /api/appointments              # Create new appointment
GET    /api/appointments/:id          # Get appointment details
PUT    /api/appointments/:id          # Update appointment
DELETE /api/appointments/:id          # Cancel appointment
GET    /api/appointments/calendar     # Calendar view data
```

### Patient Management
```
GET    /api/patients                  # List all patients
POST   /api/patients                  # Register new patient
GET    /api/patients/:id              # Get patient details
PUT    /api/patients/:id              # Update patient information
DELETE /api/patients/:id              # Remove patient record
GET    /api/patients/:id/history      # Medical history
```

### Healthcare Provider Management
```
GET    /api/doctors                   # List all doctors
POST   /api/doctors                   # Add new doctor
GET    /api/doctors/:id               # Get doctor details
PUT    /api/doctors/:id               # Update doctor information
GET    /api/doctors/:id/schedule      # Doctor's schedule
```

### User Management (Admin Only)
```
GET    /api/users                     # List all users
POST   /api/users                     # Create new user
GET    /api/users/:id                 # Get user details  
PUT    /api/users/:id                 # Update user information
DELETE /api/users/:id                 # Delete user account
```

For complete API documentation, start the server and visit: `http://localhost:3001/api-docs`

## Testing

### Backend Testing
```bash
cd hospital_backend

# Run all tests
npm test

# Run tests with coverage
npm run test:coverage

# Run tests in watch mode
npm run test:watch

# Run specific test suite
npm test -- --grep "auth"
```

### Frontend Testing
```bash
cd hospital_app

# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/

# Run specific test file
flutter test test/auth_test.dart
```

## Security Features

- **JWT Authentication**: Secure token-based authentication with refresh tokens
- **Password Security**: bcrypt hashing with configurable salt rounds
- **Rate Limiting**: API rate limiting to prevent abuse and DDoS attacks
- **CORS Protection**: Secure cross-origin resource sharing configuration
- **Input Validation**: Comprehensive validation using Zod schemas
- **SQL Injection Prevention**: Prisma ORM with parameterized queries
- **Security Headers**: Helmet.js for enhanced HTTP security headers
- **Environment Variables**: Sensitive configuration via environment variables
- **Audit Logging**: Comprehensive logging of all system activities

## Deployment

### Backend Deployment

#### Production Build
```bash
cd hospital_backend
npm run build
```

#### Environment Variables
Set these environment variables in production:
```env
NODE_ENV=production
DATABASE_URL=your-production-database-url
JWT_SECRET=your-production-jwt-secret
PORT=3001
```

#### Database Migration
```bash
npx prisma migrate deploy
npx prisma generate
```

#### Start Production Server
```bash
npm start
```

### Frontend Deployment

#### Web Deployment
```bash
cd hospital_app
flutter build web --release
# Deploy contents of build/web/ to your web server
```

#### Android Deployment
```bash
# APK for testing
flutter build apk --release

# App Bundle for Play Store
flutter build appbundle --release
```

#### iOS Deployment
```bash
flutter build ios --release
# Use Xcode to deploy to App Store
```

#### Desktop Deployment
```bash
# Windows
flutter build windows --release

# macOS  
flutter build macos --release

# Linux
flutter build linux --release
```

## Contributing

We welcome contributions from the community! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Process

1. **Fork** the repository
2. **Create** your feature branch (`git checkout -b feature/amazing-feature`)
3. **Code** your changes following our style guidelines
4. **Test** your changes thoroughly
5. **Commit** your changes (`git commit -m 'Add amazing feature'`)
6. **Push** to your branch (`git push origin feature/amazing-feature`)
7. **Create** a Pull Request

### Code Style Guidelines

- **Dart**: Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- **TypeScript**: Follow the [TypeScript Style Guide](https://ts.dev/style/)
- **Commits**: Use [Conventional Commits](https://conventionalcommits.org/)
- **Testing**: Write tests for all new features

## License

This project is licensed under **Shariah** - see the [LICENSE](LICENSE) file for complete details.

## Authors & Contributors

- **[Your Name]** - *Initial work and project architecture* - [@yourusername](https://github.com/yourusername)

See the list of [contributors](https://github.com/yourusername/Hospital_Management_System/contributors) who participated in this project.

## Acknowledgments

- **Flutter Team** - For the incredible cross-platform framework
- **Node.js Community** - For the robust JavaScript runtime
- **PostgreSQL Team** - For the reliable database system
- **Prisma Team** - For the excellent TypeScript ORM
- **Express.js Team** - For the minimal web framework
- **Material Design Team** - For the beautiful design system

## Support & Help

Need help? We're here to support you:

1. **Documentation**: Check our comprehensive [docs](./docs/)
2. **Issues**: [Open an issue](https://github.com/yourusername/Hospital_Management_System/issues) on GitHub
3. **Discussions**: Join our [GitHub Discussions](https://github.com/yourusername/Hospital_Management_System/discussions)
4. **Email**: Contact us at support@yourdomain.com

## Roadmap

### Recently Completed (v1.3.0)

- **Complete Account Management System**
  - Create Account Screen with 9 role options
  - Login Screen with remember me and quick demo login
  - Delete Account Screen with safety confirmations
  - Account Management Hub with settings and preferences
  - Profile Management capabilities
  - Session and device management
  - Two-factor authentication support
  - Login history tracking
  - Privacy and notification preferences
  - GDPR-compliant data export
- **Account API Service** - 30+ endpoints for complete account operations
- **Enhanced Authentication** - Register, login, logout, delete account methods
- **Password Security** - Strength validation with uppercase, lowercase, number requirements
- **Storage Utilities** - Remember me functionality and secure token storage
- **Production-Ready Codebase** - Removed all mock/demo/test features
- **API Service Architecture** - Implemented DoctorApiService, PatientApiService, NotificationApiService
- **Form Validation Utilities** - Comprehensive validators for email, password, phone, dates
- **Search Debouncing** - Optimized search with debouncing to reduce API calls
- **Pagination Support** - PaginationController for efficient data loading
- **Retry Mechanism** - Automatic retry with exponential backoff for failed requests
- **Forgot Password Feature** - Email-based password recovery flow
- **Notifications System** - Real-time notifications with backend integration
- **Dark Mode** - Complete dark theme with smooth transitions and persistence
- **Enhanced Error Handling** - User-friendly error messages with detailed exception handling
- **Code Quality** - Removed debug statements, cleaned imports, improved structure

### In Progress

- **Pull-to-Refresh** - Swipe-down refresh for all list screens
- **Global Search** - Advanced search across all entities
- **Loading States** - Skeleton loaders for better perceived performance

### Upcoming Features

- **Advanced Analytics** - Comprehensive reporting and insights dashboard with charts
- **Multi-tenant Support** - Support for multiple hospitals in one system
- **Mobile App Optimization** - Enhanced mobile and tablet experience
- **Internationalization** - Multi-language support (English, Spanish, French, Arabic)
- **Offline Mode** - Work without internet connectivity with background sync
- **Third-party Integrations** - Lab systems, medical imaging, insurance providers
- **AI-Powered Features** - Intelligent appointment scheduling and patient recommendations
- **Video Consultations** - Built-in telemedicine capabilities with WebRTC
- **Prescription E-Signing** - Digital signature for prescriptions with verification
- **Advanced Role Permissions** - Granular permission system with custom roles
- **Data Export** - Export reports to PDF, Excel, CSV formats
- **Automated Backup & Restore** - Scheduled backups with one-click restore
- **Comprehensive Audit Logs** - Complete activity tracking with time-based queries
- **Real-time Collaboration** - Multiple users working simultaneously with live updates
- **Push Notifications** - Mobile push notifications for critical alerts
- **QR Code Integration** - Patient identification and prescription verification

### Version History

#### v1.4.2 (October 2, 2025) - Role Alignment Update
**Critical Fix: Frontend/Backend Role System Alignment**
- Fixed role mismatch: Frontend had 9 roles but backend only supports 7
- Updated UserRole enum from 9 to 7 roles matching backend exactly
- Removed roles: BILLING_MANAGER, FACILITY_MANAGER, ACCOUNTANT (functions moved to ADMIN)
- Renamed roles: SUPER_ADMIN → ADMIN, LAB_TECHNICIAN → LABORATORY
- Added PATIENT role with portal functionality
- Updated all role-based dashboards, permissions, and UI components
- Regenerated auth models to match new role system
- Updated demo credentials for all 7 roles
- Full backend compatibility restored

#### v1.4.1 (October 2, 2025) - Permission System
- Implemented comprehensive permission system with 35+ granular permissions
- 11 permission categories: patient, appointment, medical records, prescriptions, lab, pharmacy, billing, facility, user management, reports, system settings
- Role-specific permissions for all 9 roles (later reduced to 7 in v1.4.2)
- Permission guard widgets for UI-level access control
- Permissions screen showing user's current permissions

#### v1.4.0 (October 2, 2025) - Role-Based Dashboards
- Custom dashboards for each user role with relevant widgets
- Role-specific navigation items and quick actions
- Personalized statistics and overview cards
- Quick login demo buttons for all roles

#### v1.3.0 (October 2, 2025) - Account Management System
- Complete account management with 4 dedicated screens
- Create Account: Full registration with role selection and validation
- Login Screen: Secure authentication with demo login options
- Delete Account: Safe deletion with warnings and confirmations
- Account Management Hub: Centralized settings and preferences
- 30+ API endpoints for account operations
- Enhanced auth provider with register and delete methods

#### v1.2.0 (October 2, 2025) - Production Ready
- Enhanced API services with retry mechanism and error handling
- Pagination utilities for large datasets
- Comprehensive validators for all input types
- Improved error messages and user feedback

#### v1.1.0 (October 2025)
- Notifications system with real-time updates
- Dark mode support with theme persistence
- Forgot password functionality
- UX improvements and bug fixes

#### v1.0.0 - Initial Release
- Core hospital management features
- JWT authentication and authorization
- Basic CRUD operations for all entities

#### v0.9.0 - Beta Release
- Appointment management system
- Doctor and patient modules

#### v0.8.0 - Alpha Release
- Authentication system
- Basic dashboard
- User management

---

## Developer Mode 🛠️

Developer Mode is a powerful isolated testing environment that allows developers to test all features without affecting production data. It provides a complete sandbox with pre-generated demo users across all roles.

### Access Developer Mode

1. **Entry Point**: Click the "Enter Developer Mode" button on the login screen (amber-colored section below the main form)
2. **Authentication Phrase**: Enter the special authentication phrase: `dev@hospital2025`
3. **Developer Account**: Create or log in to your developer account (max 5 accounts)
4. **Role Selection**: Choose any role to impersonate
5. **Demo User**: Select from pre-generated demo users for that role

### Demo Users Available

Developer Mode comes with pre-seeded demo users for comprehensive testing:

- **25 Demo Doctors** - Various specialties (Cardiology, Neurology, Pediatrics, etc.) - 50-50 mix of male and female names
- **500 Demo Patients** - Complete patient profiles with medical history - 50-50 mix of male and female names
- **10 Demo Nurses** - Different departments and shift types - 50-50 mix of male and female names
- **5 Demo Receptionists** - Front desk operations staff - Male names
- **5 Demo Laboratory Staff** - Lab technicians and specialists - Male names
- **3 Demo Pharmacists** - Licensed pharmacy professionals - Male names
- **2 Demo Administrators** - Full system access admins - Male names

All demo users use the password: `demo123`

**Note:** Demo user names use diverse naming conventions appropriate for a global healthcare system.

### Key Features

- **Complete Data Isolation**: Demo data never affects production
- **Role Impersonation**: Test any role without creating production accounts
- **Pre-generated Users**: 550+ demo users ready to use
- **Separate Database Tables**: Demo users stored in dedicated tables
- **Developer Audit Logs**: Track all developer actions
- **Session Management**: Manage multiple developer sessions
- **Quick Role Switching**: Switch between roles seamlessly

### Developer Mode Workflow

```
1. Click "Enter Developer Mode" button on login screen
2. Enter authentication phrase: dev@hospital2025
3. Create/Login developer account
4. Select role (e.g., Doctor)
5. Choose demo doctor from list
6. Test app features with demo data
7. Logout from role → Return to developer dashboard
8. Select different role or logout completely
```

### API Endpoints

Developer Mode provides dedicated API endpoints:

- `POST /api/developer/accounts/create` - Create developer account
- `POST /api/developer/auth/login` - Developer login
- `POST /api/developer/auth/logout` - Developer logout
- `DELETE /api/developer/accounts/:id` - Delete developer account
- `GET /api/developer/accounts` - List all developer accounts
- `POST /api/developer/role/select` - Select role to impersonate
- `GET /api/developer/session` - Get current session info
- `GET /api/developer/demo-users/:role` - Get demo users by role

All requests require the authentication phrase in the `x-developer-phrase` header.

### Environment Configuration

Set the developer authentication phrase in your `.env`:

```env
DEVELOPER_AUTH_PHRASE=dev@hospital2025
```

### Database Schema

Developer Mode adds these tables:

- `DeveloperUser` - Developer account information
- `DeveloperSession` - Active developer sessions
- `DeveloperAuditLog` - Developer activity logs
- `DemoDoctor` - Demo doctor profiles
- `DemoPatient` - Demo patient records
- `DemoNurse` - Demo nurse profiles
- `DemoReceptionist` - Demo receptionist accounts
- `DemoLaboratory` - Demo lab staff profiles
- `DemoPharmacist` - Demo pharmacist accounts
- `DemoAdmin` - Demo administrator accounts

### Security Notes

- Maximum 5 developer accounts can exist simultaneously
- Developer sessions expire after 24 hours
- All developer actions are logged in audit trail
- Demo data is completely isolated from production
- Authentication phrase required for all developer endpoints

### Testing Benefits

- **No Production Impact**: Test destructive operations safely
- **Realistic Data**: 550+ pre-populated demo users
- **All Roles Available**: Test every permission level
- **Quick Setup**: No manual user creation needed
- **Reproducible Tests**: Consistent demo data for testing
- **Multi-role Workflows**: Test cross-role interactions

---

**If you find this project helpful, please give it a star!**

**Made with care by the Hospital Management System Team**

[Homepage](https://github.com/ENTISHAR-RASHID-CHOWDHURY/Hospital_Management_System) • 
[Documentation](./docs/) • 
[Report Bug](https://github.com/ENTISHAR-RASHID-CHOWDHURY/Hospital_Management_System/issues) • 
[Request Feature](https://github.com/ENTISHAR-RASHID-CHOWDHURY/Hospital_Management_System/issues)
