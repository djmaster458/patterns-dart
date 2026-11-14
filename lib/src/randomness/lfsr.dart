/// Linear Feedback Shift Register (LFSR) implementation for generating pseudo-random numbers.
///
/// An LFSR is a shift register whose input bit is a linear function of its previous state.
/// Typically, the linear function is the XOR of certain bits of the register.
/// LFSRs are used in digital signal processing and communications. They are not
/// cryptographically secure and should not be used as cryptographic random generators.
///
/// The tap will determine if the LFSR will fully cycle through all possible states before repeating.
/// Choosing a primitive polynomial over GF(2) for the tap will ensure a maximal-length sequence.
///
/// Set [bits] to use a fixed-width register, for example `LFSR(1, 0xB8, bits: 8)`.
/// The tap mask must match the chosen register width and shift direction.
class LFSR {
  int state;
  int tap;
  final int? bits;
  late final int? _mask;

  /// Creates an LFSR with the given initial state and tap.
  ///
  /// The [state] should be a non-zero integer representing the initial state of the register.
  /// The [tap] should be chosen according to a primitive polynomial over GF(2) to ensure a maximal-length sequence.
  ///
  /// When [bits] is provided, [state] and [tap] must fit in that many bits.
  LFSR(this.state, this.tap, {this.bits}) {
    if (state <= 0) {
      throw ArgumentError.value(
        state,
        'state',
        'Must be a non-zero positive integer',
      );
    }
    if (tap < 0) {
      throw ArgumentError.value(tap, 'tap', 'Must be a non-negative integer');
    }
    if (bits != null) {
      if (bits! < 1 || bits! > 63) {
        throw ArgumentError.value(bits, 'bits', 'Must be between 1 and 63');
      }

      final mask = (1 << bits!) - 1;
      if (state > mask) {
        throw ArgumentError.value(state, 'state', 'Must fit within $bits bits');
      }
      if (tap > mask) {
        throw ArgumentError.value(tap, 'tap', 'Must fit within $bits bits');
      }
      _mask = mask;
    } else {
      _mask = null;
    }
  }

  /// Generates the next state of the LFSR and returns the output bit.
  int next() {
    final outputBit = state & 1;
    state = (state >> 1) ^ (tap & -outputBit);
    final mask = _mask;
    if (mask != null) {
      state &= mask;
    }
    return outputBit;
  }
}
