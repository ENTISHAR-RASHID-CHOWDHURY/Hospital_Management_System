import 'package:flutter/material.dart';

class DashboardOption {
  const DashboardOption({
    required this.title,
    required this.description,
    required this.iconName,
    required this.routeName,
    this.queryParams = const {},
  });

  final String title;
  final String description;
  final String iconName;
  final String routeName;
  final Map<String, String> queryParams;

  IconData get icon => _iconMap[iconName] ?? Icons.dashboard_customize;

  factory DashboardOption.fromJson(Map<String, dynamic> json) {
    return DashboardOption(
      title: json['title'] as String,
      description: json['description'] as String,
      iconName: json['icon'] as String? ?? 'dashboard_customize',
      routeName: json['routeName'] as String? ?? json['route'] as String? ?? '',
      queryParams: (json['queryParams'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, value.toString())),
    );
  }

  static const Map<String, IconData> _iconMap = {
    'calendar_month': Icons.calendar_month,
    'folder_shared': Icons.folder_shared,
    'receipt_long': Icons.receipt_long,
    'notifications_active': Icons.notifications_active,
    'schedule': Icons.schedule,
    'people_alt': Icons.people_alt,
    'medical_services': Icons.medical_services,
    'assignment': Icons.assignment,
    'local_hospital': Icons.local_hospital,
    'monitor_heart': Icons.monitor_heart,
    'swap_horiz': Icons.swap_horiz,
    'app_registration': Icons.app_registration,
    'event_available': Icons.event_available,
    'attach_money': Icons.attach_money,
    'playlist_add_check': Icons.playlist_add_check,
    'inventory': Icons.inventory,
    'local_shipping': Icons.local_shipping,
    'science': Icons.science,
    'upload_file': Icons.upload_file,
    'verified_user': Icons.verified_user,
    'analytics': Icons.analytics,
    'manage_accounts': Icons.manage_accounts,
    'account_balance': Icons.account_balance,
    'fact_check': Icons.fact_check,
    'person_add': Icons.person_add,
    'group': Icons.group,
    'medical_information': Icons.medical_information,
    'calendar_today': Icons.calendar_today,
    'description': Icons.description,
    'settings': Icons.settings,
    'dashboard_customize': Icons.dashboard_customize,
  };
}
