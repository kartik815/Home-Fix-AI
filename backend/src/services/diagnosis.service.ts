import { GoogleGenAI, Schema, Type } from "@google/genai";
import { DiagnosisResult } from "../models/diagnosis.model";
import {
  DiagnosisAnswer,
  QuestionDecision,
} from "../models/diagnosis.session.model";

const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
});

const PRIMARY_MODEL = "gemini-3.6-flash";
const FALLBACK_MODEL = "gemini-3.5-flash-lite";
const MAX_RETRIES = 3;
const INITIAL_RETRY_DELAY_MS = 1000;

const SYSTEM_PROMPT = `
You are the AI diagnosis engine for HomePilot AI, a home-service
diagnosis and professional-matching application.

Your job is to understand a user's household problem and convert it
into structured information that our backend can use to determine:

1. What type of home problem this is.
2. What service is likely required.
3. What skills a professional should have.
4. What information is already known.
5. What information is still missing and should be asked in a
   follow-up question.

IMPORTANT RULES:
- Do NOT invent information that the user did not provide.
- If information is unknown, use null or an empty array.
- Do NOT claim a definitive technical diagnosis.
- requiredSkills should represent useful professional skills based
  on the symptoms, not a confirmed internal component failure.
- problemSummary should summarize what the user actually described.
- missingInformation should contain useful information that would help
  identify the appropriate professional.
- confidence represents how confident you are about understanding and
  classifying the user's problem. It is NOT a guarantee of a technical
  diagnosis.
- For safety-sensitive situations, assign an appropriate severity and
  urgency.
- If the user's description is too vague, use category "unknown".
- Keep symptoms concise and useful for later provider matching.
- Do not recommend a specific provider.
`;

const DIAGNOSIS_SCHEMA: Schema = {
  type: Type.OBJECT,
  properties: {
    category: {
      type: Type.STRING,
      enum: [
        "electrical",
        "plumbing",
        "appliance",
        "hvac",
        "interior",
        "furniture",
        "renovation",
        "structural",
        "other",
        "unknown",
      ],
    },
    subcategory: {
      type: Type.STRING,
      nullable: true,
    },
    brand: {
      type: Type.STRING,
      nullable: true,
    },
    model: {
      type: Type.STRING,
      nullable: true,
    },
    problemSummary: {
      type: Type.STRING,
    },
    symptoms: {
      type: Type.ARRAY,
      items: { type: Type.STRING },
    },
    component: {
      type: Type.STRING,
      nullable: true,
    },
    severity: {
      type: Type.STRING,
      enum: ["low", "medium", "high", "critical", "unknown"],
    },
    urgency: {
      type: Type.STRING,
      enum: ["normal", "soon", "urgent", "emergency", "unknown"],
    },
    requiredService: {
      type: Type.STRING,
      nullable: true,
    },
    requiredSkills: {
      type: Type.ARRAY,
      items: { type: Type.STRING },
    },
    knownInformation: {
      type: Type.ARRAY,
      items: {
        type: Type.OBJECT,
        properties: {
          key: { type: Type.STRING },
          value: { type: Type.STRING },
        },
        required: ["key", "value"],
      },
    },
    missingInformation: {
      type: Type.ARRAY,
      items: { type: Type.STRING },
    },
    confidence: {
      type: Type.NUMBER,
      minimum: 0,
      maximum: 1,
    },
  },
  required: [
    "category",
    "subcategory",
    "brand",
    "model",
    "problemSummary",
    "symptoms",
    "component",
    "severity",
    "urgency",
    "requiredService",
    "requiredSkills",
    "knownInformation",
    "missingInformation",
    "confidence",
  ],
};

const QUESTION_DECISION_SCHEMA: Schema = {
  type: Type.OBJECT,
  properties: {
    isComplete: { type: Type.BOOLEAN },
    question: { type: Type.STRING, nullable: true },
    questionPurpose: { type: Type.STRING, nullable: true },
    updatedDiagnosis: DIAGNOSIS_SCHEMA,
  },
  required: [
    "isComplete",
    "question",
    "questionPurpose",
    "updatedDiagnosis",
  ],
};

