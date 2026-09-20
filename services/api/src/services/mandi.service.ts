import axios from 'axios';
import { logger } from '@rural/logger';

const API_BASE = 'https://mandi-api.onrender.com/v1';

interface CacheEntry<T> {
  data: T;
  expiry: number;
}

class MandiService {
  private cache = new Map<string, CacheEntry<any>>();

  // Cache durations
  private STATIC_TTL = 60 * 60 * 1000; // 1 hour
  private PRICE_TTL = 15 * 60 * 1000; // 15 mins

  private async fetchWithCache<T>(key: string, url: string, ttl: number): Promise<T> {
    const cached = this.cache.get(key);
    if (cached && cached.expiry > Date.now()) {
      return cached.data;
    }

    try {
      const response = await axios.get(url, { timeout: 8000 });
      if (response.data && response.data.success) {
        this.cache.set(key, {
          data: response.data.data,
          expiry: Date.now() + ttl,
        });
        return response.data.data;
      }
      throw new Error('API returned unsuccessful response');
    } catch (error) {
      logger.error({ error, url }, 'Error fetching from Mandi API');
      throw new Error('PRICE_SERVICE_UNAVAILABLE');
    }
  }

  async getStates() {
    return this.fetchWithCache('states', `${API_BASE}/states`, this.STATIC_TTL);
  }

  async getCommodities(state?: string, market?: string) {
    const params = new URLSearchParams();
    if (state) params.append('state', state);
    if (market) params.append('market', market);
    
    const query = params.toString();
    const url = `${API_BASE}/commodities${query ? `?${query}` : ''}`;
    const cacheKey = `commodities:${query}`;
    
    return this.fetchWithCache(cacheKey, url, this.STATIC_TTL);
  }

  async getMarkets(state: string) {
    const url = `${API_BASE}/markets?state=${encodeURIComponent(state)}`;
    const cacheKey = `markets:${state}`;
    return this.fetchWithCache(cacheKey, url, this.STATIC_TTL);
  }

  async getPrices(state?: string, commodity?: string, market?: string) {
    const params = new URLSearchParams();
    if (state) params.append('state', state);
    if (commodity) params.append('commodity', commodity);
    if (market) params.append('market', market);

    const query = params.toString();
    const url = `${API_BASE}/prices${query ? `?${query}` : ''}`;
    const cacheKey = `prices:${query}`;
    
    return this.fetchWithCache(cacheKey, url, this.PRICE_TTL);
  }

  async getHistory(state: string, commodity: string, market?: string, from?: string, to?: string) {
    const params = new URLSearchParams();
    params.append('state', state);
    params.append('commodity', commodity);
    if (market) params.append('market', market);
    if (from) params.append('from', from);
    if (to) params.append('to', to);

    const query = params.toString();
    const url = `${API_BASE}/prices/history${query ? `?${query}` : ''}`;
    const cacheKey = `history:${query}`;
    
    return this.fetchWithCache(cacheKey, url, this.PRICE_TTL);
  }
}

export const mandiService = new MandiService();
