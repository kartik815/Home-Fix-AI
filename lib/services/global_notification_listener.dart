import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../screens/notifications/notifications_screen.dart';

class GlobalNotificationListener extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const GlobalNotificationListener({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  State<GlobalNotificationListener> createState() =>
      _GlobalNotificationListenerState();
}

class _GlobalNotificationListenerState
    extends State<GlobalNotificationListener> {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _notificationSubscription;

  StreamSubscription<User?>? _authSubscription;

  OverlayEntry? _notificationOverlay;
  Timer? _hideTimer;

  String? _currentUserId;

  @override
  void initState() {
    super.initState();

    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen(_handleAuthChange);

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _startNotificationListener(user);
    }
  }

  void _handleAuthChange(User? user) {
    _stopNotificationListener();

    if (user != null) {
      _startNotificationListener(user);
    }
  }

  void _startNotificationListener(User user) {
    if (_currentUserId == user.uid) {
      return;
    }

    _currentUserId = user.uid;

    debugPrint(
      '🔔 Starting notification listener for ${user.uid}',
    );

    final notificationsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true);

    bool firstSnapshot = true;

    _notificationSubscription = notificationsRef.snapshots().listen(
      (snapshot) {
        debugPrint(
          '🔔 Notification snapshot received: '
          '${snapshot.docs.length} documents',
        );

        // Ignore notifications that already existed
        // when the listener started.
        if (firstSnapshot) {
          firstSnapshot = false;

          debugPrint(
            '🔔 Initial notifications ignored.',
          );

          return;
        }

        for (final change in snapshot.docChanges) {
          debugPrint(
            '🔔 Firestore change: ${change.type} '
            'ID: ${change.doc.id}',
          );

          if (change.type == DocumentChangeType.added) {
            _showNotification(change.doc);
          }
        }
      },
      onError: (error) {
        debugPrint(
          '❌ Global notification listener error: $error',
        );
      },
    );
  }

  void _showNotification(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      return;
    }

    final title =
        data['title']?.toString() ?? 'New Notification';

    final message =
        data['message']?.toString() ?? '';

    debugPrint(
      '🔔 Showing popup: $title - $message',
    );

    final overlay =
        widget.navigatorKey.currentState?.overlay;

    if (overlay == null) {
      debugPrint(
        '❌ Root navigator overlay is not available.',
      );
      return;
    }

    // Remove an existing popup if another notification arrives.
    _notificationOverlay?.remove();
    _notificationOverlay = null;

    _hideTimer?.cancel();

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return _TopNotificationPopup(
          title: title,
          message: message,
          onTap: () {
            if (entry.mounted) {
              entry.remove();
            }

            if (_notificationOverlay == entry) {
              _notificationOverlay = null;
            }

            widget.navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (_) =>
                    const NotificationsScreen(),
              ),
            );
          },
          onDismissed: () {
            if (entry.mounted) {
              entry.remove();
            }

            if (_notificationOverlay == entry) {
              _notificationOverlay = null;
            }
          },
        );
      },
    );

    _notificationOverlay = entry;

    overlay.insert(entry);

    _hideTimer = Timer(
      const Duration(seconds: 3),
      () {
        if (entry.mounted) {
          entry.remove();
        }

        if (_notificationOverlay == entry) {
          _notificationOverlay = null;
        }
      },
    );
  }

  void _stopNotificationListener() {
    _notificationSubscription?.cancel();
    _notificationSubscription = null;

    _hideTimer?.cancel();
    _hideTimer = null;

    _notificationOverlay?.remove();
    _notificationOverlay = null;

    _currentUserId = null;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();

    _stopNotificationListener();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _TopNotificationPopup extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _TopNotificationPopup({
    required this.title,
    required this.message,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  State<_TopNotificationPopup> createState() =>
      _TopNotificationPopupState();
}

class _TopNotificationPopupState
    extends State<_TopNotificationPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding =
        MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 8,
      left: 12,
      right: 12,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border
                        .withValues(alpha: 0.45),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary
                            .withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color:
                                  AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),

                          if (widget.message.isNotEmpty) ...[
                            const SizedBox(height: 4),

                            Text(
                              widget.message,
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                color:
                                    AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}