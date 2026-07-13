/// Android Emulator maps 10.0.2.2 to the development host.
/// Desktop Flutter may use http://localhost:4000.
/// A physical phone must use the PC LAN address, for example
/// http://192.168.1.35:4000.
///
/// Local HTTP is for development only. Production builds must use HTTPS.
const apiBaseUrl = String.fromEnvironment(
  'GROWLY_API_BASE_URL',
  defaultValue: 'http://10.0.2.2:4000',
);
