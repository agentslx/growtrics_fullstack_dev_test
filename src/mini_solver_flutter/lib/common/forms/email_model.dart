import 'package:easy_localization/easy_localization.dart';
import 'package:formz/formz.dart';

enum EmailValidationError { empty, invalid }

class Email extends FormzInput<String, EmailValidationError> {
  const Email.pure() : super.pure('');

  const Email.dirty([super.value = '']) : super.dirty();

  static final RegExp _emailRegExp = RegExp(
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  );

  @override
  EmailValidationError? validator(String value) {
    final checkValue = value.trim();
    if (checkValue.isEmpty) {
      return EmailValidationError.empty;
    }

    return _emailRegExp.hasMatch(checkValue) ? null : EmailValidationError.invalid;
  }

  static String getError(EmailValidationError value) {
    switch (value) {
      case EmailValidationError.empty:
        return 'validation.must_not_be_empty'.tr();
      case EmailValidationError.invalid:
        return 'validation.invalid_email'.tr();
    }
  }
}
