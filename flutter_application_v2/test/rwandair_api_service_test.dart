import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_v2/core/services/duffel_api_service.dart';
import 'package:flutter_application_v2/core/services/rwandair_api_service.dart';

void main() {
  group('RwandAirApiService Tests', () {
    test('isRwandAirRoute identifies authentic RwandAir domestic and regional routes', () {
      expect(RwandAirApiService.isRwandAirRoute('KGL', 'KME'), isTrue);
      expect(RwandAirApiService.isRwandAirRoute('KME', 'KGL'), isTrue);
      expect(RwandAirApiService.isRwandAirRoute('KGL', 'NBO'), isTrue);
      expect(RwandAirApiService.isRwandAirRoute('KGL', 'LHR'), isTrue);
      expect(RwandAirApiService.isRwandAirRoute('KGL', 'DXB'), isTrue);
      expect(RwandAirApiService.isRwandAirRoute('DEL', 'BOM'), isFalse);
    });

    test('KGL -> KME generates authentic 40m non-stop flights with realistic pricing', () {
      final offers = RwandAirApiService.searchRwandAirFlights(
        originCode: 'KGL',
        destinationCode: 'KME',
        departureDate: DateTime(2026, 9, 22),
        cabinClass: 'Economy',
        passengers: 1,
        adults: 1,
      );

      expect(offers, isNotEmpty);
      expect(offers.length, greaterThanOrEqualTo(2));

      final firstFlight = offers.first;
      expect(firstFlight.airline, 'RwandAir');
      expect(firstFlight.airlineCode, 'WB');
      expect(firstFlight.flightNumber, 'WB 601');
      expect(firstFlight.duration, '00h 40m');
      expect(firstFlight.stops, 'non-stop');
      expect(firstFlight.aircraft, 'Bombardier Dash 8-Q400');
      expect(firstFlight.priceUsd, closeTo(65.0, 10.0));
      expect(firstFlight.priceRwf, greaterThan(70000));
      expect(firstFlight.isRwandAirDirect, isTrue);

      // Verify Fare Tiers
      expect(firstFlight.fareTiers.length, 3);
      expect(firstFlight.fareTiers.map((t) => t.name), containsAll(['SAVER', 'FLEX', 'BUSINESS CLASS']));
    });

    test('buildDirectRwandAirUrl generates valid booking.rwandair.com deep link', () {
      final url = RwandAirApiService.buildDirectRwandAirUrl(
        originCode: 'KGL',
        destinationCode: 'KME',
        departureDate: DateTime(2026, 9, 22),
        adults: 1,
        children: 0,
        infants: 0,
        cabinClass: 'Economy',
        isOneWay: true,
      );

      expect(url, startsWith('https://booking.rwandair.com/en/flight-selection-departure'));
      expect(url, contains('origin=KGL'));
      expect(url, contains('destination=KME'));
      expect(url, contains('departureDate=2026-09-22'));
      expect(url, contains('adults=1'));
      expect(url, contains('cabinClass=economy'));
      expect(url, contains('tripType=oneway'));
    });

    test('KGL -> LHR generates Airbus A330-300 long-haul schedule', () {
      final offers = RwandAirApiService.searchRwandAirFlights(
        originCode: 'KGL',
        destinationCode: 'LHR',
        departureDate: DateTime(2026, 9, 25),
        cabinClass: 'Economy',
        passengers: 1,
        adults: 1,
      );

      expect(offers, isNotEmpty);
      final lhrFlight = offers.first;
      expect(lhrFlight.flightNumber, 'WB 700');
      expect(lhrFlight.aircraft, 'Airbus A330-300');
      expect(lhrFlight.duration, '08h 40m');
      expect(lhrFlight.priceUsd, closeTo(680.0, 50.0));
    });

    test('DuffelApiService.searchFlights seamlessly integrates RwandAir offers for Rwandan routes', () async {
      final offers = await DuffelApiService.searchFlights(
        originCode: 'KGL',
        destinationCode: 'KME',
        departureDate: DateTime(2026, 9, 22),
        cabinClass: 'Economy',
        passengers: 1,
        adults: 1,
      );

      expect(offers, isNotEmpty);
      final topOffer = offers.first;
      expect(topOffer.airlineCode, 'WB');
      expect(topOffer.duration, '00h 40m');
      expect(topOffer.stops, 'non-stop');
      expect(topOffer.flightNumber, 'WB 601');
      expect(topOffer.isRwandAirDirect, isTrue);
      // Ensures the unrealistic 7h 15m mock is completely gone
      expect(offers.any((o) => o.duration == '07h 15m'), isFalse);
    });
  });
}
