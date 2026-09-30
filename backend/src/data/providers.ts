import { Provider } from "../models/provider.model";

export const providers: Provider[] = [
  {
    id: "provider-001",
    name: "Arun Appliance Care",
    type: "individual",
    phone: "+91 90000 00001",
    latitude: 11.0168,
    longitude: 76.9558,
    serviceRadiusKm: 15,

    generalServices: [
      "Washing Machine Repair",
      "Refrigerator Repair",
      "Microwave Repair",
    ],

    skills: [
      "Appliance Repair",
      "Washing Machine Diagnostics",
      "Washing Machine Repair",
      "Front-Load Washer Repair",
      "Drum Repair",
      "LG Appliance Repair",
      "Samsung Appliance Repair",
    ],

    expertise: [
      {
        service: "Washing Machine Repair",
        skills: [
          "Washing Machine Diagnostics",
          "Front-Load Washer Repair",
          "Drum Repair",
          "LG Appliance Repair",
        ],
        brands: ["LG", "Samsung"],
        equipmentTypes: ["washing machine"],
        problemTypes: [
          "drum not spinning",
          "grinding noise",
          "drum problem",
          "motor problem",
        ],
        completedJobs: 185,
      },
    ],

    yearsExperience: 8,
    totalJobs: 420,
    rating: 4.8,
    reviewCount: 186,
    inspectionFee: 150,
    minimumPrice: 500,
    maximumPrice: 2500,
    available: true,

    pastJobs: [
      {
        id: "job-001",
        service: "Washing Machine Repair",
        equipmentType: "washing machine",
        brand: "LG",
        model: null,
        problemType: "drum not spinning",
        skillsUsed: [
          "Washing Machine Diagnostics",
          "Drum Repair",
        ],
        customerRating: 5,
        completedAt: "2026-08-15",
      },
      {
        id: "job-002",
        service: "Washing Machine Repair",
        equipmentType: "washing machine",
        brand: "Samsung",
        model: null,
        problemType: "grinding noise",
        skillsUsed: [
          "Washing Machine Diagnostics",
          "Motor Repair",
        ],
        customerRating: 5,
        completedAt: "2026-08-22",
      },
    ],
  },

  {
    id: "provider-002",
    name: "QuickFix Home Services",
    type: "agency",
    phone: "+91 90000 00002",
    latitude: 11.0250,
    longitude: 76.9700,
    serviceRadiusKm: 20,

    generalServices: [
      "Electrical Repair",
      "Plumbing",
      "Appliance Repair",
      "Home Maintenance",
    ],

    skills: [
      "Appliance Repair",
      "Basic Washing Machine Repair",
      "Electrical Repair",
      "Plumbing",
    ],

    expertise: [
      {
        service: "Appliance Repair",
        skills: [
          "Appliance Repair",
          "Basic Washing Machine Repair",
        ],
        brands: ["LG", "Samsung", "Whirlpool"],
        equipmentTypes: [
          "washing machine",
          "refrigerator",
          "microwave",
        ],
        problemTypes: [
          "power failure",
          "basic appliance fault",
        ],
        completedJobs: 90,
      },
    ],

    yearsExperience: 5,
    totalJobs: 600,
    rating: 4.5,
    reviewCount: 320,
    inspectionFee: 100,
    minimumPrice: 400,
    maximumPrice: 3000,
    available: true,

    pastJobs: [],
  },

  {
    id: "provider-003",
    name: "LG Master Technicians",
    type: "agency",
    phone: "+91 90000 00003",
    latitude: 11.0400,
    longitude: 76.9800,
    serviceRadiusKm: 25,

    generalServices: [
      "LG Appliance Repair",
      "Washing Machine Repair",
      "Refrigerator Repair",
    ],

    skills: [
      "LG Appliance Repair",
      "Washing Machine Diagnostics",
      "Front-Load Washer Repair",
      "Motor Repair",
      "Drum Repair",
    ],

    expertise: [
      {
        service: "Washing Machine Repair",
        skills: [
          "LG Appliance Repair",
          "Washing Machine Diagnostics",
          "Front-Load Washer Repair",
          "Drum Repair",
        ],
        brands: ["LG"],
        equipmentTypes: ["washing machine"],
        problemTypes: [
          "drum not spinning",
          "grinding noise",
          "motor problem",
          "drum problem",
        ],
        completedJobs: 310,
      },
    ],

    yearsExperience: 12,
    totalJobs: 950,
    rating: 4.7,
    reviewCount: 510,
    inspectionFee: 200,
    minimumPrice: 700,
    maximumPrice: 3500,
    available: true,

    pastJobs: [
      {
        id: "job-003",
        service: "Washing Machine Repair",
        equipmentType: "washing machine",
        brand: "LG",
        model: null,
        problemType: "drum not spinning",
        skillsUsed: [
          "LG Appliance Repair",
          "Drum Repair",
        ],
        customerRating: 5,
        completedAt: "2026-07-12",
      },
      {
        id: "job-004",
        service: "Washing Machine Repair",
        equipmentType: "washing machine",
        brand: "LG",
        model: null,
        problemType: "grinding noise",
        skillsUsed: [
          "LG Appliance Repair",
          "Motor Repair",
        ],
        customerRating: 5,
        completedAt: "2026-08-02",
      },
      {
        id: "job-005",
        service: "Washing Machine Repair",
        equipmentType: "washing machine",
        brand: "LG",
        model: null,
        problemType: "drum problem",
        skillsUsed: [
          "Drum Repair",
          "Front-Load Washer Repair",
        ],
        customerRating: 4,
        completedAt: "2026-08-28",
      },
    ],
  },

  {
    id: "provider-004",
    name: "Budget Appliance Repairs",
    type: "individual",
    phone: "+91 90000 00004",
    latitude: 11.0120,
    longitude: 76.9500,
    serviceRadiusKm: 10,

    generalServices: [
      "Washing Machine Repair",
      "Refrigerator Repair",
    ],

    skills: [
      "Appliance Repair",
      "Washing Machine Repair",
    ],

    expertise: [
      {
        service: "Washing Machine Repair",
        skills: [
          "Washing Machine Repair",
        ],
        brands: ["LG", "Samsung"],
        equipmentTypes: ["washing machine"],
        problemTypes: [
          "washing machine not working",
        ],
        completedJobs: 70,
      },
    ],

    yearsExperience: 4,
    totalJobs: 130,
    rating: 4.2,
    reviewCount: 45,
    inspectionFee: 50,
    minimumPrice: 300,
    maximumPrice: 1200,
    available: true,

    pastJobs: [],
  },

  {
    id: "provider-005",
    name: "Coimbatore Electrical Experts",
    type: "agency",
    phone: "+91 90000 00005",
    latitude: 11.0300,
    longitude: 76.9500,
    serviceRadiusKm: 20,

    generalServices: [
      "Electrical Repair",
      "Wiring",
      "Electrical Safety Inspection",
    ],

    skills: [
      "Electrical Repair",
      "Wiring",
      "Motor Electrical Repair",
      "Circuit Diagnosis",
    ],

    expertise: [
      {
        service: "Electrical Repair",
        skills: [
          "Electrical Repair",
          "Wiring",
          "Circuit Diagnosis",
        ],
        brands: [],
        equipmentTypes: [
          "electrical system",
          "motor",
        ],
        problemTypes: [
          "power failure",
          "short circuit",
          "wiring problem",
        ],
        completedJobs: 500,
      },
    ],

    yearsExperience: 15,
    totalJobs: 1200,
    rating: 4.9,
    reviewCount: 700,
    inspectionFee: 150,
    minimumPrice: 500,
    maximumPrice: 5000,
    available: true,

    pastJobs: [],
  },

  {
    id: "provider-006",
    name: "Home Plumbing Solutions",
    type: "individual",
    phone: "+91 90000 00006",
    latitude: 11.0180,
    longitude: 76.9600,
    serviceRadiusKm: 12,

    generalServices: [
      "Plumbing",
      "Leak Repair",
      "Bathroom Repair",
    ],

    skills: [
      "Plumbing",
      "Pipe Repair",
      "Leak Detection",
      "Bathroom Plumbing",
    ],

    expertise: [
      {
        service: "Plumbing",
        skills: [
          "Plumbing",
          "Leak Detection",
          "Pipe Repair",
        ],
        brands: [],
        equipmentTypes: [
          "water pipe",
          "sink",
          "toilet",
        ],
        problemTypes: [
          "water leak",
          "blocked pipe",
          "low water pressure",
        ],
        completedJobs: 220,
      },
    ],

    yearsExperience: 9,
    totalJobs: 400,
    rating: 4.6,
    reviewCount: 190,
    inspectionFee: 100,
    minimumPrice: 300,
    maximumPrice: 2500,
    available: true,

    pastJobs: [],
  },

  {
    id: "provider-007",
    name: "CoolAir HVAC Services",
    type: "agency",
    phone: "+91 90000 00007",
    latitude: 11.0500,
    longitude: 76.9900,
    serviceRadiusKm: 30,

    generalServices: [
      "AC Repair",
      "Air Conditioner Installation",
      "HVAC Maintenance",
    ],

    skills: [
      "HVAC Repair",
      "AC Repair",
      "Refrigerant Charging",
      "Compressor Repair",
    ],

    expertise: [
      {
        service: "AC Repair",
        skills: [
          "HVAC Repair",
          "AC Repair",
          "Compressor Repair",
        ],
        brands: ["LG", "Samsung", "Daikin", "Voltas"],
        equipmentTypes: ["air conditioner"],
        problemTypes: [
          "AC not cooling",
          "compressor problem",
          "refrigerant leak",
        ],
        completedJobs: 350,
      },
    ],

    yearsExperience: 11,
    totalJobs: 800,
    rating: 4.8,
    reviewCount: 420,
    inspectionFee: 150,
    minimumPrice: 600,
    maximumPrice: 5000,
    available: true,

    pastJobs: [],
  },

  {
    id: "provider-008",
    name: "General Home Technician",
    type: "individual",
    phone: "+91 90000 00008",
    latitude: 11.0220,
    longitude: 76.9650,
    serviceRadiusKm: 8,

    generalServices: [
      "Home Maintenance",
      "Basic Appliance Repair",
      "Basic Electrical Repair",
    ],

    skills: [
      "Basic Appliance Repair",
      "Basic Electrical Repair",
      "Home Maintenance",
    ],

    expertise: [
      {
        service: "Home Maintenance",
        skills: [
          "Home Maintenance",
        ],
        brands: [],
        equipmentTypes: [],
        problemTypes: [],
        completedJobs: 150,
      },
    ],

    yearsExperience: 3,
    totalJobs: 200,
    rating: 4.3,
    reviewCount: 80,
    inspectionFee: 50,
    minimumPrice: 250,
    maximumPrice: 1500,
    available: true,

    pastJobs: [],
  },

  {
    id: "provider-009",
    name: "Premium Appliance Engineers",
    type: "agency",
    phone: "+91 90000 00009",
    latitude: 11.0700,
    longitude: 77.0000,
    serviceRadiusKm: 40,

    generalServices: [
      "Premium Appliance Repair",
      "Washing Machine Repair",
      "Refrigerator Repair",
      "Dishwasher Repair",
    ],

    skills: [
      "Appliance Engineering",
      "Washing Machine Diagnostics",
      "Drum Repair",
      "Motor Repair",
      "Electronics Repair",
    ],

    expertise: [
      {
        service: "Washing Machine Repair",
        skills: [
          "Washing Machine Diagnostics",
          "Drum Repair",
          "Motor Repair",
        ],
        brands: ["LG", "Samsung", "Bosch", "IFB"],
        equipmentTypes: ["washing machine"],
        problemTypes: [
          "drum not spinning",
          "grinding noise",
          "motor problem",
          "electronics failure",
        ],
        completedJobs: 280,
      },
    ],

    yearsExperience: 14,
    totalJobs: 1100,
    rating: 4.9,
    reviewCount: 650,
    inspectionFee: 300,
    minimumPrice: 1200,
    maximumPrice: 6000,
    available: true,

    pastJobs: [
      {
        id: "job-006",
        service: "Washing Machine Repair",
        equipmentType: "washing machine",
        brand: "LG",
        model: null,
        problemType: "drum not spinning",
        skillsUsed: [
          "Washing Machine Diagnostics",
          "Motor Repair",
        ],
        customerRating: 5,
        completedAt: "2026-09-01",
      },
    ],
  },

  {
    id: "provider-010",
    name: "Unavailable Appliance Technician",
    type: "individual",
    phone: "+91 90000 00010",
    latitude: 11.0150,
    longitude: 76.9550,
    serviceRadiusKm: 15,

    generalServices: [
      "Washing Machine Repair",
    ],

    skills: [
      "Washing Machine Repair",
      "Drum Repair",
    ],

    expertise: [
      {
        service: "Washing Machine Repair",
        skills: [
          "Washing Machine Repair",
          "Drum Repair",
        ],
        brands: ["LG"],
        equipmentTypes: ["washing machine"],
        problemTypes: [
          "drum not spinning",
        ],
        completedJobs: 100,
      },
    ],

    yearsExperience: 7,
    totalJobs: 250,
    rating: 4.7,
    reviewCount: 100,
    inspectionFee: 100,
    minimumPrice: 500,
    maximumPrice: 2000,
    available: false,

    pastJobs: [],
  },
];