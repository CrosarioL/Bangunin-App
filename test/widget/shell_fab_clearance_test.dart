import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/features/shell/presentation/app_shell.dart';

/// Same nesting as the app: a page Scaffold with a centre-float button,
/// inside the shell Scaffold whose floating tab bar the page extends behind.
Widget _layout() => MaterialApp(
  home: Scaffold(
    extendBody: true,
    bottomNavigationBar: SafeArea(
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: NavigationBar(
        key: const Key('nav'),
        height: kShellNavHeight,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.alarm), label: 'a'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'b'),
        ],
      ),
    ),
    body: Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Builder(
        builder: (context) => Padding(
          padding: EdgeInsets.only(bottom: shellFabBottomPadding(context)),
          child: const SizedBox(key: Key('fab'), width: 66, height: 66),
        ),
      ),
      body: const SizedBox.expand(),
    ),
  ),
);

void main() {
  for (final (name, bottomInset) in [
    ('home-indicator iPhone', 34.0),
    ('Home-button iPhone', 0.0),
  ]) {
    testWidgets('new-alarm button clears the tab bar on a $name', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = FakeViewPadding(top: 47, bottom: bottomInset);
      tester.view.viewPadding = FakeViewPadding(top: 47, bottom: bottomInset);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_layout());

      final nav = tester.getRect(find.byKey(const Key('nav')));
      final fab = tester.getRect(find.byKey(const Key('fab')));
      expect(fab.bottom, lessThanOrEqualTo(nav.top - 8));
    });
  }
}
