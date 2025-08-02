import 'package:flutter/material.dart';
import '../features/common/domain/models/content_report.dart';
import '../features/common/data/services/report_service.dart';
import '../l10n/app_localizations.dart';
import 'text_widgets.dart';
import 'app_snackbar_widget.dart';

class ReportContentDialogWidget extends StatefulWidget {
  final String contentId;
  final ContentType contentType;
  final String contentSnapshot;
  final String contentTitle;

  const ReportContentDialogWidget({
    super.key,
    required this.contentId,
    required this.contentType,
    required this.contentSnapshot,
    required this.contentTitle,
  });

  @override
  State<ReportContentDialogWidget> createState() => _ReportContentDialogWidgetState();

  static Future<void> show({
    required BuildContext context,
    required String contentId,
    required ContentType contentType,
    required String contentSnapshot,
    required String contentTitle,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportContentDialogWidget(
        contentId: contentId,
        contentType: contentType,
        contentSnapshot: contentSnapshot,
        contentTitle: contentTitle,
      ),
    );
  }
}

class _ReportContentDialogWidgetState extends State<ReportContentDialogWidget> {
  final ReportService _reportService = ReportService();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  ReportType? _selectedReportType;
  bool _isSubmitting = false;
  bool _hasAlreadyReported = false;
  bool _showValidationErrors = false;

  @override
  void initState() {
    super.initState();
    _checkExistingReport();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingReport() async {
    final hasReported = await _reportService.hasUserReportedContent(widget.contentId);
    if (mounted) {
      setState(() {
        _hasAlreadyReported = hasReported;
      });
    }
  }

  Future<void> _submitReport() async {
    // Show validation errors if fields are not filled
    setState(() {
      _showValidationErrors = true;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if report type is selected
    if (_selectedReportType == null) {
      AppSnackBar.showError(
        context,
        AppLocalizations.of(context)!.pleaseSelectReportType,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _reportService.submitReport(
        contentId: widget.contentId,
        contentType: widget.contentType,
        reportType: _selectedReportType!,
        description: _descriptionController.text.trim(),
        contentSnapshot: widget.contentSnapshot,
      );

      if (mounted) {
        AppSnackBar.showSuccess(
          context,
          AppLocalizations.of(context)!.reportSubmittedSuccessfully,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          AppLocalizations.of(context)!.errorSubmittingReport,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _getReportTypeLabel(ReportType type) {
    switch (type) {
      case ReportType.inappropriate:
        return AppLocalizations.of(context)!.reportTypeInappropriate;
      case ReportType.incorrect:
        return AppLocalizations.of(context)!.reportTypeIncorrect;
      case ReportType.harmful:
        return AppLocalizations.of(context)!.reportTypeHarmful;
      case ReportType.spam:
        return AppLocalizations.of(context)!.reportTypeSpam;
      case ReportType.other:
        return AppLocalizations.of(context)!.reportTypeOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              TitleLargeText(
                AppLocalizations.of(context)!.reportContent,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Content title
              BodyMediumText(
                widget.contentTitle,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Required fields note
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: BodySmallText(
                        AppLocalizations.of(context)!.requiredFieldsNote,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (_hasAlreadyReported) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BodyMediumText(
                          AppLocalizations.of(context)!.alreadyReportedContent,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Report type selection
              Row(
                children: [
                  TitleMediumText(
                    AppLocalizations.of(context)!.selectReportReason,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '*',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Show error if no report type selected
              if (_showValidationErrors && _selectedReportType == null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: BodySmallText(
                          AppLocalizations.of(context)!.pleaseSelectReportType,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),

              ...ReportType.values.map((type) => RadioListTile<ReportType>(
                    value: type,
                    groupValue: _selectedReportType,
                    onChanged: _hasAlreadyReported ? null : (value) {
                      setState(() {
                        _selectedReportType = value;
                      });
                    },
                    title: BodyMediumText(_getReportTypeLabel(type)),
                    activeColor: Theme.of(context).colorScheme.secondary,
                  )),

              const SizedBox(height: 24),

              // Description field
              Row(
                children: [
                  TitleMediumText(
                    AppLocalizations.of(context)!.additionalDetails,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '*',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descriptionController,
                enabled: !_hasAlreadyReported && !_isSubmitting,
                maxLines: 4,
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.pleaseProvideDescription;
                  }
                  if (value.trim().length < 10) {
                    return AppLocalizations.of(context)!.descriptionTooShort;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.describeIssue,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: BodyMediumText(
                        AppLocalizations.of(context)!.cancel,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_isSubmitting || _hasAlreadyReported) ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.onError,
                              ),
                            )
                          : BodyMediumText(
                              AppLocalizations.of(context)!.submitReport,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onError,
                            ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Disclaimer
              BodySmallText(
                AppLocalizations.of(context)!.reportDisclaimer,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                textAlign: TextAlign.center,
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}