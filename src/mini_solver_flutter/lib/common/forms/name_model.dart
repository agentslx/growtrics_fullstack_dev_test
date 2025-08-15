import 'package:easy_localization/easy_localization.dart';
import 'package:formz/formz.dart';

enum NameValidationError { empty }

class Name extends FormzInput<String, NameValidationError> {
  const Name.pure() : super.pure('');

  const Name.dirty([super.value = '']) : super.dirty();

  @override
  NameValidationError? validator(String value) {
    final checkValue = value.trim();
    if (checkValue.isEmpty) {
      return NameValidationError.empty;
    }
    return null;
  }

  static String getError(NameValidationError value) {
    switch (value) {
      case NameValidationError.empty:
        return 'validation.must_not_be_empty'.tr();
    }
  }
}
