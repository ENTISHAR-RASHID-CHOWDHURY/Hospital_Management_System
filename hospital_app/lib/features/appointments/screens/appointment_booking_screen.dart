import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/dev/demo_names.dart';

class AppointmentBookingScreen extends ConsumerStatefulWidget {
  final String? patientId;
  final UserRole? userRole;

  const AppointmentBookingScreen({super.key, this.patientId, this.userRole});

  @override
  ConsumerState<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState
    extends ConsumerState<AppointmentBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedPatient;
  String? _selectedDoctor;
  String? _selectedDepartment;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  AppointmentType _appointmentType = AppointmentType.consultation;
  AppointmentPriority _priority = AppointmentPriority.normal;

  @override
  void initState() {
    super.initState();
    if (widget.patientId != null) {
      _selectedPatient = widget.patientId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        actions: [
          ElevatedButton.icon(
            onPressed: _bookAppointment,
            icon: const Icon(Icons.event_available),
            label: const Text('Book'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPatientSection(),
            const SizedBox(height: 24),
            _buildDoctorSection(),
            const SizedBox(height: 24),
            _buildDateTimeSection(),
            const SizedBox(height: 24),
            _buildAppointmentDetailsSection(),
            const SizedBox(height: 24),
            _buildNotesSection(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Hide patient selection if user is a patient themselves
            if (widget.userRole != UserRole.PATIENT)
              DropdownButtonFormField<String>(
                value: _selectedPatient,
                decoration: InputDecoration(
                  labelText: 'Select Patient',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchPatient,
                  ),
                ),
                items: _getMockPatients()
                    .map(
                      (patient) => DropdownMenuItem(
                        value: patient['id'],
                        child: Text('${patient['name']} (${patient['id']})'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedPatient = value),
                validator: (value) =>
                    value == null ? 'Please select a patient' : null,
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Booking for yourself',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          Text(
                            '${getDemoDisplayName(widget.patientId ?? 'P001')} (${widget.patientId ?? 'P001'})',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            if (_selectedPatient != null ||
                widget.userRole == UserRole.PATIENT) ...[
              const SizedBox(height: 16),
              _buildPatientDetails(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPatientDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Resolve the patient id used for display (either selected or the current user)
          _buildDetailRow(
              'Name',
              getDemoDisplayName(widget.userRole == UserRole.PATIENT
                  ? (widget.patientId ?? 'P001')
                  : (_selectedPatient ?? 'P001'))),
          _buildDetailRow('Age', '45 years'),
          _buildDetailRow('Phone', '+1 (555) 123-4567'),
          _buildDetailRow('Last Visit', '2 weeks ago'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDoctorSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Doctor & Department',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDepartment,
              decoration: const InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(),
              ),
              items: _getDepartments()
                  .map(
                    (dept) => DropdownMenuItem(value: dept, child: Text(dept)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDepartment = value;
                  _selectedDoctor =
                      null; // Reset doctor when department changes
                });
              },
              validator: (value) =>
                  value == null ? 'Please select a department' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDoctor,
              decoration: const InputDecoration(
                labelText: 'Doctor',
                border: OutlineInputBorder(),
              ),
              items: _getDoctorsForDepartment(_selectedDepartment)
                  .map(
                    (doctor) => DropdownMenuItem(
                      value: doctor['id'],
                      child: Text(
                          'Dr. ${doctor['name']} - ${doctor['specialization']}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedDoctor = value),
              validator: (value) =>
                  value == null ? 'Please select a doctor' : null,
            ),
            if (_selectedDoctor != null) ...[
              const SizedBox(height: 16),
              _buildDoctorDetails(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorDetails() {
    final doctor = _getDoctorsForDepartment(_selectedDepartment)
        .firstWhere((d) => d['id'] == _selectedDoctor);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildDetailRow('Specialization', doctor['specialization'] ?? ''),
          _buildDetailRow('Experience', doctor['experience'] ?? ''),
          _buildDetailRow('Consultation Fee', doctor['fee'] ?? ''),
          _buildDetailRow('Available', doctor['availability'] ?? ''),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date & Time',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate != null
                                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : 'Select Date',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _selectTime,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time),
                          const SizedBox(width: 12),
                          Text(
                            _selectedTime != null
                                ? _selectedTime!.format(context)
                                : 'Select Time',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedDate != null && _selectedTime != null) ...[
              const SizedBox(height: 16),
              _buildAvailableSlots(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableSlots() {
    final slots = [
      '09:00 AM',
      '10:00 AM',
      '11:00 AM',
      '02:00 PM',
      '03:00 PM',
      '04:00 PM'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Slots:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: slots
              .map((slot) => FilterChip(
                    label: Text(slot),
                    selected: _selectedTime?.format(context) == slot,
                    onSelected: (selected) {
                      if (selected) {
                        final parts = slot.split(' ');
                        final timeParts = parts[0].split(':');
                        final hour = int.parse(timeParts[0]) +
                            (parts[1] == 'PM' && timeParts[0] != '12' ? 12 : 0);
                        final minute = int.parse(timeParts[1]);
                        setState(() {
                          _selectedTime = TimeOfDay(hour: hour, minute: minute);
                        });
                      }
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAppointmentDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appointment Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AppointmentType>(
              value: _appointmentType,
              decoration: const InputDecoration(
                labelText: 'Appointment Type',
                border: OutlineInputBorder(),
              ),
              items: AppointmentType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child:
                          Text(type.toString().split('.').last.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _appointmentType = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AppointmentPriority>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: AppointmentPriority.values
                  .map(
                    (priority) => DropdownMenuItem(
                      value: priority,
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color: _getPriorityColor(priority),
                            size: 12,
                          ),
                          const SizedBox(width: 8),
                          Text(priority
                              .toString()
                              .split('.')
                              .last
                              .toUpperCase()),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _priority = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Visit',
                border: OutlineInputBorder(),
                hintText: 'Brief description of the reason for appointment...',
              ),
              maxLines: 2,
              validator: (value) =>
                  value?.isEmpty == true ? 'Please provide a reason' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Notes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
                hintText: 'Any additional information...',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _bookAppointment,
            icon: const Icon(Icons.event_available),
            label: const Text('Book Appointment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _searchPatient() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Patient'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Enter patient name or ID...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  // Implement patient search
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView(
                  children: _getMockPatients()
                      .map(
                        (patient) => ListTile(
                          title: Text(patient['name'] ?? ''),
                          subtitle: Text(
                              'ID: ${patient['id'] ?? ''} | Age: ${patient['age'] ?? ''}'),
                          onTap: () {
                            setState(() => _selectedPatient = patient['id']);
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _bookAppointment() {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Appointment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Patient: ${_selectedPatient != null ? getDemoDisplayName(_selectedPatient!) : "Current User"}'),
              Text(
                  'Doctor: Dr. ${_getDoctorsForDepartment(_selectedDepartment).firstWhere((d) => d['id'] == _selectedDoctor)['name']}'),
              Text(
                  'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
              Text('Time: ${_selectedTime!.format(context)}'),
              Text('Type: ${_appointmentType.toString().split('.').last}'),
              Text('Reason: ${_reasonController.text}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Appointment booked successfully!')),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, String>> _getMockPatients() {
    return [
      {'id': 'P001', 'name': getDemoDisplayName('P001'), 'age': '45'},
      {'id': 'P002', 'name': getDemoDisplayName('P002'), 'age': '32'},
      {'id': 'P003', 'name': getDemoDisplayName('P003'), 'age': '28'},
      {'id': 'P004', 'name': getDemoDisplayName('P004'), 'age': '55'},
    ];
  }

  List<String> _getDepartments() {
    return [
      'Cardiology',
      'Dermatology',
      'Emergency Medicine',
      'Gastroenterology',
      'General Medicine',
      'Neurology',
      'Orthopedics',
      'Pediatrics',
      'Psychiatry',
      'Radiology',
    ];
  }

  List<Map<String, String>> _getDoctorsForDepartment(String? department) {
    if (department == null) return [];

    final doctors = {
      'Cardiology': [
        {
          'id': 'D001',
          'name': getDemoDisplayName('D001'),
          'specialization': 'Interventional Cardiology',
          'experience': '15 years',
          'fee': '\$200',
          'availability': 'Mon-Fri 9AM-5PM'
        },
        {
          'id': 'D002',
          'name': getDemoDisplayName('D002'),
          'specialization': 'Cardiac Surgery',
          'experience': '20 years',
          'fee': '\$300',
          'availability': 'Tue-Sat 8AM-4PM'
        },
      ],
      'General Medicine': [
        {
          'id': 'D003',
          'name': getDemoDisplayName('D003'),
          'specialization': 'Internal Medicine',
          'experience': '12 years',
          'fee': '\$150',
          'availability': 'Mon-Sat 9AM-6PM'
        },
        {
          'id': 'D004',
          'name': getDemoDisplayName('D004'),
          'specialization': 'Family Medicine',
          'experience': '10 years',
          'fee': '\$120',
          'availability': 'Mon-Fri 8AM-5PM'
        },
      ],
      'Orthopedics': [
        {
          'id': 'D005',
          'name': getDemoDisplayName('D005'),
          'specialization': 'Sports Medicine',
          'experience': '8 years',
          'fee': '\$180',
          'availability': 'Mon-Fri 10AM-6PM'
        },
      ],
    };

    return doctors[department] ?? [];
  }

  Color _getPriorityColor(AppointmentPriority priority) {
    switch (priority) {
      case AppointmentPriority.urgent:
        return Colors.red;
      case AppointmentPriority.high:
        return Colors.orange;
      case AppointmentPriority.normal:
        return Colors.green;
      case AppointmentPriority.low:
        return Colors.blue;
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

enum AppointmentType {
  consultation,
  followUp,
  emergency,
  checkup,
  surgery,
}

enum AppointmentPriority {
  urgent,
  high,
  normal,
  low,
}
