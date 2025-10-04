import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('es', 'ES'), // Spanish
    Locale('fr', 'FR'), // French
    Locale('de', 'DE'), // German
    Locale('zh', 'CN'), // Chinese
    Locale('ar', 'SA'), // Arabic
    Locale('hi', 'IN'), // Hindi
  ];

  // Common UI strings
  String get appTitle =>
      _localizedStrings[locale.languageCode]?['app_title'] ??
      'Hospital Management System';
  String get loading =>
      _localizedStrings[locale.languageCode]?['loading'] ?? 'Loading...';
  String get error =>
      _localizedStrings[locale.languageCode]?['error'] ?? 'Error';
  String get retry =>
      _localizedStrings[locale.languageCode]?['retry'] ?? 'Retry';
  String get cancel =>
      _localizedStrings[locale.languageCode]?['cancel'] ?? 'Cancel';
  String get save => _localizedStrings[locale.languageCode]?['save'] ?? 'Save';
  String get delete =>
      _localizedStrings[locale.languageCode]?['delete'] ?? 'Delete';
  String get edit => _localizedStrings[locale.languageCode]?['edit'] ?? 'Edit';
  String get add => _localizedStrings[locale.languageCode]?['add'] ?? 'Add';
  String get search =>
      _localizedStrings[locale.languageCode]?['search'] ?? 'Search';
  String get filter =>
      _localizedStrings[locale.languageCode]?['filter'] ?? 'Filter';
  String get clear =>
      _localizedStrings[locale.languageCode]?['clear'] ?? 'Clear';
  String get apply =>
      _localizedStrings[locale.languageCode]?['apply'] ?? 'Apply';
  String get close =>
      _localizedStrings[locale.languageCode]?['close'] ?? 'Close';
  String get yes => _localizedStrings[locale.languageCode]?['yes'] ?? 'Yes';
  String get no => _localizedStrings[locale.languageCode]?['no'] ?? 'No';

  // Navigation
  String get dashboard =>
      _localizedStrings[locale.languageCode]?['dashboard'] ?? 'Dashboard';
  String get patients =>
      _localizedStrings[locale.languageCode]?['patients'] ?? 'Patients';
  String get appointments =>
      _localizedStrings[locale.languageCode]?['appointments'] ?? 'Appointments';
  String get laboratory =>
      _localizedStrings[locale.languageCode]?['laboratory'] ?? 'Laboratory';
  String get pharmacy =>
      _localizedStrings[locale.languageCode]?['pharmacy'] ?? 'Pharmacy';
  String get reports =>
      _localizedStrings[locale.languageCode]?['reports'] ?? 'Reports';
  String get settings =>
      _localizedStrings[locale.languageCode]?['settings'] ?? 'Settings';

  // Patient Management
  String get patientList =>
      _localizedStrings[locale.languageCode]?['patient_list'] ?? 'Patient List';
  String get patientDetails =>
      _localizedStrings[locale.languageCode]?['patient_details'] ??
      'Patient Details';
  String get newPatient =>
      _localizedStrings[locale.languageCode]?['new_patient'] ?? 'New Patient';
  String get patientName =>
      _localizedStrings[locale.languageCode]?['patient_name'] ?? 'Patient Name';
  String get patientId =>
      _localizedStrings[locale.languageCode]?['patient_id'] ?? 'Patient ID';
  String get dateOfBirth =>
      _localizedStrings[locale.languageCode]?['date_of_birth'] ??
      'Date of Birth';
  String get gender =>
      _localizedStrings[locale.languageCode]?['gender'] ?? 'Gender';
  String get phoneNumber =>
      _localizedStrings[locale.languageCode]?['phone_number'] ?? 'Phone Number';
  String get address =>
      _localizedStrings[locale.languageCode]?['address'] ?? 'Address';
  String get emergencyContact =>
      _localizedStrings[locale.languageCode]?['emergency_contact'] ??
      'Emergency Contact';
  String get medicalHistory =>
      _localizedStrings[locale.languageCode]?['medical_history'] ??
      'Medical History';
  String get allergies =>
      _localizedStrings[locale.languageCode]?['allergies'] ?? 'Allergies';
  String get currentMedications =>
      _localizedStrings[locale.languageCode]?['current_medications'] ??
      'Current Medications';

  // Laboratory
  String get labTests =>
      _localizedStrings[locale.languageCode]?['lab_tests'] ?? 'Lab Tests';
  String get testResults =>
      _localizedStrings[locale.languageCode]?['test_results'] ?? 'Test Results';
  String get pending =>
      _localizedStrings[locale.languageCode]?['pending'] ?? 'Pending';
  String get inProgress =>
      _localizedStrings[locale.languageCode]?['in_progress'] ?? 'In Progress';
  String get completed =>
      _localizedStrings[locale.languageCode]?['completed'] ?? 'Completed';
  String get testName =>
      _localizedStrings[locale.languageCode]?['test_name'] ?? 'Test Name';
  String get testDate =>
      _localizedStrings[locale.languageCode]?['test_date'] ?? 'Test Date';
  String get result =>
      _localizedStrings[locale.languageCode]?['result'] ?? 'Result';
  String get normalRange =>
      _localizedStrings[locale.languageCode]?['normal_range'] ?? 'Normal Range';
  String get abnormal =>
      _localizedStrings[locale.languageCode]?['abnormal'] ?? 'Abnormal';
  String get critical =>
      _localizedStrings[locale.languageCode]?['critical'] ?? 'Critical';

  // Pharmacy
  String get prescriptions =>
      _localizedStrings[locale.languageCode]?['prescriptions'] ??
      'Prescriptions';
  String get medications =>
      _localizedStrings[locale.languageCode]?['medications'] ?? 'Medications';
  String get inventory =>
      _localizedStrings[locale.languageCode]?['inventory'] ?? 'Inventory';
  String get dispensing =>
      _localizedStrings[locale.languageCode]?['dispensing'] ?? 'Dispensing';
  String get medicationName =>
      _localizedStrings[locale.languageCode]?['medication_name'] ??
      'Medication Name';
  String get dosage =>
      _localizedStrings[locale.languageCode]?['dosage'] ?? 'Dosage';
  String get frequency =>
      _localizedStrings[locale.languageCode]?['frequency'] ?? 'Frequency';
  String get duration =>
      _localizedStrings[locale.languageCode]?['duration'] ?? 'Duration';
  String get instructions =>
      _localizedStrings[locale.languageCode]?['instructions'] ?? 'Instructions';
  String get lowStock =>
      _localizedStrings[locale.languageCode]?['low_stock'] ?? 'Low Stock';
  String get expiryDate =>
      _localizedStrings[locale.languageCode]?['expiry_date'] ?? 'Expiry Date';
  String get batchNumber =>
      _localizedStrings[locale.languageCode]?['batch_number'] ?? 'Batch Number';

  // Appointments
  String get appointmentList =>
      _localizedStrings[locale.languageCode]?['appointment_list'] ??
      'Appointment List';
  String get newAppointment =>
      _localizedStrings[locale.languageCode]?['new_appointment'] ??
      'New Appointment';
  String get appointmentDate =>
      _localizedStrings[locale.languageCode]?['appointment_date'] ??
      'Appointment Date';
  String get appointmentTime =>
      _localizedStrings[locale.languageCode]?['appointment_time'] ??
      'Appointment Time';
  String get doctor =>
      _localizedStrings[locale.languageCode]?['doctor'] ?? 'Doctor';
  String get department =>
      _localizedStrings[locale.languageCode]?['department'] ?? 'Department';
  String get reason =>
      _localizedStrings[locale.languageCode]?['reason'] ?? 'Reason';
  String get confirmed =>
      _localizedStrings[locale.languageCode]?['confirmed'] ?? 'Confirmed';
  String get cancelled =>
      _localizedStrings[locale.languageCode]?['cancelled'] ?? 'Cancelled';
  String get rescheduled =>
      _localizedStrings[locale.languageCode]?['rescheduled'] ?? 'Rescheduled';

  // Analytics & Reports
  String get analytics =>
      _localizedStrings[locale.languageCode]?['analytics'] ?? 'Analytics';
  String get overview =>
      _localizedStrings[locale.languageCode]?['overview'] ?? 'Overview';
  String get patientFlow =>
      _localizedStrings[locale.languageCode]?['patient_flow'] ?? 'Patient Flow';
  String get revenue =>
      _localizedStrings[locale.languageCode]?['revenue'] ?? 'Revenue';
  String get expenses =>
      _localizedStrings[locale.languageCode]?['expenses'] ?? 'Expenses';
  String get occupancy =>
      _localizedStrings[locale.languageCode]?['occupancy'] ?? 'Occupancy';
  String get waitTime =>
      _localizedStrings[locale.languageCode]?['wait_time'] ?? 'Wait Time';
  String get satisfaction =>
      _localizedStrings[locale.languageCode]?['satisfaction'] ?? 'Satisfaction';
  String get efficiency =>
      _localizedStrings[locale.languageCode]?['efficiency'] ?? 'Efficiency';

  // Accessibility
  String get accessibility =>
      _localizedStrings[locale.languageCode]?['accessibility'] ??
      'Accessibility';
  String get highContrast =>
      _localizedStrings[locale.languageCode]?['high_contrast'] ??
      'High Contrast';
  String get largeFonts =>
      _localizedStrings[locale.languageCode]?['large_fonts'] ?? 'Large Fonts';
  String get reduceAnimations =>
      _localizedStrings[locale.languageCode]?['reduce_animations'] ??
      'Reduce Animations';
  String get hapticFeedback =>
      _localizedStrings[locale.languageCode]?['haptic_feedback'] ??
      'Haptic Feedback';
  String get voiceAnnouncements =>
      _localizedStrings[locale.languageCode]?['voice_announcements'] ??
      'Voice Announcements';
  String get screenReader =>
      _localizedStrings[locale.languageCode]?['screen_reader'] ??
      'Screen Reader';

  // Time and Date
  String get today =>
      _localizedStrings[locale.languageCode]?['today'] ?? 'Today';
  String get yesterday =>
      _localizedStrings[locale.languageCode]?['yesterday'] ?? 'Yesterday';
  String get tomorrow =>
      _localizedStrings[locale.languageCode]?['tomorrow'] ?? 'Tomorrow';
  String get thisWeek =>
      _localizedStrings[locale.languageCode]?['this_week'] ?? 'This Week';
  String get thisMonth =>
      _localizedStrings[locale.languageCode]?['this_month'] ?? 'This Month';
  String get lastMonth =>
      _localizedStrings[locale.languageCode]?['last_month'] ?? 'Last Month';

  // Status Messages
  String get success =>
      _localizedStrings[locale.languageCode]?['success'] ?? 'Success';
  String get warning =>
      _localizedStrings[locale.languageCode]?['warning'] ?? 'Warning';
  String get info =>
      _localizedStrings[locale.languageCode]?['info'] ?? 'Information';
  String get noDataFound =>
      _localizedStrings[locale.languageCode]?['no_data_found'] ??
      'No data found';
  String get connectionError =>
      _localizedStrings[locale.languageCode]?['connection_error'] ??
      'Connection error';
  String get offline =>
      _localizedStrings[locale.languageCode]?['offline'] ?? 'Offline';
  String get online =>
      _localizedStrings[locale.languageCode]?['online'] ?? 'Online';

  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'app_title': 'Hospital Management System',
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'search': 'Search',
      'filter': 'Filter',
      'clear': 'Clear',
      'apply': 'Apply',
      'close': 'Close',
      'yes': 'Yes',
      'no': 'No',
      'dashboard': 'Dashboard',
      'patients': 'Patients',
      'appointments': 'Appointments',
      'laboratory': 'Laboratory',
      'pharmacy': 'Pharmacy',
      'reports': 'Reports',
      'settings': 'Settings',
      'patient_list': 'Patient List',
      'patient_details': 'Patient Details',
      'new_patient': 'New Patient',
      'patient_name': 'Patient Name',
      'patient_id': 'Patient ID',
      'date_of_birth': 'Date of Birth',
      'gender': 'Gender',
      'phone_number': 'Phone Number',
      'address': 'Address',
      'emergency_contact': 'Emergency Contact',
      'medical_history': 'Medical History',
      'allergies': 'Allergies',
      'current_medications': 'Current Medications',
      'lab_tests': 'Lab Tests',
      'test_results': 'Test Results',
      'pending': 'Pending',
      'in_progress': 'In Progress',
      'completed': 'Completed',
      'test_name': 'Test Name',
      'test_date': 'Test Date',
      'result': 'Result',
      'normal_range': 'Normal Range',
      'abnormal': 'Abnormal',
      'critical': 'Critical',
      'prescriptions': 'Prescriptions',
      'medications': 'Medications',
      'inventory': 'Inventory',
      'dispensing': 'Dispensing',
      'medication_name': 'Medication Name',
      'dosage': 'Dosage',
      'frequency': 'Frequency',
      'duration': 'Duration',
      'instructions': 'Instructions',
      'low_stock': 'Low Stock',
      'expiry_date': 'Expiry Date',
      'batch_number': 'Batch Number',
      'appointment_list': 'Appointment List',
      'new_appointment': 'New Appointment',
      'appointment_date': 'Appointment Date',
      'appointment_time': 'Appointment Time',
      'doctor': 'Doctor',
      'department': 'Department',
      'reason': 'Reason',
      'confirmed': 'Confirmed',
      'cancelled': 'Cancelled',
      'rescheduled': 'Rescheduled',
      'analytics': 'Analytics',
      'overview': 'Overview',
      'patient_flow': 'Patient Flow',
      'revenue': 'Revenue',
      'expenses': 'Expenses',
      'occupancy': 'Occupancy',
      'wait_time': 'Wait Time',
      'satisfaction': 'Satisfaction',
      'efficiency': 'Efficiency',
      'accessibility': 'Accessibility',
      'high_contrast': 'High Contrast',
      'large_fonts': 'Large Fonts',
      'reduce_animations': 'Reduce Animations',
      'haptic_feedback': 'Haptic Feedback',
      'voice_announcements': 'Voice Announcements',
      'screen_reader': 'Screen Reader',
      'today': 'Today',
      'yesterday': 'Yesterday',
      'tomorrow': 'Tomorrow',
      'this_week': 'This Week',
      'this_month': 'This Month',
      'last_month': 'Last Month',
      'success': 'Success',
      'warning': 'Warning',
      'info': 'Information',
      'no_data_found': 'No data found',
      'connection_error': 'Connection error',
      'offline': 'Offline',
      'online': 'Online',
    },
    'es': {
      'app_title': 'Sistema de Gestión Hospitalaria',
      'loading': 'Cargando...',
      'error': 'Error',
      'retry': 'Reintentar',
      'cancel': 'Cancelar',
      'save': 'Guardar',
      'delete': 'Eliminar',
      'edit': 'Editar',
      'add': 'Agregar',
      'search': 'Buscar',
      'filter': 'Filtrar',
      'clear': 'Limpiar',
      'apply': 'Aplicar',
      'close': 'Cerrar',
      'yes': 'Sí',
      'no': 'No',
      'dashboard': 'Panel de Control',
      'patients': 'Pacientes',
      'appointments': 'Citas',
      'laboratory': 'Laboratorio',
      'pharmacy': 'Farmacia',
      'reports': 'Informes',
      'settings': 'Configuración',
      'patient_list': 'Lista de Pacientes',
      'patient_details': 'Detalles del Paciente',
      'new_patient': 'Nuevo Paciente',
      'patient_name': 'Nombre del Paciente',
      'patient_id': 'ID del Paciente',
      'date_of_birth': 'Fecha de Nacimiento',
      'gender': 'Género',
      'phone_number': 'Número de Teléfono',
      'address': 'Dirección',
      'emergency_contact': 'Contacto de Emergencia',
      'medical_history': 'Historia Médica',
      'allergies': 'Alergias',
      'current_medications': 'Medicamentos Actuales',
      'lab_tests': 'Pruebas de Laboratorio',
      'test_results': 'Resultados de Pruebas',
      'pending': 'Pendiente',
      'in_progress': 'En Progreso',
      'completed': 'Completado',
      'test_name': 'Nombre de la Prueba',
      'test_date': 'Fecha de la Prueba',
      'result': 'Resultado',
      'normal_range': 'Rango Normal',
      'abnormal': 'Anormal',
      'critical': 'Crítico',
      'prescriptions': 'Recetas',
      'medications': 'Medicamentos',
      'inventory': 'Inventario',
      'dispensing': 'Dispensación',
      'medication_name': 'Nombre del Medicamento',
      'dosage': 'Dosis',
      'frequency': 'Frecuencia',
      'duration': 'Duración',
      'instructions': 'Instrucciones',
      'low_stock': 'Stock Bajo',
      'expiry_date': 'Fecha de Vencimiento',
      'batch_number': 'Número de Lote',
      'accessibility': 'Accesibilidad',
      'high_contrast': 'Alto Contraste',
      'large_fonts': 'Fuentes Grandes',
      'reduce_animations': 'Reducir Animaciones',
      'haptic_feedback': 'Respuesta Háptica',
      'voice_announcements': 'Anuncios de Voz',
      'screen_reader': 'Lector de Pantalla',
      'today': 'Hoy',
      'yesterday': 'Ayer',
      'tomorrow': 'Mañana',
      'this_week': 'Esta Semana',
      'this_month': 'Este Mes',
      'last_month': 'El Mes Pasado',
      'success': 'Éxito',
      'warning': 'Advertencia',
      'info': 'Información',
      'no_data_found': 'No se encontraron datos',
      'connection_error': 'Error de conexión',
      'offline': 'Sin conexión',
      'online': 'En línea',
    },
    'fr': {
      'app_title': 'Système de Gestion Hospitalière',
      'loading': 'Chargement...',
      'error': 'Erreur',
      'retry': 'Réessayer',
      'cancel': 'Annuler',
      'save': 'Sauvegarder',
      'delete': 'Supprimer',
      'edit': 'Modifier',
      'add': 'Ajouter',
      'search': 'Rechercher',
      'filter': 'Filtrer',
      'clear': 'Effacer',
      'apply': 'Appliquer',
      'close': 'Fermer',
      'yes': 'Oui',
      'no': 'Non',
      'dashboard': 'Tableau de Bord',
      'patients': 'Patients',
      'appointments': 'Rendez-vous',
      'laboratory': 'Laboratoire',
      'pharmacy': 'Pharmacie',
      'reports': 'Rapports',
      'settings': 'Paramètres',
      'patient_list': 'Liste des Patients',
      'patient_details': 'Détails du Patient',
      'new_patient': 'Nouveau Patient',
      'patient_name': 'Nom du Patient',
      'patient_id': 'ID du Patient',
      'date_of_birth': 'Date de Naissance',
      'gender': 'Genre',
      'phone_number': 'Numéro de Téléphone',
      'address': 'Adresse',
      'emergency_contact': 'Contact d\'Urgence',
      'medical_history': 'Antécédents Médicaux',
      'allergies': 'Allergies',
      'current_medications': 'Médicaments Actuels',
      'accessibility': 'Accessibilité',
      'high_contrast': 'Contraste Élevé',
      'large_fonts': 'Grandes Polices',
      'reduce_animations': 'Réduire les Animations',
      'haptic_feedback': 'Retour Haptique',
      'voice_announcements': 'Annonces Vocales',
      'screen_reader': 'Lecteur d\'Écran',
      'today': 'Aujourd\'hui',
      'yesterday': 'Hier',
      'tomorrow': 'Demain',
      'this_week': 'Cette Semaine',
      'this_month': 'Ce Mois',
      'last_month': 'Le Mois Dernier',
      'success': 'Succès',
      'warning': 'Avertissement',
      'info': 'Information',
      'no_data_found': 'Aucune donnée trouvée',
      'connection_error': 'Erreur de connexion',
      'offline': 'Hors ligne',
      'online': 'En ligne',
    },
    'de': {
      'app_title': 'Krankenhaus-Managementsystem',
      'loading': 'Laden...',
      'error': 'Fehler',
      'retry': 'Wiederholen',
      'cancel': 'Abbrechen',
      'save': 'Speichern',
      'delete': 'Löschen',
      'edit': 'Bearbeiten',
      'add': 'Hinzufügen',
      'search': 'Suchen',
      'filter': 'Filtern',
      'clear': 'Löschen',
      'apply': 'Anwenden',
      'close': 'Schließen',
      'yes': 'Ja',
      'no': 'Nein',
      'dashboard': 'Dashboard',
      'patients': 'Patienten',
      'appointments': 'Termine',
      'laboratory': 'Labor',
      'pharmacy': 'Apotheke',
      'reports': 'Berichte',
      'settings': 'Einstellungen',
      'accessibility': 'Barrierefreiheit',
      'high_contrast': 'Hoher Kontrast',
      'large_fonts': 'Große Schriftarten',
      'reduce_animations': 'Animationen Reduzieren',
      'haptic_feedback': 'Haptisches Feedback',
      'voice_announcements': 'Sprachansagen',
      'screen_reader': 'Bildschirmleser',
      'today': 'Heute',
      'yesterday': 'Gestern',
      'tomorrow': 'Morgen',
      'this_week': 'Diese Woche',
      'this_month': 'Dieser Monat',
      'last_month': 'Letzter Monat',
      'success': 'Erfolg',
      'warning': 'Warnung',
      'info': 'Information',
      'no_data_found': 'Keine Daten gefunden',
      'connection_error': 'Verbindungsfehler',
      'offline': 'Offline',
      'online': 'Online',
    },
    'zh': {
      'app_title': '医院管理系统',
      'loading': '加载中...',
      'error': '错误',
      'retry': '重试',
      'cancel': '取消',
      'save': '保存',
      'delete': '删除',
      'edit': '编辑',
      'add': '添加',
      'search': '搜索',
      'filter': '筛选',
      'clear': '清除',
      'apply': '应用',
      'close': '关闭',
      'yes': '是',
      'no': '否',
      'dashboard': '仪表板',
      'patients': '患者',
      'appointments': '预约',
      'laboratory': '实验室',
      'pharmacy': '药房',
      'reports': '报告',
      'settings': '设置',
      'accessibility': '无障碍',
      'high_contrast': '高对比度',
      'large_fonts': '大字体',
      'reduce_animations': '减少动画',
      'haptic_feedback': '触觉反馈',
      'voice_announcements': '语音播报',
      'screen_reader': '屏幕阅读器',
      'today': '今天',
      'yesterday': '昨天',
      'tomorrow': '明天',
      'this_week': '本周',
      'this_month': '本月',
      'last_month': '上月',
      'success': '成功',
      'warning': '警告',
      'info': '信息',
      'no_data_found': '未找到数据',
      'connection_error': '连接错误',
      'offline': '离线',
      'online': '在线',
    },
    'ar': {
      'app_title': 'نظام إدارة المستشفى',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'retry': 'إعادة المحاولة',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'delete': 'حذف',
      'edit': 'تحرير',
      'add': 'إضافة',
      'search': 'بحث',
      'filter': 'تصفية',
      'clear': 'مسح',
      'apply': 'تطبيق',
      'close': 'إغلاق',
      'yes': 'نعم',
      'no': 'لا',
      'dashboard': 'لوحة القيادة',
      'patients': 'المرضى',
      'appointments': 'المواعيد',
      'laboratory': 'المختبر',
      'pharmacy': 'الصيدلية',
      'reports': 'التقارير',
      'settings': 'الإعدادات',
      'accessibility': 'إمكانية الوصول',
      'high_contrast': 'تباين عالي',
      'large_fonts': 'خطوط كبيرة',
      'reduce_animations': 'تقليل الحركات',
      'haptic_feedback': 'ملاحظات اللمس',
      'voice_announcements': 'الإعلانات الصوتية',
      'screen_reader': 'قارئ الشاشة',
      'today': 'اليوم',
      'yesterday': 'أمس',
      'tomorrow': 'غداً',
      'this_week': 'هذا الأسبوع',
      'this_month': 'هذا الشهر',
      'last_month': 'الشهر الماضي',
      'success': 'نجح',
      'warning': 'تحذير',
      'info': 'معلومات',
      'no_data_found': 'لم يتم العثور على بيانات',
      'connection_error': 'خطأ في الاتصال',
      'offline': 'غير متصل',
      'online': 'متصل',
    },
    'hi': {
      'app_title': 'अस्पताल प्रबंधन प्रणाली',
      'loading': 'लोड हो रहा है...',
      'error': 'त्रुटि',
      'retry': 'पुनः प्रयास',
      'cancel': 'रद्द करें',
      'save': 'सहेजें',
      'delete': 'हटाएं',
      'edit': 'संपादित करें',
      'add': 'जोड़ें',
      'search': 'खोजें',
      'filter': 'फ़िल्टर',
      'clear': 'साफ़ करें',
      'apply': 'लागू करें',
      'close': 'बंद करें',
      'yes': 'हाँ',
      'no': 'नहीं',
      'dashboard': 'डैशबोर्ड',
      'patients': 'मरीज़',
      'appointments': 'नियुक्तियाँ',
      'laboratory': 'प्रयोगशाला',
      'pharmacy': 'फार्मेसी',
      'reports': 'रिपोर्ट',
      'settings': 'सेटिंग्स',
      'accessibility': 'पहुंच',
      'high_contrast': 'उच्च कंट्रास्ट',
      'large_fonts': 'बड़े फ़ॉन्ट',
      'reduce_animations': 'एनीमेशन कम करें',
      'haptic_feedback': 'हैप्टिक फीडबैक',
      'voice_announcements': 'आवाज़ की घोषणाएं',
      'screen_reader': 'स्क्रीन रीडर',
      'today': 'आज',
      'yesterday': 'कल',
      'tomorrow': 'कल',
      'this_week': 'इस सप्ताह',
      'this_month': 'इस महीने',
      'last_month': 'पिछले महीने',
      'success': 'सफलता',
      'warning': 'चेतावनी',
      'info': 'जानकारी',
      'no_data_found': 'कोई डेटा नहीं मिला',
      'connection_error': 'कनेक्शन त्रुटि',
      'offline': 'ऑफ़लाइन',
      'online': 'ऑनलाइन',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any((supportedLocale) =>
        supportedLocale.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
