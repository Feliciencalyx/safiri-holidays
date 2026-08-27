import prisma from '../config/db.js';
import safiriHolidaysService from '../services/safiriholidays.service.js';

// In-memory fallback enquiries store
const enquiriesStore = new Map();

/**
 * GET /api/holidays/live-status
 * Retrieve real-time connectivity status of safiriholidays.com domain server
 */
export async function getSafiriHolidaysServerStatus(req, res) {
  try {
    const health = await safiriHolidaysService.checkServerHealth();
    const endpoints = safiriHolidaysService.getServerServiceEndpoints();

    return res.json({
      success: true,
      domain: 'safiriholidays.com',
      health,
      endpoints,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve domain server status',
      error: error.message,
    });
  }
}

/**
 * GET /api/holidays/destinations
 * Retrieve live destinations fetched from safiriholidays.com
 */
export async function getLiveDestinations(req, res) {
  try {
    const liveData = await safiriHolidaysService.fetchLivePackagesAndDestinations();
    return res.json({
      success: true,
      sourceDomain: 'safiriholidays.com',
      count: liveData.destinations?.length || 0,
      destinations: liveData.destinations || [],
      extractedPackageLinks: liveData.extractedPackageLinks || [],
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Failed to fetch live destinations from safiriholidays.com',
      error: error.message,
    });
  }
}

/**
 * GET /api/holidays/packages
 * Retrieve curated safari & luxury holiday packages combining regional + live safiriholidays.com server data
 */
export async function getHolidayPackages(req, res) {
  const regionalPackages = [
    {
      id: 'hol_akagera_01',
      title: 'Akagera Safari & Big Five Game Drive',
      location: 'Akagera National Park, Rwanda',
      duration: '3 Days / 2 Nights',
      priceRwf: 450000,
      priceUsd: 326.0,
      image: 'https://images.unsplash.com/photo-1516426122078-c23e76319801',
      highlights: ['Big 5 Game Drive', 'Lake Ihema Boat Safari', 'Luxury Lodge Stay'],
      serverSource: 'safiriholidays.com (Regional)',
    },
    {
      id: 'hol_zanzibar_02',
      title: 'Zanzibar Luxury Beach & Spice Retreat',
      location: 'Nungwi Beach, Zanzibar',
      duration: '5 Days / 4 Nights',
      priceRwf: 1150000,
      priceUsd: 833.0,
      image: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef',
      highlights: ['Private Beach Villa', 'Stone Town Spice Tour', 'Dolphin Dhow Cruise'],
      serverSource: 'safiriholidays.com (Regional)',
    },
    {
      id: 'hol_gorilla_03',
      title: 'Volcanoes Gorilla Trekking Expedition',
      location: 'Volcanoes National Park, Rwanda',
      duration: '4 Days / 3 Nights',
      priceRwf: 2200000,
      priceUsd: 1594.0,
      image: 'https://images.unsplash.com/photo-1575550959106-5a7defe28b56',
      highlights: ['Mountain Gorilla Permit', 'Singita Kwitonda Lodge', 'Golden Monkey Trek'],
      serverSource: 'safiriholidays.com (Regional)',
    },
    {
      id: 'hol_santorini_04',
      title: 'Santorini Sunset Luxury Escape',
      location: 'Oia, Santorini, Greece',
      duration: '6 Days / 5 Nights',
      priceRwf: 3450000,
      priceUsd: 2500.0,
      image: 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff',
      highlights: ['Infinity Pool Suite', 'Catamaran Wine Sunset Cruise', 'VIP Helicopter Transfer'],
      serverSource: 'safiriholidays.com (Regional)',
    },
  ];

  // Attempt to enrich with live packages fetched from safiriholidays.com
  let liveDestinations = [];
  try {
    const liveData = await safiriHolidaysService.fetchLivePackagesAndDestinations();
    if (liveData && liveData.destinations) {
      liveDestinations = liveData.destinations.map((dest) => ({
        id: dest.id,
        title: dest.name,
        location: dest.country,
        duration: '5 Days / 4 Nights',
        priceRwf: dest.priceRwf,
        priceUsd: dest.priceUsd,
        image: dest.imageUrl,
        highlights: dest.highlights,
        serverSource: dest.serverSource,
        serverUrl: dest.serverUrl,
      }));
    }
  } catch (err) {
    console.warn('⚠️ [HOLIDAY CONTROLLER] Live fetch warning:', err.message);
  }

  const allPackages = [...regionalPackages, ...liveDestinations];

  return res.json({
    success: true,
    serverDomain: 'safiriholidays.com',
    count: allPackages.length,
    packages: allPackages,
  });
}

/**
 * POST /api/holidays/enquiries
 * Submit customer enquiry for a holiday package
 */
export async function createHolidayEnquiry(req, res) {
  try {
    const { holidayTitle, customerName, email, phone, travelDate, numTravelers, notes, userId } = req.body;

    if (!holidayTitle || !customerName || !email) {
      return res.status(400).json({
        success: false,
        message: 'Missing required enquiry fields (holidayTitle, customerName, email)',
      });
    }

    const enquiryId = `ENQ-${Date.now().toString().substring(6)}`;
    const enquiryRecord = {
      id: enquiryId,
      userId: userId || null,
      holidayTitle,
      customerName,
      email,
      phone: phone || '',
      travelDate: travelDate || '',
      numTravelers: numTravelers ? parseInt(numTravelers) : 1,
      notes: notes || '',
      status: 'NEW',
      serverDomain: 'safiriholidays.com',
      createdAt: new Date().toISOString(),
    };

    enquiriesStore.set(enquiryId, enquiryRecord);

    if (prisma) {
      try {
        await prisma.holidayEnquiry.create({
          data: {
            userId: userId || null,
            holidayTitle,
            customerName,
            email,
            phone: phone || null,
            travelDate: travelDate || null,
            numTravelers: numTravelers ? parseInt(numTravelers) : 1,
            notes: notes || null,
            status: 'NEW',
          },
        });
        console.log(`✅ [SAFIRI DB] Holiday Enquiry for ${holidayTitle} persisted in Supabase PostgreSQL`);
      } catch (dbErr) {
        console.warn('⚠️ [SAFIRI DB WARN] Unable to persist holiday enquiry to database:', dbErr.message);
      }
    }

    return res.status(201).json({
      success: true,
      message: `Enquiry submitted for ${holidayTitle} on safiriholidays.com. A dedicated concierge agent will contact you within 24 hours.`,
      enquiry: enquiryRecord,
    });
  } catch (error) {
    console.error('[HOLIDAY CONTROLLER ERROR]', error);
    return res.status(500).json({ success: false, message: 'Failed to process holiday enquiry' });
  }
}
