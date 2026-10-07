import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/professional_model.dart';
import '../maps/professional_details_screen.dart';

class DiagnosisScreen extends StatefulWidget {
  final String problem;

  const DiagnosisScreen({
    super.key,
    required this.problem,
  });

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  // Android emulator -> host machine
  static const String baseUrl = 'http://localhost:3000';

  String? _sessionId;

  bool _loading = true;
  bool _sendingAnswer = false;
  bool _findingProfessionals = false;

  String? _question;
  String? _questionPurpose;

  Map<String, dynamic>? _diagnosis;
  List<dynamic> _matches = [];

  String? _error;

  final TextEditingController _answerController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _startDiagnosis();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // START DIAGNOSIS
  // ------------------------------------------------------------

  Future<void> _startDiagnosis() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/api/diagnosis/session/start',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'problem': widget.problem,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to start diagnosis (${response.statusCode})',
        );
      }

      final body = jsonDecode(response.body);

      if (body['success'] != true) {
        throw Exception(
          body['message'] ?? 'Unable to start diagnosis.',
        );
      }

      final data = body['data'];

      setState(() {
        _sessionId = data['sessionId'];
        _diagnosis =
            Map<String, dynamic>.from(
          data['diagnosis'] ?? {},
        );

        _question = data['question'];
        _questionPurpose =
            data['questionPurpose'];

        _loading = false;
      });

      // If Gemini decides no question is necessary,
      // immediately find professionals.
      if (_question == null &&
          data['status'] == 'complete') {
        await _findProfessionals();
      }
    } catch (e) {
      debugPrint('Start diagnosis error: $e');

      setState(() {
        _loading = false;
        _error =
            'Unable to connect to the diagnosis service.';
      });
    }
  }

  // ------------------------------------------------------------
  // ANSWER QUESTION
  // ------------------------------------------------------------

  Future<void> _submitAnswer() async {
    final answer = _answerController.text.trim();

    if (answer.isEmpty ||
        _sessionId == null ||
        _sendingAnswer) {
      return;
    }

    setState(() {
      _sendingAnswer = true;
      _error = null;
    });

    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/api/diagnosis/session/'
          '$_sessionId/answer',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'answer': answer,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to submit answer (${response.statusCode})',
        );
      }

      final body = jsonDecode(response.body);

      if (body['success'] != true) {
        throw Exception(
          body['message'] ?? 'Unable to process answer.',
        );
      }

      final data = body['data'];

      _answerController.clear();

      setState(() {
        _diagnosis =
            Map<String, dynamic>.from(
          data['diagnosis'] ?? {},
        );

        _question = data['question'];
        _questionPurpose =
            data['questionPurpose'];

        _sendingAnswer = false;
      });

      // Diagnosis is complete.
      if (data['status'] == 'complete') {
        await _findProfessionals();
      }
    } catch (e) {
      debugPrint('Answer diagnosis error: $e');

      setState(() {
        _sendingAnswer = false;
        _error =
            'Unable to process your answer. Please try again.';
      });
    }
  }

  // ------------------------------------------------------------
  // FIND PROFESSIONALS
  // ------------------------------------------------------------

  Future<void> _findProfessionals() async {
    if (_sessionId == null) return;

    setState(() {
      _findingProfessionals = true;
      _error = null;
    });

    try {
      // Temporary location for development/testing.
      //
      // Later we will replace this with the user's
      // actual location from the location service.
      const latitude = 11.0168;
      const longitude = 76.9558;

      final response = await http.post(
        Uri.parse(
          '$baseUrl/api/diagnosis/session/'
          '$_sessionId/matches',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'customerLocation': {
            'latitude': latitude,
            'longitude': longitude,
          },
          'budget': 2000,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to find professionals '
          '(${response.statusCode})',
        );
      }

      final body = jsonDecode(response.body);

      if (body['success'] != true) {
        throw Exception(
          body['message'] ??
              'Unable to find professionals.',
        );
      }

      final data = body['data'];

      setState(() {
        _matches =
            List<dynamic>.from(
          data['matches'] ?? [],
        );

        _findingProfessionals = false;
      });
    } catch (e) {
      debugPrint('Provider matching error: $e');

      setState(() {
        _findingProfessionals = false;
        _error =
            'Unable to find nearby professionals.';
      });
    }
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text(
          'AI Diagnosis',
          style: AppTextStyles.title,
        ),

        centerTitle: true,
      ),

      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return _buildLoading(
        'Analyzing your problem...',
      );
    }

    if (_findingProfessionals) {
      return _buildLoading(
        'Finding the best professionals...',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        30,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildHeader(),

          const SizedBox(height: 20),

          _buildProblemCard(),

          const SizedBox(height: 18),

          if (_error != null)
            _buildErrorCard(),

          if (_diagnosis != null)
            _buildDiagnosisCard(),

          const SizedBox(height: 20),

          if (_question != null)
            _buildQuestionCard(),

          if (_question == null &&
              _matches.isNotEmpty)
            _buildMatches(),

          if (_question == null &&
              _matches.isEmpty &&
              _error == null)
            _buildNoMatches(),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // LOADING
  // ------------------------------------------------------------

  Widget _buildLoading(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              padding:
                  const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child:
                  const CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'This may take a few seconds.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          _question != null
              ? 'Let’s understand the problem'
              : 'Here’s what we found',
          style: AppTextStyles.heading,
        ),

        const SizedBox(height: 6),

        Text(
          _question != null
              ? 'Answer a few questions so we can find the right professional.'
              : 'Our AI analyzed the problem you described.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // PROBLEM
  // ------------------------------------------------------------

  Widget _buildProblemCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border
              .withValues(alpha: 0.5),
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.primary
                  .withValues(alpha: 0.15),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.home_repair_service_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Problem',
                  style: TextStyle(
                    color:
                        AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  widget.problem,
                  style: TextStyle(
                    color:
                        AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // DIAGNOSIS
  // ------------------------------------------------------------

  Widget _buildDiagnosisCard() {
    final diagnosis =
        _diagnosis ?? {};

    final summary =
        diagnosis['problemSummary']
            ?.toString() ??
        'Analyzing problem...';

    final service =
        diagnosis['requiredService']
            ?.toString() ??
        'Home service';

    final urgency =
        diagnosis['urgency']
            ?.toString() ??
        'unknown';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary
                .withValues(alpha: 0.20),
            AppColors.card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: AppColors.primary
              .withValues(alpha: 0.35),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Text(
                'AI Diagnosis',
                style: TextStyle(
                  color:
                      AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            service,
            style: TextStyle(
              color:
                  AppColors.textPrimary,
              fontSize: 21,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            summary,
            style: TextStyle(
              color:
                  AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _infoItem(
                  Icons.category_rounded,
                  'Category',
                  diagnosis['subcategory']
                          ?.toString() ??
                      diagnosis['category']
                          ?.toString() ??
                      'Unknown',
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _infoItem(
                  Icons.warning_amber_rounded,
                  'Urgency',
                  urgency,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color: AppColors.background
            .withValues(alpha: 0.45),
        borderRadius:
            BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),

          const SizedBox(height: 7),

          Text(
            title,
            style: TextStyle(
              color:
                  AppColors.textSecondary,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value,
            maxLines: 2,
            overflow:
                TextOverflow.ellipsis,
            style: TextStyle(
              color:
                  AppColors.textPrimary,
              fontWeight:
                  FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // QUESTION
  // ------------------------------------------------------------

  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary
              .withValues(alpha: 0.25),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.help_outline_rounded,
                color: AppColors.primary,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  'One more thing',
                  style: TextStyle(
                    color:
                        AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            _question!,
            style: TextStyle(
              color:
                  AppColors.textPrimary,
              fontSize: 16,
              fontWeight:
                  FontWeight.w600,
              height: 1.4,
            ),
          ),

          if (_questionPurpose != null) ...[
            const SizedBox(height: 8),

            Text(
              _questionPurpose!,
              style: TextStyle(
                color:
                    AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],

          const SizedBox(height: 18),

          TextField(
            controller: _answerController,
            enabled: !_sendingAnswer,
            maxLines: 3,

            style: TextStyle(
              color:
                  AppColors.textPrimary,
            ),

            decoration: InputDecoration(
              hintText:
                  'Type your answer...',
              hintStyle: TextStyle(
                color:
                    AppColors.textSecondary,
              ),

              filled: true,
              fillColor:
                  AppColors.background,

              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),

              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
                borderSide:
                    const BorderSide(
                  color:
                      AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 52,

            child: ElevatedButton(
              onPressed:
                  _sendingAnswer
                      ? null
                      : _submitAnswer,

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
                foregroundColor:
                    Colors.white,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
              ),

              child: _sendingAnswer
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // MATCHES
  // ------------------------------------------------------------

  Widget _buildMatches() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended Professionals',
          style: TextStyle(
            color:
                AppColors.textPrimary,
            fontSize: 19,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          '${_matches.length} professionals found',
          style: TextStyle(
            color:
                AppColors.textSecondary,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 14),

        ..._matches
            .map(
              (match) =>
                  _buildProviderCard(
                Map<String, dynamic>.from(
                  match,
                ),
              ),
            )
            // .toList(),
      ],
    );
  }

Widget _buildProviderCard(
  Map<String, dynamic> match,
) {
  final provider =
      Map<String, dynamic>.from(
    match['provider'] ?? {},
  );

  final score =
      (match['score'] as num?)?.toDouble() ?? 0;

  final distance =
      (match['distanceKm'] as num?)?.toDouble() ?? 0;

  final skills =
      List<String>.from(
    match['matchedSkills'] ?? [],
  );

  final name =
      provider['name']?.toString() ?? 'Professional';

  final rating =
      (provider['rating'] as num?)?.toDouble() ?? 0;

  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: AppColors.border.withValues(alpha: 0.5),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${score.toStringAsFixed(1)}% match',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            const Icon(
              Icons.star_rounded,
              size: 17,
              color: Color(0xFFFFC857),
            ),

            const SizedBox(width: 5),

            Text(
              rating.toStringAsFixed(1),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),

            const SizedBox(width: 18),

            const Icon(
              Icons.location_on_outlined,
              size: 17,
              color: AppColors.primary,
            ),

            const SizedBox(width: 5),

            Text(
              '${distance.toStringAsFixed(1)} km away',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),

        if (skills.isNotEmpty) ...[
          const SizedBox(height: 12),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: skills.take(3).map(
              (skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ],

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
          onPressed: () {
            final professional = ProfessionalModel(
              id: provider['id']?.toString() ?? '',
              name: provider['name']?.toString() ?? 'Professional',
              category: provider['generalServices'] is List &&
                      (provider['generalServices'] as List).isNotEmpty
                  ? (provider['generalServices'] as List).first.toString()
                  : 'Home Services',
              specialty:
                  provider['generalServices'] is List &&
                          (provider['generalServices'] as List).isNotEmpty
                      ? (provider['generalServices'] as List).join(', ')
                      : 'Home Service',
              rating: rating,
              reviewCount:
                  (provider['reviewCount'] as num?)?.toInt() ?? 0,
              trustScore: score.round(),
              completedRepairs:
                  (provider['totalJobs'] as num?)?.toInt() ?? 0,
              distance: '${distance.toStringAsFixed(1)} km',
              latitude:
                  (provider['latitude'] as num?)?.toDouble() ?? 0,
              longitude:
                  (provider['longitude'] as num?)?.toDouble() ?? 0,
              phoneNumber:
                  provider['phone']?.toString() ?? '',
              address: 'Local Service Provider',
              experienceYears:
                  (provider['yearsExperience'] as num?)?.toInt() ?? 0,
              pricingStartingAt:
                  '₹${(provider['minimumPrice'] as num?)?.toInt() ?? 0}',
              aiReviewSummary:
                  skills.isNotEmpty
                      ? 'Matched expertise: ${skills.join(', ')}'
                      : 'Recommended based on your AI diagnosis.',
              isSaved: false,
              isVerified: true,
              services: const [],
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfessionalDetailsScreen(
                  professional: professional,
                ),
              ),
            );
          },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: AppColors.primary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'View Professional',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  // Widget _buildProviderCard(
  //   Map<String, dynamic> match,
  // ) {
  //   final providerId =
  //       match['providerId']?.toString() ?? '';

  //   final score =
  //       match['score']?.toString() ?? '0';

  //   final distance =
  //       (match['distanceKm'] as num?)?.toDouble() ?? 0;

  //   final skills =
  //       List<String>.from(
  //     match['matchedSkills'] ?? [],
  //   );

  //   final provider =
  //       Map<String, dynamic>.from(
  //     match['provider'] ?? {},
  //   );

  //   return Container(
  //     width: double.infinity,
  //     margin:
  //         const EdgeInsets.only(bottom: 12),
  //     padding:
  //         const EdgeInsets.all(17),

  //     decoration: BoxDecoration(
  //       color: AppColors.card,
  //       borderRadius:
  //           BorderRadius.circular(18),
  //       border: Border.all(
  //         color: AppColors.border
  //             .withValues(alpha: 0.5),
  //       ),
  //     ),

  //     child: Column(
  //       crossAxisAlignment:
  //           CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               width: 46,
  //               height: 46,
  //               decoration: BoxDecoration(
  //                 color: AppColors.primary
  //                     .withValues(alpha: 0.15),
  //                 shape: BoxShape.circle,
  //               ),
  //               child: const Icon(
  //                 Icons.person_rounded,
  //                 color: AppColors.primary,
  //               ),
  //             ),

  //             const SizedBox(width: 12),

  //             Expanded(
  //               child: Text(
  //                 provider['name']?.toString() ?? 'Professional',
  //                 style: TextStyle(
  //                   color:
  //                       AppColors.textPrimary,
  //                   fontSize: 16,
  //                   fontWeight:
  //                       FontWeight.bold,
  //                 ),
  //               ),
  //             ),

  //             Container(
  //               padding:
  //                   const EdgeInsets.symmetric(
  //                 horizontal: 9,
  //                 vertical: 5,
  //               ),
  //               decoration: BoxDecoration(
  //                 color: AppColors.primary
  //                     .withValues(alpha: 0.15),
  //                 borderRadius:
  //                     BorderRadius.circular(10),
  //               ),
  //               child: Text(
  //                 '${double.tryParse(score)?.toStringAsFixed(1) ?? score}% match',
  //                 style: const TextStyle(
  //                   color:
  //                       AppColors.primary,
  //                   fontSize: 11,
  //                   fontWeight:
  //                       FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),

  //         const SizedBox(height: 14),

  //         Row(
  //           children: [
  //             const Icon(
  //               Icons.location_on_outlined,
  //               size: 17,
  //               color: AppColors.primary,
  //             ),

  //             const SizedBox(width: 5),

  //             Text(
  //               '${distance.toStringAsFixed(1)} km away',
  //               style: TextStyle(
  //                 color:
  //                     AppColors.textSecondary,
  //                 fontSize: 13,
  //               ),
  //             ),
  //           ],
  //         ),

  //         if (skills.isNotEmpty) ...[
  //           const SizedBox(height: 12),

  //           Wrap(
  //             spacing: 6,
  //             runSpacing: 6,
  //             children: skills
  //                 .take(3)
  //                 .map(
  //                   (skill) => Container(
  //                     padding:
  //                         const EdgeInsets
  //                             .symmetric(
  //                       horizontal: 9,
  //                       vertical: 5,
  //                     ),
  //                     decoration:
  //                         BoxDecoration(
  //                       color: AppColors
  //                           .background,
  //                       borderRadius:
  //                           BorderRadius
  //                               .circular(
  //                         8,
  //                       ),
  //                     ),
  //                     child: Text(
  //                       skill,
  //                       style: TextStyle(
  //                         color: AppColors
  //                             .textSecondary,
  //                         fontSize: 11,
  //                       ),
  //                     ),
  //                   ),
  //                 )
  //                 .toList(),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  // ------------------------------------------------------------
  // ERROR
  // ------------------------------------------------------------

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(bottom: 18),
      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.red
            .withValues(alpha: 0.10),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red
              .withValues(alpha: 0.25),
        ),
      ),

      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
              ),
            ),
          ),

          TextButton(
            onPressed: _startDiagnosis,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMatches() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: const Text(
        'No suitable professionals were found.',
        style: TextStyle(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}