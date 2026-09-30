import { Router } from "express";

import {
  startDiagnosis,
  answerDiagnosis,
  getDiagnosis,
} from "../controllers/diagnosis.session.controller";

const router = Router();

/*
 * Start a new interactive diagnosis
 *
 * POST /api/diagnosis/session/start
 */
router.post(
  "/session/start",
  startDiagnosis
);

/*
 * Answer the current question
 *
 * POST /api/diagnosis/session/:sessionId/answer
 */
router.post(
  "/session/:sessionId/answer",
  answerDiagnosis
);

/*
 * Get current session state
 *
 * GET /api/diagnosis/session/:sessionId
 */
router.get(
  "/session/:sessionId",
  getDiagnosis
);

export default router;