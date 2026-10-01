import { Request, Response } from "express";

import {
  matchProviders,
  CustomerLocation,
} from "../services/provider.matching.service";

import { providers } from "../data/providers";

import {
  startDiagnosisSession,
  answerDiagnosisQuestion,
  getDiagnosisSession,
} from "../services/diagnosis.session.service";

/*
|--------------------------------------------------------------------------
| START SESSION
|--------------------------------------------------------------------------
*/

export async function startDiagnosis(
  req: Request,
  res: Response
) {
  try {
    const { problem } = req.body ?? {};

    if (
      typeof problem !== "string" ||
      problem.trim().length === 0
    ) {
      return res.status(400).json({
        success: false,
        message: "A problem description is required.",
      });
    }

    const session = await startDiagnosisSession(problem);

    return res.status(200).json({
      success: true,

      data: {
        sessionId: session.id,

        status: session.completed
          ? "complete"
          : "question",

        diagnosis: session.diagnosis,

        question: session.currentQuestion,

        questionPurpose:
          session.currentQuestionPurpose,
      },
    });
  } catch (error) {
    console.error(
      "Start diagnosis error:",
      error
    );

    return res.status(500).json({
      success: false,
      message: "Unable to start diagnosis.",
    });
  }
}

/*
|--------------------------------------------------------------------------
| ANSWER QUESTION
|--------------------------------------------------------------------------
*/

export async function answerDiagnosis(
  req: Request,
  res: Response
) {
  try {
    const { sessionId } = req.params;

    const { answer } = req.body ?? {};

    if (
      typeof answer !== "string" ||
      answer.trim().length === 0
    ) {
      return res.status(400).json({
        success: false,
        message: "An answer is required.",
      });
    }

    const session =
      await answerDiagnosisQuestion(
        sessionId as string,
        answer
      );

    return res.status(200).json({
      success: true,

      data: {
        sessionId: session.id,

        status: session.completed
          ? "complete"
          : "question",

        diagnosis: session.diagnosis,

        question: session.currentQuestion,

        questionPurpose:
          session.currentQuestionPurpose,

        answersCount: session.answers.length,
      },
    });
  } catch (error) {
    console.error(
      "Answer diagnosis error:",
      error
    );

    if (
      error instanceof Error &&
      error.message === "Diagnosis session not found."
    ) {
      return res.status(404).json({
        success: false,
        message: error.message,
      });
    }

    return res.status(500).json({
      success: false,
      message: "Unable to process diagnosis answer.",
    });
  }
}

/*
|--------------------------------------------------------------------------
| GET SESSION
|--------------------------------------------------------------------------
*/

export function getDiagnosis(
  req: Request,
  res: Response
) {
  const { sessionId } = req.params;

  const session =
    getDiagnosisSession(sessionId as string);

  if (!session) {
    return res.status(404).json({
      success: false,
      message: "Diagnosis session not found.",
    });
  }

  return res.status(200).json({
    success: true,

    data: {
      sessionId: session.id,

      status: session.completed
        ? "complete"
        : "question",

      diagnosis: session.diagnosis,

      question: session.currentQuestion,

      questionPurpose:
        session.currentQuestionPurpose,

      answersCount: session.answers.length,
    },
  });
}

export async function matchDiagnosisSession(
  req: Request,
  res: Response
) {
  try {
    const { sessionId } = req.params;

    const {
      customerLocation,
      budget,
    } = req.body ?? {};

    // -----------------------------------------
    // Get diagnosis session
    // -----------------------------------------

    const session = getDiagnosisSession(sessionId as string);

    if (!session) {
      return res.status(404).json({
        success: false,
        message: "Diagnosis session not found.",
      });
    }

    // -----------------------------------------
    // Diagnosis must be complete
    // -----------------------------------------

    if (!session.completed) {
      return res.status(400).json({
        success: false,
        message:
          "Diagnosis is not complete yet. Answer the remaining questions first.",
        data: {
          sessionId: session.id,
          currentQuestion: session.currentQuestion,
          currentQuestionPurpose:
            session.currentQuestionPurpose,
        },
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

    if (
      budget !== null &&
      budget !== undefined
    ) {
      parsedBudget = Number(budget);

      if (
        !Number.isFinite(parsedBudget) ||
        parsedBudget < 0
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Budget must be a valid positive number.",
        });
      }
    }

    // -----------------------------------------
    // Run matching engine
    // -----------------------------------------

    const matches = matchProviders(
      session.diagnosis,
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
        sessionId: session.id,

        diagnosis: session.diagnosis,

        matches,

        totalMatches: matches.length,
      },
    });
  } catch (error) {
    console.error(
      "Diagnosis session matching error:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "Unable to find providers for this diagnosis.",
    });
  }
}