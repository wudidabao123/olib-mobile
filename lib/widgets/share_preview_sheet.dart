import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/book.dart';
import '../utils/share_utils.dart';
import '../theme/app_colors.dart';
import 'share_snapshot_widget.dart';

class SharePreviewSheet extends StatefulWidget {
  final List<Book> books;

  const SharePreviewSheet({super.key, required this.books});

  @override
  State<SharePreviewSheet> createState() => _SharePreviewSheetState();
}

class _SharePreviewSheetState extends State<SharePreviewSheet> {
  final GlobalKey _snapshotKey = GlobalKey();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  ShareStyle _selectedStyle = ShareStyle.museum;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String? _generateQrData() {
    // Disabled per user request due to high data density
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final qrData = _generateQrData();

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Text(
              l.get('share_booklist'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Style Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                _buildStyleChip('Museum', ShareStyle.museum),
                const SizedBox(width: 12),
                _buildStyleChip('Magazine', ShareStyle.magazine),
                const SizedBox(width: 12),
                _buildStyleChip('Glass', ShareStyle.glass),
              ],
            ),
          ),

          // Input Fields
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              children: [
                // Title Input
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: l.get('title_optional'),
                    hintText: l.get('enter_title'),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                // Content Input
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: l.get('recommendation_optional'),
                    hintText: l.get('enter_content'),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
                  minLines: 1,
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),

          // Preview
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Center(
                child: RepaintBoundary(
                  key: _snapshotKey,
                  child: ShareSnapshotWidget(
                    books: widget.books,
                    style: _selectedStyle,
                    customTitle: _titleController.text,
                    customContent: _contentController.text,
                    qrData: qrData,
                  ),
                ),
              ),
            ),
          ),

          // Action buttons
          Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l.get('close')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      await ShareUtils.captureAndShare(_snapshotKey);
                    },
                    icon: const Icon(Icons.share_rounded, size: 20),
                    label: Text(l.get('share_image')),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleChip(String label, ShareStyle style) {
    final isSelected = style == _selectedStyle;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedStyle = style),
      selectedColor: AppColors.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey[300]!,
        ),
      ),
    );
  }
}
