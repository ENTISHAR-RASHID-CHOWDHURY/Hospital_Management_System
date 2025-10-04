import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/dev/demo_names.dart';

class PrescriptionEditorScreen extends ConsumerStatefulWidget {
  final String? patientId;

  const PrescriptionEditorScreen({super.key, this.patientId});

  @override
  ConsumerState<PrescriptionEditorScreen> createState() =>
      _PrescriptionEditorScreenState();
}

class _PrescriptionEditorScreenState
    extends ConsumerState<PrescriptionEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();

  final List<PrescriptionMedication> _medications = [];

  @override
  void initState() {
    super.initState();
    if (widget.patientId != null) {
      _patientController.text =
          'Patient ${widget.patientId}'; // Load actual patient data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write Prescription'),
        actions: [
          TextButton.icon(
            onPressed: _saveDraft,
            icon: const Icon(Icons.save, color: Colors.white),
            label:
                const Text('Save Draft', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _submitPrescription,
            icon: const Icon(Icons.send),
            label: const Text('Submit'),
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
            _buildDiagnosisSection(),
            const SizedBox(height: 24),
            _buildMedicationsSection(),
            const SizedBox(height: 24),
            _buildNotesSection(),
            const SizedBox(height: 24),
            _buildActionsSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMedication,
        tooltip: 'Add Medication',
        child: const Icon(Icons.add),
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

            TextFormField(
              controller: _patientController,
              decoration: InputDecoration(
                labelText: 'Patient',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchPatient,
                ),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Patient is required' : null,
              readOnly: true,
            ),
            const SizedBox(height: 16),

            // Patient Details (mock data)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildPatientDetailRow('Age', '45 years'),
                  _buildPatientDetailRow('Gender', 'Male'),
                  _buildPatientDetailRow('Blood Type', 'O+'),
                  _buildPatientDetailRow('Allergies', 'Penicillin, Shellfish'),
                  _buildPatientDetailRow('Last Visit', '2 weeks ago'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientDetailRow(String label, String value) {
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

  Widget _buildDiagnosisSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diagnosis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _diagnosisController,
              decoration: const InputDecoration(
                labelText: 'Primary Diagnosis',
                border: OutlineInputBorder(),
                hintText: 'Enter the primary diagnosis...',
              ),
              maxLines: 3,
              validator: (value) =>
                  value?.isEmpty == true ? 'Diagnosis is required' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Medications',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _addMedication,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Medication'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_medications.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(Icons.medication, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'No medications added yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(_medications.length,
                  (index) => _buildMedicationCard(_medications[index], index)),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationCard(PrescriptionMedication medication, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    medication.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                IconButton(
                  onPressed: () => _editMedication(index),
                  icon: const Icon(Icons.edit, size: 20),
                ),
                IconButton(
                  onPressed: () => _removeMedication(index),
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Dosage: ${medication.dosage}'),
            Text('Frequency: ${medication.frequency}'),
            Text('Duration: ${medication.duration}'),
            if (medication.instructions.isNotEmpty)
              Text('Instructions: ${medication.instructions}'),
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
                labelText: 'Notes & Instructions',
                border: OutlineInputBorder(),
                hintText: 'Any additional notes or special instructions...',
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _previewPrescription,
                    icon: const Icon(Icons.preview),
                    label: const Text('Preview'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _printPrescription,
                    icon: const Icon(Icons.print),
                    label: const Text('Print'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
              // Mock patient list
              SizedBox(
                height: 200,
                child: ListView(
                  children: [
                    ListTile(
                      title: Text(getDemoDisplayName('P001')),
                      subtitle: const Text('ID: P001 | Age: 45'),
                      onTap: () {
                        _patientController.text =
                            '${getDemoDisplayName('P001')} (P001)';
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: Text(getDemoDisplayName('P002')),
                      subtitle: const Text('ID: P002 | Age: 32'),
                      onTap: () {
                        _patientController.text =
                            '${getDemoDisplayName('P002')} (P002)';
                        Navigator.pop(context);
                      },
                    ),
                  ],
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

  void _addMedication() {
    showDialog(
      context: context,
      builder: (context) => AddMedicationDialog(
        onMedicationAdded: (medication) {
          setState(() {
            _medications.add(medication);
          });
        },
      ),
    );
  }

  void _editMedication(int index) {
    showDialog(
      context: context,
      builder: (context) => AddMedicationDialog(
        medication: _medications[index],
        onMedicationAdded: (medication) {
          setState(() {
            _medications[index] = medication;
          });
        },
      ),
    );
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prescription saved as draft')),
    );
  }

  void _submitPrescription() {
    if (_formKey.currentState!.validate() && _medications.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Submit Prescription'),
          content:
              const Text('Are you sure you want to submit this prescription?'),
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
                      content: Text('Prescription submitted successfully')),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please complete all required fields and add at least one medication'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _previewPrescription() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrescriptionPreviewScreen(
          patientName: _patientController.text,
          diagnosis: _diagnosisController.text,
          medications: _medications,
          notes: _notesController.text,
        ),
      ),
    );
  }

  void _printPrescription() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Printing prescription...')),
    );
  }

  @override
  void dispose() {
    _patientController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

class PrescriptionMedication {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String instructions;

  PrescriptionMedication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.instructions,
  });
}

class AddMedicationDialog extends StatefulWidget {
  final PrescriptionMedication? medication;
  final Function(PrescriptionMedication) onMedicationAdded;

  const AddMedicationDialog({
    super.key,
    this.medication,
    required this.onMedicationAdded,
  });

  @override
  State<AddMedicationDialog> createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends State<AddMedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _frequencyController;
  late final TextEditingController _durationController;
  late final TextEditingController _instructionsController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.medication?.name ?? '');
    _dosageController =
        TextEditingController(text: widget.medication?.dosage ?? '');
    _frequencyController =
        TextEditingController(text: widget.medication?.frequency ?? '');
    _durationController =
        TextEditingController(text: widget.medication?.duration ?? '');
    _instructionsController =
        TextEditingController(text: widget.medication?.instructions ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.medication == null ? 'Add Medication' : 'Edit Medication'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medication Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage (e.g., 500mg)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _frequencyController,
                decoration: const InputDecoration(
                  labelText: 'Frequency (e.g., Twice daily)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (e.g., 7 days)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Special Instructions',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveMedication,
          child: Text(widget.medication == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }

  void _saveMedication() {
    if (_formKey.currentState!.validate()) {
      final medication = PrescriptionMedication(
        name: _nameController.text,
        dosage: _dosageController.text,
        frequency: _frequencyController.text,
        duration: _durationController.text,
        instructions: _instructionsController.text,
      );

      widget.onMedicationAdded(medication);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }
}

class PrescriptionPreviewScreen extends StatelessWidget {
  final String patientName;
  final String diagnosis;
  final List<PrescriptionMedication> medications;
  final String notes;

  const PrescriptionPreviewScreen({
    super.key,
    required this.patientName,
    required this.diagnosis,
    required this.medications,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Preview'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Printing prescription...')),
              );
            },
            icon: const Icon(Icons.print),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Text(
                        'CITY GENERAL HOSPITAL',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const Text('123 Medical Center Dr, City, State 12345'),
                      const Text('Phone: (555) 123-4567'),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'PRESCRIPTION',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Patient Info
                Text('Patient: $patientName'),
                Text('Date: ${DateTime.now().toString().split(' ')[0]}'),
                const SizedBox(height: 16),

                // Diagnosis
                Text(
                  'Diagnosis: $diagnosis',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),

                // Medications
                const Text(
                  'Rx:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),

                ...medications.map((med) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            med.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Dosage: ${med.dosage}'),
                          Text('Sig: ${med.frequency}, ${med.duration}'),
                          if (med.instructions.isNotEmpty)
                            Text('Instructions: ${med.instructions}'),
                          const Divider(),
                        ],
                      ),
                    )),

                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Additional Notes: $notes',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],

                const SizedBox(height: 48),

                // Signature
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('_________________________'),
                        const SizedBox(height: 4),
                        const Text('Doctor Signature'),
                        const SizedBox(height: 8),
                        Text(
                            'Dr. ${patientName.split(' ').first} (License: MD12345)'),
                      ],
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('_________________________'),
                        SizedBox(height: 4),
                        Text('Date'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
