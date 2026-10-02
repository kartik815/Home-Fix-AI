import { Request, Response } from "express";
import { analyzeProblem } from "../services/diagnosis.service";

export async function analyzeDiagnosis(req: Request, res: Response) {
  try {
    const { problem } = req.body ?? {};

    if (typeof problem !== "string" || problem.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: "A problem description is required.",
      });
    }

    const diagnosis = await analyzeProblem(problem);

    return res.status(200).json({
      success: true,
      data: diagnosis,
    });
  } catch (error) {
    console.error("Diagnosis error:", error);

    return res.status(500).json({
      success: false,
      message: "Unable to analyze the problem.",
    });
  }
}