# Home-fix diagnosis backend

This backend runs the Gemini diagnosis flow and stores diagnosis sessions in MongoDB.
Firebase authentication and user notifications remain in the Flutter app; Firebase
credentials are not sent to this backend.

## Configure

From `kuldeep/backend`, create a local `.env` from `.env.example` and set:

- `MONGODB_URI` to a MongoDB connection string
- `MONGODB_DB_NAME` to the database to use
- `GEMINI_API_KEY` to a Gemini API key

Do not commit `.env`. The backend exits with an error if MongoDB cannot be reached
or the required connection string is missing.

## Run

```powershell
npm install
npm run dev
```

For a production build, use `npm run build` and `npm start`. The health endpoint is
`GET /health`.

## Diagnosis endpoints

- `POST /api/diagnosis/session/start` with `{ "problem": "..." }`
- `POST /api/diagnosis/session/:sessionId/answer` with `{ "answer": "..." }`
- `GET /api/diagnosis/session/:sessionId`
- `POST /api/diagnosis/session/:sessionId/matches` with customer location and optional budget
- `POST /api/providers/match` with a diagnosis and customer location
- `POST /api/bookings` to create a booking

Sessions are stored in the `diagnosis_sessions` collection. The `/api/diagnosis/analyze`
endpoint remains available for a single-pass diagnosis.
