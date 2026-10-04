import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {


  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    debugPrint('CURRENT USER UID: ${user?.uid}');
    debugPrint('CURRENT USER EMAIL: ${user?.email}');
  }
  // ------------------------------------------------------------
  // CURRENT USER
  // ------------------------------------------------------------

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  // ------------------------------------------------------------
  // REAL-TIME FIRESTORE STREAM
  // ------------------------------------------------------------

  Stream<QuerySnapshot<Map<String, dynamic>>> _notificationStream() {
    final user = _currentUser;

    if (user == null) {
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ------------------------------------------------------------
  // NOTIFICATION ICON
  // ------------------------------------------------------------

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'diagnosis':
        return Icons.check_circle_outline_rounded;

      case 'professional':
        return Icons.person_search_outlined;

      case 'offer':
        return Icons.local_offer_outlined;

      case 'saved':
        return Icons.bookmark_outline_rounded;

      case 'reminder':
        return Icons.notifications_active_outlined;

      default:
        return Icons.notifications_outlined;
    }
  }

  // ------------------------------------------------------------
  // FORMAT TIME
  // ------------------------------------------------------------

  String _formatTime(dynamic timestamp) {
    if (timestamp is! Timestamp) {
      return '';
    }

    final date = timestamp.toDate();
    final difference = DateTime.now().difference(date);

    if (difference.isNegative) {
      return 'Just now';
    }

    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }

    if (difference.inDays == 1) {
      return 'Yesterday';
    }

    return '${difference.inDays}d ago';
  }

  // ------------------------------------------------------------
  // CHECK WHETHER NOTIFICATION IS FROM TODAY
  // ------------------------------------------------------------

  bool _isToday(dynamic timestamp) {
    if (timestamp is! Timestamp) {
      return false;
    }

    final date = timestamp.toDate();
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // ------------------------------------------------------------
  // MARK ALL NOTIFICATIONS AS READ
  // ------------------------------------------------------------

  Future<void> _markAllAsRead() async {
    final user = _currentUser;

    if (user == null) {
      return;
    }

    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      if (query.docs.isEmpty) {
        return;
      }

      final batch = FirebaseFirestore.instance.batch();

      for (final document in query.docs) {
        batch.update(document.reference, {
          'isRead': true,
        });
      }

      await batch.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to mark notifications as read.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // MARK ONE NOTIFICATION AS READ
  // ------------------------------------------------------------

  Future<void> _markAsRead(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) async {
    final data = document.data();

    if (data == null || data['isRead'] == true) {
      return;
    }

    try {
      await document.reference.update({
        'isRead': true,
      });
    } catch (e) {
      // Keep the UI working even if the update fails.
    }
  }

  // ------------------------------------------------------------
  // BUILD NOTIFICATION CARD
  // ------------------------------------------------------------

  Widget _buildNotificationCard(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    final title = data['title']?.toString() ?? '';
    final message = data['message']?.toString() ?? '';
    final type = data['type']?.toString();
    final createdAt = data['createdAt'];
    final isUnread = data['isRead'] == false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _markAsRead(document),
        child: NotificationCard(
          icon: _getNotificationIcon(type),
          title: title,
          message: message,
          time: _formatTime(createdAt),
          isUnread: isUnread,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ----------------------------------------------------------
      // APP BAR
      // ----------------------------------------------------------

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),

        title: const Text(
          'Notifications',
          style: AppTextStyles.title,
        ),

        actions: [
          IconButton(
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
            icon: const Icon(
              Icons.done_all_rounded,
              color: AppColors.primary,
            ),
          ),
        ],
      ),

      // ----------------------------------------------------------
      // REAL-TIME FIRESTORE DATA
      // ----------------------------------------------------------

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _notificationStream(),

        builder: (context, snapshot) {

          debugPrint(
            'NOTIFICATION SNAPSHOT: '
            'state=${snapshot.connectionState}, '
            'docs=${snapshot.data?.docs.length}, '
            'error=${snapshot.error}',
);
          // ------------------------------------------------------
          // LOADING
          // ------------------------------------------------------

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          // ------------------------------------------------------
          // ERROR
          // ------------------------------------------------------

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.primary,
                      size: 48,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Unable to load notifications.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Please check your Firebase connection and try again.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
            );
          }

          // ------------------------------------------------------
          // NO USER LOGGED IN
          // ------------------------------------------------------

          if (_currentUser == null) {
            return Center(
              child: Text(
                'Please log in to view notifications.',
                style: AppTextStyles.bodySecondary,
              ),
            );
          }

          // ------------------------------------------------------
          // GET NOTIFICATIONS
          // ------------------------------------------------------

          final notifications = snapshot.data?.docs ?? [];

          // ------------------------------------------------------
          // EMPTY STATE
          // ------------------------------------------------------

          if (notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.primary,
                        size: 34,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      'No notifications yet',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'We will notify you when something important happens.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
            );
          }

          // ------------------------------------------------------
          // SEPARATE TODAY AND EARLIER
          // ------------------------------------------------------

          final todayNotifications = notifications
              .where(
                (document) =>
                    _isToday(document.data()['createdAt']),
              )
              .toList();

          final earlierNotifications = notifications
              .where(
                (document) =>
                    !_isToday(document.data()['createdAt']),
              )
              .toList();

          // ------------------------------------------------------
          // BUILD SCREEN CONTENT
          // ------------------------------------------------------

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            children: [
              // ====================================================
              // TODAY
              // ====================================================

              if (todayNotifications.isNotEmpty) ...[
                Text(
                  'Today',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                ...todayNotifications.map(
                  _buildNotificationCard,
                ),

                if (earlierNotifications.isNotEmpty)
                  const SizedBox(height: 16),
              ],

              // ====================================================
              // EARLIER
              // ====================================================

              if (earlierNotifications.isNotEmpty) ...[
                Text(
                  'Earlier',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                ...earlierNotifications.map(
                  _buildNotificationCard,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ==================================================================
// NOTIFICATION CARD
// ==================================================================

class NotificationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final bool isUnread;

  const NotificationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.card,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: isUnread
              ? AppColors.primary.withValues(alpha: 0.35)
              : AppColors.border.withValues(alpha: 0.35),
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------------------------------------------------------
          // ICON
          // --------------------------------------------------------

          Container(
            width: 46,
            height: 46,

            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(
              icon,
              color: AppColors.primary,
              size: 23,
            ),
          ),

          const SizedBox(width: 14),

          // --------------------------------------------------------
          // CONTENT
          // --------------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --------------------------------------------------
                // TITLE + UNREAD DOT
                // --------------------------------------------------

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    if (isUnread)
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(
                          top: 5,
                          left: 6,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                // --------------------------------------------------
                // MESSAGE
                // --------------------------------------------------

                Text(
                  message,
                  style: AppTextStyles.bodySecondary.copyWith(
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 8),

                // --------------------------------------------------
                // TIME
                // --------------------------------------------------

                Text(
                  time,
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}