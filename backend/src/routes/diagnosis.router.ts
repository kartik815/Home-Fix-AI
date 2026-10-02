import { Router } from "express";

import { analyzeDiagnosis } from "../controllers/diagnosis.controller";

const router = Router();

router.post(
    "/analyze",
    analyzeDiagnosis
);

export default router;

