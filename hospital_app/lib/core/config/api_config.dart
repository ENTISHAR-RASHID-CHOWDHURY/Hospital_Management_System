class ApiConfig {
  static const String baseUrl = 'http://localhost:3001/api';

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String changePasswordEndpoint = '/auth/change-password';
  static const String currentUserEndpoint = '/auth/me';

  // Patient endpoints
  static const String patientsEndpoint = '/patients';

  // Doctor endpoints
  static const String doctorsEndpoint = '/doctors';

  // Appointment endpoints
  static const String appointmentsEndpoint = '/appointments';

  // Pharmacy endpoints
  static const String pharmacyEndpoint = '/pharmacy';
  static const String medicationsEndpoint = '/pharmacy/medications';
  static const String prescriptionsEndpoint = '/pharmacy/prescriptions';
  static const String dispensingsEndpoint = '/pharmacy/dispensings';

  // Laboratory endpoints
  static const String laboratoryEndpoint = '/laboratory';
  static const String labTestsEndpoint = '/laboratory/tests';
  static const String labOrdersEndpoint = '/laboratory/orders';
  static const String labResultsEndpoint = '/laboratory/results';

  // Billing endpoints
  static const String billingEndpoint = '/billing';
  static const String billsEndpoint = '/billing/bills';
  static const String paymentsEndpoint = '/billing/payments';
  static const String insuranceClaimsEndpoint = '/billing/insurance/claims';

  // Facility endpoints
  static const String facilityEndpoint = '/facility';
  static const String wardsEndpoint = '/facility/wards';
  static const String bedsEndpoint = '/facility/beds';
  static const String admissionsEndpoint = '/facility/admissions';
  static const String dischargesEndpoint = '/facility/discharges';

  // Request timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination defaults
  static const int defaultPageSize = 10;
  static const int maxPageSize = 100;

  // File upload limits
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/gif'
  ];
  static const List<String> allowedDocumentTypes = [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ];
}
