import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kenooz_worker_app/core/routing/routes.dart';
import 'package:kenooz_worker_app/core/theming/app_fonts.dart';
import 'package:kenooz_worker_app/core/widgets/desktop/desktop_card.dart';
import 'package:kenooz_worker_app/features/sign_up/presentation/cubit/signup_cubit.dart';
import 'package:kenooz_worker_app/features/sign_up/presentation/ui/widgets/signup_bloc_listener.dart';

/// Desktop sign-up wizard. Three steps (account / personal / security) with
/// a left step indicator. Backed by [SignupCubit]; final step calls
/// `emitSignupStates`. Validation runs per-step.
class SignUpDesktopScreen extends StatefulWidget {
  const SignUpDesktopScreen({super.key});

  @override
  State<SignUpDesktopScreen> createState() => _SignUpDesktopScreenState();
}

class _SignUpDesktopScreenState extends State<SignUpDesktopScreen> {
  int _step = 0;
  final _stepFormKeys =
      List<GlobalKey<FormState>>.generate(3, (_) => GlobalKey<FormState>());
  bool _obscure1 = true;
  bool _obscure2 = true;

  bool _validateStep(int step) =>
      _stepFormKeys[step].currentState?.validate() ?? false;

  void _next() {
    if (!_validateStep(_step)) return;
    if (_step < 2) {
      setState(() => _step += 1);
    } else {
      final cubit = context.read<SignupCubit>();
      if (cubit.selectedType == null || cubit.selectedType!.isEmpty) {
        cubit.selectedType = 'worker';
      }
      cubit.emitSignupStates();
    }
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).maybePop();
    } else {
      setState(() => _step -= 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: DesktopCard(
              padding: EdgeInsets.zero,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StepIndicatorPanel(step: _step),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _titleForStep(_step),
                              style: AppFonts.heading(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildStepBody(_step),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: _back,
                                  child: Text(_step == 0
                                      ? 'common.cancel'.tr()
                                      : 'menu.back'.tr()),
                                ),
                                const Spacer(),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 14),
                                  ),
                                  onPressed: _next,
                                  child: Text(
                                    _step == 2
                                        ? 'signup.signup'.tr()
                                        : 'menu.next'.tr(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.of(context)
                                    .pushReplacementNamed(
                                        Routes.loginScreen),
                                child: Text(
                                  '${'signup.alreadyHaveAccount'.tr()}  ${'signup.signin'.tr()}',
                                ),
                              ),
                            ),
                            const SignupBlocListener(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _titleForStep(int step) {
    switch (step) {
      case 0:
        return 'signup.signup'.tr();
      case 1:
        return 'signup.firstName'.tr();
      default:
        return 'signup.password'.tr();
    }
  }

  Widget _buildStepBody(int step) {
    final cubit = context.read<SignupCubit>();
    return Form(
      key: _stepFormKeys[step],
      child: switch (step) {
        0 => _AccountStep(cubit: cubit),
        1 => _PersonalStep(
            cubit: cubit,
            onGenderChanged: (g) => setState(() => cubit.gender = g),
          ),
        _ => _SecurityStep(
            cubit: cubit,
            obscure1: _obscure1,
            obscure2: _obscure2,
            onToggle1: () => setState(() => _obscure1 = !_obscure1),
            onToggle2: () => setState(() => _obscure2 = !_obscure2),
            agreed: cubit.isCheckboxChecked,
            onAgreedChanged: (v) =>
                setState(() => cubit.isCheckboxChecked = v ?? false),
          ),
      },
    );
  }
}

class _StepIndicatorPanel extends StatelessWidget {
  const _StepIndicatorPanel({required this.step});
  final int step;

  static const _labels = ['signup.signup', 'signup.firstName', 'signup.password'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 22),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.06),
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_labels.length, (index) {
          final selected = index == step;
          final completed = index < step;
          return Padding(
            padding: EdgeInsets.only(bottom: index == 2 ? 0 : 18),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected || completed
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: theme.colorScheme.primary
                          .withValues(alpha: selected || completed ? 1 : 0.4),
                    ),
                  ),
                  child: completed
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text(
                          '${index + 1}',
                          style: AppFonts.body(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? Colors.white
                                : theme.colorScheme.primary,
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _labels[index].tr(),
                    style: AppFonts.body(
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: selected ? 1 : 0.6),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _AccountStep extends StatelessWidget {
  const _AccountStep({required this.cubit});
  final SignupCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: cubit.emailController,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          decoration: _decoration('signup.email'.tr(), Icons.email_outlined),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'signup.emailIsRequiredToSignUp'.tr()
              : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: cubit.phoneController,
          keyboardType: TextInputType.phone,
          decoration: _decoration('signup.phone'.tr(), Icons.phone_outlined),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'signup.phoneIsRequiredToSignUp'.tr()
              : null,
        ),
      ],
    );
  }
}

