import 'package:json_annotation/json_annotation.dart';
import '../../../../entities/user/user.dart';

part 'login_response_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LoginResponseModel {

  const LoginResponseModel({
    required this.user,
    required this.accessToken,
    this.refreshToken,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) => _$LoginResponseModelFromJson(json);

  final UserProfile user;
  final String accessToken;
  final String? refreshToken;

  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);
}
