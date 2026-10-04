import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<({double latitude, double longitude})?> getLocation() async {
  try {
    final completer =
        Completer<({double latitude, double longitude})?>();

    final success = (web.GeolocationPosition position) {
      final coords = position.coords;

      if (!completer.isCompleted) {
        completer.complete((
          latitude: coords.latitude,
          longitude: coords.longitude,
        ));
      }
    }.toJS;

    final error = (web.GeolocationPositionError error) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    }.toJS;

    web.window.navigator.geolocation.getCurrentPosition(
      success,
      error,
    );

    return await completer.future;
  } catch (_) {
    return null;
  }
}