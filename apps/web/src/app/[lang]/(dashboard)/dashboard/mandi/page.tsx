"use client";

import React, { useState, useEffect } from 'react';
import { useSearchParams } from 'next/navigation';
import axios from 'axios';
import { Loader2, TrendingUp, AlertCircle, RefreshCw } from 'lucide-react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Button } from '@/components/ui/button';
import { useDictionary } from '@/components/providers/DictionaryProvider';

export default function MandiPage() {
  return (
    <React.Suspense fallback={<div className="flex h-screen items-center justify-center"><Loader2 className="h-8 w-8 animate-spin text-green-600" /></div>}>
      <MandiPageContent />
    </React.Suspense>
  );
}

function MandiPageContent() {
  const { dict } = useDictionary();
  const t = dict.marketPrices || {};
  const searchParams = useSearchParams();
  const initialCommodity = searchParams.get('commodity') || '';
  const initialMarket = searchParams.get('market') || '';
  const initialState = searchParams.get('state') || '';

  const [states, setStates] = useState<string[]>([]);
  const [commodities, setCommodities] = useState<string[]>([]);
  const [markets, setMarkets] = useState<{ market: string; district: string }[]>([]);
  
  const [selectedState, setSelectedState] = useState(initialState);
  const [selectedCommodity, setSelectedCommodity] = useState(initialCommodity);
  const [selectedMarket, setSelectedMarket] = useState(initialMarket);

  const [prices, setPrices] = useState<any[]>([]);
  const [lastUpdated, setLastUpdated] = useState<string>('');
  
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  // Fetch States on mount
  useEffect(() => {
    axios.get('/api/proxy/mandi/states', { withCredentials: true })
      .then(res => setStates(res.data.data))
      .catch(err => {
        if (err.response?.status === 503) setError('PRICE_SERVICE_UNAVAILABLE');
        else setError('Failed to load states');
      });
  }, []);

  // Fetch Markets & Commodities when state changes
  useEffect(() => {
    if (!selectedState) return;
    axios.get(`/api/proxy/mandi/markets?state=${encodeURIComponent(selectedState)}`, { withCredentials: true })
      .then(res => setMarkets(res.data.data))
      .catch(() => {});
      
    axios.get(`/api/proxy/mandi/commodities?state=${encodeURIComponent(selectedState)}`, { withCredentials: true })
      .then(res => setCommodities(res.data.data))
      .catch(() => {});
  }, [selectedState]);

  // Handle Initial Query load (for AI Voice links)
  useEffect(() => {
    if (initialCommodity || initialState || initialMarket) {
      if (initialState) setSelectedState(initialState);
      if (initialCommodity) setSelectedCommodity(initialCommodity);
      if (initialMarket) setSelectedMarket(initialMarket);
      
      // We must wait for states/commodities to load theoretically, but handleSearch will fetch direct
      setTimeout(() => {
        fetchPrices(initialState, initialCommodity, initialMarket);
      }, 500);
    }
  }, [initialCommodity, initialState, initialMarket]);

  const fetchPrices = async (stateVal: string, commodityVal: string, marketVal: string) => {
    if (!stateVal && !commodityVal) {
      setError('Please select at least a state or a commodity');
      return;
    }
    
    setLoading(true);
    setError('');
    
    try {
      const params = new URLSearchParams();
      if (stateVal) params.append('state', stateVal);
      if (commodityVal) params.append('commodity', commodityVal);
      if (marketVal) params.append('market', marketVal);
      
      const res = await axios.get(`/api/proxy/mandi/prices?${params.toString()}`, { withCredentials: true });
      setPrices(res.data.data);
      
      const date = new Date(res.data.timestamp);
      setLastUpdated(date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: true }));
    } catch (err: any) {
      if (err.response?.status === 503) {
        setError('PRICE_SERVICE_UNAVAILABLE');
      } else {
        setError('Failed to fetch prices');
      }
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = () => {
    fetchPrices(selectedState, selectedCommodity, selectedMarket);
  };

  return (
    <div className="container mx-auto py-8 space-y-8">
      <div>
        <h1 className="text-4xl font-bold text-gray-900 mb-2 flex items-center gap-3">
          <TrendingUp className="h-8 w-8 text-green-600" />
          {t.pageTitle || "Market Prices"}
        </h1>
        <p className="text-lg text-gray-600">{t.pageDescription || "Check daily wholesale agricultural prices across India."}</p>
      </div>

      {error === 'PRICE_SERVICE_UNAVAILABLE' && (
        <div className="bg-red-50 border border-red-200 text-red-800 rounded-lg p-4 flex items-start gap-3">
          <AlertCircle className="h-5 w-5 mt-0.5" />
          <div>
            <h3 className="font-semibold">{t.serviceUnavailable || "Service Unavailable"}</h3>
            <p className="text-sm mt-1">
              {t.serviceUnavailableDesc || "Market prices are temporarily unavailable. Please try again shortly."}
            </p>
          </div>
        </div>
      )}

      {error && error !== 'PRICE_SERVICE_UNAVAILABLE' && (
        <div className="bg-red-50 border border-red-200 text-red-800 rounded-lg p-4 flex items-start gap-3">
          <AlertCircle className="h-5 w-5 mt-0.5" />
          <div>
            <h3 className="font-semibold">{t.errorTitle || "Error"}</h3>
            <p className="text-sm mt-1">{error}</p>
          </div>
        </div>
      )}

      <Card>
        <CardHeader>
          <CardTitle>{t.checkRatesTitle || "Check APMC Mandi Rates"}</CardTitle>
          <CardDescription>{t.checkRatesDesc || "Filter by state, market, or specific crop"}</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4 items-end">
            <div className="space-y-2">
              <label className="text-sm font-medium">{t.stateLabel || "State"}</label>
              <Select value={selectedState} onValueChange={(val) => setSelectedState(val || '')}>
                <SelectTrigger>
                  <SelectValue placeholder={t.selectState || "Select State"} />
                </SelectTrigger>
                <SelectContent>
                  {states.map(s => <SelectItem key={s} value={s}>{dict.dynamicData?.states?.[s] || s}</SelectItem>)}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">{t.commodityLabel || "Commodity"}</label>
              <Select value={selectedCommodity} onValueChange={(val) => setSelectedCommodity(val || '')}>
                <SelectTrigger>
                  <SelectValue placeholder={t.selectCrop || "Select Crop"} />
                </SelectTrigger>
                <SelectContent>
                  {commodities.map(c => <SelectItem key={c} value={c}>{dict.dynamicData?.crops?.[c] || c}</SelectItem>)}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">{t.marketLabel || "Market (APMC)"}</label>
              <Select value={selectedMarket} onValueChange={(val) => setSelectedMarket(val || '')} disabled={!selectedState}>
                <SelectTrigger>
                  <SelectValue placeholder={t.selectMarket || "Select Market"} />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all_markets">{t.allMarkets || "All Markets"}</SelectItem>
                  {markets.map(m => <SelectItem key={m.market} value={m.market}>{dict.dynamicData?.markets?.[m.market] || m.market}</SelectItem>)}
                </SelectContent>
              </Select>
            </div>
            <Button onClick={handleSearch} disabled={loading || (!selectedState && !selectedCommodity)} className="w-full">
              {loading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : <RefreshCw className="mr-2 h-4 w-4" />}
              {t.checkPricesBtn || "Check Prices"}
            </Button>
          </div>
        </CardContent>
      </Card>

      {lastUpdated && !loading && (
        <div className="text-sm text-gray-500 text-right font-medium">
          {t.lastUpdated || "Last updated:"} {lastUpdated}
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {loading ? (
          <div className="col-span-full py-12 flex justify-center">
            <Loader2 className="h-8 w-8 animate-spin text-green-600" />
          </div>
        ) : (
          prices.map((price, idx) => (
            <Card key={idx} className="overflow-hidden hover:shadow-lg transition-shadow border-t-4 border-t-green-500">
              <CardHeader className="bg-gray-50/50 pb-4">
                <div className="flex justify-between items-start">
                  <div>
                    <CardTitle className="text-xl">{dict.dynamicData?.crops?.[price.commodity] || price.commodity}</CardTitle>
                    <CardDescription>{dict.dynamicData?.markets?.[price.market] || price.market}, {dict.dynamicData?.states?.[price.state] || price.state}</CardDescription>
                  </div>
                  <span className="bg-green-100 text-green-800 text-xs px-2 py-1 rounded-full font-medium border border-green-200">
                    {price.arrival_date}
                  </span>
                </div>
              </CardHeader>
              <CardContent className="pt-6">
                <div className="grid grid-cols-3 gap-4 text-center">
                  <div>
                    <div className="text-xs text-gray-500 uppercase font-semibold mb-1">{t.minLabel || "Min"}</div>
                    <div className="font-medium text-gray-700">₹{price.min_price}</div>
                  </div>
                  <div className="bg-green-50 rounded-lg p-2 border border-green-100 transform -translate-y-2">
                    <div className="text-xs text-green-700 uppercase font-bold mb-1">{t.modalLabel || "Modal"}</div>
                    <div className="text-lg font-bold text-green-900">₹{price.modal_price}</div>
                  </div>
                  <div>
                    <div className="text-xs text-gray-500 uppercase font-semibold mb-1">{t.maxLabel || "Max"}</div>
                    <div className="font-medium text-gray-700">₹{price.max_price}</div>
                  </div>
                </div>
                <div className="mt-6 flex justify-between items-center text-xs text-gray-500 pt-4 border-t border-gray-100">
                  <span className="font-medium">{t.varietyLabel || "Variety:"} {dict.dynamicData?.varieties?.[price.variety] || price.variety}</span>
                  <span className="font-medium bg-gray-100 px-2 py-1 rounded text-gray-600">{t.unitLabel || "Unit: ₹/quintal"}</span>
                </div>
              </CardContent>
            </Card>
          ))
        )}
        {!loading && prices.length === 0 && lastUpdated && !error && (
          <div className="col-span-full py-12 text-center text-gray-500 text-lg">
            {t.noRecords || "No price records found for the selected criteria."}
          </div>
        )}
      </div>
    </div>
  );
}
