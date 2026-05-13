import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:kenooz_worker_app/features/profile/presentation/ui/widgets/profile_bloc_builder.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;
  const ProfileScreen({super.key, this.onMenuTap});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().getProfile();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkThemeBackgroundColor
          : AppColors.backGroundColorLight,
      body: ProfileBlocBuilder(onMenuTap: widget.onMenuTap),
    );
  }
}
