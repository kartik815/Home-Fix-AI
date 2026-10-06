import dotenv from "dotenv";

dotenv.config();

console.log(
  "Gemini API key loaded:",
  Boolean(process.env.GEMINI_API_KEY)
);