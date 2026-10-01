import { Db, MongoClient } from "mongodb";

const databaseName = process.env.MONGODB_DB_NAME || "homepilot";

let client: MongoClient | null = null;
let database: Db | null = null;

export async function connectToMongoDB(): Promise<Db> {
  if (database) {
    return database;
  }

  const mongoUri = process.env.MONGODB_URI;

  if (!mongoUri) {
    throw new Error("MONGODB_URI is not defined in .env");
  }

  client = new MongoClient(mongoUri);

  await client.connect();

  database = client.db(databaseName);

  await database.command({ ping: 1 });

  console.log(`Connected to MongoDB database: ${databaseName}`);

  return database;
}

export function getMongoDB(): Db {
  if (!database) {
    throw new Error(
      "MongoDB is not connected. Call connectToMongoDB() first."
    );
  }

  return database;
}

export async function closeMongoDB(): Promise<void> {
  if (client) {
    await client.close();
    client = null;
  }

  database = null;

  console.log("MongoDB connection closed.");
}