export interface MatchScoreBreakdown {
  expertise: number;
  similarJobs: number;
  skills: number;
  distance: number;
  rating: number;
  experience: number;
  budget: number;
}

export interface ProviderSummary {
  id: string;
  name: string;
  type: "individual" | "agency";
  phone: string;

  latitude: number;
  longitude: number;
  serviceRadiusKm: number;

  generalServices: string[];
  skills: string[];

  yearsExperience: number;
  totalJobs: number;

  rating: number;
  reviewCount: number;

  inspectionFee: number;
  minimumPrice: number;
  maximumPrice: number;

  available: boolean;
}

export interface ProviderMatch {
  providerId: string;

  provider: ProviderSummary;

  score: number;

  breakdown: MatchScoreBreakdown;

  distanceKm: number;

  matchedSkills: string[];

  matchedExpertise: string[];

  similarJobs: number;
}