import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  late PageController _pageController;
  String? _appliedRouteTab;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String? routeTab = GoRouterState.of(
      context,
    ).uri.queryParameters['tab'];
    if (routeTab == _appliedRouteTab) return;
    _appliedRouteTab = routeTab;

    final AppTab? targetTab = _tabFromRoute(routeTab);
    if (targetTab == null || targetTab == _activeTab) return;
    _activeTab = targetTab;
    if (_pageController.hasClients) {
      _pageController.jumpToPage(targetTab.index);
    } else {
      _pageController.dispose();
      _pageController = PageController(initialPage: targetTab.index);
    }
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
    final EdgeInsets safePadding = MediaQuery.paddingOf(context);
    final double navBottom = safePadding.bottom + 56;
    final double navRight = safePadding.right + 18;

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
                navRight: navRight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppTab? _tabFromRoute(String? value) {
    return switch (value) {
      'scan' => AppTab.scan,
      'translate' => AppTab.translate,
      'learn' => AppTab.learn,
      'butty' => AppTab.butty,
      _ => null,
    };
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.pageController,
    required this.activeTab,
    required this.onTabSelected,
    required this.navBottom,
    required this.navRight,
  });

  final PageController pageController;
  final AppTab activeTab;
  final ValueChanged<AppTab> onTabSelected;
  final double navBottom;
  final double navRight;

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
          right: navRight,
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
