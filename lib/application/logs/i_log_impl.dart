import 'package:logger/logger.dart';

import './i_log.dart';

class ILogImpl implements ILog {

  final _logger = Logger();
  @override
  void debug(message, [error, StackTrace? stackTrace]) => _logger.d(message, error: error, stackTrace: stackTrace);

  @override
  void error(message, [error, StackTrace? stackTrace]) => _logger.e(message, error: error, stackTrace: stackTrace);

  @override
  void info(message, [error, StackTrace? stackTrace]) => _logger.i(message, error: error, stackTrace: stackTrace);

  @override
  void warning(message, [error, StackTrace? stackTrace]) => _logger.w(message, error: error, stackTrace: stackTrace);

  

}