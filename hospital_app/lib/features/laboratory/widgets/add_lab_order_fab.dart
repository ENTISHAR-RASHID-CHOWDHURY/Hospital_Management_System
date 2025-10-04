import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/laboratory_providers.dart';

class AddLabOrderFab extends ConsumerWidget {
  const AddLabOrderFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCreating = ref.watch(isCreatingLabOrderProvider);

    return FloatingActionButton.extended(
      onPressed: isCreating ? null : () => _showAddOrderDialog(context, ref),
      icon: isCreating
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.add),
      label: Text(isCreating ? 'Creating...' : 'New Order'),
      backgroundColor: isCreating ? Colors.grey : Colors.blue,
    );
  }

  void _showAddOrderDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final patientNameController = TextEditingController();
    final patientIdController = TextEditingController();
    final doctorNameController = TextEditingController();
    final doctorIdController = TextEditingController();
    final notesController = TextEditingController();

    String selectedUrgency = 'ROUTINE';
    List<String> selectedTests = [];

    final availableTests = [
      'Complete Blood Count (CBC)',
      'Basic Metabolic Panel (BMP)',
      'Lipid Panel',
      'Liver Function Tests (LFT)',
      'Thyroid Function Tests',
      'Hemoglobin A1C',
      'Urinalysis',
      'Blood Glucose',
      'Creatinine',
      'ESR (Sed Rate)',
      'CRP (C-Reactive Protein)',
      'Vitamin D',
      'Vitamin B12',
      'Iron Studies',
      'PT/INR',
      'PTT',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Lab Order'),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient Information
                    Text(
                      'Patient Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: patientIdController,
                      decoration: const InputDecoration(
                        labelText: 'Patient ID *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter patient ID';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: patientNameController,
                      decoration: const InputDecoration(
                        labelText: 'Patient Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter patient name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Doctor Information
                    Text(
                      'Doctor Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: doctorIdController,
                      decoration: const InputDecoration(
                        labelText: 'Doctor ID *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter doctor ID';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: doctorNameController,
                      decoration: const InputDecoration(
                        labelText: 'Doctor Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter doctor name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Order Details
                    Text(
                      'Order Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedUrgency,
                      decoration: const InputDecoration(
                        labelText: 'Urgency *',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'ROUTINE', child: Text('Routine')),
                        DropdownMenuItem(
                            value: 'URGENT', child: Text('Urgent')),
                        DropdownMenuItem(value: 'STAT', child: Text('STAT')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedUrgency = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tests Selection
                    Text(
                      'Tests to Order *',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        itemCount: availableTests.length,
                        itemBuilder: (context, index) {
                          final test = availableTests[index];
                          return CheckboxListTile(
                            title: Text(test),
                            value: selectedTests.contains(test),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedTests.add(test);
                                } else {
                                  selectedTests.remove(test);
                                }
                              });
                            },
                            dense: true,
                          );
                        },
                      ),
                    ),
                    if (selectedTests.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Please select at least one test',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(),
                        hintText: 'Additional instructions or notes...',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _createOrder(
                context,
                ref,
                formKey,
                patientIdController.text,
                patientNameController.text,
                doctorIdController.text,
                doctorNameController.text,
                selectedUrgency,
                selectedTests,
                notesController.text,
              ),
              child: const Text('Create Order'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createOrder(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    String patientId,
    String patientName,
    String doctorId,
    String doctorName,
    String urgency,
    List<String> tests,
    String notes,
  ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (tests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one test'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final orderData = {
        'patientId': patientId,
        'patientName': patientName,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'urgency': urgency,
        'tests': tests,
        'notes': notes,
        'status': 'PENDING',
      };

      await ref.createLabOrder(orderData);

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lab order created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create lab order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
