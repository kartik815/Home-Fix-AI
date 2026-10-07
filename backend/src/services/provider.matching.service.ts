import { DiagnosisResult } from "../models/diagnosis.model";
import { Provider } from "../models/provider.model";
import {
  MatchScoreBreakdown,
  ProviderMatch,
  ProviderSummary,
} from "../models/provider.match.model";

/*
|--------------------------------------------------------------------------
| MATCHING WEIGHTS
|--------------------------------------------------------------------------
*/

const WEIGHTS = {
  expertise: 0.30,
  similarJobs: 0.20,
  skills: 0.15,
  distance: 0.15,
  rating: 0.10,
  experience: 0.05,
  budget: 0.05,
};

/*
|--------------------------------------------------------------------------
| NORMALIZE TEXT
|--------------------------------------------------------------------------
*/

function normalize(value: string): string {
  return value
    .trim()
    .toLowerCase()
    .replace(/[_-]/g, " ");
}

/*
|--------------------------------------------------------------------------
| SKILL MATCHING
|--------------------------------------------------------------------------
*/

function calculateSkillScore(
  diagnosis: DiagnosisResult,
  provider: Provider
): {
  score: number;
  matchedSkills: string[];
} {
  const requiredSkills =
    diagnosis.requiredSkills.map(normalize);

  const providerSkills =
    provider.skills.map(normalize);

  const matchedSkills =
    diagnosis.requiredSkills.filter((skill) =>
      providerSkills.includes(normalize(skill))
    );

  if (requiredSkills.length === 0) {
    return {
      score: 0,
      matchedSkills: [],
    };
  }

  const score =
    (matchedSkills.length / requiredSkills.length) *
    100;

  return {
    score,
    matchedSkills,
  };
}

/*
|--------------------------------------------------------------------------
| EXPERTISE MATCHING
|--------------------------------------------------------------------------
*/

function calculateExpertiseScore(
  diagnosis: DiagnosisResult,
  provider: Provider
): {
  score: number;
  matchedExpertise: string[];
} {
  const diagnosisService = normalize(
    diagnosis.requiredService ?? ""
  );

  const diagnosisSubcategory = normalize(
    diagnosis.subcategory ?? ""
  );

  const diagnosisBrand = normalize(
    diagnosis.brand ?? ""
  );

  const diagnosisProblems = [
    ...diagnosis.symptoms,
    diagnosis.component ?? "",
  ].map(normalize);

  let bestScore = 0;
  let bestService: string | null = null;

  for (const expertise of provider.expertise) {
    const service = normalize(expertise.service);

    const serviceMatch =
      service === diagnosisService ||
      service.includes(diagnosisService) ||
      diagnosisService.includes(service);

    const equipmentMatch = expertise.equipmentTypes.some(
      (equipment) => {
        const normalizedEquipment = normalize(equipment);

        return (
          normalizedEquipment === diagnosisSubcategory ||
          normalizedEquipment.includes(diagnosisSubcategory) ||
          diagnosisSubcategory.includes(normalizedEquipment)
        );
      }
    );

    const brandMatch =
      diagnosisBrand.length > 0 &&
      expertise.brands.some(
        (brand) =>
          normalize(brand) === diagnosisBrand
      );

    const problemMatch = expertise.problemTypes.some(
      (problemType) => {
        const normalizedProblem =
          normalize(problemType);

        return diagnosisProblems.some(
          (diagnosisProblem) =>
            diagnosisProblem.includes(normalizedProblem) ||
            normalizedProblem.includes(diagnosisProblem)
        );
      }
    );

    let score = 0;

    /*
     * Appliance-style exact match:
     * service + equipment + brand + problem
     */
    if (
      serviceMatch &&
      equipmentMatch &&
      brandMatch &&
      problemMatch
    ) {
      score = 100;
    }

    /*
     * Exact non-branded problem:
     * service + equipment + problem
     */
    else if (
      serviceMatch &&
      equipmentMatch &&
      problemMatch
    ) {
      score = 100;
    }

    /*
     * Service + equipment + brand
     */
    else if (
      serviceMatch &&
      equipmentMatch &&
      brandMatch
    ) {
      score = 90;
    }

    /*
     * Service + equipment
     */
    else if (
      serviceMatch &&
      equipmentMatch
    ) {
      score = 80;
    }

    /*
     * Service + problem
     */
    else if (
      serviceMatch &&
      problemMatch
    ) {
      score = 70;
    }

    /*
     * Equipment + problem
     */
    else if (
      equipmentMatch &&
      problemMatch
    ) {
      score = 70;
    }

    /*
     * Generic service match
     */
    else if (serviceMatch) {
      score = 50;
    }

    /*
     * Generic appliance/service expertise
     */
    else if (
      diagnosis.category === "appliance" &&
      service.includes("appliance")
    ) {
      score = 25;
    }

    if (score > bestScore) {
      bestScore = score;
      bestService = expertise.service;
    }
  }

  return {
    score: bestScore,
    matchedExpertise: bestService
      ? [bestService]
      : [],
  };
}

