import { Request, Response } from "express";

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