import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                children: [
                  // Solve tab placeholder
                  Container(),
                  // Profile tab placeholder
                  Container(),
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: state.index,
                onTap: cubit.changeTab,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.star_border_outlined),
                    label: 'Solve',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: 'Profile',
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
