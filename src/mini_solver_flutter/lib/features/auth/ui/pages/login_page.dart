import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';

import '../../../../generated/colors.gen.dart';
import '../../../../widgets/buttons/app_buttons.dart';
import '../../../../widgets/containers/app_scaffold.dart';
import '../../../../widgets/containers/common_form_body.dart';
import '../../../../widgets/snackbar/app_snackbar.dart';
import '../../../../widgets/text_fields/app_text_fields.dart';
import '../../../home/router.dart';
import '../../cubits/login_cubit/login_cubit.dart';
import '../../router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginCubit>(
      create: (_) => LoginCubit(),
      child: Builder(builder: (context) {
        return BlocConsumer<LoginCubit, LoginState>(
            listenWhen: (previous, current) => previous.loginStatus != current.loginStatus,
            listener: (context, state) {
              // If login fails
              if (state.loginStatus == FormzSubmissionStatus.failure) {
                AppSnackbar.error(
                  context: context,
                  message: state.errorMessage ?? tr('common.unknown_error'),
                );
              }

              // If login is successful, navigate to the onboarding page
              if (state.loginStatus == FormzSubmissionStatus.success) {
                context.go(HomeRouter.home);
              }
            },
            builder: (context, state) {
              return AppScaffold(
                body: CommonFormBody(
                  title: 'login.title'.tr(),
                  subtitle: 'login.subtitle'.tr(),
                  bottomWidget: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppPrimaryButton(
                        label: 'common.sign_in'.tr(),
                        isLoading: state.loginStatus.isInProgress,
                        onPressed: state.isValid ? context.read<LoginCubit>().login : null,
                        width: double.infinity,
                        size: AppButtonSize.large,
                      ),
                      const SizedBox(height: 16.0),
                      Text('login.sign_up_prompt'.tr(), style: Theme.of(context).textTheme.bodySmall),
                      InkWell(
                          onTap: () {
                            context.go(AuthRouter.signUp);
                          },
                          child: Text('login.create_an_account'.tr(), style: Theme.of(context).textTheme.bodySmall)),
                    ],
                  ),
                  child: Column(
                    children: [
                      AppTextField(
                        initialValue: state.email?.value,
                        label: 'common.email_address'.tr(),
                        onChanged: context.read<LoginCubit>().onEmailChanged,
                        onClearTap: () => context.read<LoginCubit>().onEmailChanged(''),
                      ),
                      const SizedBox(height: 16.0),
                      AppPasswordField(
                        value: state.password?.value,
                        label: 'common.password'.tr(),
                        onChanged: context.read<LoginCubit>().onPasswordChanged,
                      ),
                      const SizedBox(height: 16.0),
                      Center(
                        child: InkWell(
                          onTap: () {
                          },
                          child: Text(
                            'login.forgot_password'.tr(),
                            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                  color: ColorName.gray900,
                                ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            });
      }),
    );
  }
}
