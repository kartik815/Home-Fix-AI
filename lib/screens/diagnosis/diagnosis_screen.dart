import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/diagnosis_api_service.dart';
import '../maps/nearby_professionals_map_screen.dart';

class DiagnosisScreen extends StatefulWidget {
  final String problem;

  const DiagnosisScreen({super.key, required this.problem});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  final DiagnosisApiService _diagnosisApi = DiagnosisApiService();
  final TextEditingController _answerController = TextEditingController();

  String? _sessionId;
  String? _question;
  String? _questionPurpose;
  Map<String, dynamic>? _diagnosis;
  String? _error;
  bool _loading = true;
  bool _sendingAnswer = false;
  bool _notificationCreated = false;

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

  Future<void> _startDiagnosis() async {
    setState(() {
      _loading = true;
      _error = null;
      _sessionId = null;
      _diagnosis = null;
      _question = null;
      _questionPurpose = null;
      _notificationCreated = false;
    });

    try {
      final data = await _diagnosisApi.startDiagnosis(widget.problem);
      final sessionId = data['sessionId'];
      if (sessionId is! String || sessionId.isEmpty) {
        throw const FormatException('Diagnosis session ID is missing.');
      }
      _sessionId = sessionId;
      await _applySessionData(data);
    } catch (error) {
      debugPrint('Start diagnosis error: $error');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error =
            'Unable to connect to the AI diagnosis service. Check that the backend is running and try again.';
      });
    }
  }

  Future<void> _submitAnswer() async {
    final answer = _answerController.text.trim();
    final sessionId = _sessionId;
    if (answer.isEmpty || sessionId == null || _sendingAnswer) return;

    setState(() {
      _sendingAnswer = true;
      _error = null;
    });

    try {
      final data = await _diagnosisApi.answerQuestion(sessionId, answer);
      _answerController.clear();
      await _applySessionData(data);
    } catch (error) {
      debugPrint('Answer diagnosis error: $error');
      if (!mounted) return;
      setState(() {
        _sendingAnswer = false;
        _error = 'Unable to process your answer. Please try again.';
      });
    }
  }

  Future<void> _applySessionData(Map<String, dynamic> data) async {
    final rawDiagnosis = data['diagnosis'];
    if (rawDiagnosis is! Map) {
      throw const FormatException('Diagnosis data is missing.');
    }

    final diagnosis = Map<String, dynamic>.from(rawDiagnosis);
    final question = data['question']?.toString();
    final questionPurpose = data['questionPurpose']?.toString();
    final isComplete = data['status'] == 'complete';

    if (!mounted) return;
    setState(() {
      _diagnosis = diagnosis;
      _question = question;
      _questionPurpose = questionPurpose;
      _loading = false;
      _sendingAnswer = false;
      _error = null;
    });

    if (isComplete) {
      await _createDiagnosisNotification(diagnosis);
    }
  }

  Future<void> _createDiagnosisNotification(
    Map<String, dynamic> diagnosis,
  ) async {
    if (_notificationCreated) return;
    _notificationCreated = true;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('No logged-in user. Diagnosis notification not created.');
      return;
    }

    try {
      final service = diagnosis['requiredService']?.toString();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .add({
            'title': 'Diagnosis Complete',
            'message': service == null || service.isEmpty
                ? 'Your home problem diagnosis is ready.'
                : 'Your $service diagnosis is ready.',
            'type': 'diagnosis',
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (error) {
      debugPrint('Failed to create diagnosis notification: $error');
    }
  }

  String _categoryForMap() {
    switch (_diagnosis?['category']?.toString().toLowerCase()) {
      case 'electrical':
        return 'Electrical';
      case 'plumbing':
        return 'Plumbing';
      case 'hvac':
        return 'AC Repair';
      case 'appliance':
        return 'Appliances';
      default:
        return 'All';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('AI Diagnosis', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _loading
            ? _buildLoading()
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildProblemCard(),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      _buildErrorCard(),
                    ],
                    if (_diagnosis != null) ...[
                      const SizedBox(height: 18),
                      _buildDiagnosisCard(_diagnosis!),
                      const SizedBox(height: 16),
                      _buildUrgencyCard(
                        _diagnosis!['urgency']?.toString() ?? 'unknown',
                      ),
                      _buildSymptoms(_diagnosis!['symptoms']),
                    ],
                    if (_question != null) ...[
                      const SizedBox(height: 18),
                      _buildQuestionCard(),
                    ],
                    if (_question == null && _diagnosis != null) ...[
                      const SizedBox(height: 18),
                      _buildNextStepCard(_diagnosis!),
                      const SizedBox(height: 22),
                      _buildFindProfessionalsButton(),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 20),
            Text(
              'Analyzing your problem...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The AI may ask a few questions to understand it better.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final needsDetails = _question != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          needsDetails
              ? 'Let’s understand the problem'
              : 'Here’s what we found',
          style: AppTextStyles.heading,
        ),
        const SizedBox(height: 6),
        Text(
          needsDetails
              ? 'Answer a couple of questions so we can identify the right service.'
              : 'Our AI analyzed the details you provided.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildProblemCard() {
    return _card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBadge(Icons.home_repair_service_rounded),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Problem',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.problem.isEmpty
                      ? 'No problem described'
                      : widget.problem,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisCard(Map<String, dynamic> diagnosis) {
    final service =
        diagnosis['requiredService']?.toString().trim().isNotEmpty == true
        ? diagnosis['requiredService'].toString()
        : 'Home service';
    final summary =
        diagnosis['problemSummary']?.toString().trim().isNotEmpty == true
        ? diagnosis['problemSummary'].toString()
        : 'The AI could not confidently summarize the problem yet.';
    final category =
        diagnosis['subcategory']?.toString().trim().isNotEmpty == true
        ? diagnosis['subcategory'].toString()
        : diagnosis['category']?.toString() ?? 'unknown';
    final isComplete = _question == null;

    return _card(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBadge(Icons.auto_awesome_rounded),
              const SizedBox(width: 12),
              Text(
                isComplete ? 'AI Diagnosis' : 'Preliminary assessment',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            service,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            summary,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _infoItem(Icons.category_rounded, 'Category', category),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoItem(
                  Icons.warning_amber_rounded,
                  'Urgency',
                  diagnosis['urgency']?.toString() ?? 'unknown',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 7),
          Text(
            title,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyCard(String urgency) {
    final normalizedUrgency = urgency.toLowerCase();
    final isUrgent =
        normalizedUrgency == 'urgent' ||
        normalizedUrgency == 'emergency' ||
        normalizedUrgency == 'critical' ||
        normalizedUrgency == 'high';
    return _card(
      child: Row(
        children: [
          Icon(
            isUrgent ? Icons.priority_high_rounded : Icons.info_outline_rounded,
            color: isUrgent ? Colors.orange : AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Urgency is an AI estimate, not a confirmed technical diagnosis. '
              'Do not attempt dangerous repairs.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptoms(dynamic rawSymptoms) {
    final symptoms = rawSymptoms is List
        ? rawSymptoms.map((item) => item.toString()).toList()
        : <String>[];
    if (symptoms.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reported symptoms', style: _sectionTitleStyle),
          const SizedBox(height: 10),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: symptoms
                  .map(
                    (symptom) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              symptom,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('A quick follow-up', style: _sectionTitleStyle),
          if (_questionPurpose?.isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Text(
              _questionPurpose!,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            _question!,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _answerController,
            enabled: !_sendingAnswer,
            minLines: 1,
            maxLines: 3,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _submitAnswer(),
            decoration: InputDecoration(
              hintText: 'Type your answer',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _sendingAnswer ? null : _submitAnswer,
              icon: _sendingAnswer
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(_sendingAnswer ? 'Processing...' : 'Submit answer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepCard(Map<String, dynamic> diagnosis) {
    final service =
        diagnosis['requiredService']?.toString().trim().isNotEmpty == true
        ? diagnosis['requiredService'].toString()
        : 'A qualified home-service professional';
    return _card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Next step: consider contacting $service for an in-person '
              'inspection. This AI result is guidance, not a definitive diagnosis.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFindProfessionalsButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NearbyProfessionalsMapScreen(
                category: _categoryForMap(),
                initialProblem: widget.problem,
              ),
            ),
          );
        },
        icon: const Icon(Icons.location_on_rounded),
        label: const Text(
          'Find Nearby Professionals',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _error!,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _sessionId == null ? _startDiagnosis : _submitAnswer,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  Widget _iconBadge(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: AppColors.primary, size: 24),
    );
  }

  Widget _card({required Widget child, Color? color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color ?? AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: child,
    );
  }

  TextStyle get _sectionTitleStyle => TextStyle(
    color: AppColors.textPrimary,
    fontSize: 17,
    fontWeight: FontWeight.bold,
  );
}
