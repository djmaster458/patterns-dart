import 'package:patterns/patterns.dart';
import 'package:test/test.dart';

void main() {
  group('LFSR', () {
    test('cycles through all non-zero states in an 8-bit configuration', () {
      final lfsr = LFSR(1, 0xB8, bits: 8);
      final states = <int>{};

      for (var i = 0; i < 255; i++) {
        states.add(lfsr.state);
        lfsr.next();
        expect(lfsr.state, inInclusiveRange(1, 0xFF));
      }

      expect(states, hasLength(255));
      expect(lfsr.state, 1);
    });

    test('supports wider registers', () {
      final lfsr = LFSR(1, 0xB400, bits: 16);

      for (var i = 0; i < 1000; i++) {
        lfsr.next();
        expect(lfsr.state, inInclusiveRange(1, 0xFFFF));
      }
    });

    test('rejects a state or tap that does not fit the configured width', () {
      expect(() => LFSR(0x100, 0xB8, bits: 8), throwsArgumentError);
      expect(() => LFSR(1, 0x100, bits: 8), throwsArgumentError);
    });

    test('rejects invalid register widths', () {
      expect(() => LFSR(1, 1, bits: 0), throwsArgumentError);
      expect(() => LFSR(1, 1, bits: 64), throwsArgumentError);
    });
  });
}
