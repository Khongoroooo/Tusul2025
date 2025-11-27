// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "email": MessageLookupByLibrary.simpleMessage("E-mail"),
    "fillAllFields": MessageLookupByLibrary.simpleMessage(
      "Please fill all fields!",
    ),
    "forgotPassword": MessageLookupByLibrary.simpleMessage("Forgot password?"),
    "forgotPasswordDialogContent": MessageLookupByLibrary.simpleMessage(
      "Password recovery functionality goes here.",
    ),
    "forgotPasswordDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Forgot password",
    ),
    "fullName": MessageLookupByLibrary.simpleMessage("Full name"),
    "haveAccountSignIn": MessageLookupByLibrary.simpleMessage(
      "Already have an account? Sign in",
    ),
    "invalidEmail": MessageLookupByLibrary.simpleMessage(
      "Invalid email address",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "passwordNotMatch": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "reEnterPassword": MessageLookupByLibrary.simpleMessage(
      "Re-enter password",
    ),
    "registerSuccess": MessageLookupByLibrary.simpleMessage(
      "Registration successful!",
    ),
    "signIn": MessageLookupByLibrary.simpleMessage("Sign in"),
    "signUp": MessageLookupByLibrary.simpleMessage("Sign up"),
    "weakPassword": MessageLookupByLibrary.simpleMessage(
      "Password is too weak",
    ),
  };
}
