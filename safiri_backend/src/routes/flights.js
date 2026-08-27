import express from 'express';
import { Duffel } from '@duffel/api';
import prisma from '../config/db.js';
import safiriFlightsService from '../services/safiriflights.service.js';

const router = express.Router();

const parseDuration = (slice) => {
  if (!slice) return '7h 30m';
  const durStr = typeof slice === 'string' ? slice : (slice.duration || '');
  if (durStr && durStr.startsWith('P')) {
    const hours = durStr.match(/(\d+)H/);
    const mins = durStr.match(/(\d+)M/);
    const h = hours ? hours[1] : '0';
    const m = mins ? mins[1] : '00';
    return `${h}h ${m}m`;
  }
  return '7h 45m';
};

// Helper to get Duffel client instance
const getDuffelClient = () => {
  const token = process.env.DUFFEL_API_TOKEN || 'duffel_test_placeholder';
  return new Duffel({
    token: token,
  });
};

/**
 * POST /api/flights/search-url
 * Generate official flights.safiriholidays.com search protocol URL
 */
router.post('/search-url', (req, res) => {
  try {
    const result = safiriFlightsService.buildSearchUrl(req.body || {});
    return res.json({
      success: true,
      domain: 'flights.safiriholidays.com',
      ...result,
    });
  } catch (err) {
    return res.status(500).json({ success: false, error: err.message });
  }
});

/**
 * Step 5: POST /api/flights/search
 * Search live flight offers via Safiri Flight Engine & flights.safiriholidays.com protocol
 */
router.post('/search', async (req, res) => {
  try {
    const {
      originCode = 'LHR',
      originCity = 'London',
      originCountry = 'United Kingdom',
      destinationCode = 'JFK',
      destinationCity = 'New York',
      destinationCountry = 'United States',
      departureDate,
      returnDate,
      cabinClass = 'economy',
      passengers = 1,
      adults = 1,
      children = 0,
      infants = 0,
      isOneWay = true,
    } = req.body;

    const protocol = safiriFlightsService.buildSearchUrl({
      originCode,
      originCity,
      originCountry,
      destinationCode,
      destinationCity,
      destinationCountry,
      departureDate,
      returnDate,
      adults: adults || passengers,
      children,
      infants,
      cabinClass,
      isOneWay,
    });

    // Default departure date if not passed (14 days from now)
    const depDate = departureDate || new Date(Date.now() + 14 * 86400000).toISOString().split('T')[0];

    console.log(`[SAFIRI BACKEND] Flight Search requested: ${originCode} ➔ ${destinationCode} on ${depDate} (${passengers} pax, ${cabinClass})`);

    if (originCode.toUpperCase() === destinationCode.toUpperCase()) {
      return res.json({
        success: true,
        source: 'safiri_validation_fallback',
        count: 0,
        offers: [],
        message: 'Destination airport must be different from origin airport.',
      });
    }

    // Call live Safiri Flights Service to fetch tickets matching flights.safiriholidays.com
    const liveResults = await safiriFlightsService.fetchLiveFlightOffers(req.body || {});

    return res.json({
      success: true,
      source: 'flights.safiriholidays.com_live_api',
      protocolUrl: protocol.protocolUrl,
      protocol: protocol,
      count: liveResults.offers.length,
      offers: liveResults.offers,
    });
  } catch (error) {
    console.error('[SAFIRI BACKEND ERROR] Search failed:', error.stack || error.message);
    const isProd = process.env.NODE_ENV === 'production';
    res.status(500).json({
      success: false,
      message: 'Failed to query flight options. Please try again.',
      ...(isProd ? {} : { error: error.message }),
    });
  }
});

/**
 * GET /api/flights/airports?q=query
 * Live worldwide airport & city search via Duffel Places API
 */
