import { DiagnosisResult } from "./diagnosis.model";

export interface DiagnosisAnswer {
  question: string;
  answer: string;
}

export interface DiagnosisSession {
  id: string;

  originalProblem: string;

  diagnosis: DiagnosisResult;

  answers: DiagnosisAnswer[];

  askedQuestions: string[];

  currentQuestion: string | null;

  currentQuestionPurpose: string | null;

  completed: boolean;

  createdAt: string;
}

export interface QuestionDecision {
  isComplete: boolean;

  question: string | null;

  questionPurpose: string | null;

  updatedDiagnosis: DiagnosisResult;
}