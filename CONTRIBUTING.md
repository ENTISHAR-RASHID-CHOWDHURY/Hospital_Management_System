# Contributing to Hospital Management System

First off, thank you for considering contributing to the Hospital Management System!

It's people like you that make this project a great tool for healthcare institutions worldwide.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Process](#development-process)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)
- [Community](#community)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

### Our Standards

- **Be respectful**: Treat everyone with respect and kindness
- **Be inclusive**: Welcome newcomers and help them learn
- **Be constructive**: Provide helpful feedback and suggestions
- **Be patient**: Remember that everyone is learning
- **Be collaborative**: Work together towards common goals

### Unacceptable Behavior

- Harassment, discrimination, or offensive comments
- Personal attacks or trolling
- Publishing private information without permission
- Any conduct that would be inappropriate in a professional setting

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** 18.0 or higher
- **Flutter SDK** 3.0 or higher
- **PostgreSQL** 14.0 or higher
- **Git** for version control

### Setting Up Development Environment

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/your-username/Hospital_Management_System.git
   cd Hospital_Management_System
   ```

3. **Set up the backend**:
   ```bash
   cd hospital_backend
   npm install
   cp .env.example .env
   # Edit .env with your database credentials
   npx prisma migrate dev
   npm run dev
   ```

4. **Set up the frontend**:
   ```bash
   cd ../hospital_app
   flutter pub get
   flutter run
   ```

5. **Create a new branch** for your feature:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## How to Contribute

### Types of Contributions

We welcome various types of contributions:

- **Bug fixes**
- **New features**
- **Documentation improvements**
- **Test coverage improvements**
- **UI/UX enhancements**
- **Performance optimizations**
- **Code refactoring**
- **Translations**

### Areas Where Help is Needed

- **Frontend Development**: Flutter UI components and screens
- **Backend Development**: Node.js API endpoints and business logic
- **Database Design**: PostgreSQL schema improvements
- **Testing**: Unit, integration, and end-to-end tests
- **Documentation**: Code comments, user guides, API documentation
- **Security**: Security audits and improvements
- **Performance**: Optimization and monitoring
- **DevOps**: CI/CD, deployment, and infrastructure

## Development Process

### Branching Strategy

We use Git Flow for our branching strategy:

- **`main`**: Production-ready code
- **`develop`**: Integration branch for features
- **`feature/*`**: Individual feature branches
- **`bugfix/*`**: Bug fix branches
- **`hotfix/*`**: Critical production fixes

### Feature Development Workflow

1. **Create a feature branch** from `develop`:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following coding standards

3. **Write tests** for your changes

4. **Test thoroughly**:
   ```bash
   # Backend tests
   cd hospital_backend
   npm test
   
   # Frontend tests
   cd hospital_app
   flutter test
   ```

5. **Commit your changes** using conventional commits

6. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create a Pull Request** against the `develop` branch

## Coding Standards

### Dart/Flutter Standards

Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style):

```dart
// Good
class PatientService {
  Future<List<Patient>> getPatients() async {
    // Implementation
  }
}

// Bad
class patientservice {
  getpatients() {
    // Implementation
  }
}
```

**Key Points:**
- Use `camelCase` for variables and functions
- Use `PascalCase` for classes
- Use `snake_case` for file names
- Always use `const` constructors when possible
- Add documentation comments for public APIs

### TypeScript/Node.js Standards

Follow the [TypeScript Style Guide](https://ts.dev/style/):

```typescript
// Good
interface PatientData {
  id: string;
  name: string;
  email: string;
}

export class PatientService {
  async createPatient(data: PatientData): Promise<Patient> {
    // Implementation
  }
}

// Bad
export class patientservice {
  createpatient(data) {
    // Implementation
  }
}
```

**Key Points:**
- Use `camelCase` for variables and functions
- Use `PascalCase` for classes and interfaces
- Use `kebab-case` for file names
- Always define types for parameters and return values
- Use async/await instead of promises where possible

### Database Standards

- Use descriptive table and column names
- Follow PostgreSQL naming conventions
- Always use migrations for schema changes
- Include proper indexes for performance
- Document complex queries

## Testing Guidelines

### Backend Testing

Write comprehensive tests for all API endpoints:

```typescript
describe('Patient API', () => {
  test('should create a new patient', async () => {
    const patientData = {
      name: 'John Doe',
      email: 'john@example.com',
      phone: '123-456-7890'
    };
    
    const response = await request(app)
      .post('/api/patients')
      .send(patientData)
      .expect(201);
    
    expect(response.body.name).toBe(patientData.name);
  });
});
```

### Frontend Testing

Write widget tests for UI components:

```dart
testWidgets('PatientCard displays patient information', (WidgetTester tester) async {
  final patient = Patient(
    id: '1',
    name: 'John Doe',
    email: 'john@example.com',
  );

  await tester.pumpWidget(MaterialApp(
    home: PatientCard(patient: patient),
  ));

  expect(find.text('John Doe'), findsOneWidget);
  expect(find.text('john@example.com'), findsOneWidget);
});
```

### Test Coverage Requirements

- **Minimum coverage**: 80% for both frontend and backend
- **Critical paths**: 100% coverage required
- **New features**: Must include tests
- **Bug fixes**: Must include regression tests

## Commit Message Guidelines

We follow the [Conventional Commits](https://conventionalcommits.org/) specification:

### Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, etc.)
- **refactor**: Code refactoring
- **test**: Adding or updating tests
- **chore**: Maintenance tasks

### Examples

```bash
# Good commit messages
feat(auth): add JWT refresh token functionality
fix(appointments): resolve scheduling conflict detection
docs(api): update authentication endpoint documentation
test(patients): add unit tests for patient service

# Bad commit messages
fixed bug
added feature
update
WIP
```

### Commit Message Body

For complex changes, include a detailed body:

```
feat(appointments): add recurring appointment support

- Add RecurringAppointment model to database schema
- Implement recurring appointment creation API
- Add UI components for recurring appointment setup
- Include validation for recurring appointment conflicts

Closes #123
```

## Pull Request Process

### Before Submitting

1. **Ensure all tests pass**
2. **Update documentation** if needed
3. **Add tests** for new functionality
4. **Follow coding standards**
5. **Rebase on latest develop** branch

### Pull Request Template

```markdown
## Description
Brief description of changes made.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring
- [ ] Performance improvement

## Testing
- [ ] All existing tests pass
- [ ] New tests added for new functionality
- [ ] Manual testing completed

## Screenshots (if applicable)
Add screenshots for UI changes.

## Related Issues
Fixes #123
```

### Review Process

1. **Automated Checks**: CI/CD pipeline runs tests and checks
2. **Code Review**: Maintainers review code quality and functionality
3. **Testing**: Reviewers test functionality manually if needed
4. **Approval**: At least one maintainer approval required
5. **Merge**: Squash and merge into develop branch

### Review Criteria

- **Functionality**: Does it work as expected?
- **Code Quality**: Is it readable and maintainable?
- **Performance**: Does it impact system performance?
- **Security**: Are there any security concerns?
- **Testing**: Is it adequately tested?
- **Documentation**: Is documentation updated?

## Issue Reporting

### Before Creating an Issue

1. **Search existing issues** to avoid duplicates
2. **Check documentation** for known solutions
3. **Test with latest version** if possible
4. **Gather relevant information** about your environment

### Bug Report Template

```markdown
**Describe the Bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected Behavior**
What you expected to happen.

**Screenshots**
Add screenshots if applicable.

**Environment:**
- OS: [e.g. Windows 10]
- Flutter Version: [e.g. 3.0.0]
- Node.js Version: [e.g. 18.0.0]
- Database Version: [e.g. PostgreSQL 14.0]

**Additional Context**
Any other context about the problem.
```

### Feature Request Template

```markdown
**Feature Description**
Clear description of the feature you'd like to see.

**Problem Solved**
What problem would this feature solve?

**Proposed Solution**
How do you envision this feature working?

**Alternatives Considered**
Other solutions you've considered.

**Additional Context**
Screenshots, mockups, or examples.
```

## Community

### Getting Help

- **GitHub Discussions**: Ask questions and share ideas
- **Issues**: Report bugs and request features
- **Documentation**: Check our comprehensive docs
- **Email**: Contact maintainers directly

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and ideas
- **Email**: Direct contact with maintainers
- **Code Reviews**: Feedback on pull requests

### Recognition

Contributors are recognized in several ways:

- **Contributors File**: Listed in the main README
- **Release Notes**: Mentioned in version releases
- **GitHub Profile**: Contributions visible on your profile
- **Community Recognition**: Highlighted in discussions

## Thank You

Thank you for taking the time to contribute to the Hospital Management System! Your efforts help make healthcare technology more accessible and effective for institutions worldwide.

Every contribution, no matter how small, makes a difference. Whether you're fixing a typo, adding a feature, or improving documentation, you're helping to build something that can positively impact healthcare delivery.

## Questions?

If you have any questions about contributing, please:

1. Check this guide thoroughly
2. Search existing issues and discussions
3. Create a new discussion or issue
4. Contact the maintainers directly

**Happy Contributing!**

---

*This contributing guide is a living document and will be updated as the project evolves. Thank you for being part of our community!*