// lib/dashboard/presentation/pages/view_firearms_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../injection_container.dart';
import '../bloc/file_upload_bloc.dart';
import '../bloc/file_upload_event.dart';
import '../bloc/file_upload_state.dart';
import '../../domain/entities/firearm.dart';

class ViewFirearmsPage extends StatelessWidget {
  const ViewFirearmsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FileUploadBloc>()..add(const GetFirearmsEvent()),
      child: const ViewFirearmsView(),
    );
  }
}

class ViewFirearmsView extends StatelessWidget {
  const ViewFirearmsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Firearms'),
        backgroundColor: Colors.orange,
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
                      'Loading firearms...',
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
                        context.read<FileUploadBloc>().add(const GetFirearmsEvent());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is FirearmsLoaded) {
              if (state.firearms.isEmpty) {
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
                        'No firearms found',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                );
              }
              return _buildFirearmsTable(state.firearms);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildFirearmsTable(List<Firearm> firearms) {
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
              headingRowColor: MaterialStateProperty.all(Colors.orange[100]),
              dataRowMaxHeight: 60,
              columnSpacing: 20,
              columns: const [
                DataColumn(
                  label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Brand', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Model', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Generation', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Caliber', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Firing Mechanism', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Make', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
              rows: firearms.map((firearm) {
                return DataRow(
                  cells: [
                    DataCell(Text(firearm.type)),
                    DataCell(Text(firearm.brand)),
                    DataCell(Text(firearm.model)),
                    DataCell(Text(firearm.generation)),
                    DataCell(Text(firearm.caliber)),
                    DataCell(Text(firearm.firingMachanism)),
                    DataCell(Text(firearm.make)),
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