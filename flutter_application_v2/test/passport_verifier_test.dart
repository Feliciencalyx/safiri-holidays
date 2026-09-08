import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_v2/core/utils/passport_verifier.dart';

void main() {
  group('PassportVerifierService Tests', () {
    test('Valid Rwandan Ordinary Passport format', () {
      final result = PassportVerifierService.verify('PC9920148X');
      expect(result.isValid, isTrue);
      expect(result.countryCode, equals('RWA'));
      expect(result.countryName, equals('Republic of Rwanda'));
      expect(result.passportType, contains('Ordinary E-Passport'));
    });

    test('Valid Rwandan Diplomatic Passport format', () {
      final result = PassportVerifierService.verify('PD009124');
      expect(result.isValid, isTrue);
      expect(result.countryCode, equals('RWA'));
      expect(result.passportType, contains('Diplomatic Passport'));
    });

    test('Valid Kenyan Passport format', () {
      final result = PassportVerifierService.verify('AK1092841');
      expect(result.isValid, isTrue);
      expect(result.countryCode, equals('KEN'));
      expect(result.countryName, equals('Republic of Kenya'));
    });

    test('Valid Ugandan Passport format', () {
      final result = PassportVerifierService.verify('A1234567');
      expect(result.isValid, isTrue);
      expect(result.countryCode, equals('UGA'));
      expect(result.countryName, equals('Republic of Uganda'));
    });

    test('Valid USA Passport format', () {
      final result = PassportVerifierService.verify('C98234123', selectedNationality: 'USA');
      expect(result.isValid, isTrue);
      expect(result.countryCode, equals('USA'));
    });

    test('Empty input should be invalid', () {
      final result = PassportVerifierService.verify('');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('cannot be empty'));
    });

    test('Too short passport number should be invalid', () {
      final result = PassportVerifierService.verify('PC12');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('too short'));
    });

    test('Invalid characters in passport number should be rejected', () {
      final result = PassportVerifierService.verify('PC9920!48');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('invalid characters'));
    });
  });
}
