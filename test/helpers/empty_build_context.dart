import 'package:flutter/widgets.dart';

class EmptyBuildContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }
}
