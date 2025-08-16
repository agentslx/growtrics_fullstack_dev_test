import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../solving/ui/pages/solving_main_page.dart';
import '../../../profile/ui/pages/profile_page.dart';
import '../../blocs/tabs_cubit/tabs_cubit.dart';

class HomeTabsPage extends StatelessWidget {
  const HomeTabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TabsCubit(),
      child: Builder(
        builder: (context) => BlocBuilder<TabsCubit, TabsState>(
          builder: (context, state) {
            final cubit = context.read<TabsCubit>();
            return Scaffold(
              body: PageView(
                controller: cubit.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  // Solve tab shows the session list page
                  SolvingMainPage(),
                  // Profile tab
                  ProfilePage(),
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: state.index,
                onTap: cubit.changeTab,
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.star_border_outlined),
                    label: 'tabs.solve'.tr(),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.person_outline),
                    label: 'tabs.profile'.tr(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
