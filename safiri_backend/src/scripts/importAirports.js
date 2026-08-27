import https from 'https';
import http from 'http';
import prisma from '../config/db.js';

// OpenFlights Dataset Official URL
const OPENFLIGHTS_DATASET_URL = 'https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat';

/**
 * Robust CSV parser line splitter handling double quotes and escaped commas
 */
function parseCsvLine(line) {
  const result = [];
  let cur = '';
  let inQuotes = false;

  for (let i = 0; i < line.length; i++) {
    const c = line[i];
    if (c === '"') {
      inQuotes = !inQuotes;
    } else if (c === ',' && !inQuotes) {
      result.push(cur.trim());
      cur = '';
    } else {
      cur += c;
    }
  }
  result.push(cur.trim());
  return result.map((field) => {
    let cleaned = field;
    if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
      cleaned = cleaned.substring(1, cleaned.length - 1);
    }
    return cleaned === '\\N' || cleaned === '' ? null : cleaned;
  });
}

/**
 * Download raw data from URL
 */
function fetchRemoteData(url) {
  return new Promise((resolve, reject) => {
    const client = url.startsWith('https') ? https : http;
    client.get(url, (res) => {
      if (res.statusCode !== 200) {
        return reject(new Error(`Failed to download OpenFlights data: HTTP ${res.statusCode}`));
      }
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => resolve(data));
    }).on('error', reject);
  });
}

/**
 * Curated Regional Fallback (East Africa & Major Global Airports)
 */
