# HOPE Mobile Application

A Flutter-based mobile application designed to connect communities through donations, events, and social interactions. HOPE serves as a platform where users can request help, make donations, organize events, and build meaningful connections within their community.

## 🌟 Features

### 🔐 Authentication & User Management

- **Firebase Authentication** with email/password and social login
- **User Registration** with profile creation
- **OTP Verification** for secure account setup
- **Profile Management** with photo upload and personal information

### 💝 Donation & Request System

- **Request Help**: Users can post requests for assistance with descriptions and images
- **Make Donations**: Browse and contribute to community needs
- **Payment Integration**: Secure transaction processing for donations
- **Location-based Services**: Find requests and donations in your area

### 📅 Events Management

- **Create Events**: Organize community events with details and location
- **Event Discovery**: Browse and search for upcoming events
- **Event Participation**: Join events and connect with other participants
- **Event Wall**: Share updates and photos from events

### 💬 Social Features

- **Community Wall**: Share posts, updates, and stories
- **Real-time Chat**: Connect with other community members
- **Like & Interaction**: Engage with posts through likes and comments
- **User Profiles**: View and connect with other community members

### 🗺️ Location Services

- **Google Maps Integration**: Location-based discovery of requests and events
- **Geolocation**: Find nearby community activities
- **Location Permissions**: Secure handling of location data

## 🛠️ Technology Stack

- **Framework**: Flutter 3.0.5+
- **Backend**: Firebase (Authentication, Firestore, Storage, Messaging)
- **Database**: Cloud Firestore + MySQL
- **Maps**: Google Maps Flutter
- **State Management**: Provider
- **HTTP Client**: HTTP package
- **Image Handling**: Image Picker
- **Location Services**: Geolocator, Geocoding
- **Push Notifications**: Firebase Messaging

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.5 or higher)
- Dart SDK
- Firebase project setup
- Google Maps API key
- Android Studio / Xcode (for mobile development)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/HOPE-mobile-application.git
   cd HOPE-mobile-application
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Firebase Setup**

   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication, Firestore, Storage, and Messaging
   - Download and add configuration files:
     - `google-services.json` for Android (place in `android/app/`)
     - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)

4. **Google Maps Setup**

   - Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
   - Add the API key to your platform-specific configuration files

5. **Database Setup**

   - Configure your MySQL database connection
   - Set up Firestore security rules

6. **Run the application**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── chat/                    # Chat functionality
├── components/              # Reusable UI components
├── constants/               # App constants (colors, styles)
├── events/                  # Event management features
├── get_started/             # Onboarding screens
├── models/                  # Data models
├── otp/                     # OTP verification
├── request&donation/        # Donation and request features
├── screens/                 # Main app screens
│   ├── authentication/      # Login/Register screens
│   └── home/                # Home and wall screens
├── services/                # Business logic services
├── transaction/             # Payment processing
└── user/                    # User profile management
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the root directory with:

```
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
FIREBASE_PROJECT_ID=your_firebase_project_id
MYSQL_HOST=your_mysql_host
MYSQL_DATABASE=your_database_name
MYSQL_USER=your_mysql_user
MYSQL_PASSWORD=your_mysql_password
```

### Firebase Security Rules

Ensure your Firestore security rules are properly configured for user data protection.

## 🎨 Customization

### Themes and Colors

- Modify `lib/constants/colors.dart` for color scheme changes
- Update `lib/constants/styles.dart` for typography and styling

### Assets

- Add custom images to the `assets/` directory
- Update `pubspec.yaml` to include new assets

### Fonts

- Custom fonts are configured in `pubspec.yaml`
- Current fonts: Oswald, BebasNeue

## 🧪 Testing

Run tests using:

```bash
flutter test
```

## 📦 Building for Production

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request



**Made with ❤️ for building stronger communities**