function isRetryableError(error: unknown): boolean {
  if (typeof error !== "object" || error === null) {
    return false;
  }

  const candidate = error as {
    status?: unknown;
    error?: { code?: unknown };
  };
  const status = Number(candidate.status ?? candidate.error?.code);
  return [408, 429, 500, 502, 503, 504].includes(status);
}

function sleep(milliseconds: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

async function generateJson<T>(
  contents: string,
  responseSchema: Schema,
  systemInstruction: string
): Promise<T> {
  let lastError: unknown;

  for (const model of [PRIMARY_MODEL, FALLBACK_MODEL]) {
    for (let attempt = 0; attempt <= MAX_RETRIES; attempt += 1) {
      try {
        const response = await ai.models.generateContent({
          model,
          contents,
          config: {
            responseMimeType: "application/json",
            responseSchema,
            systemInstruction,
          },
        });

        if (!response.text) {
          throw new Error("Gemini returned an empty response.");
        }

        return JSON.parse(response.text) as T;
      } catch (error) {
        lastError = error;
        console.error(
          `Gemini request failed: model=${model}, attempt=${attempt + 1}`,
          error
        );

        if (!isRetryableError(error)) {
          throw error;
        }

        if (attempt < MAX_RETRIES) {
          const backoff = INITIAL_RETRY_DELAY_MS * 2 ** attempt;
          await sleep(backoff + Math.floor(Math.random() * 500));
        }
      }
    }
  }

  throw lastError ?? new Error("All Gemini models failed.");
}

export async function analyzeProblem(
  problem: string
): Promise<DiagnosisResult> {
  const cleanedProblem = problem.trim();

  if (!cleanedProblem) {
    throw new Error("Problem description cannot be empty.");
  }

  try {
    return await generateJson<DiagnosisResult>(
      `USER'S HOME PROBLEM:\n\n${cleanedProblem}`,
      DIAGNOSIS_SCHEMA,
      SYSTEM_PROMPT
    );
  } catch (error) {
    console.error("Gemini diagnosis error:", error);
    throw error;
  }
}

export async function decideNextQuestion(
  originalProblem: string,
  currentDiagnosis: DiagnosisResult,
  answers: DiagnosisAnswer[],
  askedQuestions: string[]
): Promise<QuestionDecision> {
  const answerHistory =
    answers.length === 0
      ? "No questions have been answered yet."
      : answers
          .map(
            (item, index) =>
              `${index + 1}. Question: ${item.question}\nAnswer: ${item.answer}`
          )
          .join("\n\n");
  const previousQuestions =
    askedQuestions.length === 0
      ? "No questions have been asked yet."
      : askedQuestions
          .map((question, index) => `${index + 1}. ${question}`)
          .join("\n");

  const prompt = `
The goal is to identify the correct general service and useful professional skills,
not to make a definitive technical diagnosis.

The user originally said:
"${originalProblem}"

CURRENT DIAGNOSIS:
${JSON.stringify(currentDiagnosis, null, 2)}

QUESTIONS ALREADY ASKED:
${previousQuestions}

USER ANSWERS:
${answerHistory}

Decide whether enough information is available to identify the appropriate service.
Ask exactly one useful, non-repeated question at a time. Ask at least two questions
before completing, and normally finish within two to four questions. If fewer than
two answers have been provided, set isComplete to false and ask a question. After
two or more answers, complete when the available information is sufficient.
Update the diagnosis using the original problem and all answers. Do not invent facts,
recommend a provider, or ask the user to perform dangerous work.
`;

  return generateJson<QuestionDecision>(
    prompt,
    QUESTION_DECISION_SCHEMA,
    SYSTEM_PROMPT
  );
}