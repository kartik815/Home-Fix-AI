import dotenv from "dotenv";

dotenv.config();

async function testMongoDBMatching() {
  try {
    const {
      connectToMongoDB,
      closeMongoDB,
    } = await import("./config/mongodb");

    const {
      getProvidersFromMongoDB,
    } = await import(
      "./services/provider.repository"
    );

    // Connect first
    await connectToMongoDB();

    // Then retrieve providers
    const providers =
      await getProvidersFromMongoDB();

    console.log(
      `Providers loaded from MongoDB: ${providers.length}`
    );

    providers.forEach((provider) => {
      console.log(
        `${provider.id} | ${provider.name} | ${provider.rating}★`
      );
    });

    if (providers.length === 0) {
      throw new Error(
        "No providers were found in MongoDB."
      );
    }

    console.log(
      "\nMongoDB provider retrieval successful."
    );

    await closeMongoDB();
  } catch (error) {
    console.error(
      "MongoDB matching test failed:",
      error
    );

    process.exit(1);
  }
}

testMongoDBMatching();