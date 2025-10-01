import 'package:flutter/material.dart';

import '../../data/auth_user.dart';

class RoleSelector extends StatelessWidget {
  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  final UserRole selectedRole;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select your role',
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<UserRole>(
          value: selectedRole,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.badge_outlined),
            labelText: 'Role',
          ),
          dropdownColor: const Color(0xFF1E293B),
          items: UserRole.values
              .map(
                (role) => DropdownMenuItem<UserRole>(
                  value: role,
                  child: Text(role.displayName),
                ),
              )
              .toList(),
          onChanged: (role) {
            if (role != null) {
              onChanged(role);
            }
          },
        ),
      ],
    );
  }
}