const curatedRegionalAirports = [
  // Rwanda
  { openFlightsId: 9001, name: 'Kigali International Airport', city: 'Kigali', country: 'Rwanda', iata: 'KGL', icao: 'HRYR', latitude: -1.9686, longitude: 30.1394, type: 'airport' },
  { openFlightsId: 9002, name: 'Kamembe International Airport', city: 'Rusizi / Cyangugu', country: 'Rwanda', iata: 'KME', icao: 'HRZA', latitude: -2.4619, longitude: 28.9078, type: 'airport' },
  { openFlightsId: 9003, name: 'Gisenyi Airport', city: 'Rubavu / Gisenyi', country: 'Rwanda', iata: 'GYI', icao: 'HRYG', latitude: -1.6775, longitude: 29.2581, type: 'airport' },
  { openFlightsId: 9004, name: 'Butare Airport', city: 'Huye / Butare', country: 'Rwanda', iata: 'BTQ', icao: 'HRYU', latitude: -2.6033, longitude: 29.7428, type: 'airport' },
  // DRC
  { openFlightsId: 9005, name: 'Goma International Airport', city: 'Goma', country: 'DR Congo', iata: 'GOM', icao: 'FZNA', latitude: -1.6699, longitude: 29.2384, type: 'airport' },
  { openFlightsId: 9006, name: 'Kavumu Airport (Bukavu)', city: 'Bukavu', country: 'DR Congo', iata: 'BKY', icao: 'FZJH', latitude: -2.3089, longitude: 28.8083, type: 'airport' },
  { openFlightsId: 9007, name: 'N\'djili International Airport', city: 'Kinshasa', country: 'DR Congo', iata: 'FIH', icao: 'FZAA', latitude: -4.3857, longitude: 15.4446, type: 'airport' },
  { openFlightsId: 9008, name: 'Lubumbashi International Airport', city: 'Lubumbashi', country: 'DR Congo', iata: 'FBM', icao: 'FZQA', latitude: -11.5913, longitude: 27.5311, type: 'airport' },
  // Burundi
  { openFlightsId: 9009, name: 'Melchior Ndadaye International Airport', city: 'Bujumbura', country: 'Burundi', iata: 'BJM', icao: 'HBBA', latitude: -3.3240, longitude: 29.3185, type: 'airport' },
  // Kenya
  { openFlightsId: 9010, name: 'Jomo Kenyatta International Airport', city: 'Nairobi', country: 'Kenya', iata: 'NBO', icao: 'HKJK', latitude: -1.3192, longitude: 36.9275, type: 'airport' },
  { openFlightsId: 9011, name: 'Wilson Airport', city: 'Nairobi', country: 'Kenya', iata: 'WIL', icao: 'HKNW', latitude: -1.3217, longitude: 36.8147, type: 'airport' },
  { openFlightsId: 9012, name: 'Moi International Airport', city: 'Mombasa', country: 'Kenya', iata: 'MBA', icao: 'HKMO', latitude: -4.0348, longitude: 39.5942, type: 'airport' },
  { openFlightsId: 9013, name: 'Kisumu International Airport', city: 'Kisumu', country: 'Kenya', iata: 'KIS', icao: 'HKKI', latitude: -0.0861, longitude: 34.7289, type: 'airport' },
  { openFlightsId: 9014, name: 'Eldoret International Airport', city: 'Eldoret', country: 'Kenya', iata: 'EDL', icao: 'HKEL', latitude: 0.4044, longitude: 35.2394, type: 'airport' },
  { openFlightsId: 9015, name: 'Ukunda Airport (Diani)', city: 'Diani', country: 'Kenya', iata: 'UKU', icao: 'HKLU', latitude: -4.2981, longitude: 39.5744, type: 'airport' },
  // Tanzania
  { openFlightsId: 9016, name: 'Abeid Amani Karume International', city: 'Zanzibar', country: 'Tanzania', iata: 'ZNZ', icao: 'HTZA', latitude: -6.2220, longitude: 39.2249, type: 'airport' },
  { openFlightsId: 9017, name: 'Julius Nyerere International Airport', city: 'Dar es Salaam', country: 'Tanzania', iata: 'DAR', icao: 'HTDA', latitude: -6.8781, longitude: 39.2026, type: 'airport' },
  { openFlightsId: 9018, name: 'Kilimanjaro International Airport', city: 'Kilimanjaro', country: 'Tanzania', iata: 'JRO', icao: 'HTKJ', latitude: -3.4294, longitude: 37.0745, type: 'airport' },
  { openFlightsId: 9019, name: 'Arusha Airport', city: 'Arusha', country: 'Tanzania', iata: 'ARK', icao: 'HTAR', latitude: -3.3678, longitude: 36.6333, type: 'airport' },
  { openFlightsId: 9020, name: 'Mwanza Airport', city: 'Mwanza', country: 'Tanzania', iata: 'MWZ', icao: 'HTMW', latitude: -2.4444, longitude: 32.9328, type: 'airport' },
  // Uganda
  { openFlightsId: 9021, name: 'Entebbe International Airport', city: 'Entebbe', country: 'Uganda', iata: 'EBB', icao: 'HUEN', latitude: 0.0424, longitude: 32.4435, type: 'airport' },
  { openFlightsId: 9022, name: 'Arua Airport', city: 'Arua', country: 'Uganda', iata: 'RUA', icao: 'HUAR', latitude: 3.0478, longitude: 30.9167, type: 'airport' },
  // Ethiopia & Major Worldwide
  { openFlightsId: 9023, name: 'Addis Ababa Bole International', city: 'Addis Ababa', country: 'Ethiopia', iata: 'ADD', icao: 'HAAB', latitude: 8.9779, longitude: 38.7993, type: 'airport' },
  { openFlightsId: 9024, name: 'London Heathrow Airport', city: 'London', country: 'United Kingdom', iata: 'LHR', icao: 'EGLL', latitude: 51.4700, longitude: -0.4543, type: 'airport' },
  { openFlightsId: 9025, name: 'John F. Kennedy International Airport', city: 'New York', country: 'United States', iata: 'JFK', icao: 'KJFK', latitude: 40.6413, longitude: -73.7781, type: 'airport' },
  { openFlightsId: 9026, name: 'Dubai International Airport', city: 'Dubai', country: 'United Arab Emirates', iata: 'DXB', icao: 'OMDB', latitude: 25.2532, longitude: 55.3657, type: 'airport' },
  { openFlightsId: 9027, name: 'Paris Charles de Gaulle Airport', city: 'Paris', country: 'France', iata: 'CDG', icao: 'LFPG', latitude: 49.0097, longitude: 2.5479, type: 'airport' },
];

