import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smedge/common_files/custom_container.dart';
import 'package:smedge/common_files/custom_elevated_button.dart';
import 'package:smedge/constants/numbers.dart';
import 'package:smedge/view/dash_board/screens/pos_financing_2.dart';
import '../../../common_files/utils.dart';
import '../../../provider/provider.dart';
import '../model/company_model.dart';

const _kStepTitles = ['COMPANY DETAILS', 'STEP 2', 'STEP 3'];

class PosFinancing1 extends ConsumerStatefulWidget {
  const PosFinancing1({super.key});

  @override
  ConsumerState<PosFinancing1> createState() => _PosFinancing1State();
}

class _PosFinancing1State extends ConsumerState<PosFinancing1> {
  final Set<String> _pickingInProgress = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardStateProvider).setContext(context);
      ref.read(dashboardStateProvider).setCurrentIndex(0);
    });
  }
  Future<void> _pickFile(String companyId) async {
    if (_pickingInProgress.contains(companyId)) return;
    setState(() => _pickingInProgress.add(companyId));

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file     = result.files.single;
        final sizeMB   = (file.size / 1048576).toStringAsFixed(2);
        final filePath = file.path ?? '';

        ref.read(dashboardStateProvider).uploadFileToCompany(
          companyId,
          file.name,
          double.parse(sizeMB),
          filePath,
        );
      }
    } finally {
      setState(() => _pickingInProgress.remove(companyId));
    }
  }

  void _showPreview(BuildContext context, CompanyModel company) {
    if (company.uploadedFilePath == null) return;
    final isPdf = company.uploadedFileName?.toLowerCase().endsWith('.pdf') ?? false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        company.uploadedFileName ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Preview content
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55,
                ),
                child:ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: Image.file(
                    File(company.uploadedFilePath!),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.broken_image_outlined,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Unable to preview image'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Footer actions
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _pickFile(company.id);
                        },
                        icon: const Icon(Icons.sync_alt_rounded, size: 16),
                        label: const Text('Replace'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                          Theme.of(context).colorScheme.primary,
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ref
                              .read(dashboardStateProvider)
                              .removeFileFromCompany(company.id);
                        },
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Remove'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE53935),
                          side: const BorderSide(color: Color(0xFFE53935)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state           = ref.watch(dashboardStateProvider);
    final companies       = state.companyList;
    final selectedId      = state.selectedCompanyId;
    final selectedCompany = state.selectedCompany;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title:Text(
          'Merchant Financing',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ) ,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStepIndicator(context, state.currentIndex),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: Numbers.DOUBLE_NUMBER_16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...companies.map((company) {
                      final isSelected = company.id == selectedId;
                      return _CompanyCard(
                        company: company,
                        isSelected: isSelected,
                        isPickingFile: _pickingInProgress.contains(company.id),
                        onSelect: () => ref
                            .read(dashboardStateProvider)
                            .setSelectedCompanyId(company.id),
                        onPickFile: () => _pickFile(company.id),
                        onReplaceFile: () => _pickFile(company.id),
                        onRemoveFile: () => ref
                            .read(dashboardStateProvider)
                            .removeFileFromCompany(company.id),
                        onPreviewFile: () => (company.uploadedFilePath!.contains(".pdf"))? Utils.openFile(File(company.uploadedFilePath!)):  _showPreview(context, company),
                      );
                    }),

                    SizedBox(height: Numbers.DOUBLE_NUMBER_8),
                    _buildInfoSection(
                      context: context,
                      title: 'Basic Information',
                      rows: [
                        _InfoRow('Company Name', selectedCompany.companyName),
                        _InfoRow('Website URL', selectedCompany.websiteUrl,
                            isLink: true),
                      ],
                    ),
                    SizedBox(height: Numbers.DOUBLE_NUMBER_16),
                    _buildInfoSection(
                      context: context,
                      title: 'Legal Information',
                      rows: [
                        _InfoRow('Trade License Number',
                            selectedCompany.tradeLicenseNumber),
                        _InfoRow('Incorporation Date',
                            selectedCompany.incorporationDate),
                        _InfoRow('Expiry Date', selectedCompany.expiryDate),
                        _InfoRow('Jurisdiction / Issuing Authority', "JAFZA"),
                      ],
                    ),
                    SizedBox(height: Numbers.DOUBLE_NUMBER_20),
                  ],
                ),
              ),
            ),
            _buildProceedButton(context, state),
          ],
        ),
      ),
    );
  }


  Widget _buildStepIndicator(BuildContext context, int currentStep) {
    final theme = Theme.of(context);
    final safe  = currentStep.clamp(0, _kStepTitles.length - 1);
    return Container(
      padding:  EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xffFBBC05),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(Numbers.DOUBLE_NUMBER_10),
                    topLeft: Radius.circular(Numbers.DOUBLE_NUMBER_10),
                    bottomRight: Radius.circular(Numbers.DOUBLE_NUMBER_10)
                  ),
                ),
                child: Text(
                  'Step ${safe + 1} of ${_kStepTitles.length}',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _kStepTitles[safe],
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
           SizedBox(height: Numbers.DOUBLE_NUMBER_8),
          Row(
            children: List.generate(_kStepTitles.length, (i) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                      right: i < _kStepTitles.length - 1 ? 4 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= safe
                        ? theme.colorScheme.primary
                        : Color(0xffDBEAFD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
           SizedBox(height: Numbers.DOUBLE_NUMBER_16),
          _buildSectionHeader(
            context: context,
            title: 'Select Company',
            action: 'Add Company',
            onAction: () {
              // TODO: push Add Company screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    String? action,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoSection({
    required BuildContext context,
    required String title,
    required List<_InfoRow> rows,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        CustomContainer(
         padding: Numbers.DOUBLE_NUMBER_8,
          child: Column(
            children: rows.asMap().entries.map((entry) {
              final i   = entry.key;
              final row = entry.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          row.label,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(color: theme.hintColor),
                        ),
                        Flexible(
                          child: Text(
                            row.value,
                            textAlign: TextAlign.right,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: row.isLink
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < rows.length - 1)
                    Divider(height: 1, color: Colors.black12),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProceedButton(BuildContext context, dynamic state) {
    final theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: EdgeInsets.fromLTRB(
        Numbers.DOUBLE_NUMBER_16,
        Numbers.DOUBLE_NUMBER_10,
        Numbers.DOUBLE_NUMBER_16,
        Numbers.DOUBLE_NUMBER_16,
      ),
      child: SizedBox(
        width: double.infinity,
        child: CustomElevatedButton(
          onPressed: () {
            // state.setCurrentIndex(state.currentIndex + 1);
             Navigator.push(context, MaterialPageRoute(
              builder: (_) => const POSFinancingScreen2()));
          },
          title: 'Proceed',
        ),
      ),
    );
  }
}


class _CompanyCard extends ConsumerWidget {
  final CompanyModel company;
  final bool isSelected;
  final bool isPickingFile;
  final VoidCallback onSelect;
  final VoidCallback onPickFile;
  final VoidCallback onReplaceFile;
  final VoidCallback onRemoveFile;
  final VoidCallback onPreviewFile;

  const _CompanyCard({
    required this.company,
    required this.isSelected,
    required this.isPickingFile,
    required this.onSelect,
    required this.onPickFile,
    required this.onReplaceFile,
    required this.onRemoveFile,
    required this.onPreviewFile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme   = Theme.of(context);
    final hasFile = company.uploadedFileName != null;

    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: EdgeInsets.only(bottom: Numbers.DOUBLE_NUMBER_10),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.black12,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Company info row ──
            Padding(
              padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_12),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: company.avatarColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        company.avatarLetter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: Numbers.DOUBLE_NUMBER_12),

                  // Name & ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company.name,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID: ${company.gstId}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.hintColor),
                        ),
                      ],
                    ),
                  ),

                  // Radio indicator
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.hintColor,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                        : null,
                  ),
                ],
              ),
            ),

            // ── File area (only on selected card) ──
            if (isSelected) ...[
              // Divider(height: 1, color: theme.dividerColor),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: hasFile
                    ? _UploadedFileRow(
                  key: const ValueKey('file'),
                  company: company,
                  onReplace: onReplaceFile,
                  onDelete: onRemoveFile,
                  onPreview: onPreviewFile,
                )
                    : _UploadZone(
                  key: const ValueKey('zone'),
                  isLoading: isPickingFile,
                  onTap: onPickFile,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}



class _UploadedFileRow extends StatelessWidget {
  final CompanyModel company;
  final VoidCallback onReplace;
  final VoidCallback onDelete;
  final VoidCallback onPreview;

  const _UploadedFileRow({
    super.key,
    required this.company,
    required this.onReplace,
    required this.onDelete,
    required this.onPreview,
  });

  bool get _isImage {
    final name = company.uploadedFileName?.toLowerCase() ?? '';
    return name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Numbers.DOUBLE_NUMBER_12,
        vertical: Numbers.DOUBLE_NUMBER_10,
      ),
      child: Row(
        children: [
          // ── Thumbnail / PDF badge ──
          GestureDetector(
            onTap: onPreview,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2)),
              ),
              child: _isImage && company.uploadedFilePath != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.file(
                  File(company.uploadedFilePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.image_outlined,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
              )
                  : Center(
                child: Text(
                  'PDF',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: Numbers.DOUBLE_NUMBER_10),

          // ── File name, size, preview link ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company.uploadedFileName ?? '',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${company.uploadedFileSizeMB} MB',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onPreview,
                      child: Text(
                        'Preview',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Replace button ──
          _CircleIconButton(
            color: const Color(0xFFFFF8E1),
            icon: Icons.sync_alt_rounded,
            iconColor: const Color(0xFFFFA000),
            onTap: onReplace,
            margin: const EdgeInsets.only(right: 8),
          ),

          // ── Remove button ──
          _CircleIconButton(
            color: const Color(0xFFFFEBEE),
            icon: Icons.delete_outline,
            iconColor: const Color(0xFFE53935),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}



class _UploadZone extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;
  const _UploadZone({super.key, required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.all(Numbers.DOUBLE_NUMBER_10),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.35),
            width: 1.5,
          ),
        ),
        child: isLoading
            ? Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: theme.colorScheme.primary,
            ),
          ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_rounded,
                color: theme.colorScheme.primary, size: 28),
            const SizedBox(height: 6),
            Text(
              'Upload Trade License',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Accepted formats: JPG, PNG, PDF (Max 5 MB)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _CircleIconButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final EdgeInsets margin;

  const _CircleIconButton({
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        margin: margin,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 17),
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  final bool isLink;
  const _InfoRow(this.label, this.value, {this.isLink = false});
}