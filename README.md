# Sahara Pet Care Service App

A modern Flutter-based pet care booking platform that connects pet owners with professional caregivers for dog walking, pet sitting, grooming, veterinary visits, and pet adoption services.

## Key Features

**For Pet Owners:**
- Browse and book professional caregivers with filtering and ratings
- Manage multiple pets with photos and detailed profiles
- Real-time chatting with assigned caregivers
- Track ongoing services and booking history
- Edit/delete sent messages in chat
- Emergency caregiver reporting for safety
- Live notifications for booking updates
- My Pets section to manage pet information

**For Caregivers:**
- Create detailed profiles with ratings and reviews
- Accept/manage pet care bookings
- Real-time communication with pet owners
- Service completion tracking
- Review and rating system

**Pet Services & Discovery:**
- Dog Walking
- Pet Sitting
- Grooming
- Veterinary Visits
- Pet Adoption with detailed pet profiles
- Search and filter caregivers by location, rating, price
- Featured promotions and pet care tips

## Technology Stack

**Frontend:**
- Flutter 3.41.2
- Dart 3.0+
- Provider (State Management)
- Material Design 3
- Montserrat Font Family

**Backend & Services:**
- Firebase Authentication (Email/Password, Google Sign-In)
- Cloud Firestore (Real-time Database)
- Firebase Cloud Messaging (Notifications)
- Cloudinary (Image Storage & Processing)
- Google Maps Integration

**Additional Libraries:**
- cached_network_image (Image Caching)
- intl (Date/Time Formatting)
- url_launcher (Email/Phone Integration)
- geolocator (Location Services)
- permission_handler (App Permissions)

## Project Architecture

```
lib/
├── main.dart                 # App entry point
├── config/                   # App configuration
├── models/                   # Data models
├── providers/                # State management (Provider)
├── screens/                  # UI screens
├── services/                 # Business logic & APIs
├── theme/                    # Design system & colors
├── utils/                    # Helper functions
└── widgets/                  # Reusable components
```

## Firestore Structure

```
users/
├── {userId}
│   ├── profile data
│   └── pets/
│       └── {petId}
chat_rooms/
├── {chatRoomId}
│   └── messages/
│       └── {messageId}
caregivers/
└── {caregiverId}
bookings/
└── {bookingId}
```

## Core Screens

- **Authentication**: Sign up, Login (Email & Google)
- **Home**: Dashboard with services, top caregivers, tips
- **Search**: Filter caregivers by location, rating, price
- **My Pets**: Add/edit/delete pet profiles
- **Chat**: Real-time messaging with edit/delete options
- **Bookings**: View and manage service bookings
- **Caregiver Detail**: Full profile, ratings, booking options
- **Adopt Pet**: Browse adoptable pets with detailed info
- **Help & Support**: Contact form and FAQs
- **Profile**: User account settings and preferences

## Design System

**Color Palette:**
- Primary (Navy): #1A2332
- Secondary (Orange): #FF6B35
- Accent (Sky Blue): #4ECDC4
- Background: #F8FAFC
- Text Primary: #0F172A

**Typography:**
- Font: Montserrat
- Heading sizes: 18-24px
- Body text: 13-16px
- Grid spacing: 8px

## Getting Started

### Prerequisites
- Flutter 3.41.2+
- Dart 3.0+
- Android SDK 21+ or iOS 11+
- Firebase account with Firestore setup

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd Sahaara_service_application/Sahara-main
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
- Download google-services.json (Android)
- Download GoogleService-Info.plist (iOS)
- Place files in respective platform directories

4. Run the app:
```bash
flutter run
```

## Key Implementation Details

**Database Management:**
- Firestore subcollection structure for pet data (/users/{userId}/pets/)
- Real-time chat streaming with ordered messages
- Automatic default pet creation on user signup (Max - Golden Retriever)

**Security:**
- Firebase Authentication with email verification
- Firestore security rules enforcing user-specific access
- Caregiver vetting and reporting system

**Performance:**
- Image caching with cached_network_image
- Efficient state management with Provider
- Optimized list rendering with ListView builders
- Smooth animations and transitions

## Future Enhancements

- Payment integration (Stripe/Razorpay)
- Video call support for consultations
- AI-powered caregiver recommendations
- Monthly subscription plans
- Pet health tracking and vaccination records
- Multi-language support

## Troubleshooting

**Chat messages continuously refreshing:** Remove `onChanged` callback from message input TextField to prevent unnecessary state rebuilds.

**Images not loading:** Ensure Cloudinary API keys are properly configured and internet connectivity is stable.

**Firestore permission errors:** Verify security rules allow subcollection access (/users/{userId}/pets/).

## Project Status

✅ Core functionality complete
✅ Authentication & real-time chat implemented
✅ Pet management with profile pictures
✅ Caregiver booking system
✅ Chat edit/delete features
✅ Pet adoption section
✅ Help & support contact integration

## Support

For issues and feature requests, contact: notaayush1213@gmail.com
