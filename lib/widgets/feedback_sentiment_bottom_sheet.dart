import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import '../l10n/generated/app_localizations.dart';
import 'feedback_bottom_sheet.dart';

class FeedbackSentimentBottomSheet extends StatelessWidget {
  const FeedbackSentimentBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.feedbackSentimentTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSentimentOption(
                  context,
                  icon: Icons.sentiment_dissatisfied_rounded,
                  color: const Color(0xFFE57373), // Red 300
                  label: l10n.feedbackSentimentSad,
                  onTap: () {
                    Navigator.pop(context); // Pop current sheet
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => FeedbackBottomSheet(
                        title: l10n.feedbackImprovementTitle,
                      ),
                    );
                  },
                ),
                _buildSentimentOption(
                  context,
                  icon: Icons.sentiment_neutral_rounded,
                  color: const Color(0xFFFFB74D), // Orange 300
                  label: l10n.feedbackSentimentNeutral,
                  onTap: () {
                    Navigator.pop(context); // Pop current sheet
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => FeedbackBottomSheet(
                        title: l10n.feedbackImprovementTitle,
                      ),
                    );
                  },
                ),
                _buildSentimentOption(
                  context,
                  icon: Icons.sentiment_very_satisfied_rounded,
                  color: const Color(0xFF81C784), // Green 300
                  label: l10n.feedbackSentimentHappy,
                  onTap: () async {
                    Navigator.pop(context); // Pop current sheet
                    final InAppReview inAppReview = InAppReview.instance;

                    if (await inAppReview.isAvailable()) {
                      await inAppReview.requestReview();
                    } else {
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.reviewAlertTitle),
                            content: Text(l10n.reviewAlertBody),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(l10n.cancel),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // Update with Mosalla's actual App Store ID when known if you want deep linking
                                  // const appStoreId = '...'; 
                                  inAppReview.openStoreListing();
                                },
                                child: Text(l10n.reviewAlertAction),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentOption(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.3),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).cardColor,
            ),
            child: Icon(icon, size: 48, color: iconColor),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
