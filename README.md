# HomePilot AI

Describe a home repair problem, get an AI-powered assessment, and find nearby
service professionals. HomePilot AI is a Flutter application backed by Firebase
for sign-in and notifications, and by a Node.js API for diagnosis, matching, and
bookings.

## Highlights

- **AI home diagnosis:** Gemini analyzes the reported problem and can ask follow-up
  questions before completing its assessment.
- **Nearby professionals:** Browse service providers on a map and explore provider
  details.
- **Service bookings:** Submit a booking request for a selected provider.
- **Firebase sign-in:** Authenticate users and route administrators to management
  tools.
- **Notifications:** Store and display user notifications with Cloud Firestore.
- **Useful account tools:** Review search history, save professionals, and manage
  profile and app settings.
- **Voice input:** Describe a problem using speech recognition.

## Technology

| Area | Technology |
| --- | --- |
| Mobile and web app | Flutter, Dart |
| Authentication | Firebase Authentication |
| User notifications and app data | Cloud Firestore |
| API | Node.js, Express, TypeScript |
| AI diagnosis | Google Gemini |
| Diagnosis sessions and bookings | MongoDB |
| Maps and location | Google Maps, Geolocator |

## Prerequisites

- Flutter SDK and the Dart SDK version required by `pubspec.yaml`
- Node.js 18 or later and npm
- A MongoDB instance (local or hosted)
- A Google Gemini API key
- A Firebase project configured for the platforms you intend to run
- A Google Maps API key for map features

## Configure Firebase and Maps

Before running the Flutter app, configure Firebase for your target platforms.
Ensure the platform configuration files and `lib/firebase_options.dart` belong
to your Firebase project. Enable the authentication providers you plan to use
and set up Cloud Firestore.

For Android maps, put the Maps key in `android/local.properties`:

```properties
MAPS_API_KEY=your_google_maps_api_key
```

Keep API keys and other credentials private. Do not commit local configuration
files containing secrets.

## Start the backend

From the project root:

```powershell
cd backend
Copy-Item .env.example .env
```

Edit `backend/.env` and set:

```dotenv
PORT=3000
GEMINI_API_KEY=your_gemini_api_key
MONGODB_URI=your_mongodb_connection_string
MONGODB_DB_NAME=homepilot
```

Then install dependencies and start the development server:

```powershell
npm install
npm run dev
```

The API connects to MongoDB before it starts accepting requests. Check that it
is running with `GET http://localhost:3000/health`.

For a production build:

```powershell
npm run build
npm start
```

The local `.env` is ignored by Git. Never put real credentials in
`.env.example` or commit them to the repository.

## Run the Flutter app

From the project root, install packages and run the app:

```powershell
flutter pub get
flutter run
```

The diagnosis API address defaults to:

- Android emulator: `http://10.0.2.2:3000`
- Web and other platforms: `http://localhost:3000`

For a physical device, use your development computer's reachable LAN address:

```powershell
flutter run --dart-define=API_BASE_URL=http://YOUR_COMPUTER_LAN_IP:3000
```

Make sure the device and computer can reach each other and that the backend port
is allowed through the computer's firewall. Use HTTPS and suitable platform
network settings when deploying beyond local development.

## API overview

| Method | Endpoint | Purpose |
| --- | --- | --- |
| `GET` | `/health` | Check backend availability |
| `POST` | `/api/diagnosis/analyze` | Request a single-pass AI assessment |
| `POST` | `/api/diagnosis/session/start` | Start an interactive diagnosis |
| `POST` | `/api/diagnosis/session/:sessionId/answer` | Submit a follow-up answer |
| `GET` | `/api/diagnosis/session/:sessionId` | Retrieve a diagnosis session |
| `POST` | `/api/diagnosis/session/:sessionId/matches` | Match providers to a completed diagnosis |
| `POST` | `/api/providers/match` | Match providers from a diagnosis and location |
| `POST` | `/api/bookings` | Create a booking request |

## Tests and checks

Run the Flutter tests:

```powershell
flutter test
```

Run Flutter static analysis:

```powershell
flutter analyze
```

Build-check the backend:

```powershell
cd backend
npm run build
```

## Repository layout

```text
lib/       Flutter application, screens, services, and models
backend/   Express API, Gemini diagnosis, and MongoDB integration
assets/    App images and other bundled assets
android/   Android platform project
ios/       iOS platform project
web/       Web platform project
windows/   Windows platform project
macos/     macOS platform project
linux/     Linux platform project
test/      Flutter tests
```
