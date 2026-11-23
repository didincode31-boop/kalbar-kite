import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalbarku/main.dart';

void main() {
  testWidgets('Kalbar Kite menampilkan halaman login', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Login()));
    expect(find.text('Kalbar Kite'), findsOneWidget);
    expect(find.text('Masuk ke Akun'), findsOneWidget);
    expect(find.text('Masuk Sekarang'), findsOneWidget);
    expect(find.text('Belum punya akun? Daftar', findRichText: true), findsOneWidget);
  });
}