/*
|--------------------------------------------------------------------------
| SIMILAR PAST JOB MATCHING
|--------------------------------------------------------------------------
*/

function calculateSimilarJobScore(
  diagnosis: DiagnosisResult,
  provider: Provider
): {
  score: number;
  similarJobs: number;
} {
  const diagnosisService = normalize(
    diagnosis.requiredService ?? ""
  );

  const diagnosisEquipment = normalize(
    diagnosis.subcategory ?? ""
  );

  const diagnosisBrand = normalize(
    diagnosis.brand ?? ""
  );

  const diagnosisProblems = [
    ...diagnosis.symptoms,
    diagnosis.component ?? "",
    diagnosis.problemSummary,
  ].map(normalize);

  let bestJobScore = 0;
  let similarJobs = 0;

  for (const job of provider.pastJobs) {
    const jobService = normalize(job.service);
    const jobEquipment = normalize(job.equipmentType);
    const jobBrand = normalize(job.brand ?? "");
    const jobProblem = normalize(job.problemType);

    const serviceMatch =
      jobService === diagnosisService ||
      jobService.includes(diagnosisService) ||
      diagnosisService.includes(jobService);

    const equipmentMatch =
      jobEquipment === diagnosisEquipment ||
      jobEquipment.includes(diagnosisEquipment) ||
      diagnosisEquipment.includes(jobEquipment);

    const brandMatch =
      diagnosisBrand.length > 0 &&
      jobBrand.length > 0 &&
      jobBrand === diagnosisBrand;

    const problemMatch = diagnosisProblems.some(
      (problem) =>
        problem.length > 0 &&
        (
          problem.includes(jobProblem) ||
          jobProblem.includes(problem)
        )
    );

    let jobScore = 0;

    /*
     * Exact problem + same equipment + same brand
     */
    if (
      serviceMatch &&
      equipmentMatch &&
      brandMatch &&
      problemMatch
    ) {
      jobScore = 100;
    }

    /*
     * Exact problem + same equipment
     */
    else if (
      serviceMatch &&
      equipmentMatch &&
      problemMatch
    ) {
      jobScore = 85;
    }

    /*
     * Same equipment + same brand
     */
    else if (
      equipmentMatch &&
      brandMatch
    ) {
      jobScore = 70;
    }

    /*
     * Same equipment
     */
    else if (equipmentMatch) {
      jobScore = 30;
    }

    if (jobScore > 0) {
      similarJobs++;
    }

    bestJobScore = Math.max(bestJobScore, jobScore);
  }

  if (similarJobs >= 3 && bestJobScore >= 85) {
    bestJobScore = Math.min(100, bestJobScore + 10);
  } else if (similarJobs >= 2 && bestJobScore >= 85) {
    bestJobScore = Math.min(100, bestJobScore + 5);
  }

  return {
    score: bestJobScore,
    similarJobs,
  };
}

/*
|--------------------------------------------------------------------------
| DISTANCE SCORE
|--------------------------------------------------------------------------
*/

function calculateDistanceScore(
  distanceKm: number,
  serviceRadiusKm: number
): number {
  if (distanceKm < 0) {
    return 0;
  }

  if (serviceRadiusKm <= 0) {
    return 0;
  }

  /*
   * Provider is outside their service area.
   */
  if (distanceKm > serviceRadiusKm) {
    return 0;
  }

  /*
   * 0 km = 100
   * service radius = 0
   */
  const score =
    100 *
    (1 - distanceKm / serviceRadiusKm);

  return Math.max(
    0,
    Math.min(100, score)
  );
}

