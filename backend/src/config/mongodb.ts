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
    throw new Error("MONGODB_URI is not configured.");
  }

  const newClient = new MongoClient(mongoUri);
  await newClient.connect();

  const connectedDatabase = newClient.db(databaseName);
  await connectedDatabase.command({ ping: 1 });

  client = newClient;
  database = connectedDatabase;
  console.log(`Connected to MongoDB database: ${databaseName}`);

  return connectedDatabase;
}

export function getMongoDB(): Db {
  if (!database) {
    throw new Error("MongoDB is not connected.");
  }

  return database;
}

export async function closeMongoDB(): Promise<void> {
  await client?.close();
  client = null;
  database = null;
}
