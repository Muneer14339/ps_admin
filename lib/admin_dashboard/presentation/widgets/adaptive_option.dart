
import 'package:flutter/material.dart';

class AdaptiveOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Widget? trailing;
  final double scale;

  const AdaptiveOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.trailing,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(14 / scale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10 / scale),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 26 * scale),
              ),
              SizedBox(width: 12 / scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.w600)),
                    SizedBox(height: 4 / scale),
                    Text(subtitle, style: TextStyle(fontSize: 13 * scale, color: Colors.grey[600])),
                  ],
                ),
              ),
              if (trailing != null) trailing! else const Icon(Icons.cloud_upload, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}