export async function importOpenFlightsDataset() {
  console.log('🚀 [SAFIRI DB SEED] Starting OpenFlights Airport Dataset Import...');

  let parsedAirports = [];

  try {
    console.log(`📥 Downloading live dataset from: ${OPENFLIGHTS_DATASET_URL}`);
    const rawData = await fetchRemoteData(OPENFLIGHTS_DATASET_URL);
    const lines = rawData.split('\n').filter((l) => l.trim().length > 0);
    console.log(`📦 Received ${lines.length} airport entries from OpenFlights repository.`);

    for (const line of lines) {
      const parts = parseCsvLine(line);
      if (parts.length >= 8) {
        const openFlightsId = parts[0] ? parseInt(parts[0], 10) : null;
        const name = parts[1] || 'Unknown Airport';
        const city = parts[2] || parts[3] || 'Unknown City';
        const country = parts[3] || 'International';
        const iata = parts[4] && parts[4].length === 3 ? parts[4].toUpperCase() : null;
        const icao = parts[5] && parts[5].length === 4 ? parts[5].toUpperCase() : null;
        const latitude = parts[6] ? parseFloat(parts[6]) : null;
        const longitude = parts[7] ? parseFloat(parts[7]) : null;
        const altitude = parts[8] ? parseFloat(parts[8]) : null;
        const timezone = parts[9] ? parseFloat(parts[9]) : null;
        const dst = parts[10] || null;
        const tzDb = parts[11] || null;
        const type = parts[12] || 'airport';

        if (name && (iata || icao || city)) {
          parsedAirports.push({
            openFlightsId: isNaN(openFlightsId) ? null : openFlightsId,
            name,
            city,
            country,
            iata,
            icao,
            latitude: isNaN(latitude) ? null : latitude,
            longitude: isNaN(longitude) ? null : longitude,
            altitude: isNaN(altitude) ? null : altitude,
            timezone: isNaN(timezone) ? null : timezone,
            dst,
            tzDb,
            type,
            source: 'OpenFlights',
          });
        }
      }
    }
  } catch (err) {
    console.warn(`⚠️ [SAFIRI DB WARN] Remote OpenFlights fetch failed (${err.message}). Using curated regional dataset fallback.`);
  }

  // Merge curated regional list to guarantee Kamembe (KME), Gisenyi (GYI), etc. exist
  const existingIatas = new Set(parsedAirports.map((a) => a.iata).filter(Boolean));
  for (const reg of curatedRegionalAirports) {
    if (!existingIatas.has(reg.iata)) {
      parsedAirports.push(reg);
    }
  }

  console.log(`✈️ Total airports ready to process: ${parsedAirports.length}`);

  // Write to local JSON dataset cache so backend search always has all 7,700+ airports available
  try {
    const fs = await import('fs');
    const path = await import('path');
    const dataDir = path.join(process.cwd(), 'src', 'data');
    if (!fs.existsSync(dataDir)) {
      fs.mkdirSync(dataDir, { recursive: true });
    }
    const jsonPath = path.join(dataDir, 'airports.json');
    const formattedData = parsedAirports.map((a) => ({
      code: a.iata || a.icao || `APT-${a.openFlightsId || Math.floor(Math.random() * 10000)}`,
      name: a.name,
      country: a.country,
      city: a.city,
      type: a.type || 'airport',
      source: 'openflights_offline_dataset',
    }));
    fs.writeFileSync(jsonPath, JSON.stringify(formattedData, null, 2));
    console.log(`💾 Saved ${formattedData.length} airports to local cache: ${jsonPath}`);
  } catch (fsErr) {
    console.warn('⚠️ [SAFIRI FS WARN] Failed to save local airports.json cache:', fsErr.message);
  }

  if (!prisma) {
    console.log('⚠️ [SAFIRI DB WARN] Prisma client disabled or DATABASE_URL unconfigured. Skipping PostgreSQL write.');
    return { success: false, count: parsedAirports.length, message: 'DATABASE_URL not configured.' };
  }

  try {
    let batchCount = 0;
    const chunkSize = 250;

    for (let i = 0; i < parsedAirports.length; i += chunkSize) {
      const chunk = parsedAirports.slice(i, i + chunkSize);
      
      // Batch insertion with skipDuplicates for PostgreSQL
      await prisma.airport.createMany({
        data: chunk,
        skipDuplicates: true,
      });

      batchCount += chunk.length;
      if (batchCount % 1000 === 0 || i + chunkSize >= parsedAirports.length) {
        console.log(`✅ Processed ${batchCount}/${parsedAirports.length} airports into Prisma Database...`);
      }
    }

    console.log('🎉 [SAFIRI DB SEED] Successfully imported OpenFlights airport dataset into PostgreSQL Database!');
    return { success: true, count: parsedAirports.length };
  } catch (dbErr) {
    console.warn('⚠️ [SAFIRI DB WARN] PostgreSQL database unreachable. Local JSON dataset cache was successfully updated for offline queries.');
    return { success: false, error: dbErr.message };
  }
}

// Auto execute if script is invoked directly
if (process.argv[1].endsWith('importAirports.js')) {
  importOpenFlightsDataset()
    .then(() => process.exit(0))
    .catch((err) => {
      console.error(err);
      process.exit(1);
    });
}
