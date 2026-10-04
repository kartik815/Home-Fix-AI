import dotenv from "dotenv";
import {
  connectToMongoDB,
  closeMongoDB,
} from "./config/mongodb";

dotenv.config();

async function testMongoDB() {
  try {
    await connectToMongoDB();

    console.log("MongoDB test successful.");

    await closeMongoDB();
  } catch (error) {
    console.error("MongoDB test failed:", error);
    process.exit(1);
  }
}

testMongoDB();