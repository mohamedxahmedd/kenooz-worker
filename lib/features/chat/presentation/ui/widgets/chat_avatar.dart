import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';

class ChatAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;

  const ChatAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    this.size = 48,
  });

  String get _initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+')).take(2);
    return parts
        .map((p) => p.isEmpty ? '' : p.characters.first.toUpperCase())
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final dimension = size.w;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkBrown.withOpacity(0.10),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.20),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => _placeholder(),
              errorWidget: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Text(
        _initials,
        style: AppFonts.heading(
          fontSize: (size * 0.36).sp,
          fontWeight: FontWeight.w700,
          color: AppColors.darkBrown,
        ),
      ),
    );
  }
}
