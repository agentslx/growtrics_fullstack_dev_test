import 'package:easy_localization/easy_localization.dart';
import 'package:formz/formz.dart';

enum PasswordValidationError { empty, short, long, noDigit, noLowercase, noUppercase, match, noSpecialCharacter }

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure({required this.checkFormat}) : super.pure('');

  const Password.dirty(this.checkFormat, [String value = '']) : super.dirty(value);

  final bool checkFormat;

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) {
      return PasswordValidationError.empty;
    }
    if (!checkFormat) return null;

    if (!hasEnoughLength) {
      return PasswordValidationError.short;
    } else if (!hasDigit) {
      return PasswordValidationError.noDigit;
    } else if (!hasSymbol) {
      return PasswordValidationError.noSpecialCharacter;
    }
    return null;
  }

  bool get hasEnoughLength => value.length >= 8;

  bool get hasDigit => value.contains(RegExp(r'[0-9]'));

  bool get hasSymbol => value.contains(RegExp(r'[!-\/:-@[-`{-~]'));

  static String getError(PasswordValidationError value) {
    switch (value) {
      case PasswordValidationError.empty:
        return 'validation.must_not_be_empty'.tr();
      case PasswordValidationError.short:
        return 'validation.invalid_password'.tr();
      case PasswordValidationError.long:
        return 'validation.invalid_password'.tr();
      case PasswordValidationError.noDigit:
        return 'validation.invalid_password'.tr();
      case PasswordValidationError.noLowercase:
        return 'validation.invalid_password'.tr();
      case PasswordValidationError.noUppercase:
        return 'validation.invalid_password'.tr();
      case PasswordValidationError.match:
        return 'validation.invalid_password'.tr();
      case PasswordValidationError.noSpecialCharacter:
        return 'validation.invalid_password'.tr();
    }
  }
}
