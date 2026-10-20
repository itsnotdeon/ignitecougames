import 'package:flutter_test/flutter_test.dart';
import 'package:ignite_couple_games/data/html_legacy_content.dart';

void main() {
  group('HTML-derived IGNITE content', () {
    test('preserves the source prompt collection sizes', () {
      expect(HtmlLegacyContent.cards, hasLength(27));
      expect(HtmlLegacyContent.truth, hasLength(28));
      expect(HtmlLegacyContent.dare, hasLength(28));
      expect(HtmlLegacyContent.commands, hasLength(28));
    });

    test('preserves roleplay context/challenge pairs', () {
      expect(HtmlLegacyContent.roleplayContext, hasLength(13));
      expect(HtmlLegacyContent.roleplayChallenge, hasLength(13));
    });

    test('does not contain blank prompt entries', () {
      for (final prompt in [
        ...HtmlLegacyContent.cards,
        ...HtmlLegacyContent.truth,
        ...HtmlLegacyContent.dare,
        ...HtmlLegacyContent.commands,
        ...HtmlLegacyContent.roleplayContext,
        ...HtmlLegacyContent.roleplayChallenge,
      ]) {
        expect(prompt.trim(), isNotEmpty);
      }
    });
  });
}