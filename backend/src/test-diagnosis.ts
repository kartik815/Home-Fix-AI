import dotenv from "dotenv";

dotenv.config();

async function testDiagnosis() {
  try {
    const { analyzeProblem } =
      await import("./services/diagnosis.service");

    const result = await analyzeProblem(
      "My LG washing machine turns on but the drum is not spinning and I hear a grinding noise."
    );

    console.log(
      JSON.stringify(result, null, 2)
    );
  } catch (error) {
    console.error("Diagnosis test failed:", error);
    process.exit(1);
  }
}

testDiagnosis();