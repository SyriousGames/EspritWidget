import 'package:logger/logger.dart';

/// Simple way to create a [Logger].
Logger getLogger(String loggerName) {
  return Logger(printer: PrettyPrinter());
}
