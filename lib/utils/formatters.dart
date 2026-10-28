import 'package:intl/intl.dart';

class AppFormat {
  AppFormat._();

  static final DateFormat time = DateFormat('hh:mm a');
  static final DateFormat dateTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat longDate = DateFormat('EEEE, d MMMM yyyy');
}
