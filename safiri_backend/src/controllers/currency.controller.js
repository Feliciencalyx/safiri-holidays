import https from 'https';

// In-memory cache for forex exchange rates
let ratesCache = {
  rates: {
    USD: 1.0,
    EUR: 0.92,
    GBP: 0.78,
    CAD: 1.36,
    AUD: 1.52,
    JPY: 155.0,
    AED: 3.67,
    RWF: 1320.0,
    KES: 130.0,
    ZAR: 18.5,
  },
  lastFetched: 0,
};

const CACHE_TTL_MS = 60 * 60 * 1000; // 1 hour

async function fetchLiveForexRates() {
  return new Promise((resolve) => {
    https.get('https://open.er-api.com/v6/latest/USD', (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          if (parsed && parsed.result === 'success' && parsed.rates) {
            resolve(parsed.rates);
          } else {
            resolve(null);
          }
        } catch {
          resolve(null);
        }
      });
    }).on('error', () => {
      resolve(null);
    });
  });
}

export const getLiveRates = async (req, res) => {
  try {
    const now = Date.now();
    if (now - ratesCache.lastFetched > CACHE_TTL_MS) {
      const live = await fetchLiveForexRates();
      if (live) {
        ratesCache.rates = {
          ...ratesCache.rates,
          ...live,
        };
        ratesCache.lastFetched = now;
      }
    }

    res.json({
      success: true,
      base: 'USD',
      rates: ratesCache.rates,
      timestamp: new Date().toISOString(),
      source: ratesCache.lastFetched > 0 ? 'live_api' : 'fallback_rates',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve currency exchange rates',
      rates: ratesCache.rates,
    });
  }
};