/*
|--------------------------------------------------------------------------
| RATING SCORE
|--------------------------------------------------------------------------
*/

function calculateRatingScore(
  rating: number,
  reviewCount: number
): number {
  if (
    rating <= 0 ||
    reviewCount <= 0
  ) {
    return 0;
  }

  const ratingScore =
    (rating / 5) * 100;

  /*
   * More reviews = more confidence
   * in the rating.
   */
  const confidence =
    Math.min(reviewCount / 100, 1);

  return (
    ratingScore *
    (0.5 + 0.5 * confidence)
  );
}

/*
|--------------------------------------------------------------------------
| EXPERIENCE SCORE
|--------------------------------------------------------------------------
*/

function calculateExperienceScore(
  yearsExperience: number
): number {
  if (yearsExperience <= 0) {
    return 0;
  }

  return (
    Math.min(
      yearsExperience / 10,
      1
    ) * 100
  );
}

/*
|--------------------------------------------------------------------------
| BUDGET SCORE
|--------------------------------------------------------------------------
*/

function calculateBudgetScore(
  provider: Provider,
  budget: number | null
): number {
  /*
   * No budget provided.
   *
   * We don't want to punish the provider.
   */
  if (budget === null) {
    return 50;
  }

  /*
   * Budget falls within provider's
   * expected price range.
   */
  if (
    budget >= provider.minimumPrice &&
    budget <= provider.maximumPrice
  ) {
    return 100;
  }

  /*
   * Slightly outside the expected range.
   */
  if (
    budget >=
      provider.minimumPrice * 0.8 &&
    budget <=
      provider.maximumPrice * 1.2
  ) {
    return 70;
  }

  /*
   * Significantly outside the range.
   */
  return 20;
}

/*
|--------------------------------------------------------------------------
| FINAL PROVIDER MATCH
|--------------------------------------------------------------------------
*/

export function calculateProviderMatch(
  diagnosis: DiagnosisResult,
  provider: Provider,
  distanceKm: number,
  budget: number | null
): ProviderMatch {
  /*
   * Calculate every individual factor.
   */

  const skillResult =
    calculateSkillScore(
      diagnosis,
      provider
    );

  const expertiseResult =
    calculateExpertiseScore(
      diagnosis,
      provider
    );

  const similarJobResult =
    calculateSimilarJobScore(
      diagnosis,
      provider
    );

  const distanceScore =
    calculateDistanceScore(
      distanceKm,
      provider.serviceRadiusKm
    );

  const ratingScore =
    calculateRatingScore(
      provider.rating,
      provider.reviewCount
    );

  const experienceScore =
    calculateExperienceScore(
      provider.yearsExperience
    );

  const budgetScore =
    calculateBudgetScore(
      provider,
      budget
    );

  /*
   * Store individual scores.
   */

  const breakdown: MatchScoreBreakdown = {
    expertise: expertiseResult.score,
    similarJobs: similarJobResult.score,
    skills: skillResult.score,
    distance: distanceScore,
    rating: ratingScore,
    experience: experienceScore,
    budget: budgetScore,
  };

  /*
   * Weighted final score.
   */

  const score =
    breakdown.expertise *
      WEIGHTS.expertise +

    breakdown.similarJobs *
      WEIGHTS.similarJobs +

    breakdown.skills *
      WEIGHTS.skills +

    breakdown.distance *
      WEIGHTS.distance +

    breakdown.rating *
      WEIGHTS.rating +

    breakdown.experience *
      WEIGHTS.experience +

    breakdown.budget *
      WEIGHTS.budget;

const providerSummary: ProviderSummary = {
  id: provider.id,
  name: provider.name,
  type: provider.type,
  phone: provider.phone,

  latitude: provider.latitude,
  longitude: provider.longitude,
  serviceRadiusKm: provider.serviceRadiusKm,

  generalServices: provider.generalServices,
  skills: provider.skills,

  yearsExperience: provider.yearsExperience,
  totalJobs: provider.totalJobs,

  rating: provider.rating,
  reviewCount: provider.reviewCount,

  inspectionFee: provider.inspectionFee,
  minimumPrice: provider.minimumPrice,
  maximumPrice: provider.maximumPrice,

  available: provider.available,
};

return {
  providerId: provider.id,

  provider: providerSummary,

  score: Number(
    score.toFixed(2)
  ),

  breakdown,

  distanceKm,

  matchedSkills:
    skillResult.matchedSkills,

  matchedExpertise:
    expertiseResult.matchedExpertise,

  similarJobs:
    similarJobResult.similarJobs,
};
}

