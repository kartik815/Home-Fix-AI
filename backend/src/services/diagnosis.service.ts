import { GoogleGenAI } from "@google/genai";
import { DiagnosisResult } from "../models/diagnosis.model";

const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
});

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
- If the user's description is too vague, use category "unknown" and
  explain what information is missing.
- Keep symptoms concise and useful for later provider matching.
- Do not recommend a specific provider. Provider matching is handled
  separately by our backend.
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
      enum: [
        "low",
        "medium",
        "high",
        "critical",
        "unknown",
      ],
    },

    urgency: {
      type: "string",
      enum: [
        "normal",
        "soon",
        "urgent",
        "emergency",
        "unknown",
      ],
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

export async function analyzeProblem(
  problem: string
): Promise<DiagnosisResult> {
  const cleanedProblem = problem.trim();

  if (!cleanedProblem) {
    throw new Error("Problem description cannot be empty.");
  }

  try {
    const response = await ai.models.generateContent({
      model: "gemini-3.6-flash",

      contents: [
        {
          role: "user",
          parts: [
            {
              text: `${SYSTEM_PROMPT}

USER'S HOME PROBLEM:

${cleanedProblem}`,
            },
          ],
        },
      ],

      config: {
        responseMimeType: "application/json",
        responseSchema: DIAGNOSIS_SCHEMA,
      },
    });

    if (!response.text) {
      throw new Error("Gemini returned an empty response.");
    }

    const result = JSON.parse(response.text) as DiagnosisResult;

    return result;
  } catch (error) {
    console.error("Gemini diagnosis error:", error);
    throw error;
  }
}