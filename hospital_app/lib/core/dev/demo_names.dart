// Helper utilities for mapping demo user ids/emails to a deterministic
// male Muslim display name for developer/demo mode.

const List<String> kMuslimMaleNames = [
  'Muhammad',
  'Ahmed',
  'Ali',
  'Omar',
  'Hassan',
  'Husain',
  'Yusuf',
  'Ibrahim',
  'Ismail',
  'Salman',
  'Tariq',
  'Bilal',
  'Karim',
  'Saeed',
  'Zaid',
  'Zain',
  'Abdulrahman',
  'Abdulaziz',
  'Hamza',
  'Imran',
  'Farhan',
  'Faisal',
  'Mustafa',
  'Nabil',
  'Rafiq',
  'Azhar',
  'Sami',
  'Amin',
  'Jamal',
  'Khalid',
  'Mahmud',
  'Mansoor',
  'Nawaz',
  'Rashid',
  'Riyaz',
  'Salah',
  'Shahid',
  'Taimur',
  'Yahya',
  'Zubair',
  'Fahad',
  'Waleed',
  'Yasin',
  'Adnan',
  'Anas',
  'Usman',
  'Riyad',
  'Ehsan',
];

/// Deterministically picks a demo display name for the provided key
/// (for example a demo user's id or email). The same key will always map
/// to the same name, so developer mode stays stable across screens.
String getDemoDisplayName(String key) {
  if (key.isEmpty) return kMuslimMaleNames.first;
  // Simple deterministic hash
  int hash = 0;
  for (final codeUnit in key.codeUnits) {
    hash = (hash * 31 + codeUnit) & 0x7fffffff;
  }
  return kMuslimMaleNames[hash % kMuslimMaleNames.length];
}

String getDemoInitial(String key) {
  final name = getDemoDisplayName(key);
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
}
