import { Router } from "express";
import {
  matchProvidersController,
} from "../controllers/provider.matching.controller";

const router = Router();

router.post(
  "/match",
  matchProvidersController
);

export default router;