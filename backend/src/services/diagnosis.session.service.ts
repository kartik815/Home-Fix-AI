import { randomUUID } from "crypto";
import { Collection, Document } from "mongodb";

import { getMongoDB } from "../config/mongodb";
import { DiagnosisResult } from "../models/diagnosis.model";
import {
  DiagnosisAnswer,
  DiagnosisSession,
  QuestionDecision,
} from "../models/diagnosis.session.model";
import {
  analyzeProblem,
  decideNextQuestion,
} from "./diagnosis.service";

interface DiagnosisSessionDocument extends Document, DiagnosisSession {}

const MAX_QUESTIONS = 6;

function sessionsCollection(): Collection<DiagnosisSessionDocument> {
  return getMongoDB().collection<DiagnosisSessionDocument>(
    "diagnosis_sessions"
  );
}

export async function initializeDiagnosisSessions(): Promise<void> {
  await sessionsCollection().createIndex({ id: 1 }, { unique: true });
}

export async function startDiagnosisSession(
  problem: string
): Promise<DiagnosisSession> {
  const originalProblem = problem.trim();
  if (!originalProblem) {
    throw new Error("Problem description cannot be empty.");
  }

  const diagnosis = await analyzeProblem(originalProblem);
  const decision = await decideNextQuestion(
    originalProblem,
    diagnosis,
    [],
    []
  );
  const session: DiagnosisSession = {
    id: randomUUID(),
    originalProblem,
    diagnosis: decision.updatedDiagnosis,
    answers: [],
    askedQuestions: decision.question ? [decision.question] : [],
    currentQuestion: decision.question,
    currentQuestionPurpose: decision.questionPurpose,
    completed: decision.isComplete,
    createdAt: new Date().toISOString(),
  };

  await sessionsCollection().insertOne(session);
  return session;
}

export async function answerDiagnosisQuestion(
  sessionId: string,
  answer: string
): Promise<DiagnosisSession> {
  const session = await getDiagnosisSession(sessionId);
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

  const answers: DiagnosisAnswer[] = [
    ...session.answers,
    { question: session.currentQuestion, answer: cleanedAnswer },
  ];
  const decision: QuestionDecision = await decideNextQuestion(
    session.originalProblem,
    session.diagnosis,
    answers,
    session.askedQuestions
  );

  session.answers = answers;
  session.diagnosis = decision.updatedDiagnosis;
  session.completed =
    decision.isComplete || answers.length >= MAX_QUESTIONS;
  session.currentQuestion = session.completed ? null : decision.question;
  session.currentQuestionPurpose = session.completed
    ? null
    : decision.questionPurpose;
  if (session.currentQuestion) {
    session.askedQuestions.push(session.currentQuestion);
  }

  await sessionsCollection().replaceOne({ id: sessionId }, session);
  return session;
}

export async function getDiagnosisSession(
  sessionId: string
): Promise<DiagnosisSession | null> {
  const session = await sessionsCollection().findOne({ id: sessionId });
  if (!session) {
    return null;
  }

  const { _id: _ignored, ...result } = session;
  return result;
}
