import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_theme.dart';
import '../../../data/models/message_model.dart';
import '../../../data/providers/message_provider.dart';

import 'chat_screen.dart';
import '../../../data/providers/roommate_provider.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final msgProvider = context.watch<MessageProvider>();
    final conversations = msgProvider.conversations;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Messages',
                    style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.edit_outlined, color: AppColors.textDark, size: 20),
                  ),
                ],
              ).animate().fade(duration: 400.ms),
            ),
            const SizedBox(height: 16),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textLight),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ).animate().fade(duration: 400.ms, delay: 50.ms),
            ),
            const SizedBox(height: 16),
            _buildGroupChatBanner(context, context.watch<RoommateProvider>(), msgProvider),

            // Unread badge
            if (msgProvider.totalUnread > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${msgProvider.totalUnread}',
                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'unread messages',
                        style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                    ],
                  ),
                ).animate().fade(duration: 400.ms, delay: 100.ms),
              ),

            const SizedBox(height: 8),

            // Conversations list
            Expanded(
              child: conversations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(color: AppColors.cardBg, shape: BoxShape.circle),
                            child: const Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppColors.textLight),
                          ),
                          const SizedBox(height: 16),
                          Text('No conversations yet', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                          Text('Match with someone to start chatting', style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textMedium)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      itemCount: conversations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 2),
                      itemBuilder: (context, i) {
                        final conv = conversations[i];
                        return _ConversationTile(
                          conversation: conv,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(conversation: conv),
                              ),
                            );
                          },
                        ).animate().fade(duration: 400.ms, delay: (50 * i).ms).slideX(begin: 0.05);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupChatBanner(BuildContext context, RoommateProvider roommateProvider, MessageProvider msgProvider) {
    final hasGroup = msgProvider.conversations.any((c) => c.id == 'group_roommates');
    if (roommateProvider.roommateIds.isEmpty || hasGroup) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              height: 36,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 14,
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400'),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 14,
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Roommate Group Chat',
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  Text(
                    'Start chatting with all roommates',
                    style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 11),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                msgProvider.startRoommateGroup(roommateProvider.roommateIds);
                final groupConv = msgProvider.conversations.firstWhere((c) => c.id == 'group_roommates');
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ChatScreen(conversation: groupConv)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text(
                'Create',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ],
        ),
      ).animate().fade(duration: 400.ms).slideY(begin: -0.1),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final lastMsg = conversation.lastMessage;
    final hasUnread = conversation.unreadCount > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasUnread ? AppColors.primary.withOpacity(0.03) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasUnread ? AppColors.primary.withOpacity(0.15) : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(conversation.otherUserPhoto),
                  backgroundColor: AppColors.cardBg,
                ),
                if (conversation.isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              conversation.otherUserName,
                              style: GoogleFonts.outfit(
                                fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                                fontSize: 15,
                                color: AppColors.textDark,
                              ),
                            ),
                            if (conversation.otherUserVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified_rounded, size: 14, color: AppColors.verified),
                            ],
                          ],
                        ),
                      ),
                      if (lastMsg != null)
                        Text(
                          timeago.format(lastMsg.timestamp),
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: hasUnread ? AppColors.primary : AppColors.textLight,
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMsg?.text ?? 'Start a conversation',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: hasUnread ? AppColors.textDark : AppColors.textMedium,
                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${conversation.unreadCount}',
                              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: AppColors.matchGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${(conversation.compatibility * 100).toInt()}% match',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
