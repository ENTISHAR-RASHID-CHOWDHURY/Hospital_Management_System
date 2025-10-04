import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/dev/demo_names.dart';
import '../../../core/widgets/gradient_scaffold.dart';

class PatientDetailsScreen extends ConsumerStatefulWidget {
  final String patientId;

  const PatientDetailsScreen({
    super.key,
    required this.patientId,
  });

  @override
  ConsumerState<PatientDetailsScreen> createState() =>
      _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends ConsumerState<PatientDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _patient;
  bool _isLoading = true;
  bool _isEditing = false;

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _insuranceController = TextEditingController();

  String _selectedBloodType = 'A+';
  String _selectedGender = 'Male';
  DateTime _dateOfBirth =
      DateTime.now().subtract(const Duration(days: 365 * 30));

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPatientData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _insuranceController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock patient data
      // Use deterministic demo name for emergency contact so developer/demo mode
      // shows male Muslim demo names consistently.
      final emergencyContactName = getDemoDisplayName(widget.patientId);
      final demoName = getDemoDisplayName(widget.patientId);
      final nameParts = demoName.split(' ');
      final patient = {
        'id': widget.patientId,
        'firstName': nameParts.isNotEmpty ? nameParts.first : demoName,
        'lastName': nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
        'email':
            '${demoName.toLowerCase().replaceAll(' ', '.')}@demo.patient.com',
        'phone': '+1-555-0123',
        'dateOfBirth': '1985-03-15',
        'gender': 'Male',
        'bloodType': 'A+',
        'address': '123 Main St, City, State 12345',
        'emergencyContact': '$emergencyContactName - +1-555-0124',
        'insurance': 'Blue Cross Blue Shield - Policy #123456',
        'status': 'Active',
        'lastVisit': DateTime.now().subtract(const Duration(days: 30)),
        'nextAppointment': DateTime.now().add(const Duration(days: 7)),
      };

      _populateForm(patient);

      setState(() {
        _patient = patient;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      _showError('Failed to load patient data: $error');
    }
  }

  void _populateForm(Map<String, dynamic> patient) {
    _firstNameController.text = patient['firstName'] ?? '';
    _lastNameController.text = patient['lastName'] ?? '';
    _emailController.text = patient['email'] ?? '';
    _phoneController.text = patient['phone'] ?? '';
    _addressController.text = patient['address'] ?? '';
    _emergencyContactController.text = patient['emergencyContact'] ?? '';
    _insuranceController.text = patient['insurance'] ?? '';
    _selectedBloodType = patient['bloodType'] ?? 'A+';
    _selectedGender = patient['gender'] ?? 'Male';
    _dateOfBirth = DateTime.parse(patient['dateOfBirth'] ?? '1985-03-15');
  }

  Future<void> _savePatient() async {
    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final updatedPatient = {
        ..._patient!,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'emergencyContact': _emergencyContactController.text,
        'insurance': _insuranceController.text,
        'bloodType': _selectedBloodType,
        'gender': _selectedGender,
        'dateOfBirth': _dateOfBirth.toIso8601String(),
      };

      setState(() {
        _patient = updatedPatient;
        _isLoading = false;
        _isEditing = false;
      });

      _showSuccess('Patient information updated successfully!');
    } catch (error) {
      setState(() => _isLoading = false);
      _showError('Failed to save patient data: $error');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _patient == null) {
      return GradientScaffold(
        appBar: AppBar(
          title: const Text('Patient Details'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return GradientScaffold(
      appBar: AppBar(
        title: Text(_patient != null
            ? '${_patient!['firstName']} ${_patient!['lastName']}'
            : 'Patient Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
            },
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
          ),
          if (_isEditing)
            IconButton(
              onPressed: _isLoading ? null : _savePatient,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Info', icon: Icon(Icons.person)),
            Tab(text: 'Medical', icon: Icon(Icons.medical_services)),
            Tab(text: 'Visits', icon: Icon(Icons.history)),
            Tab(text: 'Bills', icon: Icon(Icons.receipt)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildMedicalTab(),
          _buildVisitsTab(),
          _buildBillsTab(),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient Header Card
          _buildPatientHeaderCard(),
          const SizedBox(height: 24),

          // Personal Information
          _buildSectionCard(
            title: 'Personal Information',
            icon: Icons.person,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: _buildInfoField(
                            'First Name', _firstNameController)),
                    const SizedBox(width: 16),
                    Expanded(
                        child:
                            _buildInfoField('Last Name', _lastNameController)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoField('Email', _emailController),
                const SizedBox(height: 16),
                _buildInfoField('Phone', _phoneController),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _buildDropdownField('Gender', _selectedGender,
                            ['Male', 'Female', 'Other'])),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildDropdownField(
                            'Blood Type', _selectedBloodType, [
                      'A+',
                      'A-',
                      'B+',
                      'B-',
                      'AB+',
                      'AB-',
                      'O+',
                      'O-'
                    ])),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDateField(),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Contact Information
          _buildSectionCard(
            title: 'Contact Information',
            icon: Icons.contact_page,
            child: Column(
              children: [
                _buildInfoField('Address', _addressController),
                const SizedBox(height: 16),
                _buildInfoField(
                    'Emergency Contact', _emergencyContactController),
                const SizedBox(height: 16),
                _buildInfoField('Insurance', _insuranceController),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withOpacity(0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              _patient != null
                  ? '${_patient!['firstName'][0]}${_patient!['lastName'][0]}'
                  : 'P',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _patient != null
                      ? '${_patient!['firstName']} ${_patient!['lastName']}'
                      : 'Patient Name',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${widget.patientId}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _patient?['status'] ?? 'Active',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        filled: true,
        fillColor: _isEditing
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: _isEditing
          ? (newValue) {
              setState(() {
                if (label == 'Gender') {
                  _selectedGender = newValue!;
                } else if (label == 'Blood Type') {
                  _selectedBloodType = newValue!;
                }
              });
            }
          : null,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        filled: true,
        fillColor: _isEditing
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: AppColors.surfaceDark,
      items: options
          .map((option) => DropdownMenuItem(
                value: option,
                child:
                    Text(option, style: const TextStyle(color: Colors.white)),
              ))
          .toList(),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _isEditing
          ? () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _dateOfBirth,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _dateOfBirth = date);
              }
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isEditing
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.7)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date of Birth',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_dateOfBirth.day}/${_dateOfBirth.month}/${_dateOfBirth.year}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalTab() {
    return const Center(
      child: Text(
        'Medical History\n(Implementation in progress)',
        style: TextStyle(color: Colors.white70, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildVisitsTab() {
    return const Center(
      child: Text(
        'Visit History\n(Implementation in progress)',
        style: TextStyle(color: Colors.white70, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBillsTab() {
    return const Center(
      child: Text(
        'Billing Information\n(Implementation in progress)',
        style: TextStyle(color: Colors.white70, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }
}
