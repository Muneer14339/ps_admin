// lib/dashboard/presentation/pages/view_ammunitions_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../injection_container.dart';
import '../bloc/file_upload_bloc.dart';
import '../bloc/file_upload_event.dart';
import '../bloc/file_upload_state.dart';
import '../../domain/entities/ammunition.dart';

class ViewAmmunitionsPage extends StatelessWidget {
  const ViewAmmunitionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FileUploadBloc>()..add(const GetAmmunitionsEvent()),
      child: const ViewAmmunitionsView(),
    );
  }
}

class ViewAmmunitionsView extends StatelessWidget {
  const ViewAmmunitionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Ammunitions'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BlocBuilder<FileUploadBloc, FileUploadState>(
          builder: (context, state) {
            if (state is FileUploadLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Loading ammunitions...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              );
            } else if (state is FileUploadError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red[300],
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<FileUploadBloc>().add(const GetAmmunitionsEvent());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is AmmunitionsLoaded) {
              if (state.ammunitions.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        color: Colors.white70,
                        size: 64,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No ammunitions found',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                );
              }
              return _buildAmmunitionsTable(state.ammunitions);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildAmmunitionsTable(List<Ammunition> ammunitions) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.blue[100]),
              dataRowMaxHeight: 60,
              columnSpacing: 30,
              columns: const [
                DataColumn(
                  label: Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Brand', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Caliber', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Bullet Weight (gr)', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
              rows: ammunitions.asMap().entries.map((entry) {
                final index = entry.key + 1; // 1-based index
                final ammunition = entry.value;
                return DataRow(
                  cells: [
                    DataCell(Text(index.toString())), // index column
                    DataCell(Text(ammunition.brand)),
                    DataCell(Text(ammunition.caliber)),
                    DataCell(Text(ammunition.bulletWeight)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

}