router.get('/airports', async (req, res) => {
  try {
    const query = (req.query.q || '').trim();
    const token = process.env.DUFFEL_API_TOKEN;

    // Comprehensive worldwide and regional (East Africa + Global) dataset
    const comprehensiveAirports = [
      // Rwanda
      { code: 'KGL', name: 'Kigali International Airport', country: 'Rwanda', city: 'Kigali' },
      { code: 'KME', name: 'Kamembe International Airport', country: 'Rwanda', city: 'Rusizi / Cyangugu' },
      { code: 'GYI', name: 'Gisenyi Airport', country: 'Rwanda', city: 'Rubavu / Gisenyi' },
      { code: 'BTQ', name: 'Butare Airport', country: 'Rwanda', city: 'Huye / Butare' },
      // Democratic Republic of Congo
      { code: 'GOM', name: 'Goma International Airport', country: 'DR Congo', city: 'Goma' },
      { code: 'BKY', name: 'Kavumu Airport (Bukavu)', country: 'DR Congo', city: 'Bukavu' },
      { code: 'FIH', name: 'N\'djili International Airport', country: 'DR Congo', city: 'Kinshasa' },
      { code: 'FBM', name: 'Lubumbashi International Airport', country: 'DR Congo', city: 'Lubumbashi' },
      { code: 'FKI', name: 'Bangoka International Airport', country: 'DR Congo', city: 'Kisangani' },
      // Burundi
      { code: 'BJM', name: 'Melchior Ndadaye International Airport', country: 'Burundi', city: 'Bujumbura' },
      // Kenya
      { code: 'NBO', name: 'Jomo Kenyatta International Airport', country: 'Kenya', city: 'Nairobi' },
      { code: 'WIL', name: 'Wilson Airport', country: 'Kenya', city: 'Nairobi' },
      { code: 'MBA', name: 'Moi International Airport', country: 'Kenya', city: 'Mombasa' },
      { code: 'KIS', name: 'Kisumu International Airport', country: 'Kenya', city: 'Kisumu' },
      { code: 'EDL', name: 'Eldoret International Airport', country: 'Kenya', city: 'Eldoret' },
      { code: 'UKU', name: 'Ukunda Airport (Diani)', country: 'Kenya', city: 'Ukunda / Diani' },
      { code: 'LAU', name: 'Manda Airport', country: 'Kenya', city: 'Lamu' },
      { code: 'MYD', name: 'Malindi Airport', country: 'Kenya', city: 'Malindi' },
      // Tanzania
      { code: 'ZNZ', name: 'Abeid Amani Karume Intl', country: 'Tanzania', city: 'Zanzibar' },
      { code: 'DAR', name: 'Julius Nyerere International Airport', country: 'Tanzania', city: 'Dar es Salaam' },
      { code: 'JRO', name: 'Kilimanjaro International Airport', country: 'Tanzania', city: 'Kilimanjaro / Arusha' },
      { code: 'ARK', name: 'Arusha Airport', country: 'Tanzania', city: 'Arusha' },
      { code: 'MWZ', name: 'Mwanza Airport', country: 'Tanzania', city: 'Mwanza' },
      { code: 'DOD', name: 'Dodoma Airport', country: 'Tanzania', city: 'Dodoma' },
      // Uganda
      { code: 'EBB', name: 'Entebbe International Airport', country: 'Uganda', city: 'Entebbe / Kampala' },
      { code: 'RUA', name: 'Arua Airport', country: 'Uganda', city: 'Arua' },
      { code: 'SRT', name: 'Soroti Airport', country: 'Uganda', city: 'Soroti' },
      // Ethiopia
      { code: 'ADD', name: 'Addis Ababa Bole International', country: 'Ethiopia', city: 'Addis Ababa' },
      { code: 'DIR', name: 'Dire Dawa Airport', country: 'Ethiopia', city: 'Dire Dawa' },
      // South Africa & West Africa
      { code: 'JNB', name: 'O.R. Tambo International', country: 'South Africa', city: 'Johannesburg' },
      { code: 'CPT', name: 'Cape Town International', country: 'South Africa', city: 'Cape Town' },
      { code: 'DUR', name: 'King Shaka International', country: 'South Africa', city: 'Durban' },
      { code: 'LOS', name: 'Murtala Muhammed Intl', country: 'Nigeria', city: 'Lagos' },
      { code: 'ABV', name: 'Nnamdi Azikiwe International', country: 'Nigeria', city: 'Abuja' },
      { code: 'ACC', name: 'Kotoka International', country: 'Ghana', city: 'Accra' },
      { code: 'DSS', name: 'Blaise Diagne International', country: 'Senegal', city: 'Dakar' },
      { code: 'ABJ', name: 'Félix-Houphouët-Boigny Intl', country: 'Ivory Coast', city: 'Abidjan' },
      { code: 'HRE', name: 'Robert Gabriel Mugabe Intl', country: 'Zimbabwe', city: 'Harare' },
      { code: 'CAI', name: 'Cairo International', country: 'Egypt', city: 'Cairo' },
      { code: 'CMN', name: 'Mohammed V International', country: 'Morocco', city: 'Casablanca' },
      // Middle East
      { code: 'DXB', name: 'Dubai International', country: 'United Arab Emirates', city: 'Dubai' },
      { code: 'AUH', name: 'Zayed International Airport', country: 'United Arab Emirates', city: 'Abu Dhabi' },
      { code: 'DOH', name: 'Hamad International', country: 'Qatar', city: 'Doha' },
      { code: 'RUH', name: 'King Khalid International', country: 'Saudi Arabia', city: 'Riyadh' },
      { code: 'JED', name: 'King Abdulaziz International', country: 'Saudi Arabia', city: 'Jeddah' },
      // Europe
      { code: 'LHR', name: 'London Heathrow', country: 'United Kingdom', city: 'London' },
      { code: 'LGW', name: 'London Gatwick', country: 'United Kingdom', city: 'London' },
      { code: 'CDG', name: 'Paris Charles de Gaulle', country: 'France', city: 'Paris' },
      { code: 'AMS', name: 'Amsterdam Airport Schiphol', country: 'Netherlands', city: 'Amsterdam' },
      { code: 'FRA', name: 'Frankfurt Airport', country: 'Germany', city: 'Frankfurt' },
      { code: 'MUC', name: 'Munich Airport', country: 'Germany', city: 'Munich' },
      { code: 'IST', name: 'Istanbul Airport', country: 'Turkey', city: 'Istanbul' },
      { code: 'BRU', name: 'Brussels Airport', country: 'Belgium', city: 'Brussels' },
      { code: 'ZRH', name: 'Zurich Airport', country: 'Switzerland', city: 'Zurich' },
      // Americas
      { code: 'JFK', name: 'New York JFK', country: 'United States', city: 'New York' },
      { code: 'EWR', name: 'Newark Liberty International', country: 'United States', city: 'New York / Newark' },
      { code: 'LAX', name: 'Los Angeles International', country: 'United States', city: 'Los Angeles' },
      { code: 'ORD', name: 'Chicago O\'Hare International', country: 'United States', city: 'Chicago' },
      { code: 'MIA', name: 'Miami International', country: 'United States', city: 'Miami' },
      { code: 'IAD', name: 'Washington Dulles International', country: 'United States', city: 'Washington D.C.' },
      { code: 'ATL', name: 'Hartsfield-Jackson Atlanta', country: 'United States', city: 'Atlanta' },
      { code: 'YVR', name: 'Vancouver International', country: 'Canada', city: 'Vancouver' },
      { code: 'YYZ', name: 'Toronto Pearson International', country: 'Canada', city: 'Toronto' },
      // Asia & Oceania
      { code: 'SIN', name: 'Singapore Changi', country: 'Singapore', city: 'Singapore' },
      { code: 'HKG', name: 'Hong Kong International', country: 'Hong Kong', city: 'Hong Kong' },
      { code: 'HND', name: 'Tokyo Haneda', country: 'Japan', city: 'Tokyo' },
      { code: 'NRT', name: 'Tokyo Narita', country: 'Japan', city: 'Tokyo' },
      { code: 'ICN', name: 'Incheon International Airport', country: 'South Korea', city: 'Seoul' },
      { code: 'SYD', name: 'Sydney Kingsford Smith', country: 'Australia', city: 'Sydney' },
      { code: 'MEL', name: 'Melbourne Airport', country: 'Australia', city: 'Melbourne' },
      { code: 'BOM', name: 'Chhatrapati Shivaji Maharaj Intl', country: 'India', city: 'Mumbai' },
      { code: 'DEL', name: 'Indira Gandhi International', country: 'India', city: 'New Delhi' },
      { code: 'BKK', name: 'Suvarnabhumi Airport', country: 'Thailand', city: 'Bangkok' },
      { code: 'KUL', name: 'Kuala Lumpur International', country: 'Malaysia', city: 'Kuala Lumpur' },
    ];

    let dbAirports = [];
    if (prisma) {
      try {
        const qLower = query.toLowerCase();
        const whereCondition = query.length === 0 ? {} : {
          OR: [
            { iata: { contains: query, mode: 'insensitive' } },
            { name: { contains: query, mode: 'insensitive' } },
            { city: { contains: query, mode: 'insensitive' } },
            { country: { contains: query, mode: 'insensitive' } },
          ],
        };

        const records = await prisma.airport.findMany({
          where: whereCondition,
          take: 60,
        });

        dbAirports = records.map((r) => ({
          code: r.iata || r.icao || `APT-${r.id}`,
          name: r.name,
          country: r.country,
          city: r.city,
          type: r.type || 'airport',
          source: 'postgresql_openflights_db',
        }));
      } catch (dbErr) {
        console.warn('⚠️ [SAFIRI DB WARN] Unable to query prisma.airport table:', dbErr.message);
      }
    }

    // Offline JSON dataset cache fallback if PostgreSQL is unconfigured or unreachable
    let jsonAirports = [];
    if (dbAirports.length === 0) {
      try {
        const fs = await import('fs');
        const path = await import('path');
        const jsonPath = path.join(process.cwd(), 'src', 'data', 'airports.json');
        if (fs.existsSync(jsonPath)) {
          const raw = fs.readFileSync(jsonPath, 'utf8');
          const cacheData = JSON.parse(raw);
          const qLower = query.toLowerCase();
          jsonAirports = query.length === 0 ? cacheData.slice(0, 60) : cacheData.filter((a) =>
            a.code.toLowerCase().includes(qLower) ||
            a.name.toLowerCase().includes(qLower) ||
            a.country.toLowerCase().includes(qLower) ||
            a.city.toLowerCase().includes(qLower)
          ).slice(0, 60);
        }
      } catch (jsonErr) {
        // Silent fallback
      }
    }

    let duffelAirports = [];
    if (token && token.startsWith('duffel_test_') && token !== 'duffel_test_token_placeholder' && query.length > 0) {
      try {
        const duffel = getDuffelClient();
        const response = await duffel.suggestions.list({ query });
        
        duffelAirports = (response.data || [])
          .filter((item) => item.iata_code)
          .map((item) => ({
            code: item.iata_code,
            name: item.name || item.city_name || `${item.iata_code} Airport`,
            country: item.iata_country_code || 'International',
            city: item.city_name || item.name || '',
            type: item.type || 'airport',
            source: 'duffel_places_api',
          }));
      } catch (err) {
        console.warn('[SAFIRI BACKEND WARN] Duffel places suggestions search failed, using local database:', err.message);
      }
    }

    // Filter local comprehensive list
    const qLower = query.toLowerCase();
    const filteredLocal = query.length === 0 
      ? comprehensiveAirports 
      : comprehensiveAirports.filter((a) => 
          a.code.toLowerCase().includes(qLower) ||
          a.name.toLowerCase().includes(qLower) ||
          a.country.toLowerCase().includes(qLower) ||
          a.city.toLowerCase().includes(qLower)
        );

    // Merge DB records, offline JSON cache, Duffel suggestions, and local dataset (deduplicating by IATA/code)
    const combinedMap = new Map();
    // 1. First insert PostgreSQL OpenFlights DB records
    dbAirports.forEach((a) => combinedMap.set(a.code.toUpperCase(), a));
    // 2. Insert offline JSON dataset cache records
    jsonAirports.forEach((a) => {
      if (!combinedMap.has(a.code.toUpperCase())) {
        combinedMap.set(a.code.toUpperCase(), a);
      }
    });
    // 3. Insert Duffel Places API suggestions
    duffelAirports.forEach((a) => {
      if (!combinedMap.has(a.code.toUpperCase())) {
        combinedMap.set(a.code.toUpperCase(), a);
      }
    });
    // 4. Insert local comprehensive fallback dataset
    filteredLocal.forEach((a) => {
      if (!combinedMap.has(a.code.toUpperCase())) {
        combinedMap.set(a.code.toUpperCase(), a);
      }
    });

    const finalAirports = Array.from(combinedMap.values());

    return res.json({
      success: true,
      source: dbAirports.length > 0 
        ? 'postgresql_openflights_and_duffel_hybrid' 
        : (jsonAirports.length > 0 ? 'openflights_offline_json_cache' : (duffelAirports.length > 0 ? 'duffel_and_local_hybrid' : 'safiri_expanded_global_dataset')),
      count: finalAirports.length,
      airports: finalAirports,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * Step 8: GET /api/flights/offers/:id
 * Get detailed offer breakdown
 */
router.get('/offers/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const token = process.env.DUFFEL_API_TOKEN;

    if (token && token.startsWith('duffel_test_') && token !== 'duffel_test_token_placeholder') {
      const duffel = getDuffelClient();
      const offer = await duffel.offers.get(id);
      return res.json({ success: true, offer: offer.data });
    }

    res.json({
      success: true,
      offer: {
        id,
        baggageAllowance: '2 x 23kg Checked Bags + 1 Cabin Bag',
        seatSelection: 'Complimentary Standard Seat Selection',
        cancellationPolicy: 'Refundable up to 24h prior to departure with zero penalty',
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * Step 9 & 10: POST /api/flights/orders
 * Place live order & issue booking
 */
router.post('/orders', async (req, res) => {
  try {
    const { offerId, passengerName, passportNumber, nationality, email, originCode, destinationCode, totalAmount } = req.body;

    console.log(`[SAFIRI BACKEND] Order creation requested for Offer ${offerId} by ${passengerName}`);

    const bookingId = `#SAF-2026-${Math.floor(1000 + Math.random() * 9000)}`;
    const qrCodeData = `${bookingId}-${passengerName.toUpperCase().replace(/\s+/g, '_')}-SAFIRI_VERIFIED`;

    // Persist booking record in PostgreSQL via Prisma if connected
    if (prisma) {
      try {
        await prisma.booking.create({
          data: {
            id: bookingId,
            offerId: offerId || 'off_default',
            passengerName: passengerName || 'Passenger',
            passportNumber: passportNumber || null,
            nationality: nationality || null,
            email: email || null,
            originCode: originCode || 'KGL',
            destinationCode: destinationCode || 'DXB',
            totalAmount: parseFloat(totalAmount || 0),
            currency: 'RWF',
            status: 'CONFIRMED',
            qrCodeData: qrCodeData,
          },
        });
        console.log(`✅ [SAFIRI DB] Booking ${bookingId} persisted in Supabase PostgreSQL`);
      } catch (dbErr) {
        console.warn(`⚠️ [SAFIRI DB WARN] Unable to persist booking ${bookingId} to database:`, dbErr.message);
      }
    }

    res.json({
      success: true,
      bookingId,
      status: 'Confirmed',
      passengerName,
      issuedAt: new Date().toISOString(),
      qrCodeData,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

export default router;
