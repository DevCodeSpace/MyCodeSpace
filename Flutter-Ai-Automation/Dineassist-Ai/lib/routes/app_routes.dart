abstract final class AppRoutes {
  static const splash = '/';
  static const order = '/order';
  static const qr = '/qr';
  static const tableSelection = '/table-selection';
  static const notFound = '/not-found';

  static String qrWithTable(String tableId) => '$qr/$tableId';
  static String orderWithTable(String tableId) => '$order?table=$tableId';
}
