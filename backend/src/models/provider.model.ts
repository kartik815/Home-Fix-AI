export interface ProviderExpertise {
  service: string;

  skills: string[];

  brands: string[];

  equipmentTypes: string[];

  problemTypes: string[];

  completedJobs: number;
}

export interface PastJob {
  id: string;

  service: string;

  equipmentType: string;

  brand: string | null;

  model: string | null;

  problemType: string;

  skillsUsed: string[];

  customerRating: number;

  completedAt: string;
}

export interface Provider {
  id: string;

  name: string;

  type: "individual" | "agency";

  phone: string;

  latitude: number;

  longitude: number;

  serviceRadiusKm: number;

  generalServices: string[];

  skills: string[];

  expertise: ProviderExpertise[];

  yearsExperience: number;

  totalJobs: number;

  rating: number;

  reviewCount: number;

  inspectionFee: number;

  minimumPrice: number;

  maximumPrice: number;

  available: boolean;

  pastJobs: PastJob[];
}