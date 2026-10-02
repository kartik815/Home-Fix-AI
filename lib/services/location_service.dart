import 'location_service_stub.dart'
    if (dart.library.js_interop) 'location_service_web.dart';

Future<({double latitude, double longitude})?> getWebLocation() {
  return getLocation();
}