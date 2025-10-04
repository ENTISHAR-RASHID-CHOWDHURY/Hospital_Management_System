import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/dev/demo_names.dart';

class VitalSignsEntryScreen extends ConsumerStatefulWidget {
  final String? patientId;

  const VitalSignsEntryScreen({super.key, this.patientId});

  @override
  ConsumerState<VitalSignsEntryScreen> createState() =>
      _VitalSignsEntryScreenState();
}

class _VitalSignsEntryScreenState extends ConsumerState<VitalSignsEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _temperatureController = TextEditingController();
  final _bloodPressureSystolicController = TextEditingController();
  final _bloodPressureDiastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _respiratoryRateController = TextEditingController();
  final _oxygenSaturationController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedPatient;
  DateTime _recordedTime = DateTime.now();

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
        title: const Text('Vital Signs Entry'),
        actions: [
          ElevatedButton.icon(
            onPressed: _saveVitalSigns,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
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
            _buildVitalSignsSection(),
            const SizedBox(height: 24),
            _buildPhysicalMeasurementsSection(),
            const SizedBox(height: 24),
            _buildNotesSection(),
            const SizedBox(height: 24),
            _buildHistorySection(),
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
            ),
            if (_selectedPatient != null) ...[
              const SizedBox(height: 16),
              _buildPatientDetails(),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Recorded: ${_recordedTime.toString().substring(0, 16)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _updateRecordedTime,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Update Time'),
                ),
              ],
            ),
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
          _buildDetailRow(
              'Name',
              _selectedPatient != null
                  ? getDemoDisplayName(_selectedPatient!)
                  : getDemoDisplayName('P001')),
          _buildDetailRow('Age', '45 years'),
          _buildDetailRow('Room', 'A-201'),
          _buildDetailRow('Condition', 'Post-surgery recovery'),
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

  Widget _buildVitalSignsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vital Signs',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Temperature
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _temperatureController,
                    decoration: const InputDecoration(
                      labelText: 'Temperature',
                      suffixText: '°F',
                      border: OutlineInputBorder(),
                      hintText: '98.6',
                      prefixIcon: Icon(Icons.thermostat, color: Colors.red),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validateTemperature,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getTemperatureColor(_temperatureController.text),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getTemperatureStatus(_temperatureController.text),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Blood Pressure
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bloodPressureSystolicController,
                    decoration: const InputDecoration(
                      labelText: 'Systolic BP',
                      suffixText: 'mmHg',
                      border: OutlineInputBorder(),
                      hintText: '120',
                      prefixIcon: Icon(Icons.favorite, color: Colors.red),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validateSystolic,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('/',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _bloodPressureDiastolicController,
                    decoration: const InputDecoration(
                      labelText: 'Diastolic BP',
                      suffixText: 'mmHg',
                      border: OutlineInputBorder(),
                      hintText: '80',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validateDiastolic,
                  ),
                ),
              ],
            ),

            if (_bloodPressureSystolicController.text.isNotEmpty &&
                _bloodPressureDiastolicController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getBPColor(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getBPStatus(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Heart Rate and Respiratory Rate
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heartRateController,
                    decoration: const InputDecoration(
                      labelText: 'Heart Rate',
                      suffixText: 'bpm',
                      border: OutlineInputBorder(),
                      hintText: '72',
                      prefixIcon: Icon(Icons.monitor_heart, color: Colors.red),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validateHeartRate,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _respiratoryRateController,
                    decoration: const InputDecoration(
                      labelText: 'Respiratory Rate',
                      suffixText: '/min',
                      border: OutlineInputBorder(),
                      hintText: '16',
                      prefixIcon: Icon(Icons.air, color: Colors.blue),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validateRespiratoryRate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Oxygen Saturation
            TextFormField(
              controller: _oxygenSaturationController,
              decoration: const InputDecoration(
                labelText: 'Oxygen Saturation (SpO2)',
                suffixText: '%',
                border: OutlineInputBorder(),
                hintText: '98',
                prefixIcon: Icon(Icons.bubble_chart, color: Colors.blue),
              ),
              keyboardType: TextInputType.number,
              validator: _validateOxygenSaturation,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalMeasurementsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Physical Measurements',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'Height',
                      suffixText: 'cm',
                      border: OutlineInputBorder(),
                      hintText: '175',
                      prefixIcon: Icon(Icons.height, color: Colors.green),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight',
                      suffixText: 'kg',
                      border: OutlineInputBorder(),
                      hintText: '70',
                      prefixIcon:
                          Icon(Icons.monitor_weight, color: Colors.orange),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            if (_heightController.text.isNotEmpty &&
                _weightController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildBMISection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBMISection() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);

    if (height != null && weight != null && height > 0) {
      final bmi = weight / ((height / 100) * (height / 100));
      final bmiCategory = _getBMICategory(bmi);
      final bmiColor = _getBMIColor(bmi);

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bmiColor.withOpacity(0.1),
          border: Border.all(color: bmiColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calculate, color: bmiColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BMI: ${bmi.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: bmiColor,
                    ),
                  ),
                  Text(
                    'Category: $bmiCategory',
                    style: TextStyle(color: bmiColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clinical Notes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Observations & Notes',
                border: OutlineInputBorder(),
                hintText:
                    'Patient appears comfortable, no distress observed...',
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Vital Signs History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildHistoryItem('2 hours ago', '98.6°F', '120/80', '72 bpm'),
            _buildHistoryItem('6 hours ago', '98.4°F', '118/78', '68 bpm'),
            _buildHistoryItem('12 hours ago', '98.8°F', '122/82', '75 bpm'),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String time, String temp, String bp, String hr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              time,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text('Temp: $temp')),
          Expanded(child: Text('BP: $bp')),
          Expanded(child: Text('HR: $hr')),
        ],
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
            onPressed: _saveVitalSigns,
            icon: const Icon(Icons.save),
            label: const Text('Save Vital Signs'),
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
                  hintText: 'Enter patient name or room number...',
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
                          title: Text(patient['name']!),
                          subtitle: Text(
                              'Room: ${patient['room']} | ID: ${patient['id']}'),
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

  void _updateRecordedTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _recordedTime,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_recordedTime),
      );

      if (time != null) {
        setState(() {
          _recordedTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _saveVitalSigns() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Save Vital Signs'),
          content:
              const Text('Are you sure you want to save these vital signs?'),
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
                      content: Text('Vital signs saved successfully!')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    }
  }

  // Validation methods
  String? _validateTemperature(String? value) {
    if (value == null || value.isEmpty) return 'Temperature is required';
    final temp = double.tryParse(value);
    if (temp == null) return 'Invalid temperature';
    if (temp < 90 || temp > 110) return 'Temperature out of normal range';
    return null;
  }

  String? _validateSystolic(String? value) {
    if (value == null || value.isEmpty) return 'Systolic BP is required';
    final sys = int.tryParse(value);
    if (sys == null) return 'Invalid systolic pressure';
    if (sys < 70 || sys > 200) return 'Systolic BP out of range';
    return null;
  }

  String? _validateDiastolic(String? value) {
    if (value == null || value.isEmpty) return 'Diastolic BP is required';
    final dia = int.tryParse(value);
    if (dia == null) return 'Invalid diastolic pressure';
    if (dia < 40 || dia > 120) return 'Diastolic BP out of range';
    return null;
  }

  String? _validateHeartRate(String? value) {
    if (value == null || value.isEmpty) return 'Heart rate is required';
    final hr = int.tryParse(value);
    if (hr == null) return 'Invalid heart rate';
    if (hr < 40 || hr > 150) return 'Heart rate out of normal range';
    return null;
  }

  String? _validateRespiratoryRate(String? value) {
    if (value == null || value.isEmpty) return 'Respiratory rate is required';
    final rr = int.tryParse(value);
    if (rr == null) return 'Invalid respiratory rate';
    if (rr < 8 || rr > 30) return 'Respiratory rate out of range';
    return null;
  }

  String? _validateOxygenSaturation(String? value) {
    if (value == null || value.isEmpty) return 'Oxygen saturation is required';
    final spo2 = int.tryParse(value);
    if (spo2 == null) return 'Invalid oxygen saturation';
    if (spo2 < 85 || spo2 > 100) return 'SpO2 out of range';
    return null;
  }

  // Status and color methods
  Color _getTemperatureColor(String temp) {
    final temperature = double.tryParse(temp);
    if (temperature == null) return Colors.grey;
    if (temperature < 97 || temperature > 99.5) return Colors.red;
    return Colors.green;
  }

  String _getTemperatureStatus(String temp) {
    final temperature = double.tryParse(temp);
    if (temperature == null) return 'Unknown';
    if (temperature < 97) return 'Hypothermia';
    if (temperature > 99.5) return 'Fever';
    return 'Normal';
  }

  Color _getBPColor() {
    final sys = int.tryParse(_bloodPressureSystolicController.text);
    final dia = int.tryParse(_bloodPressureDiastolicController.text);
    if (sys == null || dia == null) return Colors.grey;

    if (sys >= 140 || dia >= 90) return Colors.red;
    if (sys >= 130 || dia >= 80) return Colors.orange;
    if (sys < 90 || dia < 60) return Colors.blue;
    return Colors.green;
  }

  String _getBPStatus() {
    final sys = int.tryParse(_bloodPressureSystolicController.text);
    final dia = int.tryParse(_bloodPressureDiastolicController.text);
    if (sys == null || dia == null) return 'Unknown';

    if (sys >= 140 || dia >= 90) return 'High Blood Pressure';
    if (sys >= 130 || dia >= 80) return 'Elevated';
    if (sys < 90 || dia < 60) return 'Low Blood Pressure';
    return 'Normal';
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  List<Map<String, String>> _getMockPatients() {
    return [
      {'id': 'P001', 'name': getDemoDisplayName('P001'), 'room': 'A-201'},
      {'id': 'P002', 'name': getDemoDisplayName('P002'), 'room': 'B-105'},
      {'id': 'P003', 'name': getDemoDisplayName('P003'), 'room': 'A-203'},
      {'id': 'P004', 'name': getDemoDisplayName('P004'), 'room': 'C-102'},
    ];
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _bloodPressureSystolicController.dispose();
    _bloodPressureDiastolicController.dispose();
    _heartRateController.dispose();
    _respiratoryRateController.dispose();
    _oxygenSaturationController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
