import 'dart:ui';

class CompanyModel {
  final String id;
  final String name;
  final String gstId;
  final Color avatarColor;
  final String avatarLetter;
  String? uploadedFileName;
  double? uploadedFileSizeMB;
  String? uploadedFilePath;        // ← NEW: local file path for preview
  final String companyName;
  final String websiteUrl;
  final String tradeLicenseNumber;
  final String incorporationDate;
  final String expiryDate;

  CompanyModel({
    required this.id,
    required this.name,
    required this.gstId,
    required this.avatarColor,
    required this.avatarLetter,
    required this.companyName,
    required this.websiteUrl,
    required this.tradeLicenseNumber,
    required this.incorporationDate,
    required this.expiryDate,
    this.uploadedFileName,
    this.uploadedFileSizeMB,
    this.uploadedFilePath,
  });
}