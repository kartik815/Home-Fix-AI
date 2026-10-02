class ProfessionalModel {
  final String id;
  final String name;
  final String category;
  final String specialty;
  final double rating;
  final int reviewCount;
  final int trustScore;
  final int completedRepairs;
  final String distance;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final String address;
  final int experienceYears;
  final String pricingStartingAt;
  final String aiReviewSummary;
  bool isSaved;
  final bool isVerified;
  final List<ServicePricing> services;

  ProfessionalModel({
    required this.id,
    required this.name,
    required this.category,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
    required this.trustScore,
    required this.completedRepairs,
    required this.distance,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    required this.address,
    required this.experienceYears,
    required this.pricingStartingAt,
    required this.aiReviewSummary,
    this.isSaved = false,
    this.isVerified = true,
    this.services = const [],
  });

  static List<ProfessionalModel> sampleProfessionals = [
    ProfessionalModel(
      id: 'pro_1',
      name: 'Sharma Electricals & Cooling',
      category: 'Electrical',
      specialty: 'Fan, Wiring & AC Coil Repair',
      rating: 4.8,
      reviewCount: 148,
      trustScore: 94,
      completedRepairs: 182,
      distance: '0.8 km',
      latitude: 28.6139,
      longitude: 77.2090,
      phoneNumber: '+91 98112 34567',
      address: 'Shop 12, Block C, Central Market',
      experienceYears: 9,
      pricingStartingAt: '₹299',
      aiReviewSummary:
          'Ranked highest for rapid electrical diagnosis and circuit troubleshooting. 98% first-visit resolution rate.',
      isSaved: true,
      services: [
        ServicePricing(title: 'General Inspection & Diagnostics', price: '₹249'),
        ServicePricing(title: 'Ceiling Fan Installation / Fix', price: '₹349'),
        ServicePricing(title: 'Short Circuit & Fuse Repair', price: '₹499'),
        ServicePricing(title: 'Full House Wiring Check', price: '₹799'),
      ],
    ),
    ProfessionalModel(
      id: 'pro_2',
      name: 'R.K. Quick Plumbing Services',
      category: 'Plumbing',
      specialty: 'Leakages, Pipe Replacement & Taps',
      rating: 4.7,
      reviewCount: 112,
      trustScore: 91,
      completedRepairs: 135,
      distance: '1.2 km',
      latitude: 28.6185,
      longitude: 77.2145,
      phoneNumber: '+91 98234 56789',
      address: 'Plot 45, Near Metro Pillar 118',
      experienceYears: 7,
      pricingStartingAt: '₹249',
      aiReviewSummary:
          'Consistently rated 5 stars for pipe leakage sealing and urgent bathroom drainage blocks.',
      isSaved: true,
      services: [
        ServicePricing(title: 'Leakage Inspection', price: '₹199'),
        ServicePricing(title: 'Tap & Faucet Replacement', price: '₹299'),
        ServicePricing(title: 'Drainage Unclogging', price: '₹499'),
        ServicePricing(title: 'Water Tank & Pipe Overhaul', price: '₹899'),
      ],
    ),
    ProfessionalModel(
      id: 'pro_3',
      name: 'CoolCare AC Solutions',
      category: 'AC Repair',
      specialty: 'AC Cooling, Gas Refill & Compressor',
      rating: 4.9,
      reviewCount: 230,
      trustScore: 96,
      completedRepairs: 260,
      distance: '1.8 km',
      latitude: 28.6080,
      longitude: 77.2030,
      phoneNumber: '+91 98765 12340',
      address: 'Suite 3B, Tech Park Commercial Arcade',
      experienceYears: 11,
      pricingStartingAt: '₹399',
      aiReviewSummary:
          'AI verified: Specializes in split and inverter AC compressor repair. Genuine spares guarantee.',
      isSaved: true,
      services: [
        ServicePricing(title: 'AC Jet Cleaning & Service', price: '₹499'),
        ServicePricing(title: 'Cooling Gas Refill (R32/R410)', price: '₹1,499'),
        ServicePricing(title: 'PCB Board Diagnostics & Repair', price: '₹1,200'),
        ServicePricing(title: 'Compressor Replacement Support', price: '₹2,500'),
      ],
    ),
    ProfessionalModel(
      id: 'pro_4',
      name: 'PowerFix Appliance Masters',
      category: 'Appliances',
      specialty: 'Refrigerator, Microwave & Washing Machine',
      rating: 4.6,
      reviewCount: 89,
      trustScore: 88,
      completedRepairs: 95,
      distance: '2.4 km',
      latitude: 28.6220,
      longitude: 77.2190,
      phoneNumber: '+91 98450 98765',
      address: '14/A, New Colony, Industrial Area',
      experienceYears: 6,
      pricingStartingAt: '₹349',
      aiReviewSummary:
          'Expertise in digital inverter motors and front-load washing machine drum alignment.',
      isSaved: false,
      services: [
        ServicePricing(title: 'Appliance Diagnostics', price: '₹299'),
        ServicePricing(title: 'Fridge Gas & Cooling Coil', price: '₹1,100'),
        ServicePricing(title: 'Washing Machine Motor Repair', price: '₹950'),
        ServicePricing(title: 'Microwave Magnetron Fix', price: '₹850'),
      ],
    ),
    ProfessionalModel(
      id: 'pro_5',
      name: 'VoltSafe Electrical Care',
      category: 'Electrical',
      specialty: 'Smart Switches, Inverters & Wiring',
      rating: 4.7,
      reviewCount: 94,
      trustScore: 89,
      completedRepairs: 110,
      distance: '3.1 km',
      latitude: 28.6050,
      longitude: 77.2120,
      phoneNumber: '+91 98980 11223',
      address: '2nd Floor, Sai Complex, Green Park',
      experienceYears: 5,
      pricingStartingAt: '₹249',
      aiReviewSummary:
          'Recommended for smart home installations, inverter backups, and MCB breaker replacements.',
      isSaved: false,
      services: [
        ServicePricing(title: 'Safety Load Audit', price: '₹399'),
        ServicePricing(title: 'Inverter Wiring & Setup', price: '₹599'),
        ServicePricing(title: 'Switchboard Replacement', price: '₹299'),
      ],
    ),
  ];
}

class ServicePricing {
  final String title;
  final String price;

  const ServicePricing({required this.title, required this.price});
}
