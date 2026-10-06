import { Collection, Document } from "mongodb";

import { getMongoDB } from "../config/mongodb";
import { Provider } from "../models/provider.model";

type ProviderDocument = Provider &
  Document & {
    _id: string;
  };

export async function getProvidersFromMongoDB(): Promise<Provider[]> {
  const db = getMongoDB();

  const collection =
    db.collection<ProviderDocument>("providers");

  const documents = await collection
    .find({})
    .toArray();

  return documents.map((document) => {
    const { _id, ...provider } = document;

    return provider;
  });
}