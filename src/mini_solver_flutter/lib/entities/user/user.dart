import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

enum AuthenticationState {
  initial,
  unauthenticated,
  loggedIn,
  loggedInNeedVerify,
  error,
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.isVerified,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  final String id;
  final String name;
  final String email;
  final bool isVerified;

  @override
  List<Object?> get props => [
    id,
  ];

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    bool? isVerified,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: fullName ?? this.name,
      email: email ?? this.email,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
