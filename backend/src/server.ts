import express from "express";
import cors from "cors";
import dotenv from "dotenv";

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

async function startServer() {
  let closeMongoDB: (() => Promise<void>) | undefined;

  try {
    if (!process.env.MONGODB_URI) {
      throw new Error("MONGODB_URI is not configured.");
    }
    if (!process.env.GEMINI_API_KEY) {
      throw new Error("GEMINI_API_KEY is not configured.");
    }

    const mongo = await import("./config/mongodb");
    closeMongoDB = mongo.closeMongoDB;
    const { connectToMongoDB } = mongo;
    await connectToMongoDB();

    const { initializeDiagnosisSessions } = await import(
      "./services/diagnosis.session.service"
    );
    await initializeDiagnosisSessions();

    const { default: diagnosisRoutes } = await import(
      "./routes/diagnosis.router"
    );
    const { default: diagnosisSessionRoutes } = await import(
      "./routes/diagnosis.session.router"
    );
    const { default: providerMatchingRoutes } = await import(
      "./routes/provider.matching.router"
    );
    const { default: bookingRoutes } = await import(
      "./routes/booking.router"
    );

    app.get("/health", (_req, res) => {
      res.status(200).json({ success: true, status: "healthy" });
    });
    app.use("/api/diagnosis", diagnosisRoutes);
    app.use("/api/diagnosis", diagnosisSessionRoutes);
    app.use("/api/providers", providerMatchingRoutes);
    app.use("/api/bookings", bookingRoutes);

    const port = Number(process.env.PORT ?? 3000);
    const server = app.listen(port, () => {
      console.log(`Server running on port ${port}`);
    });

    const shutdown = () => {
      server.close(() => {
        void closeMongoDB?.().catch((error) => {
          console.error("Failed to close MongoDB connection:", error);
          process.exitCode = 1;
        });
      });
    };

    process.once("SIGINT", shutdown);
    process.once("SIGTERM", shutdown);
  } catch (error) {
    console.error("Failed to start backend:", error);
    if (closeMongoDB) {
      try {
        await closeMongoDB();
      } catch (closeError) {
        console.error("Failed to close MongoDB after startup error:", closeError);
      }
    }
    process.exit(1);
  }
}

void startServer();