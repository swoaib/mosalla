import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../model/feedback_model.dart';
import '../providers/theme_provider.dart';
import '../repositories/mosalla_repository.dart';

class FeedbackBottomSheet extends StatefulWidget {
  final String? title;

  const FeedbackBottomSheet({super.key, this.title});

  @override
  State<FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<FeedbackBottomSheet> {
  final _contentController = TextEditingController();
  final _emailController = TextEditingController();
  final _repository = MosallaRepository();
  bool _isSubmitting = false;
  String? _errorMessage;

  void _submit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final l10n = AppLocalizations.of(context)!;

    try {
      final feedback = FeedbackModel(
        content: content,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        timestamp: DateTime.now(),
      );

      await _repository.submitFeedback(feedback);

      if (mounted) {
        Navigator.pop(context); // Pop current sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.feedbackThanks),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Error sending feedback: $e');
        setState(() {
          _errorMessage = l10n.feedbackError;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider?>(context);
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final isTealTheme = (themeProvider?.isTealTheme ?? false) ||
        scaffoldBg == Colors.teal ||
        scaffoldBg == const Color(0xFF00695C);

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isTealTheme ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Center(
              child: Text(
                widget.title ?? l10n.feedbackTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isTealTheme ? Colors.white : null,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: isTealTheme ? Colors.white : null),
              decoration: InputDecoration(
                filled: isTealTheme,
                fillColor: isTealTheme
                    ? Colors.white.withValues(alpha: 0.12)
                    : null,
                labelText: l10n.feedbackOptionalEmail,
                labelStyle: TextStyle(
                    color: isTealTheme ? Colors.white70 : null),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: isTealTheme
                      ? BorderSide(
                          color: Colors.white.withValues(alpha: 0.2))
                      : const BorderSide(),
                ),
                enabledBorder: isTealTheme
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2)),
                      )
                    : null,
                focusedBorder: isTealTheme
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF00BFA5), width: 1.5),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 5,
              maxLength: 500,
              style: TextStyle(color: isTealTheme ? Colors.white : null),
              decoration: InputDecoration(
                filled: isTealTheme,
                fillColor: isTealTheme
                    ? Colors.white.withValues(alpha: 0.12)
                    : null,
                hintText: l10n.feedbackHint,
                hintStyle: TextStyle(
                    color: isTealTheme ? Colors.white38 : null),
                counterStyle: TextStyle(
                    color: isTealTheme ? Colors.white54 : null),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: isTealTheme
                      ? BorderSide(
                          color: Colors.white.withValues(alpha: 0.2))
                      : const BorderSide(),
                ),
                enabledBorder: isTealTheme
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2)),
                      )
                    : null,
                focusedBorder: isTealTheme
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF00BFA5), width: 1.5),
                      )
                    : null,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isTealTheme ? const Color(0xFF00BFA5) : null,
                foregroundColor: isTealTheme ? Colors.black87 : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.submitFeedback, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
