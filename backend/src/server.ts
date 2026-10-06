import express from "express";
import cors from "cors";
import dotenv from "dotenv";

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

async function startServer() {
  try {
    // Connect to MongoDB before starting the server
    const { connectToMongoDB } =
      await import("./config/mongodb");

    await connectToMongoDB();

    // Load routes after environment variables are available
    const { default: diagnosisRoutes } =
      await import("./routes/diagnosis.router");

    const { default: diagnosisSessionRoutes } =
      await import("./routes/diagnosis.session.router");

    const { default: providerMatchingRoutes } =
      await import("./routes/provider.matching.router");

    app.use("/api/diagnosis", diagnosisRoutes);
    app.use("/api/diagnosis", diagnosisSessionRoutes);
    app.use("/api/providers", providerMatchingRoutes);

    const PORT = process.env.PORT || 3000;

    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (error) {
    console.error("Failed to start server:", error);
    process.exit(1);
  }
}

startServer();