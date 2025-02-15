// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library firebase_core_web;

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_web/src/interop/package_web_tweaks.dart';
import 'package:firebase_core_web/src/interop/utils/es6_interop.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:meta/meta.dart';
import 'package:web/web.dart' as web;

import 'src/interop/core.dart' as firebase;

part 'src/firebase_app_web.dart';
part 'src/firebase_core_web.dart';
part 'src/firebase_sdk_version.dart';

/// Returns a [FirebaseAppWeb] instance from [firebase.App].
FirebaseAppPlatform _createFromJsApp(firebase.App jsApp) {
  return FirebaseAppWeb._(jsApp.name, _createFromJsOptions(jsApp.options));
}

/// Returns a [FirebaseOptions] instance from [firebase.FirebaseOptions].
FirebaseOptions _createFromJsOptions(firebase.FirebaseOptions options) {
  return FirebaseOptions(
    apiKey: options.apiKey,
    authDomain: options.authDomain,
    databaseURL: options.databaseURL,
    projectId: options.projectId,
    storageBucket: options.storageBucket,
    messagingSenderId: options.messagingSenderId,
    appId: options.appId,
    measurementId: options.measurementId,
  );
}

/// Returns a code from a JavaScript error.
///
/// When the Firebase JS SDK throws an error, it contains a code which can be
/// used to identify the specific type of error. This helper function is used
/// to keep error messages consistent across different platforms.
String _getJSErrorCode(JSError e) {
  if (e.name == 'FirebaseError') {
    return e.code ?? '';
  }

  return '';
}

/// Returns a [FirebaseException] if the error is a Firebase Error.
///
/// If a JavaScript error is thrown and not manually handled using the code,
/// this function ensures that if the error is Firebase related, it is instead
/// re-created as a [FirebaseException] with a familiar code and message.
FirebaseException _catchJSError(JSError e) {
  if (e.name == 'FirebaseError') {
    String code = e.code ?? '';
    String message = e.message ?? '';

    if (code.contains('/')) {
      List<String> chunks = code.split('/');
      code = chunks[chunks.length - 1];
    }

    return FirebaseException(
      plugin: 'core',
      code: code,
      message: message.replaceAll(' ($code)', ''),
    );
  }

  throw e;
}
