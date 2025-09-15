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
import '../widgets/armory_tab_view.dart';

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
        backgroundColor: const Color(0xFF0F1115),
        appBar: AppBar(
          backgroundColor: const Color(0xFF151923),
          elevation: 0,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PulseAim',
                style: TextStyle(
                  color: Color(0xFFE8EEF7),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                'Enhanced with Level 3 Schema',
                style: TextStyle(
                  color: Color(0xFF9AA4B2),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFFE8EEF7)),
              onPressed: () {
                context.read<AuthBloc>().add(const LogoutRequested());
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFF57B7FF),
            unselectedLabelColor: const Color(0xFF9AA4B2),
            indicatorColor: const Color(0xFF57B7FF),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.2,
            ),
            tabs: const [
              Tab(text: 'Firearms'),
              Tab(text: 'Ammo'),
              Tab(text: 'Gear'),
              Tab(text: 'Tools & Maint.'),
              Tab(text: 'Loadouts'),
              Tab(text: 'Report'),
            ],
          ),
        ),
        body: userId == null
            ? const Center(
          child: Text(
            'User not authenticated',
            style: TextStyle(color: Color(0xFFE8EEF7)),
          ),
        )
            : TabBarView(
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
      ),
    );
  }
}