class _PersonalStep extends StatelessWidget {
  const _PersonalStep({required this.cubit, required this.onGenderChanged});
  final SignupCubit cubit;
  final ValueChanged<String?> onGenderChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: cubit.firstNameController,
                decoration: _decoration(
                    'signup.firstName'.tr(), Icons.person_outline),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'signup.firstNameIsRequiredToSignUp'.tr()
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: cubit.lastNameController,
                decoration: _decoration(
                    'signup.lastName'.tr(), Icons.person_outline),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'signup.lastNameIsRequiredToSignUp'.tr()
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: cubit.gender,
          decoration: _decoration('signup.gender'.tr(), Icons.wc_outlined),
          items: [
            DropdownMenuItem(value: 'male', child: Text('signup.male'.tr())),
            DropdownMenuItem(
                value: 'female', child: Text('signup.female'.tr())),
          ],
          onChanged: onGenderChanged,
          validator: (v) => v == null
              ? 'signup.genderIsRequiredToSignUp'.tr()
              : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: cubit.birthdateController,
          readOnly: true,
          decoration: _decoration(
              'signup.selectYourBirthDate'.tr(), Icons.cake_outlined),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              initialDate: DateTime(2000),
            );
            if (picked != null) {
              cubit.birthdateController.text =
                  picked.toIso8601String().split('T').first;
            }
          },
        ),
      ],
    );
  }
}

class _SecurityStep extends StatelessWidget {
  const _SecurityStep({
    required this.cubit,
    required this.obscure1,
    required this.obscure2,
    required this.onToggle1,
    required this.onToggle2,
    required this.agreed,
    required this.onAgreedChanged,
  });

  final SignupCubit cubit;
  final bool obscure1;
  final bool obscure2;
  final VoidCallback onToggle1;
  final VoidCallback onToggle2;
  final bool agreed;
  final ValueChanged<bool?> onAgreedChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: cubit.passwordController,
          obscureText: obscure1,
          decoration: _decoration(
            'signup.password'.tr(),
            Icons.lock_outline,
          ).copyWith(
            suffixIcon: IconButton(
              icon: Icon(obscure1
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              onPressed: onToggle1,
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) {
              return 'signup.passwordIsRequiredToSignUp'.tr();
            }
            if (v.length < 6) {
              return 'signup.passwordShouldBeAtLeast6Characters'.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: cubit.confirmPasswordController,
          obscureText: obscure2,
          decoration: _decoration(
            'signup.confirmPassword'.tr(),
            Icons.lock_outline,
          ).copyWith(
            suffixIcon: IconButton(
              icon: Icon(obscure2
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              onPressed: onToggle2,
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) {
              return 'signup.confirmPasswordIsRequiredToSignUp'.tr();
            }
            if (v != cubit.passwordController.text) {
              return 'signup.passwordsDoNotMatch'.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Checkbox(
              value: agreed,
              onChanged: onAgreedChanged,
            ),
            Expanded(
              child: Text(
                '${'signup.iAgreeToThe'.tr()}${'signup.termsOfServices'.tr()}${'signup.and'.tr()}${'signup.privacyPolicy'.tr()}',
                style: AppFonts.body(fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

InputDecoration _decoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  );
}
