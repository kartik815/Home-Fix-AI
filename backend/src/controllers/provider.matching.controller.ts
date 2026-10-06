import { Request, Response } from "express";

import { DiagnosisResult } from "../models/diagnosis.model";

import {
  CustomerLocation,
  matchProviders,
} from "../services/provider.matching.service";

import {
  getProvidersFromMongoDB,
} from "../services/provider.repository";

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

    if (!diagnosis) {
      return res.status(400).json({
        success: false,
        message: "Diagnosis is required.",
      });
    }

    if (
      !customerLocation ||
      typeof customerLocation.latitude !== "number" ||
      typeof customerLocation.longitude !== "number"
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Valid customer latitude and longitude are required.",
      });
    }

    let parsedBudget: number | undefined;

    if (
      budget !== undefined &&
      budget !== null &&
      budget !== ""
    ) {
      parsedBudget = Number(budget);

      if (Number.isNaN(parsedBudget)) {
        return res.status(400).json({
          success: false,
          message: "Budget must be a valid number.",
        });
      }
    }

    const providers =
      await getProvidersFromMongoDB();

    console.log(
      `Loaded ${providers.length} providers from MongoDB.`
    );

    const matches = matchProviders(
      diagnosis as DiagnosisResult,
      providers,
      customerLocation as CustomerLocation,
      parsedBudget as number
    );

    return res.status(200).json({
      success: true,
      data: {
        matches,
        totalMatches: matches.length,
      },
    });
  } catch (error) {
    console.error(
      "Provider matching error:",
      error
    );

    return res.status(500).json({
      success: false,
      message: "Unable to find matching providers.",
    });
  }
}