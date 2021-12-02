import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    lineLength: 0,
    errorMethodCount: 3,
    // noBoxingByDefault: true,
    colors: true,
    printEmojis: true,
  ),
);
