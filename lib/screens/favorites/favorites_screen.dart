import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../models/book.dart';
import '../../providers/books_provider.dart';
import '../../screens/book_detail/book_detail_screen.dart';
import '../../widgets/book_card.dart';
import '../../widgets/book_list_tile.dart';
import '../../widgets/share_snapshot_widget.dart';
import '../../widgets/share_preview_sheet.dart'; // [New]
import 'scanner_screen.dart'; // [New]
import '../../utils/share_utils.dart';
import '../../theme/app_colors.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  bool _isListView = false;
  bool _isSelectMode = false;
  Set<int> _selectedBookIds = {};
  final GlobalKey _snapshotKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final savedBooksAsync = ref.watch(savedBooksProvider);
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: _buildAppBar(l, savedBooksAsync),
      body: savedBooksAsync.when(
        data: (books) {
          if (books.isEmpty) {
            return _buildEmptyState(l);
          }
          return Column(
            children: [
              _buildInfoBar(l, books.length),
              Expanded(
                child: _isListView
                    ? _buildListView(books)
                    : _buildGridView(books),
              ),
            ],
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l.get('loading_favorites')),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Text('${l.get('error')}: $err'),
        ),
      ),
      bottomNavigationBar: _isSelectMode && _selectedBookIds.isNotEmpty
          ? _buildBottomBar(l, savedBooksAsync)
          : null,
    );
  }

  // ─── AppBar ───────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(AppLocalizations l, AsyncValue<List<Book>> booksAsync) {
    if (_isSelectMode) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => setState(() {
            _isSelectMode = false;
            _selectedBookIds.clear();
          }),
        ),
        title: Text(
          '${_selectedBookIds.length} / ${booksAsync.valueOrNull?.length ?? 0}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final allIds = booksAsync.valueOrNull
                      ?.map((b) => b.id)
                      .whereType<int>()
                      .toSet() ??
                  {};
              setState(() {
                if (_selectedBookIds.length == allIds.length) {
                  _selectedBookIds.clear();
                } else {
                  _selectedBookIds = Set.from(allIds);
                }
              });
            },
            child: Text(
              _selectedBookIds.length ==
                      (booksAsync.valueOrNull?.length ?? 0)
                  ? l.get('deselect_all')
                  : l.get('select_all'),
            ),
          ),
        ],
      );
    }

    return AppBar(
      title: Text(
        l.get('favorites'),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      actions: [
        if (booksAsync.valueOrNull != null &&
            booksAsync.valueOrNull!.isNotEmpty)
          TextButton(
            onPressed: () => setState(() => _isSelectMode = true),
            child: Text(l.get('edit')),
          ),

      ],
    );
  }

  // ─── Info Bar ─────────────────────────────────────────

  Widget _buildInfoBar(AppLocalizations l, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            l.get('books_count').replaceAll('%d', '$count'),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          // View mode toggle
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.textSecondary.withOpacity(0.15),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildViewToggle(
                  icon: Icons.grid_view_rounded,
                  selected: !_isListView,
                  onTap: () => setState(() => _isListView = false),
                  tooltip: l.get('grid_view'),
                ),
                _buildViewToggle(
                  icon: Icons.view_list_rounded,
                  selected: _isListView,
                  onTap: () => setState(() => _isListView = true),
                  tooltip: l.get('list_view'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle({
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withOpacity(0.12) : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 20,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ─── Grid View ────────────────────────────────────────

  Widget _buildGridView(List<Book> books) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        final isSelected = _selectedBookIds.contains(book.id);

        return Stack(
          children: [
            BookCard(
              book: book,
              onTap: () {
                if (_isSelectMode) {
                  _toggleSelection(book.id);
                } else {
                  _navigateToDetail(book);
                }
              },
            ),
            if (_isSelectMode)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _toggleSelection(book.id),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ─── List View ────────────────────────────────────────

  Widget _buildListView(List<Book> books) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        final isSelected = _selectedBookIds.contains(book.id);

        if (_isSelectMode) {
          return Row(
            children: [
              Checkbox(
                value: isSelected,
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: (_) => _toggleSelection(book.id),
              ),
              Expanded(
                child: BookListTile(
                  book: book,
                  onTap: () => _toggleSelection(book.id),
                ),
              ),
            ],
          );
        }

        return BookListTile(
          book: book,
          onTap: () => _navigateToDetail(book),
        );
      },
    );
  }

  // ─── Empty State ──────────────────────────────────────

  Widget _buildEmptyState(AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bookmark_border_rounded,
              size: 56,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l.get('no_favorites'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l.get('save_books_hint'),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bottom Bar (select mode) ─────────────────────────

  Widget _buildBottomBar(AppLocalizations l, AsyncValue<List<Book>> booksAsync) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Batch remove
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _confirmBatchRemove(l),
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              label: Text(l.get('batch_remove')),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red[400],
                side: BorderSide(color: Colors.red[300]!),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Share booklist
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _showSharePreview(l, booksAsync),
              icon: const Icon(Icons.share_rounded, size: 20),
              label: Text(l.get('share_booklist')),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Actions ──────────────────────────────────────────

  void _toggleSelection(int? bookId) {
    if (bookId == null) return;
    setState(() {
      if (_selectedBookIds.contains(bookId)) {
        _selectedBookIds.remove(bookId);
      } else {
        _selectedBookIds.add(bookId);
      }
    });
  }

  void _navigateToDetail(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BookDetailScreen(),
        settings: RouteSettings(arguments: book),
      ),
    );
  }

  void _confirmBatchRemove(AppLocalizations l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.get('confirm_remove_title')),
        content: Text(
          l.get('confirm_remove_msg').replaceAll('%d', '${_selectedBookIds.length}'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.get('cancel')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _batchRemove();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red[400],
            ),
            child: Text(l.get('remove')),
          ),
        ],
      ),
    );
  }

  Future<void> _batchRemove() async {
    final notifier = ref.read(savedBooksProvider.notifier);
    for (final id in _selectedBookIds.toList()) {
      await notifier.unsaveBook(id.toString());
    }
    if (mounted) {
      setState(() {
        _selectedBookIds.clear();
        _isSelectMode = false;
      });
    }
  }

  void _showSharePreview(AppLocalizations l, AsyncValue<List<Book>> booksAsync) {
    final allBooks = booksAsync.valueOrNull ?? [];
    final selectedBooks = allBooks
        .where((b) => _selectedBookIds.contains(b.id))
        .toList();

    if (selectedBooks.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SharePreviewSheet(books: selectedBooks),
    );
  }

  Future<void> _scanQRCode(AppLocalizations l) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );

    if (result != null && result is String) {
      if (result.startsWith('olib_share:')) {
        final idsStr = result.substring(11);
        if (idsStr.isNotEmpty) {
          final entries = idsStr.split(',');
          // Extract IDs, ignoring hash for now as we re-fetch fresh data
          final ids = entries.map((e) => e.split(':')[0]).toList();
          if (ids.isNotEmpty) {
            _importBooks(ids, l);
          }
        }
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.get('invalid_qr_code'))),
          );
        }
      }
    }
  }

  Future<void> _importBooks(List<String> ids, AppLocalizations l) async {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.get('processing'))),
    );

    final notifier = ref.read(savedBooksProvider.notifier);
    int count = 0;

    for (final id in ids) {
      // Basic number check
      if (int.tryParse(id) != null) {
        await notifier.saveBook(id); 
        count++;
      }
    }

    if (mounted) {
      final msg = l.get('imported_success').replaceAll('%d', count.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
