// @dart=2.9

import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hottie/hottie.dart';
import 'package:logging/logging.dart' as l;

import 'multi_sliver_test.dart';
import 'sliver_clip_test.dart';
import 'sliver_stack_test.dart';

Future<void> main() async {
  l.Logger.root.level = l.Level.ALL;
  l.Logger.root.onRecord.listen(print);
  final logger = l.Logger('runner');
  log('test', name: 'runner');
  logger.finest('ola');
  await runApp(
    TestRunner(main: testAll, child: Container()),
  );
}

@pragma('vm:entry-point')
void hottie() => hottieInner();

void testAll() {
  sliverStackTests();
  sliverClipTests();
  multiSliverTests();
}
