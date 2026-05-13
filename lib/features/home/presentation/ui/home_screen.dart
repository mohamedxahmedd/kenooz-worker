import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/theming/colors.dart';
import 'package:kenooz_worker_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:kenooz_worker_app/features/home/presentation/ui/widgets/home_bloc_builder.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const HomeScreen({super.key, this.onMenuTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().fetchAllRates();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkThemeBackgroundColor
          : AppColors.backGroundColorLight,
      body: HomeBlocBuilder(onMenuTap: widget.onMenuTap),
    );
  }
}
