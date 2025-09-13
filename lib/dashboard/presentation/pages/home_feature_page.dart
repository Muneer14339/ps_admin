// lib/home_feature/presentation/pages/home_feature_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_picker/file_picker.dart' as fiePicker;
import '../../../injection_container.dart';
import '../../../authentication/presentation/bloc/login_bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/login_bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/login_bloc/auth_state.dart';
import '../../../authentication/presentation/pages/login_page.dart';
import '../bloc/file_upload_bloc.dart';
import '../bloc/file_upload_event.dart';
import '../bloc/file_upload_state.dart';

class HomeFeaturePage extends StatelessWidget {
  const HomeFeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<FileUploadBloc>(create: (_) => sl<FileUploadBloc>()),
      ],
      child: const HomeFeatureView(),
    );
  }
}

class HomeFeatureView extends StatelessWidget {
  const HomeFeatureView({super.key});

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
        appBar: AppBar(
          title: const Text('Home'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
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
        body: BlocListener<FileUploadBloc, FileUploadState>(
          listener: (context, state) {
            if (state is FileUploadSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<FileUploadBloc>().add(const ResetStateEvent());
            } else if (state is FileUploadError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Update Database',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildUploadOption(
                          context,
                          'Update Firearm',
                          Icons.security,
                          'Upload firearm data from CSV/Excel file',
                              () => _selectFile(context, FileType.firearm),
                          Colors.orange,
                        ),
                        const SizedBox(height: 20),
                        _buildUploadOption(
                          context,
                          'Update Ammunition',
                          Icons.bolt,
                          'Upload ammunition data from CSV/Excel file',
                              () => _selectFile(context, FileType.ammunition),
                          Colors.blue,
                        ),
                        const SizedBox(height: 30),
                        BlocBuilder<FileUploadBloc, FileUploadState>(
                          builder: (context, state) {
                            if (state is FileUploadLoading) {
                              return const Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 10),
                                  Text('Processing file...'),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadOption(
      BuildContext context,
      String title,
      IconData icon,
      String subtitle,
      VoidCallback onPressed,
      Color color,
      ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectFile(BuildContext context, FileType type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: fiePicker.FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;

        if (type == FileType.firearm) {
          context.read<FileUploadBloc>().add(
            UploadFirearmFileEvent(filePath: filePath),
          );
        } else {
          context.read<FileUploadBloc>().add(
            UploadAmmunitionFileEvent(filePath: filePath),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

enum FileType { firearm, ammunition }