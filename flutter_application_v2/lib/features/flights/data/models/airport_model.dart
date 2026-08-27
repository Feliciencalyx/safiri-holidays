class AirportModel {
  final String name;
  final String city;
  final String country;
  final String iataCode;
  final String icaoCode;

  const AirportModel({
    required this.name,
    required this.city,
    required this.country,
    required this.iataCode,
    required this.icaoCode,
  });

  static const List<AirportModel> globalAirports = [
    AirportModel(name: 'Kigali International Airport', city: 'Kigali', country: 'Rwanda', iataCode: 'KGL', icaoCode: 'HRYR'),
    AirportModel(name: 'London Heathrow Airport', city: 'London', country: 'United Kingdom', iataCode: 'LHR', icaoCode: 'EGLL'),
    AirportModel(name: 'John F. Kennedy International Airport', city: 'New York', country: 'United States', iataCode: 'JFK', icaoCode: 'KJFK'),
    AirportModel(name: 'Jomo Kenyatta International Airport', city: 'Nairobi', country: 'Kenya', iataCode: 'NBO', icaoCode: 'HKJK'),
    AirportModel(name: 'Dubai International Airport', city: 'Dubai', country: 'United Arab Emirates', iataCode: 'DXB', icaoCode: 'OMDB'),
    AirportModel(name: 'Charles de Gaulle Airport', city: 'Paris', country: 'France', iataCode: 'CDG', icaoCode: 'LFPG'),
    AirportModel(name: 'Abeid Amani Karume International', city: 'Zanzibar', country: 'Tanzania', iataCode: 'ZNZ', icaoCode: 'HTZA'),
    AirportModel(name: 'O. R. Tambo International Airport', city: 'Johannesburg', country: 'South Africa', iataCode: 'JNB', icaoCode: 'FAOR'),
  ];
}
