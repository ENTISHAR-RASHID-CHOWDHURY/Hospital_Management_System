import 'package:flutter/material.dart';

/// Centralized Terms and Privacy policies.
/// Use these constants and helpers to display consistent dialogs across the app.

const String kTermsOfServiceTitle = 'Terms of Service';
const String kPrivacyPolicyTitle = 'Privacy Policy';

const String kTermsOfServiceText =
    '''HOSPITAL MANAGEMENT SYSTEM – TERMS OF SERVICE

1. ACCEPTANCE OF TERMS
By accessing and using this Hospital Management System, you agree to abide by these terms in a manner consistent with Islamic principles of honesty (sidq), trustworthiness (amanah), and accountability (muhasabah).

2. MEDICAL DISCLAIMER
This system is designed for hospital management purposes only. It does not replace professional medical advice, diagnosis, or treatment. Islam encourages seeking proper knowledge and expertise (ahl al-dhikr) for matters of health.

3. PRIVACY AND CONFIDENTIALITY
All patient data is treated as a sacred trust (amanah). Protecting the dignity and privacy of patients is an obligation in Islam, as it is in law. Unauthorized access, misuse, or disclosure of information is strictly prohibited.

4. USER RESPONSIBILITIES
As a user of this system, you are entrusted with responsibilities that align with both hospital policies and Islamic ethics:

• Safeguard your login credentials (amana).
• Report any breaches of security without delay.
• Use the system only for lawful and authorized purposes.
• Uphold hospital rules, regulations, and Shariah-compliant practices of integrity.

5. DATA SECURITY
We employ security measures to protect sensitive medical data. Preserving life (hifz al-nafs) and safeguarding rights (hifz al-haqq) are among the objectives of Shariah (maqasid al-shariah), and data protection is part of this duty.

6. LIMITATION OF LIABILITY
This system is provided "as is" without warranties. We are not responsible for any harm or damages arising from its use. In Islam, accountability is tied to intention and capacity; users are reminded to act within their role and responsibility.

7. MODIFICATIONS
We reserve the right to update these terms at any time. Continued use of the system signifies acceptance of any changes, in accordance with the principle of mutual consent (taradhi) in contracts.

Last Updated: October 2025''';

const String kPrivacyPolicyText = '''HOSPITAL MANAGEMENT SYSTEM – PRIVACY POLICY

1. SACRED TRUST (AMANAH) OF INFORMATION
We consider all patient and user information as a sacred trust (amanah). Islam emphasizes the protection of privacy as a fundamental right, and we honor this principle in our data handling practices.

2. INFORMATION WE COLLECT
• Patient medical records and personal health information
• Healthcare provider credentials and professional details
• Administrative and operational data for hospital management
• System access logs for security and audit purposes

3. HOW WE USE INFORMATION
Information is used solely for:
• Providing healthcare services and hospital management
• Ensuring patient safety and quality of care (hifz al-nafs)
• Compliance with legal, regulatory, and Shariah requirements
• System security and improvement for the benefit of all users

4. INFORMATION SHARING PRINCIPLES
In accordance with Islamic principles of justice (adl) and trustworthiness (amanah), we do not sell or inappropriately share personal information. Information is shared only:
• With authorized healthcare providers for legitimate patient care
• As required by law or religious obligations
• With explicit consent from the individual
• In emergency situations to preserve life (darura)

5. DATA SECURITY MEASURES
• Comprehensive encryption for sensitive data protection
• Regular security assessments and system updates
• Strict access controls and user authentication
• Secure backup and recovery systems
• Training on both technical and ethical data handling

6. PATIENT AND USER RIGHTS
As part of honoring human dignity (karama), you have the right to:
• Access your medical records and personal information
• Request corrections to inaccurate data
• Withdraw consent for non-essential uses
• File complaints about privacy violations
• Request deletion of data where permissible according to Shariah

7. RELIGIOUS AND LEGAL COMPLIANCE
This system adheres to:
• Islamic principles of privacy, dignity, and trustworthiness
• Healthcare privacy regulations and standards
• Islamic medical ethics and confidentiality rules
• International data protection requirements

8. CONTACT FOR PRIVACY CONCERNS
For privacy-related questions or concerns, please contact our Privacy Officer who is trained in both legal and ethical obligations.

Email: privacy@hospital.com
Phone: [Contact Number]

Last Updated: October 2025

May Allah (SWT) guide us in fulfilling our responsibilities with integrity and righteousness.''';

/// Shows a dialog containing the Terms of Service.
Future<void> showTermsDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1F2A3F),
      title: const Text(kTermsOfServiceTitle,
          style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Text(
          kTermsOfServiceText,
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close')),
      ],
    ),
  );
}

/// Shows a dialog containing the Privacy Policy.
Future<void> showPrivacyDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1F2A3F),
      title: const Text(kPrivacyPolicyTitle,
          style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Text(
          kPrivacyPolicyText,
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close')),
      ],
    ),
  );
}
