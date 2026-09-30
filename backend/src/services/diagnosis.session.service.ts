import { randomUUID } from "crypto";

import {
  DiagnosisAnswer,
  DiagnosisSession,
  QuestionDecision,
} from "../models/diagnosis.session.model";

import { DiagnosisResult } from "../models/diagnosis.model";

import {
  analyzeProblem,
  decideNextQuestion,
} from "./diagnosis.service";

/*
|--------------------------------------------------------------------------
| Temporary in-memory session storage
|--------------------------------------------------------------------------
|
| This is intentionally temporary.
|
| Later:
|
| Map
|  ↓
| Supabase/PostgreSQL
|
|--------------------------------------------------------------------------
*/

const sessions = new Map<string, DiagnosisSession>();

const MAX_QUESTIONS = 6;

/*
|--------------------------------------------------------------------------
| START DIAGNOSIS SESSION
|--------------------------------------------------------------------------
*/

export async function startDiagnosisSession(
  problem: string
): Promise<DiagnosisSession> {
  const cleanedProblem = problem.trim();

  if (!cleanedProblem) {
    throw new Error("Problem description cannot be empty.");
  }

  /*
   * First perform the Phase 1 analysis.
   */
  const diagnosis = await analyzeProblem(cleanedProblem);

  /*
   * Ask Gemini whether another question is needed.
   */
  const decision = await decideNextQuestion(
    cleanedProblem,
    diagnosis,
    [],
    []
  );

  const sessionId = randomUUID();

  const session: DiagnosisSession = {
    id: sessionId,

    originalProblem: cleanedProblem,

    diagnosis: decision.updatedDiagnosis,

    answers: [],

    askedQuestions: decision.question
      ? [decision.question]
      : [],

    currentQuestion: decision.question,

    currentQuestionPurpose: decision.questionPurpose,

    completed: decision.isComplete,

    createdAt: new Date().toISOString(),
  };

  sessions.set(sessionId, session);

  return session;
}

/*
|--------------------------------------------------------------------------
| ANSWER CURRENT QUESTION
|--------------------------------------------------------------------------
*/

export async function answerDiagnosisQuestion(
  sessionId: string,
  answer: string
): Promise<DiagnosisSession> {
  const session = sessions.get(sessionId);

  if (!session) {
    throw new Error("Diagnosis session not found.");
  }

  if (session.completed) {
    throw new Error("This diagnosis session is already complete.");
  }

  const cleanedAnswer = answer.trim();

  if (!cleanedAnswer) {
    throw new Error("Answer cannot be empty.");
  }

  if (!session.currentQuestion) {
    throw new Error("There is no active question.");
  }

  /*
   * Save the user's answer.
   */
  const newAnswer: DiagnosisAnswer = {
    question: session.currentQuestion,
    answer: cleanedAnswer,
  };

  session.answers.push(newAnswer);

  /*
   * Safety limit.
   *
   * Even if Gemini keeps asking questions,
   * we don't want an endless conversation.
   */
  if (session.answers.length >= MAX_QUESTIONS) {
    session.completed = true;

    session.currentQuestion = null;

    session.currentQuestionPurpose = null;

    sessions.set(sessionId, session);

    return session;
  }

  /*
   * Ask Gemini what we should do next.
   */
  const decision: QuestionDecision =
    await decideNextQuestion(
      session.originalProblem,
      session.diagnosis,
      session.answers,
      session.askedQuestions
    );

  /*
   * Update diagnosis.
   */
  session.diagnosis = decision.updatedDiagnosis;

  /*
   * Update session state.
   */
  session.completed = decision.isComplete;

  session.currentQuestion = decision.question;

  session.currentQuestionPurpose =
    decision.questionPurpose;

  if (decision.question) {
    session.askedQuestions.push(decision.question);
  }

  sessions.set(sessionId, session);

  return session;
}

/*
|--------------------------------------------------------------------------
| GET SESSION
|--------------------------------------------------------------------------
*/

export function getDiagnosisSession(
  sessionId: string
): DiagnosisSession | undefined {
  return sessions.get(sessionId);
}