import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kenooz_worker_app/core/di/dependency_injection.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/widgets/desktop/desktop_card.dart';
import 'package:kenooz_worker_app/core/widgets/failure_snack_bar.dart';
import 'package:kenooz_worker_app/core/widgets/success_snack_bar.dart';
import 'package:kenooz_worker_app/features/blogs/data/models/blog_model.dart';
import 'package:kenooz_worker_app/features/blogs/presentation/cubit/blog_delete_cubit.dart';
import 'package:kenooz_worker_app/features/blogs/presentation/cubit/blog_delete_state.dart';
import 'package:kenooz_worker_app/features/blogs/presentation/cubit/blog_form_cubit.dart';
import 'package:kenooz_worker_app/features/blogs/presentation/cubit/blogs_list_cubit.dart';
import 'package:kenooz_worker_app/features/blogs/presentation/cubit/blogs_list_state.dart';
import 'package:kenooz_worker_app/features/blogs/presentation/ui/blog_form_screen.dart';

const Color _accent = Color(0xFFCBA135);

/// Desktop Blogs — split pane: list on the left, detail preview on the
/// right. Edit and create use the existing mobile `BlogFormScreen` in a
/// dialog (a desktop-sized modal) so every field, validation, and image
/// upload path is preserved. Reuses `BlogsListCubit` + `BlogDeleteCubit`
/// without changes.
class BlogsDesktopScreen extends StatefulWidget {
  const BlogsDesktopScreen({super.key});

  @override
  State<BlogsDesktopScreen> createState() => _BlogsDesktopScreenState();
}

class _BlogsDesktopScreenState extends State<BlogsDesktopScreen> {
  BlogModel? _selected;

  @override
  void initState() {
    super.initState();
    context.read<BlogsListCubit>().fetchFirstPage();
  }

