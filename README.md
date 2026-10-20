
# Home Fix AI (kuldeep)

## AI diagnosis backend

AI diagnosis uses the Node backend under `backend/`. Configure MongoDB and Gemini
there using [`backend/.env.example`](./backend/.env.example), then follow
[`backend/README.md`](./backend/README.md) to start it.

The Flutter app calls `http://10.0.2.2:3000` by default on an Android emulator and
`http://localhost:3000` on web and other platforms. Override the API address for
a physical device or another deployment with:

```powershell
flutter run --dart-define=API_BASE_URL=http://YOUR_COMPUTER_LAN_IP:3000
```

Firebase authentication, Firestore notifications, and the existing app screens
remain managed by the Flutter app.
