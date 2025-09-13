import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String uid;
  final String email;
  final String firstName;
  final String? location;
  final DateTime createdAt;
  final int role;

  const User({
    required this.uid,
    required this.email,
    required this.firstName,
    this.location,
    required this.role,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [uid, email, firstName, location, createdAt,role];
}