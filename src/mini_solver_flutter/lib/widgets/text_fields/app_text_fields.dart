import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../generated/colors.gen.dart';

class AppTextField extends StatefulWidget {
  AppTextField({
    super.key,
    this.hint,
    this.label,
    this.validator,
    this.supportingText,
    this.onChanged,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.enabled = true,
    this.focusNode,
    this.errorText,
    this.onTap,
    this.textInputAction,
    this.initialValue,
    this.autoValidationMode,
    this.autoFocus = false,
    this.isRequired = false,
    WidgetStatesController? stateController,
    this.controller,
    this.onFieldSubmitted,
    this.onClearTap,
    this.allowClearButton = true,
  }) : statesController = stateController ?? WidgetStatesController();

  final WidgetStatesController statesController;
  final String? errorText;
  final String? initialValue;
  final String? hint;
  final String? label;
  final TextEditingController? controller;
  final String? supportingText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final FocusNode? focusNode;
  final AutovalidateMode? autoValidationMode;
  final bool autoFocus;
  final void Function(String? value)? onFieldSubmitted;
  final VoidCallback? onClearTap;
  final bool allowClearButton;
  final bool isRequired;
  final VoidCallback? onTap;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final controller = widget.controller ??
      TextEditingController(
        text: widget.initialValue,
      );

  @override
  void initState() {
    widget.statesController.addListener(() {
      setState(() {
        _supportTextColor = _getSupportingTextColor(context, widget.statesController.value, controller.value);
        _hintTextColor = _getHintTextColor(context, widget.statesController.value);
      });
    });
    super.initState();
  }

  Color _getSupportingTextColor(BuildContext context, Set<WidgetState> states, TextEditingValue controllerState) {
    if (states.contains(WidgetState.disabled)) {
      return ColorName.gray400;
    }
    if (controllerState.text.isNotEmpty) {
      return ColorName.gray300;
    }
    return ColorName.gray500;
  }

  Color _getHintTextColor(BuildContext context, Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return ColorName.gray400;
    }
    return ColorName.gray500;
  }

  Color _supportTextColor = ColorName.gray800;
  Color _hintTextColor = ColorName.gray500;

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }
    widget.statesController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    // widget.controller.moveCursorToEnd();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: ColorName.gray500,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextFormField(
          autofocus: widget.autoFocus,
          statesController: widget.statesController,
          autovalidateMode: widget.autoValidationMode,
          textInputAction: widget.textInputAction,
          onTap: widget.onTap,
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          focusNode: widget.focusNode,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: ColorName.gray900,
              ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(left: 12, right: 8, top: 8, bottom: 8),
            label: widget.label != null
                ? Row(
                    children: [
                      Text(
                        widget.label!,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: ColorName.gray800,
                            ),
                      ),
                      if (widget.isRequired)
                        Text(
                          "common.required_symbol".tr(),
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: ColorName.error,
                              ),
                        ),
                    ],
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              maxWidth: 48,
              maxHeight: 40,
            ),
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            error: widget.errorText != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 0),
                    child: Text(
                      widget.errorText!,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: ColorName.brandBlue,
                          ),
                    ),
                  )
                : null,
            helper: widget.supportingText != null
                ? Padding(
                    padding: const EdgeInsets.only(
                      top: 4,
                      left: 16,
                      right: 16,
                      bottom: 0,
                    ),
                    child: Text(
                      widget.supportingText!,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: _supportTextColor,
                          ),
                    ),
                  )
                : null,
            hintText: widget.hint,
            hintStyle: Theme.of(context).inputDecorationTheme.hintStyle?.copyWith(
                  color: _hintTextColor,
                ),
            suffixIcon: widget.suffixIcon ??
                (widget.allowClearButton && controller.text.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: controller.text.isNotEmpty ? widget.onClearTap : null,
                          child: controller.text.isNotEmpty ? Icon(Icons.close) : null,
                        ),
                      )
                    : null),
            errorStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                ),
          ),
          cursorColor: ColorName.gray600,
          obscureText: widget.obscureText,
        ),
      );
}

class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    this.label,
    this.value,
    this.hint,
    this.controller,
    this.description,
    this.validator,
    this.onChanged,
    this.enabled = false,
    this.focusNode,
    this.autoValidationMode,
    this.errorText,
  });

  final String? label;
  final String? value;
  final String? hint;
  final TextEditingController? controller;
  final String? description;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final FocusNode? focusNode;
  final AutovalidateMode? autoValidationMode;
  final String? errorText;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscureText = true;

  void _toggleObscureText() => setState(
        () {
          _obscureText = !_obscureText;
        },
      );

  @override
  Widget build(BuildContext context) => AppTextField(
        hint: widget.hint,
        initialValue: widget.value,
        obscureText: _obscureText,
        controller: widget.controller,
        supportingText: widget.description,
        validator: widget.validator,
        onChanged: widget.onChanged,
        errorText: widget.errorText,
        autoValidationMode: widget.autoValidationMode,
        label: widget.label,
        suffixIcon: IconButton(
          icon: _obscureText
              ? Icon(Icons.visibility_outlined, color: ColorName.gray800,)
              : Icon(Icons.visibility_off_outlined, color: ColorName.gray800,),
          onPressed: _toggleObscureText,
        ),
        keyboardType: TextInputType.visiblePassword,
      );
}
