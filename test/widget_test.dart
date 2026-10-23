import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/app.dart';

void main() {
  testWidgets('Video player app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const VideoPlayerApp());

    expect(find.text('Video Player'), findsOneWidget);
    expect(find.text('Nothing playing'), findsOneWidget);
  });
}