import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart' as fiePicker;

import '../../../injection_container.dart';
import '../../../authentication/presentation/bloc/login_bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/login_bloc/auth_state.dart';
import '../../../authentication/presentation/pages/login_page.dart';
import '../bloc/file_upload_bloc.dart';
import '../bloc/file_upload_event.dart';
import '../bloc/file_upload_state.dart';
import '../widgets/app_drawer.dart';
import '../widgets/responsive_body.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<FileUploadBloc>(create: (_) => sl<FileUploadBloc>()),
      ],
      child: const AdminHomeView(),
    );
  }
}

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

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
          centerTitle: true,
        ),
        drawer: AppDrawer(),
        body: BlocListener<FileUploadBloc, FileUploadState>(
          listener: (context, state) {
            if (state is FileUploadSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
              context.read<FileUploadBloc>().add(const ResetStateEvent());
            } else if (state is FileUploadError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          child: ResponsiveBody(onSelectFile: (type) => _selectFile(context, type)),
        ),
      ),
    );
  }

  Future<void> _selectFile(BuildContext context, FileType type) async {
    try {
      final result = await fiePicker.FilePicker.platform.pickFiles(
        type: fiePicker.FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;

        if (type == FileType.firearm) {
          context.read<FileUploadBloc>().add(UploadFirearmFileEvent(filePath: filePath));
        } else {
          context.read<FileUploadBloc>().add(UploadAmmunitionFileEvent(filePath: filePath));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting file: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

enum FileType { firearm, ammunition }