  Future<void> _openForm({BlogModel? existing}) async {
    final result = await showDialog<BlogModel>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980, maxHeight: 820),
          child: BlocProvider(
            create: (_) => BlogFormCubit(getIt()),
            child: BlogFormScreen(existingBlog: existing),
          ),
        ),
      ),
    );
    if (!mounted || result == null) return;
    if (existing == null) {
      context.read<BlogsListCubit>().prependBlog(result);
    } else {
      context.read<BlogsListCubit>().replaceBlog(result);
      setState(() => _selected = result);
    }
  }

  Future<void> _confirmDelete(BlogModel blog) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('blogs.deleteTitle'.tr()),
        content: Text('blogs.deleteConfirm'.tr(args: [blog.title])),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('blogs.delete'.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<BlogDeleteCubit>().deleteBlog(blog.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BlogDeleteCubit, BlogDeleteState>(
      listener: (context, state) {
        state.whenOrNull(
          loading: (_) => EasyLoading.show(),
          success: (id, message) {
            EasyLoading.dismiss();
            successSnackBar(msg: message, context: context);
            context.read<BlogsListCubit>().removeBlogLocally(id);
            if (_selected?.id == id) {
              setState(() => _selected = null);
            }
            context.read<BlogDeleteCubit>().resetState();
          },
          error: (_, message) {
            EasyLoading.dismiss();
            failureSnackBar(msg: message, context: context);
            context.read<BlogDeleteCubit>().resetState();
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DesktopHeader(
              onAddNew: () => _openForm(),
              onRefresh: () =>
                  context.read<BlogsListCubit>().fetchFirstPage(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<BlogsListCubit, BlogsListState>(
                builder: (context, state) => state.maybeWhen(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (message) => _DesktopError(
                    message: message,
                    onRetry: () =>
                        context.read<BlogsListCubit>().fetchFirstPage(),
                  ),
                  loaded: (blogs, hasMore, isLoadingMore, currentPage) =>
                      _buildBody(
                    blogs: blogs,
                    hasMore: hasMore,
                    isLoadingMore: isLoadingMore,
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody({
    required List<BlogModel> blogs,
    required bool hasMore,
    required bool isLoadingMore,
  }) {
    if (blogs.isEmpty) {
      return Center(child: _EmptyCard(onAddNew: () => _openForm()));
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1000;
        final listPane = _ListPane(
          blogs: blogs,
          selectedId: _selected?.id,
          hasMore: hasMore,
          isLoadingMore: isLoadingMore,
          onSelect: (b) => setState(() => _selected = b),
          onLoadMore: () =>
              context.read<BlogsListCubit>().fetchNextPage(),
          onEdit: (b) => _openForm(existing: b),
          onDelete: _confirmDelete,
        );
        if (!wide) return listPane;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 5, child: listPane),
            const SizedBox(width: 16),
            Expanded(
              flex: 5,
              child: _selected == null
                  ? _SelectAPrompt()
                  : _DetailPane(
                      blog: _selected!,
                      onEdit: () => _openForm(existing: _selected),
                      onDelete: () => _confirmDelete(_selected!),
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────────

class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader({
    required this.onAddNew,
    required this.onRefresh,
  });
  final VoidCallback onAddNew;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DesktopCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: _accent.withValues(alpha: 0.14),
            child: const Icon(Icons.article_outlined, color: _accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'blogs.title'.tr(),
                  style: AppFonts.heading(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'blogs.subtitle'.tr(),
                  style: AppFonts.body(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text('common.refresh'.tr()),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: _accent),
            onPressed: onAddNew,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text('blogs.addBlog'.tr()),
          ),
        ],
      ),
    );
  }
}

// ─── List pane ─────────────────────────────────────────────────────────────

class _ListPane extends StatefulWidget {
  const _ListPane({
    required this.blogs,
    required this.selectedId,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onSelect,
    required this.onLoadMore,
    required this.onEdit,
    required this.onDelete,
  });
  final List<BlogModel> blogs;
  final int? selectedId;
  final bool hasMore;
  final bool isLoadingMore;
  final ValueChanged<BlogModel> onSelect;
  final VoidCallback onLoadMore;
  final ValueChanged<BlogModel> onEdit;
  final ValueChanged<BlogModel> onDelete;

  @override
  State<_ListPane> createState() => _ListPaneState();
}

class _ListPaneState extends State<_ListPane> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (widget.hasMore && !widget.isLoadingMore) widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DesktopCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: widget.blogs.length + (widget.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index >= widget.blogs.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final blog = widget.blogs[index];
          return _BlogRow(
            blog: blog,
            selected: blog.id == widget.selectedId,
            onTap: () => widget.onSelect(blog),
            onEdit: () => widget.onEdit(blog),
            onDelete: () => widget.onDelete(blog),
          );
        },
      ),
    );
  }
}

class _BlogRow extends StatelessWidget {
  const _BlogRow({
    required this.blog,
    required this.selected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });
  final BlogModel blog;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cover = blog.coverImageUrl;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? _accent.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? _accent
                : theme.colorScheme.onSurface.withValues(alpha: 0.08),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: (cover != null && cover.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: cover,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.broken_image_outlined),
                    )
                  : Icon(
                      Icons.article_outlined,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          blog.title,
                          style: AppFonts.heading(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _StatusBadge(active: blog.isActive),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    (blog.subtitle?.isNotEmpty == true)
                        ? blog.subtitle!
                        : '—',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'blogs.edit'.tr(),
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: 'blogs.delete'.tr(),
              color: theme.colorScheme.error,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        active ? 'blogs.active'.tr() : 'blogs.hidden'.tr(),
        style: AppFonts.body(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─── Detail pane ───────────────────────────────────────────────────────────

class _DetailPane extends StatelessWidget {
  const _DetailPane({
    required this.blog,
    required this.onEdit,
    required this.onDelete,
  });
  final BlogModel blog;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DesktopCard(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    blog.title,
                    style: AppFonts.heading(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(active: blog.isActive),
              ],
            ),
            if ((blog.subtitle?.isNotEmpty) == true) ...[
              const SizedBox(height: 6),
              Text(
                blog.subtitle!,
                style: AppFonts.body(
                  fontSize: 14,
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              _formatDate(blog.createdAt),
              style: AppFonts.body(
                fontSize: 11,
                color:
                    theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            if (blog.images.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: blog.images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: blog.images[i].url,
                        width: 200,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          width: 200,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.04),
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              blog.details,
              style: AppFonts.body(
                fontSize: 13,
                color: theme.colorScheme.onSurface,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: _accent),
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: Text('blogs.edit'.tr()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(
                        color: theme.colorScheme.error.withValues(alpha: 0.5),
                      ),
                    ),
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: Text('blogs.delete'.tr()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectAPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DesktopCard(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.article_outlined,
              size: 40,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'blogs.selectToView'.tr(),
              textAlign: TextAlign.center,
              style: AppFonts.body(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.onAddNew});
  final VoidCallback onAddNew;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: DesktopCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.article_outlined, size: 40),
            const SizedBox(height: 12),
            Text(
              'blogs.emptyTitle'.tr(),
              style: AppFonts.heading(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'blogs.emptySubtitle'.tr(),
              textAlign: TextAlign.center,
              style: AppFonts.body(fontSize: 12),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _accent),
              onPressed: onAddNew,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text('blogs.addBlog'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopError extends StatelessWidget {
  const _DesktopError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: DesktopCard(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 36),
              const SizedBox(height: 12),
              Text(
                'common.somethingWentWrong'.tr(),
                style: AppFonts.heading(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(message,
                  textAlign: TextAlign.center,
                  style: AppFonts.body(fontSize: 12)),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: onRetry,
                child: Text('common.tryAgain'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    return '$dd/$mm/${dt.year}';
  } catch (_) {
    return iso;
  }
}
