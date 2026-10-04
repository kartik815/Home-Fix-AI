import { Router } from "express";

import {
  startDiagnosis,
  answerDiagnosis,
  getDiagnosis,
  matchDiagnosisSession,
} from "../controllers/diagnosis.session.controller";

const router = Router();

router.post(
  "/session/start",
  startDiagnosis
);

router.post(
  "/session/:sessionId/answer",
  answerDiagnosis
);

router.get(
  "/session/:sessionId",
  getDiagnosis
);

router.post(
  "/session/:sessionId/matches",
  matchDiagnosisSession
);

export default router;