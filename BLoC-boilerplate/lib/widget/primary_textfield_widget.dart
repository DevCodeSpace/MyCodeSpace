import 'package:bloc_boiler_plate/const/primary_theme.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

typedef Validator = String? Function(String?);

// Common text filed for all screen
class PrimaryTextFieldWidget extends StatefulWidget {
  final String? placeholder;
  final String? label;
  final String? hint;
  final String obscuringCharacter;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompletd;
  final Validator? validator;
  final AutovalidateMode? autovalidateMode;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int maxLine;
  final TextInputAction? textInputAction;
  final FocusNode? focus;

  const PrimaryTextFieldWidget(
      {super.key,
      this.controller,
      this.obscuringCharacter = "•",
      this.onChanged,
      this.placeholder,
      this.suffixIcon,
      this.validator,
      this.maxLength,
      this.keyboardType,
      this.label,
      this.hint,
      this.textInputAction,
      this.autovalidateMode,
      this.maxLine = 1,
      this.onCompletd,
      this.focus});

  @override
  State<PrimaryTextFieldWidget> createState() => _PrimaryTextFieldWidgetState();
}

class _PrimaryTextFieldWidgetState extends State<PrimaryTextFieldWidget> {
  bool showPass = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label ?? "",
          style: const TextStyle(
              color: typeofContactColor,
              fontSize: 14,
              fontWeight: FontWeight.w500),
        ),
        5.heightBox,
        SizedBox(
          // height: widget.maxLine == 1 ? 45 : null,
          child: TextFormField(
            textInputAction: widget.textInputAction,
            focusNode: widget.focus,
            autovalidateMode: widget.autovalidateMode,
            validator: widget.validator,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            onFieldSubmitted: widget.onCompletd,
            obscureText: showPass
                ? !showPass
                : widget.keyboardType != null &&
                    TextInputType.visiblePassword == widget.keyboardType,
            obscuringCharacter: widget.obscuringCharacter,
            controller: widget.controller,
            onChanged: widget.onChanged,
            maxLines: widget.maxLine,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                  color: textColor, fontSize: 16, fontWeight: FontWeight.w400),
              isDense: true,
              isCollapsed: true,
              contentPadding:
                  const EdgeInsets.only(bottom: 10, top: 12, left: 10),
              floatingLabelStyle: const TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(
                  color: txtBorderColor,
                ),
              ),
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: errorColor)),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: txtBorderColor),
              ),
              errorBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: errorColor)),
              filled: true,
              fillColor: Colors.transparent,
              // Check if the keyboard type is for a password field and set the suffix icon accordingly
              suffixIcon: TextInputType.visiblePassword == widget.keyboardType
                  ? showPass
                      ? const Icon(Icons.visibility).onTap(() {
                          setState(() {
                            showPass = !showPass;
                          });
                        })
                      : const Icon(Icons.visibility_off).onTap(() {
                          setState(() {
                            showPass = !showPass;
                          });
                        })
                  : widget.suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}