export interface CustomerLocation {
  latitude: number;
  longitude: number;
}

function calculateDistanceKm(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const earthRadiusKm = 6371;

  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return earthRadiusKm * c;
}

function isProviderRelevant(
  diagnosis: DiagnosisResult,
  provider: Provider
): boolean {
  const requiredService = normalize(
    diagnosis.requiredService ?? ""
  );

  const subcategory = normalize(
    diagnosis.subcategory ?? ""
  );

  const requiredSkills = diagnosis.requiredSkills.map(normalize);

  // 1. Exact required skill
  const exactSkillMatch = provider.skills.some((skill) =>
    requiredSkills.includes(normalize(skill))
  );

  if (exactSkillMatch) {
    return true;
  }

  // 2. Strong equipment + service expertise
  const expertiseMatch = provider.expertise.some((expertise) => {
    const service = normalize(expertise.service);

    const serviceMatch =
      requiredService.length > 0 &&
      (
        service === requiredService ||
        service.includes(requiredService) ||
        requiredService.includes(service)
      );

    const equipmentMatch =
      subcategory.length > 0 &&
      expertise.equipmentTypes.some(
        (equipment) =>
          normalize(equipment) === subcategory
      );

    return serviceMatch && equipmentMatch;
  });

  if (expertiseMatch) {
    return true;
  }

  // 3. Relevant past job
  const pastJobMatch = provider.pastJobs.some((job) => {
    const equipment = normalize(job.equipmentType);
    const service = normalize(job.service);

    const equipmentMatch =
      subcategory.length > 0 &&
      equipment === subcategory;

    const serviceMatch =
      requiredService.length > 0 &&
      (
        service === requiredService ||
        service.includes(requiredService) ||
        requiredService.includes(service)
      );

    return equipmentMatch && serviceMatch;
  });

  if (pastJobMatch) {
    return true;
  }

  // 4. Equipment-specific expertise even when service wording differs
  const equipmentOnlyMatch = provider.expertise.some(
    (expertise) =>
      subcategory.length > 0 &&
      expertise.equipmentTypes.some(
        (equipment) =>
          normalize(equipment) === subcategory
      )
  );

  if (equipmentOnlyMatch) {
    return true;
  }

  // 5. Broad categories only
  const category = normalize(
    diagnosis.category
  );

  if (
    category === "other" ||
    category === "unknown"
  ) {
    return provider.generalServices.length > 0;
  }

  return false;
}

export function matchProviders(
  diagnosis: DiagnosisResult,
  providers: Provider[],
  customerLocation: CustomerLocation,
  budget: number | null
): ProviderMatch[] {
  const matches: ProviderMatch[] = [];

  for (const provider of providers) {
    if (!isProviderRelevant(diagnosis, provider)) {
      continue;
    }    
    // Never recommend unavailable providers.
    if (!provider.available) {
      continue;
    }

    const distanceKm = calculateDistanceKm(
      customerLocation.latitude,
      customerLocation.longitude,
      provider.latitude,
      provider.longitude
    );

    // Don't recommend providers who don't serve this location.
    if (distanceKm > provider.serviceRadiusKm) {
      continue;
    }

    const match = calculateProviderMatch(
      diagnosis,
      provider,
      distanceKm,
      budget
    );

    matches.push(match);
  }

  return matches.sort((a, b) => b.score - a.score);
}

export function getProviderById(
  providers: Provider[],
  providerId: string
): Provider | undefined {
  return providers.find((provider) => provider.id === providerId);
}