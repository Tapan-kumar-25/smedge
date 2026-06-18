import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smedge/common_files/custom_elevated_button.dart';
import 'package:smedge/constants/numbers.dart';
import 'package:smedge/view/dash_board/screens/pos_conformation_scren.dart';
import 'package:smedge/view/dash_board/screens/pos_term_&_condition_screen.dart';

import '../../../provider/provider.dart';


class UploadedFile {
  final String name;
  final String size;
  final String? path;
  final bool isImage;

  UploadedFile({
    required this.name,
    required this.size,
    this.path,
    this.isImage = false,
  });
}

class DocumentSection {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  List<UploadedFile> files;

  DocumentSection({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.files = const [],
  });
}

class POSFinancingDocumentsScreen extends ConsumerStatefulWidget {
  const POSFinancingDocumentsScreen({super.key});

  @override
  ConsumerState<POSFinancingDocumentsScreen> createState() =>
      _POSFinancingDocumentsScreenState();
}

class _POSFinancingDocumentsScreenState
    extends ConsumerState<POSFinancingDocumentsScreen> {
  bool _confirmed = false;

  final List<DocumentSection> _sections = [
    DocumentSection(
      icon: Icons.description_outlined,
      iconBg: const Color(0xFFE8EEF7),
      iconColor: const Color(0xFF1A3A6B),
      title: 'Trade License',
      subtitle: 'Official Company Registration',
      files: [],
    ),
    DocumentSection(
      icon: Icons.menu_book,
      iconBg: const Color(0xFFE8EEF7),
      iconColor: const Color(0xFF1A3A6B),
      title: 'MOA / AOA',
      subtitle: 'Latest version',
      files: [],
    ),
    DocumentSection(
      icon: Icons.group,
      iconBg: const Color(0xFFE8EEF7),
      iconColor: const Color(0xFF1A3A6B),
      title: 'Passport',
      subtitle: 'With valid UAE residency visa',
      files: [],
    ),
    DocumentSection(
      icon: Icons.account_balance_outlined,
      iconBg: const Color(0xFFE8EEF7),
      iconColor: const Color(0xFF1A3A6B),
      title: 'Bank Statement',
      subtitle: 'Last 6 months required',
      files: [],
    ),
    DocumentSection(
      icon: Icons.people_outline,
      iconBg: const Color(0xFFE8EEF7),
      iconColor: const Color(0xFF1A3A6B),
      title: 'Stakeholder Documents',
      subtitle: 'Passports & IDs of owners',
      files: [],
    ),
  ];

  Future<void> _pickFile(int sectionIndex) async {
    final choice = await showModalBottomSheet<String>(
      useSafeArea: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding:  EdgeInsets.all(MediaQuery.of(context).viewInsets.bottom+30),
        child: _UploadBottomSheet(),
      ),
    );

    if (choice == null) return;

    if (choice == 'camera') {
      final picked = await ImagePicker().pickImage(source: ImageSource.camera);
      if (picked != null) _addFile(sectionIndex, picked.path, true);
    } else if (choice == 'gallery') {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) _addFile(sectionIndex, picked.path, true);
    } else if (choice == 'file') {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.isNotEmpty) {
        final f = result.files.first;
        final sizeKB = (f.size / 1024);
        final sizeStr = sizeKB >= 1024
            ? '${(sizeKB / 1024).toStringAsFixed(1)} MB'
            : '${sizeKB.toStringAsFixed(0)} KB';
        setState(() {
          _sections[sectionIndex].files.add(
            UploadedFile(
              name: f.name,
              size: sizeStr,
              path: f.path,
              isImage: [
                'jpg',
                'jpeg',
                'png',
              ].contains(f.extension?.toLowerCase()),
            ),
          );
        });
      }
    }
  }

  void _addFile(int sectionIndex, String path, bool isImage) {
    final name = path.split('/').last;
    final file = File(path);
    final bytes = file.lengthSync();
    final kb = bytes / 1024;
    final sizeStr = kb >= 1024
        ? '${(kb / 1024).toStringAsFixed(1)} MB'
        : '${kb.toStringAsFixed(0)} KB';

    setState(() {
      _sections[sectionIndex].files.add(
        UploadedFile(name: name, size: sizeStr, path: path, isImage: isImage),
      );
    });
  }

  void _deleteFile(int sectionIndex, int fileIndex) {
    setState(() {
      _sections[sectionIndex].files.removeAt(fileIndex);
    });
  }

  void _viewFile(UploadedFile file) {
    if (file.isImage && file.path != null) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.file(File(file.path!), fit: BoxFit.contain),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening: ${file.name}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardStateProvider).setContext(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardStateProvider);
    final theme = Theme.of(context);
    return SafeArea(
      top: false,bottom: true,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
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
        body: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntroText(),
                    const SizedBox(height: 16),
                    ..._sections.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildDocumentCard(e.key, e.value),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildConfirmRow(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final theme = Theme.of(context);
    return Container(
      padding:  EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Color(0xffFBBC05),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(Numbers.DOUBLE_NUMBER_10),
                      topLeft: Radius.circular(Numbers.DOUBLE_NUMBER_10),
                      bottomRight: Radius.circular(Numbers.DOUBLE_NUMBER_10)
                  ),
                ),
                child: const Text(
                  'Step 3 of 3',
                  style: TextStyle(
                    color: Color(0xFF856404),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'DOCUMENTS',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: i <= 1 ? Colors.green : theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }


  Widget _buildIntroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Required Documents',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
            children: [
              TextSpan(
                text:
                    'Please upload clear, legible copies of the following documents. ',
              ),
              TextSpan(
                text: 'Accepted formats: JPG, PNG, PDF (Max 5 MB).',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Document card ───────────────────────────────────────────────────────────

  Widget _buildDocumentCard(int index, DocumentSection section) {
    final hasFiles = section.files.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header row ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: section.iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(section.icon, color: section.iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        section.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(hasFiles),
              ],
            ),
          ),

          // ── Uploaded files ──
          if (hasFiles)
            ...section.files.asMap().entries.map(
              (e) => _buildFileRow(index, e.key, e.value),
            ),

          // ── Upload button (always show, allows adding more) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _buildUploadButton(index),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool uploaded) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: uploaded ? const Color(0xFFE6F4EA) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: uploaded ? const Color(0xFF34A853) : const Color(0xFFE53935),
        ),
      ),
      child: Text(
        uploaded ? 'Uploaded' : 'Missing',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: uploaded ? const Color(0xFF1E7E34) : const Color(0xFFE53935),
        ),
      ),
    );
  }

  // ─── File row ────────────────────────────────────────────────────────────────

  Widget _buildFileRow(int sectionIdx, int fileIdx, UploadedFile file) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          // Thumbnail or PDF icon
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: file.isImage && file.path != null
                ? Image.file(
                    File(file.path!),
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDE8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'PDF',
                        style: TextStyle(
                          color: Color(0xFFE53935),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  file.size,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // View button
          GestureDetector(
            onTap: () => _viewFile(file),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.open_in_new_rounded,
                size: 17,
                color: Color(0xFFF59E0B),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Delete button
          GestureDetector(
            onTap: () => _showDeleteConfirm(sectionIdx, fileIdx, file.name),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: Color(0xFFE53935),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(int sectionIdx, int fileIdx, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete File?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text('Remove "$name" from this section?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteFile(sectionIdx, fileIdx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ─── Upload button ───────────────────────────────────────────────────────────

  Widget _buildUploadButton(int sectionIndex) {
    return GestureDetector(
      onTap: () => _pickFile(sectionIndex),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F6FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF1A3A6B),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.upload_outlined,
              size: 20,
              color: const Color(0xFF1A3A6B),
            ),
            const SizedBox(width: 8),
            const Text(
              'Upload File',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A3A6B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Confirm row ─────────────────────────────────────────────────────────────

  Widget _buildConfirmRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: _confirmed ? const Color(0xFF1A3A6B) : Colors.white,
            border: Border.all(
              color: _confirmed
                  ? const Color(0xFF1A3A6B)
                  : const Color(0xFFD1D5DB),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: _confirmed
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : null,
        ),

        const SizedBox(width: 10),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => POSTermsConditionsScreen()),
            ).then((value) {
              setState(() {
                if (value != null) {
                  _confirmed = value;
                }
              });
            });
          },
          child: Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF374151),
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text:
                        'I Confirm that all provided information is accurate and \nI agree to the ',
                  ),
                  TextSpan(
                    text: 'Terms & Conditions.',
                    style: TextStyle(
                      color: Color(0xFFE53935),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: SizedBox(
        width: double.infinity,
        child: CustomElevatedButton(
          onPressed: () {
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => POSConformation()));
          },
          title: 'Submit Application',
        ),
      ),
    );
  }
}

class _UploadBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Upload Document',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose how you want to upload your file',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildOption(
                context,
                icon: Icons.camera_alt_outlined,
                color: const Color(0xFF1A3A6B),
                bg: const Color(0xFFE8EEF7),
                label: 'Camera',
                value: 'camera',
              ),
              const SizedBox(width: 12),
              _buildOption(
                context,
                icon: Icons.photo_library_outlined,
                color: const Color(0xFF059669),
                bg: const Color(0xFFD1FAE5),
                label: 'Gallery',
                value: 'gallery',
              ),
              const SizedBox(width: 12),
              _buildOption(
                context,
                icon: Icons.insert_drive_file_outlined,
                color: const Color(0xFFF59E0B),
                bg: const Color(0xFFFEF3C7),
                label: 'Files',
                value: 'file',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required Color bg,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.pop(context, value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
