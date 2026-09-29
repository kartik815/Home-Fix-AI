export type DiagnosisCategory =
  | "electrical"
  | "plumbing"
  | "appliance"
  | "hvac"
  | "interior"
  | "furniture"
  | "renovation"
  | "structural"
  | "other"
  | "unknown";

export type DiagnosisSeverity =
  | "low"
  | "medium"
  | "high"
  | "critical"
  | "unknown";

export type DiagnosisUrgency =
  | "normal"
  | "soon"
  | "urgent"
  | "emergency"
  | "unknown";

export interface KnownInformationItem {
  key: string;
  value: string;
}

export interface DiagnosisResult {
  category: DiagnosisCategory;
  subcategory: string | null;
  brand: string | null;
  model: string | null;
  problemSummary: string;
  symptoms: string[];
  component: string | null;
  severity: DiagnosisSeverity;
  urgency: DiagnosisUrgency;
  requiredService: string | null;
  requiredSkills: string[];
  knownInformation: KnownInformationItem[];
  missingInformation: string[];
  confidence: number;
}