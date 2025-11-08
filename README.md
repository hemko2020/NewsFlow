# NewsFlow

A secure Flutter news application with Firebase integration and premium subscriptions.

## 🔒 Security Overview

NewsFlow implements enterprise-grade security for handling sensitive user data and payments:

### Core Security Features
- **End-to-End Encryption**: AES-256 encryption for all sensitive data
- **Hardware Security**: Keychain (iOS) and Keystore (Android) storage
- **PCI DSS Compliance**: Stripe integration (Level 1 certified)
- **GDPR Compliance**: Complete user data rights and audit logging
- **Biometric Protection**: Fingerprint/Face ID for sensitive operations
- **Secure Backend**: All payment processing server-side

### Security Architecture
```
User Data → AES-256 Encryption → Hardware Storage (Keychain/Keystore)
Payment Data → Stripe SDK → Secure Tokens → Backend Processing
Authentication → Biometric/Fallback → Encrypted Session Tokens
```

## Security Configuration

This app uses encrypted environment variables for sensitive data. Never commit real API keys to version control.

### Setup

1. **Copy environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Configure your API keys in `.env`:**
   ```env
   NEWS_API_KEY=your_news_api_key_here
   FIREBASE_API_KEY=your_firebase_api_key_here
   FIREBASE_APP_ID=your_firebase_app_id_here
   FIREBASE_MESSAGING_SENDER_ID=your_firebase_sender_id_here
   FIREBASE_PROJECT_ID=your_firebase_project_id_here
   FIREBASE_STORAGE_BUCKET=your_firebase_storage_bucket_here

   # Payments (Stripe)
   STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key_here
   ```

3. **Firebase Configuration:**
   - Copy `google-services.template.json` to `google-services.json`
   - Replace placeholder values with your real Firebase config
   - **Never commit** `google-services.json` - it's in `.gitignore`

## Payment Security & Compliance

NewsFlow implements enterprise-grade security for premium subscriptions:

### 🔒 Payment Security
- **PCI DSS Compliant**: Uses Stripe (Level 1 certified)
- **No Card Data Storage**: Never stores credit card details in the app
- **Tokenized Payments**: Only secure payment tokens are stored locally
- **End-to-End Encryption**: All payment data encrypted AES-256

### 🛡️ GDPR Compliance
- **Right to Access**: Users can export their data anytime
- **Right to Deletion**: Complete data removal on demand
- **Data Minimization**: Only essential data collected
- **Consent Management**: Granular consent tracking
- **Data Portability**: Export data in standard formats

### 🔐 Data Protection
- **Hardware Security**: Keychain (iOS) and Keystore (Android)
- **Biometric Authentication**: Optional fingerprint/face unlock
- **Encrypted Storage**: All sensitive data AES-256 encrypted
- **Secure Backend**: All payment processing server-side

### 🚫 What We DON'T Store
- ❌ Credit card numbers
- ❌ CVV codes
- ❌ Full billing addresses
- ❌ Raw payment details

### ✅ What We DO Store Securely
- ✅ Payment tokens (Stripe-generated)
- ✅ Subscription status
- ✅ User email (encrypted)
- ✅ User preferences

## Security Features

- **Encrypted Storage**: Uses `flutter_secure_storage` for sensitive tokens
- **Environment Variables**: API keys stored in `.env` (ignored by git)
- **Firebase Security**: Configuration loaded from environment, not hardcoded
- **Biometric Protection**: Fingerprint/face authentication for sensitive operations
- **GDPR Compliance**: Complete data protection and user rights
- **Audit Logging**: Track all consent and data operations
- **HTTPS Only**: All API calls use secure HTTPS connections

## Subscription Management

### For Users
- Secure payment processing via Stripe
- Biometric authentication for account access
- Data export and deletion options
- Transparent privacy controls

### For Developers
- Backend API endpoints for subscription management
- Secure token handling
- Compliance reporting tools

## Testing Security

Run security tests:
```bash
flutter test test/security_services_test.dart
```

## Deployment

See [DEPLOYMENT_SECURITY_GUIDE.md](DEPLOYMENT_SECURITY_GUIDE.md) for secure deployment procedures.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the [online documentation](https://docs.flutter.dev/), which offers tutorials, samples, guidance on mobile development, and a full API reference.
