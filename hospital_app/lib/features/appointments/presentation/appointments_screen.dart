import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/appointment.dart';
import '../services/appointment_service.dart';
import '../../core/services/api_service.dart';
import '../../core/providers/auth_provider.dart';
import '../../../core/dev/demo_names.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  final authState = ref.watch(authProvider);
  return ApiService(authState.token);
});

final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AppointmentService(apiService);
});

final appointmentsProvider = FutureProvider<List<Appointment>>((ref) async {
  final service = ref.watch(appointmentServiceProvider);
  return await service.getAllAppointments();
});

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  String? _selectedStatus;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final appointmentsAsync = ref.watch(appointmentsProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Appointments',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showCreateAppointmentDialog();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Appointment'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 16),
            Expanded(
              child: appointmentsAsync.when(
                data: (appointments) => _buildAppointmentsList(appointments),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading appointments',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(appointmentsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                value: _selectedStatus,
                items: const [
                  DropdownMenuItem(value: null, child: Text('All Statuses')),
                  DropdownMenuItem(
                      value: 'SCHEDULED', child: Text('Scheduled')),
                  DropdownMenuItem(
                      value: 'CONFIRMED', child: Text('Confirmed')),
                  DropdownMenuItem(
                      value: 'IN_PROGRESS', child: Text('In Progress')),
                  DropdownMenuItem(
                      value: 'COMPLETED', child: Text('Completed')),
                  DropdownMenuItem(
                      value: 'CANCELLED', child: Text('Cancelled')),
                  DropdownMenuItem(value: 'NO_SHOW', child: Text('No Show')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                  ref.invalidate(appointmentsProvider);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                        ref.invalidate(appointmentsProvider);
                      }
                    },
                  ),
                ),
                readOnly: true,
                controller: TextEditingController(
                  text: _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : '',
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedStatus = null;
                  _selectedDate = null;
                });
                ref.invalidate(appointmentsProvider);
              },
              child: const Text('Clear'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No appointments found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a new appointment to get started',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _buildAppointmentCard(appointment);
      },
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(appointment.status),
          child: const Icon(
            Icons.schedule,
            color: Colors.white,
          ),
        ),
        title: Text(
          _getPatientName(appointment),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getDoctorName(appointment)),
            Text(
                '${_formatDate(appointment.appointmentDate)} - ${appointment.timeSlot}'),
            Text('Type: ${appointment.type}'),
            if (appointment.reasonForVisit != null)
              Text('Reason: ${appointment.reasonForVisit}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(appointment.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStatusColor(appointment.status)),
              ),
              child: Text(
                appointment.status,
                style: TextStyle(
                  color: _getStatusColor(appointment.status),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (appointment.consultationFee != null)
              Text(
                '\$${appointment.consultationFee!.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
          ],
        ),
        onTap: () => _showAppointmentDetails(appointment),
        isThreeLine: true,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return Colors.blue;
      case 'CONFIRMED':
        return Colors.green;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.purple;
      case 'CANCELLED':
        return Colors.red;
      case 'NO_SHOW':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getPatientName(Appointment appointment) {
    if (appointment.patient != null) {
      return '${appointment.patient!.firstName} ${appointment.patient!.lastName}';
    }
    // Demo names based on patient ID
    // Use deterministic demo name mapping keyed by patientId
    if (appointment.patientId.isNotEmpty) {
      return getDemoDisplayName(appointment.patientId);
    }
    return 'Patient ${appointment.patientId}';
  }

  String _getDoctorName(Appointment appointment) {
    if (appointment.doctor != null) {
      return 'Dr. ${appointment.doctor!.firstName} ${appointment.doctor!.lastName}';
    }
    // Demo names based on doctorId via demo helper
    if (appointment.doctorId.isNotEmpty) {
      return 'Dr. ${getDemoDisplayName(appointment.doctorId)}';
    }
    return 'Dr. ${appointment.doctorId}';
  }

  void _showAppointmentDetails(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appointment Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Patient', _getPatientName(appointment)),
              _buildDetailRow('Doctor', _getDoctorName(appointment)),
              _buildDetailRow('Date', _formatDate(appointment.appointmentDate)),
              _buildDetailRow('Time', appointment.timeSlot),
              _buildDetailRow('Type', appointment.type),
              _buildDetailRow('Status', appointment.status),
              if (appointment.reasonForVisit != null)
                _buildDetailRow('Reason', appointment.reasonForVisit!),
              if (appointment.notes != null)
                _buildDetailRow('Notes', appointment.notes!),
              if (appointment.consultationFee != null)
                _buildDetailRow('Fee',
                    '\$${appointment.consultationFee!.toStringAsFixed(2)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (appointment.status != 'COMPLETED' &&
              appointment.status != 'CANCELLED')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showEditAppointmentDialog(appointment);
              },
              child: const Text('Edit'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showCreateAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Appointment'),
        content: const Text(
            'Appointment creation feature will be implemented soon!\n\nThis would include:\n• Patient selection\n• Doctor selection\n• Date and time picker\n• Appointment type\n• Reason for visit\n• Consultation fee'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEditAppointmentDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Appointment'),
        content: const Text(
            'Appointment editing feature will be implemented soon!\n\nThis would include:\n• Update status\n• Reschedule date/time\n• Modify notes\n• Update consultation fee'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
