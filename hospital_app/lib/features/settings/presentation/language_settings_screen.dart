import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/localization_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/gradient_scaffold.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return GradientScaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            localizationProvider.getTextDirection() == TextDirection.rtl
                ? Icons.arrow_forward
                : Icons.arrow_back,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Directionality(
        textDirection: localizationProvider.getTextDirection(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.language,
                            color: Theme.of(context).primaryColor,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Language Settings',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose your preferred language for the application interface.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Current Language Display
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Text(
                    localizationProvider.getLanguageFlag(
                      localizationProvider.currentLocale.languageCode,
                    ),
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    'Current Language',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  subtitle: Text(
                    localizationProvider.getLanguageName(
                      localizationProvider.currentLocale.languageCode,
                    ),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  trailing: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Available Languages
              Text(
                'Available Languages',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: ListView.builder(
                  itemCount: localizationProvider.supportedLocales.length,
                  itemBuilder: (context, index) {
                    final locale = localizationProvider.supportedLocales[index];
                    final isSelected = locale.languageCode ==
                        localizationProvider.currentLocale.languageCode;

                    return Card(
                      elevation: isSelected ? 4 : 1,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isSelected
                            ? BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              )
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        onTap: isSelected
                            ? null
                            : () => _changeLanguage(context, locale),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              localizationProvider
                                  .getLanguageFlag(locale.languageCode),
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        title: Text(
                          localizationProvider
                              .getLanguageName(locale.languageCode),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : null,
                                  ),
                        ),
                        subtitle: Text(
                          locale.languageCode.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).primaryColor,
                              )
                            : Icon(
                                localizationProvider.getTextDirection() ==
                                        TextDirection.rtl
                                    ? Icons.chevron_left
                                    : Icons.chevron_right,
                                color: Colors.grey[400],
                              ),
                      ),
                    );
                  },
                ),
              ),

              // Language Info Card
              Card(
                elevation: 2,
                color: Colors.blue[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Language Support',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'The application will restart to apply the new language settings.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.blue[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _changeLanguage(BuildContext context, Locale locale) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final localizationProvider =
            Provider.of<LocalizationProvider>(context, listen: false);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Text(
                localizationProvider.getLanguageFlag(locale.languageCode),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Text('Change Language'),
            ],
          ),
          content: Text(
            'Are you sure you want to change the language to ${localizationProvider.getLanguageName(locale.languageCode)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                localizationProvider.setLocale(locale);
                Navigator.pop(context);

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Language changed to ${localizationProvider.getLanguageName(locale.languageCode)}',
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
  }
}
