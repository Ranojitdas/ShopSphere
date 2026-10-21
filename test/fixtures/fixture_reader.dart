import 'dart:io';

String fixture(String name) {
  var dir = Directory.current.path;
  if (dir.endsWith('/test') || dir.endsWith('\\test')) {
    dir = Directory.current.parent.path;
  }
  return File('$dir/test/fixtures/$name').readAsStringSync();
}
