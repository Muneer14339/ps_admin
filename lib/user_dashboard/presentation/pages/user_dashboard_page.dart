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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
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
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        appBar: _buildAppBar(),
        body: userId == null ? _buildUnauthenticatedView() : _buildMainContent(),
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
      tabs: const [
        Tab(text: 'Firearms'),
        Tab(text: 'Ammo'),
        Tab(text: 'Gear'),
        Tab(text: 'Tools & Maint.'),
        Tab(text: 'Loadouts'),
        Tab(text: 'Report'),
      ],
    );
  }

  Widget _buildUnauthenticatedView() {
    return Center(
      child: CommonWidgets.buildError('User not authenticated'),
    );
  }

  Widget _buildMainContent() {
    return Container(
      decoration: AppDecorations.pageDecoration,
      child: TabBarView(
        controller: _tabController,
        children: [
          ArmoryTabView(
            userId: userId!,
            tabType: ArmoryTabType.firearms,
          ),
          ArmoryTabView(
            userId: userId!,
            tabType: ArmoryTabType.ammunition,
          ),
          ArmoryTabView(
            userId: userId!,
            tabType: ArmoryTabType.gear,
          ),
          ArmoryTabView(
            userId: userId!,
            tabType: ArmoryTabType.tools,
          ),
          ArmoryTabView(
            userId: userId!,
            tabType: ArmoryTabType.loadouts,
          ),
          ArmoryTabView(
            userId: userId!,
            tabType: ArmoryTabType.report,
          ),
        ],
      ),
    );
  }
}