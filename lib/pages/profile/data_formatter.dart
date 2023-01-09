import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

MaskTextInputFormatter phoneNumberFormatter = MaskTextInputFormatter(
  mask: '+7 ### ### ## ##',
  filter: {
    "#": RegExp(r'[0-9]'),
    '7': RegExp('7'),
  },
  type: MaskAutoCompletionType.lazy,
);
