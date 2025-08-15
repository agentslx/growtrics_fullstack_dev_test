import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_solver_flutter/features/home/router.dart';

import '../../../../widgets/buttons/app_buttons.dart';
import '../../../../widgets/containers/app_scaffold.dart';
import '../../../../widgets/containers/common_form_body.dart';
import '../../../../widgets/snackbar/app_snackbar.dart';
import '../../../../widgets/text_fields/app_text_fields.dart';
import '../../cubits/register_cubit/register_cubit.dart';
import '../../router.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterCubit>(
      create: (_) => RegisterCubit(),
      child: Builder(builder: (context) {
        return BlocListener<RegisterCubit, RegisterState>(
          listenWhen: (previous, current) => previous.signUpStatus != current.signUpStatus,
          listener: (context, state) {
            // If verification fails
            if (state.signUpStatus == FormzSubmissionStatus.failure) {
              AppSnackbar.error(
                context: context,
                message: state.errorMessage ?? tr('common.unknown_error'),
              );
            }

            // If verification is successful, navigate to the onboarding page
            if (state.signUpStatus == FormzSubmissionStatus.success) {
              context.go(HomeRouter.home);
            }
          },
          child: BlocBuilder<RegisterCubit, RegisterState>(builder: (context, state) {
            return AppScaffold(
              body: CommonFormBody(
                title: 'register.title'.tr(),
                subtitle: 'register.subtitle'.tr(),
                bottomWidget: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppPrimaryButton(
                      isLoading: state.signUpStatus.isInProgress,
                      label: 'register.create_account'.tr(),
                      onPressed: state.isValid
                          ? () {
                              context.read<RegisterCubit>().requestEmailVerify();
                            }
                          : null,
                      width: double.infinity,
                      size: AppButtonSize.large,
                    ),
                    const SizedBox(height: 16.0),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'register.already_have_an_account'.tr(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          TextSpan(
                            text: ' ${'common.sign_in'.tr()}',
                            style: Theme.of(context).textTheme.bodySmall,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.go(AuthRouter.login);
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      initialValue: state.fullName?.value,
                      label: 'common.full_name'.tr(),
                      onChanged: context.read<RegisterCubit>().onFullNameChanged,
                      onClearTap: () => context.read<RegisterCubit>().onFullNameChanged(''),
                    ),
                    const SizedBox(height: 16.0),
                    AppTextField(
                      initialValue: state.email?.value,
                      label: 'common.email'.tr(),
                      onChanged: context.read<RegisterCubit>().onEmailChanged,
                      onClearTap: () => context.read<RegisterCubit>().onEmailChanged(''),
                    ),
                    const SizedBox(height: 16.0),
                    AppPasswordField(
                      value: state.password?.value,
                      label: 'common.password'.tr(),
                      onChanged: context.read<RegisterCubit>().onPasswordChanged,
                    ),
                    const SizedBox(height: 24.0),
                    Builder(builder: (context) {
                      final tncTexts = tr('register.terms_and_conditions').split('**');

                      return RichText(
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: tncTexts[0],
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            TextSpan(
                                text: tncTexts[1],
                                style: Theme.of(context).textTheme.bodySmall,
                                recognizer: TapGestureRecognizer()..onTap = () {}),
                            TextSpan(
                              text: tncTexts[2],
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            TextSpan(
                                text: tncTexts[3],
                                style: Theme.of(context).textTheme.bodySmall,
                                recognizer: TapGestureRecognizer()..onTap = () {}),
                          ],
                        ),
                      );
                    })
                  ],
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}
