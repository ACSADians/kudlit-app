import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/screens/butty_chat_screen.dart';
import 'package:kudlit_ph/features/home/presentation/screens/learn_tab.dart';
import 'package:kudlit_ph/features/home/presentation/screens/scan_tab.dart';
import 'package:kudlit_ph/features/home/presentation/screens/translate_screen.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/app_header/app_header.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/floating_tab_nav.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  AppTab _activeTab = AppTab.scan;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _activeTab.index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(AppTab tab) {
    if (tab == _activeTab) return;
    setState(() => _activeTab = tab);
    _pageController.animateToPage(
      tab.index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double navBottom = MediaQuery.paddingOf(context).bottom + 20;

    return Scaffold(
      body: Column(
        children: <Widget>[
          const AppHeader(),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: _HomeBody(
                pageController: _pageController,
                activeTab: _activeTab,
                onTabSelected: _onTabSelected,
                navBottom: navBottom,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.pageController,
    required this.activeTab,
    required this.onTabSelected,
    required this.navBottom,
  });

  final PageController pageController;
  final AppTab activeTab;
  final ValueChanged<AppTab> onTabSelected;
  final double navBottom;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        PageView(
          controller: pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            const ScanTab(),
            const TranslateScreen(),
            LearnTab(onSwitchToButty: () => onTabSelected(AppTab.butty)),
            const ButtyChatScreen(),
          ],
        ),
        Positioned(
          right: 18,
          bottom: navBottom,
          child: FloatingTabNav(
            activeTab: activeTab,
            onTabSelected: onTabSelected,
          ),
        ),
      ],
    );
  }
}
