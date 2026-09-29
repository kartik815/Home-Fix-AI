import express from "express";
import cors from "cors";
import dotenv from "dotenv";

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

async function startServer() {
  const { default: diagnosisRoutes } = await import(
    "./routes/diagnosis.router"
  );

  app.use("/api/diagnosis", diagnosisRoutes);

  const PORT = process.env.PORT || 3000;

  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

startServer();