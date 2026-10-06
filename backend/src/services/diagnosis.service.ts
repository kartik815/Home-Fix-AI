import { GoogleGenAI, ThinkingLevel } from "@google/genai";
import { DiagnosisResult } from "../models/diagnosis.model";
import {
  DiagnosisAnswer,
  QuestionDecision,
} from "../models/diagnosis.session.model";

const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
});

// Primary model
const MODEL = "gemini-3.6-flash";

// Fallback model if the primary model is unavailable
const FALLBACK_MODEL = "gemini-3.5-flash-lite";

// Retry configuration
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

const DIAGNOSIS_SCHEMA = {
  type: "object",
  properties: {
    category: {
      type: "string",
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
      type: ["string", "null"],
    },
    brand: {
      type: ["string", "null"],
    },
    model: {
      type: ["string", "null"],
    },
    problemSummary: {
      type: "string",
    },
    symptoms: {
      type: "array",
      items: {
        type: "string",
      },
    },
    component: {
      type: ["string", "null"],
    },
    severity: {
      type: "string",
      enum: ["low", "medium", "high", "critical", "unknown"],
    },
    urgency: {
      type: "string",
      enum: ["normal", "soon", "urgent", "emergency", "unknown"],
    },
    requiredService: {
      type: ["string", "null"],
    },
    requiredSkills: {
      type: "array",
      items: {
        type: "string",
      },
    },
    knownInformation: {
      type: "array",
      items: {
        type: "object",
        properties: {
          key: {
            type: "string",
          },
          value: {
            type: "string",
          },
        },
        required: ["key", "value"],
      },
    },
    missingInformation: {
      type: "array",
      items: {
        type: "string",
      },
    },
    confidence: {
      type: "number",
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

const QUESTION_DECISION_SCHEMA = {
  type: "object",
  properties: {
    isComplete: {
      type: "boolean",
    },
    question: {
      type: ["string", "null"],
    },
    questionPurpose: {
      type: ["string", "null"],
    },
    updatedDiagnosis: DIAGNOSIS_SCHEMA,
  },
  required: [
    "isComplete",
    "question",
    "questionPurpose",
    "updatedDiagnosis",
  ],
};

/**
 * Returns true when the error is temporary and worth retrying.
 */
function isRetryableError(error: unknown): boolean {
  const candidate = error as {
    status?: number;
    error?: {
      code?: number;
      status?: string;
    };
  };

  const status = candidate?.status ?? candidate?.error?.code;

  return (
    status === 408 ||
    status === 429 ||
    status === 500 ||
    status === 502 ||
    status === 503 ||
    status === 504
  );
}

/**
 * Wait before retrying.
 */
function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/**
 * Generate Gemini content with retry + model fallback.
 */
async function generateWithFallback(
  contents: any,
  responseSchema: any,
  systemInstruction?: string
) {
  const models = [MODEL, FALLBACK_MODEL];
  let lastError: unknown = null;

  for (const model of models) {
    for (let attempt = 0; attempt <= MAX_RETRIES; attempt++) {
      try {
        console.log(`Gemini request: model=${model}, attempt=${attempt + 1}`);

        const response = await ai.models.generateContent({
          model,
          contents,
          config: {
            responseMimeType: "application/json",
            responseSchema,
            systemInstruction,
            thinkingConfig: {
              thinkingLevel: ThinkingLevel.LOW,
            },
          },
        });

        if (!response.text) {
          throw new Error("Gemini returned an empty response.");
        }

        console.log(`Gemini response successful using ${model}`);
        return response;
      } catch (error) {
        lastError = error;
        console.error(
          `Gemini request failed: model=${model}, attempt=${attempt + 1}`,
          error
        );

        if (!isRetryableError(error)) {
          throw error;
        }

        if (attempt === MAX_RETRIES) {
          console.log(`Model ${model} unavailable after retries.`);
          break;
        }

        // Exponential backoff: 1s → 2s → 4s
        const delay = INITIAL_RETRY_DELAY_MS * Math.pow(2, attempt);
        const jitter = Math.floor(Math.random() * 500);
        const totalDelay = delay + jitter;

        console.log(`Retrying in ${totalDelay}ms...`);
        await sleep(totalDelay);
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

  const contents = [
    {
      role: "user",
      parts: [
        {
          text: `USER'S HOME PROBLEM:\n\n${cleanedProblem}`,
        },
      ],
    },
  ];

  try {
    const response = await generateWithFallback(
      contents,
      DIAGNOSIS_SCHEMA,
      SYSTEM_PROMPT
    );

    return JSON.parse(response.text as string) as DiagnosisResult;
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
The goal is NOT to perform a definitive medical, electrical, structural, or mechanical diagnosis.

The goal is to collect enough useful information to identify:
- the correct general service
- the relevant professional skills
- useful expertise for provider matching

The user originally said:
"${originalProblem}"

CURRENT DIAGNOSIS:
${JSON.stringify(currentDiagnosis, null, 2)}

QUESTIONS ALREADY ASKED:
${previousQuestions}

USER ANSWERS:
${answerHistory}

YOUR TASK:
Decide whether we have enough information to identify the appropriate type of professional and useful skills.

If important information is still missing:
1. Set isComplete to false.
2. Ask exactly ONE question.
3. Make the question natural and easy for a normal homeowner to answer.
4. Ask only for information that materially helps identify the correct professional.
5. Do not repeat a previous question.
6. Update the diagnosis using the information already provided.
7. Set questionPurpose to briefly explain why this question matters.

If we already have enough information:
1. Set isComplete to true.
2. Set question to null.
3. Set questionPurpose to null.
4. Update the diagnosis with all useful information collected.

IMPORTANT:
- Do not ask unnecessary questions.
- Prefer specific questions over generic questions.
- Do not ask multiple questions in one question.
- Do not ask the user to perform dangerous electrical, gas, structural, or mechanical procedures.
- Do not claim that a particular component has definitely failed.
- The system should normally finish within 3-6 questions.
- If the diagnosis is already sufficiently specific, finish early.
`;

  const contents = [
    {
      role: "user",
      parts: [
        {
          text: prompt,
        },
      ],
    },
  ];

  try {
    const response = await generateWithFallback(
      contents,
      QUESTION_DECISION_SCHEMA,
      SYSTEM_PROMPT
    );

    return JSON.parse(response.text as string) as QuestionDecision;
  } catch (error) {
    console.error("Gemini question decision error:", error);
    throw error;
  }
}