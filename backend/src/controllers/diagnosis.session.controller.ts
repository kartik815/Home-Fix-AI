import { Request, Response } from "express";

import {
  answerDiagnosisQuestion,
  getDiagnosisSession,
  startDiagnosisSession,
} from "../services/diagnosis.session.service";
import {
  CustomerLocation,
  matchProviders,
} from "../services/provider.matching.service";
import { getProvidersFromMongoDB } from "../services/provider.repository";

function responseData(session: Awaited<ReturnType<typeof startDiagnosisSession>>) {
  return {
    sessionId: session.id,
    status: session.completed ? "complete" : "question",
    diagnosis: session.diagnosis,
    question: session.currentQuestion,
    questionPurpose: session.currentQuestionPurpose,
    answersCount: session.answers.length,
  };
}

export async function startDiagnosis(req: Request, res: Response) {
  const { problem } = req.body ?? {};
  if (typeof problem !== "string" || problem.trim().length === 0) {
    return res.status(400).json({
      success: false,
      message: "A problem description is required.",
    });
  }

  try {
    const session = await startDiagnosisSession(problem);
    return res.status(200).json({
      success: true,
      data: responseData(session),
    });
  } catch (error) {
    console.error("Start diagnosis error:", error);
    return res.status(500).json({
      success: false,
      message: "Unable to start diagnosis.",
    });
  }
}

export async function answerDiagnosis(req: Request, res: Response) {
  const sessionId = Array.isArray(req.params.sessionId)
    ? req.params.sessionId[0] ?? ""
    : req.params.sessionId;
  const { answer } = req.body ?? {};
  if (typeof answer !== "string" || answer.trim().length === 0) {
    return res.status(400).json({
      success: false,
      message: "An answer is required.",
    });
  }

  try {
    const session = await answerDiagnosisQuestion(sessionId, answer);
    return res.status(200).json({
      success: true,
      data: responseData(session),
    });
  } catch (error) {
    if (
      error instanceof Error &&
      error.message === "Diagnosis session not found."
    ) {
      return res.status(404).json({
        success: false,
        message: error.message,
      });
    }

    console.error("Answer diagnosis error:", error);
    return res.status(500).json({
      success: false,
      message: "Unable to process diagnosis answer.",
    });
  }
}

export async function getDiagnosis(req: Request, res: Response) {
  try {
    const sessionId = Array.isArray(req.params.sessionId)
      ? req.params.sessionId[0] ?? ""
      : req.params.sessionId;
    const session = await getDiagnosisSession(sessionId);
    if (!session) {
      return res.status(404).json({
        success: false,
        message: "Diagnosis session not found.",
      });
    }

    return res.status(200).json({
      success: true,
      data: responseData(session),
    });
  } catch (error) {
    console.error("Get diagnosis session error:", error);
    return res.status(500).json({
      success: false,
      message: "Unable to load diagnosis session.",
    });
  }
}

export async function matchDiagnosisSession(req: Request, res: Response) {
  const sessionId = Array.isArray(req.params.sessionId)
    ? req.params.sessionId[0] ?? ""
    : req.params.sessionId;

  try {
    const session = await getDiagnosisSession(sessionId);
    if (!session) {
      return res.status(404).json({
        success: false,
        message: "Diagnosis session not found.",
      });
    }
    if (!session.completed) {
      return res.status(400).json({
        success: false,
        message:
          "Diagnosis is not complete yet. Answer the remaining questions first.",
        data: {
          sessionId: session.id,
          currentQuestion: session.currentQuestion,
          currentQuestionPurpose: session.currentQuestionPurpose,
        },
      });
    }

    const { customerLocation, budget } = req.body ?? {};
    if (!customerLocation || typeof customerLocation !== "object") {
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
        message: "Customer latitude and longitude must be valid numbers.",
      });
    }

    let parsedBudget: number | null = null;
    if (budget !== null && budget !== undefined) {
      parsedBudget = Number(budget);
      if (!Number.isFinite(parsedBudget) || parsedBudget < 0) {
        return res.status(400).json({
          success: false,
          message: "Budget must be a valid positive number.",
        });
      }
    }

    const providers = await getProvidersFromMongoDB();
    const matches = matchProviders(
      session.diagnosis,
      providers,
      location,
      parsedBudget
    );

    return res.status(200).json({
      success: true,
      data: {
        sessionId: session.id,
        diagnosis: session.diagnosis,
        matches,
        totalMatches: matches.length,
      },
    });
  } catch (error) {
    console.error("Diagnosis session matching error:", error);
    return res.status(500).json({
      success: false,
      message: "Unable to find providers for this diagnosis.",
    });
  }
}
