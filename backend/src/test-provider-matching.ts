import { providers } from "./data/providers";
import { matchProviders } from "./services/provider.matching.service";
import { DiagnosisResult } from "./models/diagnosis.model";

const diagnosis: DiagnosisResult = {
  category: "electrical",
  subcategory: "electrical system",
  brand: null,
  model: null,

  problemSummary:
    "The living room power socket is sparking when a device is plugged in.",

  symptoms: [
    "sparking socket",
    "electrical sparks",
  ],

  component: "power socket",

  severity: "high",
  urgency: "urgent",

  requiredService: "Electrical Repair",

  requiredSkills: [
    "Electrical Repair",
    "Circuit Diagnosis",
  ],

  knownInformation: [
    {
      key: "location",
      value: "living room",
    },
    {
      key: "problem",
      value: "socket sparking",
    },
  ],

  missingInformation: [],

  confidence: 0.95,
};

const customerLocation = {
  latitude: 11.0168,
  longitude: 76.9558,
};

const budget = 2000;

const matches = matchProviders(
  diagnosis,
  providers,
  customerLocation,
  budget
);

console.log("\n========================================");
console.log("        PROVIDER MATCHING TEST");
console.log("========================================\n");

console.log(`Providers in dataset: ${providers.length}`);
console.log(`Providers matched: ${matches.length}`);
console.log(`Customer budget: ₹${budget}\n`);

matches.forEach((match, index) => {
  const provider = providers.find(
    (p) => p.id === match.providerId
  );

  if (!provider) return;

  console.log("----------------------------------------");

  console.log(`#${index + 1} ${provider.name}`);
  console.log(`Overall Score: ${match.score}/100`);
  console.log(`Distance: ${match.distanceKm.toFixed(2)} km`);

  console.log("\nScore Breakdown:");

  console.log(`  Expertise:     ${match.breakdown.expertise}`);
  console.log(`  Similar Jobs:  ${match.breakdown.similarJobs}`);
  console.log(`  Skills:        ${match.breakdown.skills}`);
  console.log(`  Distance:      ${match.breakdown.distance}`);
  console.log(`  Rating:        ${match.breakdown.rating}`);
  console.log(`  Experience:    ${match.breakdown.experience}`);
  console.log(`  Budget:        ${match.breakdown.budget}`);

  console.log("\nMatched Skills:");

  if (match.matchedSkills.length === 0) {
    console.log("  None");
  } else {
    match.matchedSkills.forEach((skill) => {
      console.log(`  ✓ ${skill}`);
    });
  }

  console.log("\nMatched Expertise:");

  if (match.matchedExpertise.length === 0) {
    console.log("  None");
  } else {
    match.matchedExpertise.forEach((expertise) => {
      console.log(`  ✓ ${expertise}`);
    });
  }

  console.log(`\nSimilar Past Jobs: ${match.similarJobs}`);
});

console.log("\n========================================");
console.log("              TEST COMPLETE");
console.log("========================================\n");