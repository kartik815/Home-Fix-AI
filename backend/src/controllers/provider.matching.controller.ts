import { Request, Response } from "express";
import {
  matchProviders,
  CustomerLocation,
} from "../services/provider.matching.service";
import { DiagnosisResult } from "../models/diagnosis.model";
import { providers } from "../data/providers";

export async function matchProvidersController(
  req: Request,
  res: Response
) {
  try {
    const {
      diagnosis,
      customerLocation,
      budget,
    } = req.body ?? {};

    // -----------------------------------------
    // Validate diagnosis
    // -----------------------------------------

    if (!diagnosis || typeof diagnosis !== "object") {
      return res.status(400).json({
        success: false,
        message: "A diagnosis object is required.",
      });
    }

    // -----------------------------------------
    // Validate customer location
    // -----------------------------------------

    if (
      !customerLocation ||
      typeof customerLocation !== "object"
    ) {
      return res.status(400).json({
        success: false,
        message: "Customer location is required.",
      });
    }

    const location: CustomerLocation = {
      latitude: Number(customerLocation.latitude),
      longitude: Number(customerLocation.longitude),
    };

    if (
      !Number.isFinite(location.latitude) ||
      !Number.isFinite(location.longitude)
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Customer latitude and longitude must be valid numbers.",
      });
    }

    // -----------------------------------------
    // Validate budget
    // -----------------------------------------

    let parsedBudget: number | null = null;

    if (budget !== null && budget !== undefined) {
      parsedBudget = Number(budget);

      if (
        !Number.isFinite(parsedBudget) ||
        parsedBudget < 0
      ) {
        return res.status(400).json({
          success: false,
          message: "Budget must be a valid positive number.",
        });
      }
    }

    // -----------------------------------------
    // Run deterministic matching
    // -----------------------------------------

    const matches = matchProviders(
      diagnosis as DiagnosisResult,
      providers,
      location,
      parsedBudget
    );

    // -----------------------------------------
    // Return results
    // -----------------------------------------

    return res.status(200).json({
      success: true,
      data: {
        matches,
        totalMatches: matches.length,
      },
    });
  } catch (error) {
    console.error("Provider matching error:", error);

    return res.status(500).json({
      success: false,
      message: "Unable to find matching providers.",
    });
  }
}