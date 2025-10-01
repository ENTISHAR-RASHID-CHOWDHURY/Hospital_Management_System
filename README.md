# Hospital Management System

A comprehensive, full-stack hospital management system built with **Flutter** (frontend) and **Node.js/Express** (backend), featuring PostgreSQL database integration, JWT authentication, and role-based access control.

## Features

### Authentication & Security
- **JWT-based authentication** with refresh token support
- **Role-based access control** (Admin, Doctor, Nurse, Receptionist, Patient)
- **Secure password hashing** using bcrypt
- **Session management** with automatic token refresh
- **Rate limiting** and **CORS protection**

### User Management
- **Multi-role user system** with granular permissions
- **Patient registration** and profile management
- **Healthcare provider** management (doctors, nurses, staff)
- **User profile** updates and medical history tracking

### Appointment System
- **Real-time appointment scheduling** with PostgreSQL backend
- **Advanced filtering** by date, doctor, department, and status
- **Appointment status tracking** (scheduled, completed, cancelled)
- **Calendar integration** with visual appointment overview
- **Conflict detection** and automatic scheduling

### Pharmacy Management
- **Medication inventory** tracking and management
- **Prescription processing** and digital records
- **Drug information** database with detailed medication data
- **Stock level** monitoring and alerts

### Dashboard & Analytics
- **Role-specific dashboards** with relevant metrics
- **Real-time statistics** and hospital analytics
- **Appointment trends** and patient flow insights
- **Performance metrics** for healthcare providers

### Cross-Platform Support
- **Web application** (Chrome, Firefox, Safari, Edge)
- **Mobile apps** (Android, iOS)
- **Desktop applications** (Windows, macOS, Linux)
- **Responsive design** adapting to all screen sizes

## Technology Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.x with Dart
- **State Management**: Riverpod for reactive state management
- **UI Framework**: Material Design 3 components
- **HTTP Client**: http package for API communication
- **Local Storage**: SharedPreferences for app settings
- **Testing**: flutter_test with widget and integration tests

### Backend (Node.js)
- **Runtime**: Node.js 18+ with Express.js framework
- **Language**: TypeScript for type safety
- **Database ORM**: Prisma for PostgreSQL integration
- **Authentication**: JWT with jsonwebtoken library
- **Validation**: Zod for comprehensive input validation
- **Security**: bcrypt, helmet, cors for secure operations
- **Logging**: Winston for structured logging
- **Testing**: Jest for unit and integration testing

### Database & Infrastructure
- **Database**: PostgreSQL 14+ with ACID compliance
- **ORM**: Prisma with migration system
- **Containerization**: Docker and Docker Compose
- **Version Control**: Git with conventional commits

## Quick Start

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

## Demo Accounts

The system includes pre-configured demo accounts for testing all features:

| Role | Email | Password | Access Level |
|---------|----------|-------------|-----------------|
| **Admin** | admin@hospital.com | admin123 | Full system access, user management |
| **Doctor** | doctor@hospital.com | doctor123 | Patient records, appointments, medical data |
| **Nurse** | nurse@hospital.com | nurse123 | Patient care, basic records, medications |
| **Receptionist** | receptionist@hospital.com | reception123 | Appointments, basic patient info |
| **Patient** | patient@hospital.com | patient123 | Personal records, appointments |

## API Documentation

### Authentication Endpoints
```
POST   /api/auth/login      # User authentication
POST   /api/auth/register   # New user registration  
POST   /api/auth/refresh    # Token refresh
POST   /api/auth/logout     # User logout
GET    /api/auth/me         # Current user profile
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

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for complete details.

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

### Upcoming Features

- **Real-time Notifications** - WebSocket integration for live updates
- **Advanced Analytics** - Comprehensive reporting and insights
- **Multi-tenant Support** - Support for multiple hospitals
- **Mobile App Optimization** - Enhanced mobile and tablet experience
- **Internationalization** - Multi-language support
- **Dark Mode** - Dark theme for better user experience
- **Offline Mode** - Work without internet connectivity
- **Third-party Integrations** - Lab systems, imaging, insurance
- **AI Features** - Intelligent scheduling and recommendations
- **Advanced Security** - 2FA, SSO, advanced audit trails

### Version History

- **v1.0.0** - Initial release with core features
- **v1.1.0** - Added appointment management
- **v1.2.0** - Enhanced security and authentication
- **v1.3.0** - PostgreSQL integration and data persistence

---

**If you find this project helpful, please give it a star!**

**Made with care by the Hospital Management System Team**

[Homepage](https://github.com/yourusername/Hospital_Management_System) • 
[Documentation](./docs/) • 
[Report Bug](https://github.com/yourusername/Hospital_Management_System/issues) • 
[Request Feature](https://github.com/yourusername/Hospital_Management_System/issues)