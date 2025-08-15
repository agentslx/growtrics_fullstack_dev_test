import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../entities/user/user.dart';
import '../../../../generated/colors.gen.dart';
import '../../../../widgets/components/circular_loading_indicator.dart';
import '../../../home/router.dart';
import '../../cubits/loading_cubit/loading_cubit.dart';
import '../../router.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoadingCubit>(
      create: (_) => LoadingCubit(),
      child: BlocConsumer<LoadingCubit, LoadingState>(
        listener: (context, state) {
          if (state.authenticationState == AuthenticationState.unauthenticated) {
            context.go(AuthRouter.signUp);
          } else if (state.authenticationState == AuthenticationState.loggedInNeedVerify) {
            context.go(HomeRouter.home);
          } else if (state.authenticationState == AuthenticationState.loggedIn) {
            context.go(HomeRouter.home);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: ColorName.white,
            body: Center(
              child: CircularLoadingIndicator(),
            ),
          );
        },
      ),
    );
  }
}
