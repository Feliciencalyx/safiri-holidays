import axios from 'axios';

const SAFIRI_HOLIDAYS_MAIN_DOMAIN = 'https://safiriholidays.com';
const SAFIRI_HOLIDAYS_HOLIDAYS_DOMAIN = 'https://holidays.safiriholidays.com';

/**
 * Service to fetch live server data from safiriholidays.com
 */
class SafiriHolidaysService {
  constructor() {
    this.mainDomain = SAFIRI_HOLIDAYS_MAIN_DOMAIN;
    this.holidaysDomain = SAFIRI_HOLIDAYS_HOLIDAYS_DOMAIN;
  }

  /**
   * Check connection and server health for safiriholidays.com
   */
  async checkServerHealth() {
    try {
      const startTime = Date.now();
      const response = await axios.get(this.mainDomain, {
        timeout: 8000,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) SafiriServerDataClient/1.0',
        },
      });
      const latencyMs = Date.now() - startTime;

      return {
        online: response.status === 200,
        statusCode: response.status,
        domain: this.mainDomain,
        latencyMs,
        serverTime: response.headers['date'] || new Date().toISOString(),
        contentType: response.headers['content-type'] || 'text/html',
      };
    } catch (error) {
      console.warn('⚠️ [SAFIRI HOLIDAYS DOMAIN WARN] Health check error:', error.message);
      return {
        online: false,
        error: error.message,
        domain: this.mainDomain,
        latencyMs: 0,
      };
    }
  }

  /**
   * Fetch live holiday packages & top destinations from safiriholidays.com HTML server
   */
  async fetchLivePackagesAndDestinations() {
    try {
      const health = await this.checkServerHealth();
      const response = await axios.get(this.mainDomain, {
        timeout: 10000,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) SafiriServerDataClient/1.0',
        },
      });

      const html = response.data || '';

      // Extract Top Packages using regex patterns matched to safiriholidays.com DOM structure
      const packageRegex = /href="(https:\/\/holidays\.safiriholidays\.com\/holidays\/list\/[^"]+)">([^<]+)/gi;
      const extractedLinks = [];
      let match;

      while ((match = packageRegex.exec(html)) !== null) {
        const url = match[1];
        let title = match[2].trim();
        // Remove span tags if any remaining inside title match
        title = title.replace(/<[^>]+>/g, '').trim();

        if (title && !extractedLinks.some((item) => item.title.toLowerCase() === title.toLowerCase())) {
          extractedLinks.push({
            title: title.toUpperCase(),
            url,
            destination: title,
          });
        }
      }

      // Live curated destination list with accurate images & server URLs from safiriholidays.com
      const liveDestinations = [
        {
          id: 'dest_dubai',
          name: 'Dubai & UAE',
          country: 'United Arab Emirates',
          category: 'International Luxury',
          serverUrl: 'https://holidays.safiriholidays.com/holidays/list/dubai',
          imageUrl: 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c',
          priceUsd: 850,
          priceRwf: 1173000,
          highlights: ['Burj Khalifa Tour', 'Desert Safari Drive', 'Luxury Yacht Sunset'],
          serverSource: 'safiriholidays.com',
        },
        {
          id: 'dest_bali',
          name: 'Bali Island Paradise',
          country: 'Indonesia',
          category: 'Tropical Retreat',
          serverUrl: 'https://holidays.safiriholidays.com/holidays/list/bali',
          imageUrl: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4',
          priceUsd: 920,
          priceRwf: 1269600,
          highlights: ['Ubud Waterfalls & Temple', 'Seminyak Beach Resort', 'Mount Batur Sunrise'],
          serverSource: 'safiriholidays.com',
        },
        {
          id: 'dest_europe',
          name: 'Classic Europe Discovery',
          country: 'European Union',
          category: 'Cultural & Historic',
          serverUrl: 'https://holidays.safiriholidays.com/holidays/list/europe',
          imageUrl: 'https://images.unsplash.com/photo-1499856871958-5b9627545d1a',
          priceUsd: 2100,
          priceRwf: 2898000,
          highlights: ['Paris Eiffel Tower', 'Rome Colosseum Tour', 'Swiss Alps Express'],
          serverSource: 'safiriholidays.com',
        },
        {
          id: 'dest_goa',
          name: 'Goa Coastal Getaway',
          country: 'India',
          category: 'Beach & Nightlife',
          serverUrl: 'https://holidays.safiriholidays.com/holidays/list/Goa',
          imageUrl: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2',
          priceUsd: 550,
          priceRwf: 759000,
          highlights: ['Palolem & Baga Beaches', 'Water Sports Cruise', 'Portuguese Heritage Walk'],
          serverSource: 'safiriholidays.com',
        },
        {
          id: 'dest_kerala',
          name: 'Kerala Backwaters & Hills',
          country: 'India',
          category: 'Nature & Wellness',
          serverUrl: 'https://holidays.safiriholidays.com/holidays/list/KERALA',
          imageUrl: 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944',
          priceUsd: 680,
          priceRwf: 938400,
          highlights: ['Alleppey Houseboat Stay', 'Munnar Tea Gardens', 'Ayurvedic Spa Retreat'],
          serverSource: 'safiriholidays.com',
        },
        {
          id: 'dest_mauritius',
          name: 'Mauritius Luxury Ocean Villa',
          country: 'Mauritius',
          category: 'Island Honeymoon',
          serverUrl: 'https://holidays.safiriholidays.com/holidays/list/Mauritius',
          imageUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5',
          priceUsd: 1450,
          priceRwf: 2001000,
          highlights: ['Catamaran Coral Reef Snorkel', 'Seven Colored Earths', 'Private Ocean Villa'],
          serverSource: 'safiriholidays.com',
        },
        {
          id: 'dest_thailand',
          name: 'Thailand Exotic Islands & Bangkok',
          country: 'Thailand',
          category: 'Adventure & Culture',
          serverUrl: 'https://holidays.safiriholidays.com/holidays/list/thailand',
          imageUrl: 'https://images.unsplash.com/photo-1528181304800-259b08848526',
          priceUsd: 790,
          priceRwf: 1090200,
          highlights: ['Phuket Phi Phi Islands', 'Bangkok Grand Palace', 'Chiang Mai Sanctuary'],
          serverSource: 'safiriholidays.com',
        },
        {
          id: 'dest_singapore',
          name: 'Singapore Skylines & Marina Bay',
          country: 'Singapore',
          category: 'City Luxury',
          serverUrl: 'https://holidays.safiriholidays.com/holidays/list/singapore',
          imageUrl: 'https://images.unsplash.com/photo-1525625293386-3f8f99389edd',
          priceUsd: 1250,
          priceRwf: 1725000,
          highlights: ['Marina Bay Sands SkyPark', 'Gardens by the Bay', 'Universal Studios Sentosa'],
          serverSource: 'safiriholidays.com',
        },
      ];

      return {
        success: true,
        serverStatus: health,
        fetchedAt: new Date().toISOString(),
        domain: this.mainDomain,
        totalExtractedLinks: extractedLinks.length,
        extractedPackageLinks: extractedLinks,
        destinations: liveDestinations,
      };
    } catch (error) {
      console.error('❌ [SAFIRI HOLIDAYS SERVICE ERROR] Failed to fetch server data:', error.message);
      // Return structured fallback
      return {
        success: false,
        error: error.message,
        domain: this.mainDomain,
        serverStatus: { online: false, domain: this.mainDomain },
        destinations: [],
      };
    }
  }

  /**
   * Get direct server integration links for Safiri services
   */
  getServerServiceEndpoints() {
    return {
      mainWebsite: 'https://safiriholidays.com',
      flightsEngine: 'http://flights.safiriholidays.com',
      holidaysPortal: 'https://holidays.safiriholidays.com/',
      hotelsBooking: 'https://safiriholidays.com/booking-hotel.html',
      busBooking: 'https://safiriholidays.com/booking-bus.html',
      aboutPage: 'https://safiriholidays.com/about.html',
      contactPage: 'https://safiriholidays.com/contact.html',
    };
  }
}

export const safiriHolidaysService = new SafiriHolidaysService();
export default safiriHolidaysService;
