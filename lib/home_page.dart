import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'injection_container.dart';
import 'authentication/presentation/bloc/auth_bloc.dart';
import 'authentication/presentation/bloc/auth_event.dart';
import 'authentication/presentation/bloc/auth_state.dart';
import 'authentication/presentation/pages/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  String? firstName;
  final nameController = TextEditingController();

  Future<void> _getName() async {
    if (user == null) return;
    final snap =
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    setState(() => firstName = snap['firstName']);
    nameController.text = firstName ?? '';
  }

  Future<void> _updateName() async {
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .update({'firstName': nameController.text});
    setState(() => firstName = nameController.text);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Name updated')));
  }

  @override
  void initState() {
    super.initState();
    _getName();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Home')),
          drawer: Drawer(
            child: ListView(
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: Text(
                    firstName != null ? 'Hi, $firstName!' : 'Menu',
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    context.read<AuthBloc>().add(const LogoutRequested());
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(firstName == null
                    ? 'Loading...'
                    : 'Welcome, $firstName!'),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Edit Name'),
                  ),
                ),
                ElevatedButton(
                  onPressed: _updateName,
                  child: const Text('Update'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
