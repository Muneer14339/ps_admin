// lib/user_dashboard/presentation/pages/user_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../injection_container.dart';
import '../../../authentication/presentation/bloc/login_bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/login_bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/login_bloc/auth_state.dart';
import '../../../authentication/presentation/pages/login_page.dart';
import '../bloc/armory_bloc.dart';
import '../core/theme/app_theme.dart';
import '../widgets/armory_tab_view.dart';
import '../widgets/common/common_widgets.dart';

class UserDashboardPage extends StatelessWidget {
  const UserDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<ArmoryBloc>(create: (_) => sl<ArmoryBloc>()),
      ],
      child: const UserDashboardView(),
    );
  }
}

class UserDashboardView extends StatefulWidget {
  const UserDashboardView({super.key});

  @override
  State<UserDashboardView> createState() => _UserDashboardViewState();
}

class _UserDashboardViewState extends State<UserDashboardView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? userId;
  int _selectedTabIndex = 0;

  final List<TabInfo> _tabs = [
    TabInfo(
      title: 'Firearms',
      icon: Icons.gps_fixed,
      tabType: ArmoryTabType.firearms,
    ),
    TabInfo(
      title: 'Ammo',
      icon: Icons.fiber_manual_record,
      tabType: ArmoryTabType.ammunition,
    ),
    TabInfo(
      title: 'Gear',
      icon: Icons.inventory,
      tabType: ArmoryTabType.gear,
    ),
    TabInfo(
      title: 'Tools & Maint.',
      icon: Icons.build,
      tabType: ArmoryTabType.tools,
    ),
    TabInfo(
      title: 'Loadouts',
      icon: Icons.playlist_add_check,
      tabType: ArmoryTabType.loadouts,
    ),
    TabInfo(
      title: 'Report',
      icon: Icons.analytics,
      tabType: ArmoryTabType.report,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      },
      child: OrientationBuilder(
        builder: (context, orientation) {
          return Scaffold(
            backgroundColor: AppColors.primaryBackground,
            appBar: orientation == Orientation.portrait ? _buildAppBar() : null,
            body: userId == null
                ? _buildUnauthenticatedView()
                : orientation == Orientation.portrait
                ? _buildPortraitLayout()
                : _buildLandscapeLayout(),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.cardBackground,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PulseAim',
            style: AppTextStyles.pageTitle,
          ),
          Text(
            'Enhanced with Level 3 Schema',
            style: AppTextStyles.pageSubtitle,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.logout,
            color: AppColors.primaryText,
            size: AppSizes.mediumIcon,
          ),
          onPressed: () {
            context.read<AuthBloc>().add(const LogoutRequested());
          },
        ),
      ],
      bottom: _buildTabBar(),
    );
  }

  PreferredSizeWidget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: AppColors.accentText,
      unselectedLabelColor: AppColors.secondaryText,
      indicatorColor: AppColors.accentText,
      labelStyle: AppTextStyles.tabLabel,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.itemSpacing),
      tabs: _tabs.map((tab) => Tab(text: tab.title)).toList(),
    );
  }

  Widget _buildUnauthenticatedView() {
    return Center(
      child: CommonWidgets.buildError('User not authenticated'),
    );
  }

  Widget _buildPortraitLayout() {
    return Container(
      decoration: AppDecorations.pageDecoration,
      child: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) => ArmoryTabView(
          userId: userId!,
          tabType: tab.tabType,
        )).toList(),
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        // Sidebar Navigation (20% width)
        Container(
          width: MediaQuery.of(context).size.width * 0.2,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: Border(
              right: BorderSide(
                color: AppColors.primaryBorder,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.primaryBorder,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PulseAim',
                      style: AppTextStyles.pageTitle.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enhanced with Level 3 Schema',
                      style: AppTextStyles.pageSubtitle.copyWith(fontSize: 11),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              // Navigation Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _tabs.length,
                  itemBuilder: (context, index) {
                    final tab = _tabs[index];
                    final isSelected = _selectedTabIndex == index;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accentText.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: AppColors.accentText.withOpacity(0.3))
                            : null,
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        leading: Icon(
                          tab.icon,
                          color: isSelected
                              ? AppColors.accentText
                              : AppColors.secondaryText,
                          size: 20,
                        ),
                        title: Text(
                          tab.title,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.accentText
                                : AppColors.primaryText,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedTabIndex = index;
                          });
                          _tabController.animateTo(index);
                        },
                      ),
                    );
                  },
                ),
              ),

              // Logout Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.primaryBorder,
                      width: 1,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(const LogoutRequested());
                    },
                    icon: Icon(
                      Icons.logout,
                      color: AppColors.primaryText,
                      size: 16,
                    ),
                    label: Text(
                      'Logout',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 12,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Main Content (80% width)
        Expanded(
          child: Container(
            decoration: AppDecorations.pageDecoration,
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((tab) => ArmoryTabView(
                userId: userId!,
                tabType: tab.tabType,
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class TabInfo {
  final String title;
  final IconData icon;
  final ArmoryTabType tabType;

  const TabInfo({
    required this.title,
    required this.icon,
    required this.tabType,
  });
}