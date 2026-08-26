import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/admin_provider.dart';

class AdminBulkUploadScreen extends ConsumerStatefulWidget {
  const AdminBulkUploadScreen({super.key});

  @override
  ConsumerState<AdminBulkUploadScreen> createState() => _AdminBulkUploadScreenState();
}

class _AdminBulkUploadScreenState extends ConsumerState<AdminBulkUploadScreen> {
  String _uploadType = 'places';
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  Map<String, dynamic>? _uploadResult;
  String? _errorMessage;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          _uploadResult = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking file: $e';
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null || _selectedFile!.bytes == null) {
      setState(() {
        _errorMessage = 'Please select a valid CSV file first.';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadResult = null;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(adminRepositoryProvider);
      final result = await repository.bulkUpload(
        _uploadType,
        _selectedFile!.bytes!,
        _selectedFile!.name,
      );

      setState(() {
        _uploadResult = result;
        _isUploading = false;
        _selectedFile = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Upload failed: $e';
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bulk Upload (CSV)',
            style: TextStyle(
              fontFamily: 'Segoe UI',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Upload places or danger zones in bulk using a CSV file.",
            style: TextStyle(
              fontFamily: 'Segoe UI',
              color: Color(0xFF64748B),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upload Configuration',
                  style: TextStyle(
                    fontFamily: 'Segoe UI',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Select Data Type:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _uploadType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'places', child: Text('Places (Hospital, Police, Help Center)', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: 'danger_zones', child: Text('Danger Zones', overflow: TextOverflow.ellipsis)),
                  ],
                  onChanged: (v) => setState(() => _uploadType = v!),
                ),
                const SizedBox(height: 25),
                const Text(
                  'Select File:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _pickFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Choose CSV File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        foregroundColor: const Color(0xFF334155),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        _selectedFile != null ? _selectedFile!.name : 'No file chosen',
                        style: TextStyle(
                          color: _selectedFile != null ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                          fontStyle: _selectedFile != null ? FontStyle.normal : FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isUploading || _selectedFile == null ? null : _uploadFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E5CE6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isUploading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Upload Data',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                border: Border.all(color: const Color(0xFFF87171)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFDC2626)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Color(0xFF991B1B)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_uploadResult != null) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upload Results',
                    style: TextStyle(
                      fontFamily: 'Segoe UI',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildResultRow('Total Rows Processed', _uploadResult!['total_rows'].toString(), Colors.blue),
                  _buildResultRow('Successfully Imported', _uploadResult!['success_count'].toString(), Colors.green),
                  _buildResultRow('Skipped / Errors', _uploadResult!['skipped_count'].toString(), Colors.orange),
                  if (_uploadResult!['error_messages'] != null && (_uploadResult!['error_messages'] as List).isNotEmpty) ...[
                    const SizedBox(height: 15),
                    const Text('Error Details:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (_uploadResult!['error_messages'] as List).map<Widget>((msg) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text('• $msg', style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B))),
                          );
                        }).toList(),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w500)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
