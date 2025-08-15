import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'configs/app_theme.dart';
import 'configs/env.dart';
import 'di.dart';
import 'router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => EasyLocalization(
    supportedLocales: AppEnv.supportedLocales,
    fallbackLocale: AppEnv.mainLocale,
    path: AppEnv.i18nPath,
    child: const _App(),
  );
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
    designSize: const Size(390, 844),
    minTextAdapt: true,
    splitScreenMode: true,
    child: MaterialApp.router(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      title: AppEnv.appName,
      routeInformationParser: getIt<AppRouter>().goRouter.routeInformationParser,
      routeInformationProvider: getIt<AppRouter>().goRouter.routeInformationProvider,
      routerDelegate: getIt<AppRouter>().goRouter.routerDelegate,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      locale: context.locale,
    ),
  );
}
