import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pa_sreens/dashboard/presentation/widgets/section_title.dart';

import '../bloc/file_upload_bloc.dart';
import '../bloc/file_upload_state.dart';
import '../pages/home_feature_page.dart';
import '../pages/view_ammunitions_page.dart';
import '../pages/view_firearms_page.dart';
import 'adaptive_option.dart';
import 'header.dart';


const _kPrimaryGradientStart = Color(0xFF6A11CB);
const _kPrimaryGradientEnd = Color(0xFF2575FC);
const _kCardRadius = 16.0;
const _kCardElevation = 6.0;
const _kPadding = 20.0;

class ResponsiveBody extends StatelessWidget {
  final void Function(FileType) onSelectFile;
  const ResponsiveBody({required this.onSelectFile});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kPrimaryGradientStart, _kPrimaryGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isWide = width >= 800;
        final scale = (width / 800).clamp(0.8, 1.25);

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(_kPadding),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 900 : 600),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kCardRadius)),
                elevation: _kCardElevation,
                child: Padding(
                  padding: EdgeInsets.all(_kPadding * (1 / scale)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Header(scale: scale),
                      SizedBox(height: 24 / scale),
                      SectionTitle('Upload Data', scale: scale),
                      SizedBox(height: 12 / scale),
                      AdaptiveOption(
                        title: 'Update Firearm',
                        subtitle: 'Upload firearm data from CSV/Excel file',
                        icon: Icons.security,
                        color: Colors.orange,
                        onTap: () => onSelectFile(FileType.firearm),
                        scale: scale,
                      ),
                      SizedBox(height: 12 / scale),
                      AdaptiveOption(
                        title: 'Update Ammunition',
                        subtitle: 'Upload ammunition data from CSV/Excel file',
                        icon: Icons.bolt,
                        color: Colors.blue,
                        onTap: () => onSelectFile(FileType.ammunition),
                        scale: scale,
                      ),
                      SizedBox(height: 20 / scale),
                      SectionTitle('View Data', scale: scale),
                      SizedBox(height: 12 / scale),
                      AdaptiveOption(
                        title: 'View Firearms',
                        subtitle: 'View all firearms in database',
                        icon: Icons.visibility,
                        color: Colors.green,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewFirearmsPage())),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        scale: scale,
                      ),
                      SizedBox(height: 12 / scale),
                      AdaptiveOption(
                        title: 'View Ammunitions',
                        subtitle: 'View all ammunitions in database',
                        icon: Icons.list,
                        color: Colors.purple,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewAmmunitionsPage())),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        scale: scale,
                      ),
                      const SizedBox(height: 18),
                      BlocBuilder<FileUploadBloc, FileUploadState>(builder: (context, state) {
                        if (state is FileUploadLoading) {
                          return Column(
                            children: const [CircularProgressIndicator(), SizedBox(height: 10), Text('Processing file...')],
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}