export interface MatchScoreBreakdown {
  expertise: number;

  similarJobs: number;

  skills: number;

  distance: number;

  rating: number;

  experience: number;

  budget: number;
}

export interface ProviderMatch {
  providerId: string;

  score: number;

  breakdown: MatchScoreBreakdown;

  distanceKm: number;

  matchedSkills: string[];

  matchedExpertise: string[];

  similarJobs: number;
}