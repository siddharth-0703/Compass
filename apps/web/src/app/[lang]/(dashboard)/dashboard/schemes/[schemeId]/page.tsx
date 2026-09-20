"use client";
import React, { useEffect, useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import axios from 'axios';

interface RecommendationTrace {
  schemeId: string;
  matchedRules: any[];
  failedRules: any[];
  score: number;
  eligibilityStatus: string;
  engineVersion: string;
  evaluatedAt: string;
}

interface SchemeDetails {
  schemeName: string;
  category: string;
  ministry: string;
  overview: string;
  benefits: string[];
  eligibilityCriteria: string[];
  requiredDocuments: string[];
  applicationProcess: string;
  officialUrl: string;
  applicationUrl: string;
  targetGroups: string[];
  isVerified?: boolean;
}

const CATEGORY_COLORS: Record<string, string> = {
  AGRICULTURE: 'bg-green-100 text-green-800',
  ENTREPRENEURSHIP: 'bg-blue-100 text-blue-800',
  FINANCE: 'bg-yellow-100 text-yellow-800',
  EMPLOYMENT: 'bg-purple-100 text-purple-800',
  MSME: 'bg-cyan-100 text-cyan-800',
  WOMEN: 'bg-pink-100 text-pink-800',
  STARTUP: 'bg-violet-100 text-violet-800',
  OTHER: 'bg-gray-100 text-gray-800',
};

export default function SchemeDetailsPage() {
  const routeParams = useParams();
  const schemeId = (routeParams?.schemeId as string) || '';
  const schemeName = decodeURIComponent(schemeId);
  const cacheKey = `scheme_detail_${schemeId}`;

  const [details, setDetails] = useState<SchemeDetails | null>(null);
  const [trace, setTrace] = useState<RecommendationTrace | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string>('');
  
  const [explanation, setExplanation] = useState<string | null>(null);
  const [loadingExplanation, setLoadingExplanation] = useState(false);

  const [savingScheme, setSavingScheme] = useState(false);
  const [isSaved, setIsSaved] = useState(false);

  useEffect(() => {
    const fetchDetails = async () => {
      // Phase C: Check sessionStorage cache first — avoid redundant Gemini calls
      try {
        const cached = sessionStorage.getItem(cacheKey);
        if (cached) {
          setDetails(JSON.parse(cached));
          setLoading(false);
          return;
        }
      } catch {}

      try {
        const res = await axios.post('/api/proxy/ai/scheme-details', { schemeName });
        if (res.data?.success && res.data.data) {
          const data = res.data.data as SchemeDetails;
          setDetails(data);
          // Cache in sessionStorage to avoid repeat calls
          try { sessionStorage.setItem(cacheKey, JSON.stringify(data)); } catch {}
        } else {
          throw new Error('Invalid response');
        }
      } catch (err: any) {
        setError(err?.response?.data?.error?.message || 'Failed to load scheme details.');
      } finally {
        setLoading(false);
      }
    };

    fetchDetails();

    // Check for trace in sessionStorage
    try {
      const savedTrace = sessionStorage.getItem(`trace_${schemeName}`);
      if (savedTrace) {
        setTrace(JSON.parse(savedTrace));
      }
    } catch (e) {}
  }, [schemeName, cacheKey]);

  const handleWhyRecommended = async () => {
    if (explanation) { setExplanation(null); return; }
    setLoadingExplanation(true);
    try {
      const res = await axios.post('/api/proxy/ai/explain-scheme', {
        schemeName: details?.schemeName || schemeName,
        trace,
      });
      setExplanation(res.data?.data?.explanation || 'Could not generate explanation.');
    } catch {
      setExplanation('Unable to fetch explanation. Please try again.');
    } finally {
      setLoadingExplanation(false);
    }
  };

  const handleSaveScheme = async () => {
    if (isSaved) return;
    setSavingScheme(true);
    try {
      await axios.post('/api/proxy/users/me/saved-schemes', { schemeId: trace?.schemeId || schemeName });
      setIsSaved(true);
    } catch {
      alert('Failed to save scheme.');
    } finally {
      setSavingScheme(false);
    }
  };


  // ── Loading ────────────────────────────────────────────────────────────────
  if (loading) {
    return (
      <div className="container mx-auto py-8 max-w-4xl">
        <div className="flex flex-col items-center justify-center py-24 gap-4">
          <div className="w-14 h-14 border-4 border-green-500 border-t-transparent rounded-full animate-spin" />
          <p className="text-gray-500 text-sm">Loading scheme details from Gemini AI…</p>
        </div>
      </div>
    );
  }

  // ── Error ──────────────────────────────────────────────────────────────────
  if (error || !details) {
    return (
      <div className="container mx-auto py-8 max-w-4xl">
        <Link href="/dashboard/schemes" className="text-green-600 hover:underline text-sm mb-6 inline-block">
          ← Back to Schemes
        </Link>
        <div className="text-center py-20">
          <div className="text-5xl mb-4">⚠️</div>
          <p className="text-lg font-semibold text-gray-800 mb-2">{error || 'Could not load scheme'}</p>
          <p className="text-sm text-gray-500">The scheme details could not be fetched. Please try again later.</p>
        </div>
      </div>
    );
  }

  const categoryColor = CATEGORY_COLORS[details.category] || CATEGORY_COLORS.OTHER;

  // ── Details ────────────────────────────────────────────────────────────────
  return (
    <div className="container mx-auto py-8 max-w-4xl">
      {/* Back navigation */}
      <Link href="/dashboard/schemes" className="text-green-600 hover:underline text-sm mb-6 inline-flex items-center gap-1">
        ← Back to Schemes
      </Link>

      {/* Header */}
      <div className="mb-6 mt-3">
        <div className="flex flex-wrap items-center gap-2 mb-3">
          <span className={`text-xs font-bold uppercase tracking-wider px-2.5 py-1 rounded ${categoryColor}`}>
            {details.category?.replace('_', ' ')}
          </span>
          {trace || details.isVerified ? (
            <span className="text-xs bg-green-50 border border-green-200 text-green-700 px-2.5 py-1 rounded font-semibold">
              ✓ Verified Recommendation
            </span>
          ) : (
            <span className="text-xs bg-purple-50 border border-purple-200 text-purple-700 px-2.5 py-1 rounded font-semibold">
              ✨ AI Discovered (Unverified)
            </span>
          )}
        </div>
        <h1 className="text-3xl font-bold text-gray-900 mb-2 leading-tight">{details.schemeName}</h1>
        <p className="text-gray-500 text-sm">{details.ministry}</p>
      </div>

      <div className="space-y-6">
        {/* Recommendation Trace */}
        {trace && (
          <div className="bg-gradient-to-r from-green-50 to-emerald-50 p-6 rounded-2xl shadow-sm border border-green-200">
            <div className="flex justify-between items-start mb-4">
              <div>
                <h2 className="text-lg font-bold text-green-900 flex items-center gap-2">
                  <span>🎯 Personalised Match</span>
                  <span className="bg-green-600 text-white text-xs px-2 py-0.5 rounded-full">{trace.score}%</span>
                </h2>
                <p className="text-sm text-green-700 mt-1">Status: <span className="font-semibold">{trace.eligibilityStatus}</span></p>
              </div>
              <button
                onClick={handleWhyRecommended}
                disabled={loadingExplanation}
                className="px-4 py-2 bg-white border border-green-300 text-green-700 rounded-lg text-sm font-semibold hover:bg-green-50 transition shadow-sm disabled:opacity-50"
              >
                {loadingExplanation ? 'Generating...' : explanation ? 'Hide Explanation' : 'Why Recommended?'}
              </button>
            </div>

            {explanation && (
              <div className="mb-4 p-4 bg-white border border-green-100 rounded-xl shadow-sm text-sm text-gray-800 leading-relaxed">
                <p className="font-semibold text-green-800 mb-2">💡 AI Explanation</p>
                {explanation}
              </div>
            )}

            <div className="grid md:grid-cols-2 gap-4">
              <div>
                <h3 className="text-sm font-semibold text-gray-700 mb-2">Matched Requirements</h3>
                <ul className="space-y-1">
                  {trace.matchedRules?.map((r, i) => (
                    <li key={i} className="flex items-start gap-2 text-xs text-green-800 bg-white px-2 py-1.5 rounded border border-green-100 shadow-sm">
                      <span className="text-green-500 font-bold shrink-0">✓</span>
                      <span>{r.field.replace(/([A-Z])/g, ' $1').trim()} {r.operator} {r.value}</span>
                    </li>
                  ))}
                  {(!trace.matchedRules || trace.matchedRules.length === 0) && (
                    <li className="text-xs text-gray-500">No specific rules matched.</li>
                  )}
                </ul>
              </div>
              <div>
                <h3 className="text-sm font-semibold text-gray-700 mb-2">Unmet / Missing Information</h3>
                <ul className="space-y-1">
                  {trace.failedRules?.map((r, i) => (
                    <li key={i} className="flex items-start gap-2 text-xs text-red-800 bg-white px-2 py-1.5 rounded border border-red-100 shadow-sm">
                      <span className="text-red-500 font-bold shrink-0">✗</span>
                      <span>{r.field.replace(/([A-Z])/g, ' $1').trim()} {r.operator} {r.value}</span>
                    </li>
                  ))}
                  {(!trace.failedRules || trace.failedRules.length === 0) && (
                    <li className="text-xs text-gray-500 italic">None</li>
                  )}
                </ul>
              </div>
            </div>
            <div className="mt-4 pt-3 border-t border-green-200/50 flex justify-between items-center text-[10px] text-green-600 uppercase tracking-wide">
              <span>Engine: {trace.engineVersion}</span>
              <span>Evaluated: {new Date(trace.evaluatedAt).toLocaleDateString()}</span>
            </div>
          </div>
        )}

        {/* Overview */}
        <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900 mb-3 flex items-center gap-2">
            📋 Overview
          </h2>
          <p className="text-gray-700 leading-relaxed">{details.overview}</p>
        </div>

        {/* Target groups */}
        {details.targetGroups?.length > 0 && (
          <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
            <h2 className="text-lg font-semibold text-gray-900 mb-3">👥 Who Is This For?</h2>
            <div className="flex flex-wrap gap-2">
              {details.targetGroups.map((g, i) => (
                <span key={i} className="bg-green-50 text-green-800 border border-green-200 text-sm px-3 py-1 rounded-full font-medium">
                  {g}
                </span>
              ))}
            </div>

            <button
              onClick={handleSaveScheme}
              disabled={savingScheme || isSaved}
              className="mt-3 w-full py-3 border-2 border-gray-300 text-gray-700 rounded-xl font-bold text-sm hover:bg-gray-50 transition flex items-center justify-center gap-2 disabled:opacity-50"
            >
              {isSaved ? '✓ Saved to your profile' : savingScheme ? 'Saving...' : 'Save Scheme for Later'}
            </button>
          </div>
        )}

        <div className="grid md:grid-cols-2 gap-6">
          {/* Benefits */}
          {details.benefits?.length > 0 && (
            <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
              <h2 className="text-lg font-semibold text-gray-900 mb-3">💰 Benefits</h2>
              <ul className="space-y-2">
                {details.benefits.map((b, i) => (
                  <li key={i} className="flex items-start gap-2 text-sm text-gray-700">
                    <span className="text-green-500 mt-0.5 shrink-0">✓</span>
                    {b}
                  </li>
                ))}
              </ul>
            </div>
          )}

          {/* Eligibility */}
          {details.eligibilityCriteria?.length > 0 && (
            <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
              <h2 className="text-lg font-semibold text-gray-900 mb-3">✅ Eligibility Criteria</h2>
              <ul className="space-y-2">
                {details.eligibilityCriteria.map((c, i) => (
                  <li key={i} className="flex items-start gap-2 text-sm text-gray-700">
                    <span className="text-blue-500 mt-0.5 shrink-0">•</span>
                    {c}
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>

        {/* Required documents */}
        {details.requiredDocuments?.length > 0 && (
          <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
            <h2 className="text-lg font-semibold text-gray-900 mb-3">📄 Required Documents</h2>
            <div className="grid sm:grid-cols-2 gap-2">
              {details.requiredDocuments.map((doc, i) => (
                <div key={i} className="flex items-center gap-2 text-sm text-gray-700 bg-gray-50 px-3 py-2 rounded-lg">
                  <span className="text-gray-400">📎</span>
                  {doc}
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Application process */}
        {details.applicationProcess && (
          <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
            <h2 className="text-lg font-semibold text-gray-900 mb-3">🚀 How to Apply</h2>
            <p className="text-gray-700 text-sm leading-relaxed">{details.applicationProcess}</p>
          </div>
        )}

        {/* Disclaimer */}
        <div className="bg-yellow-50 border border-yellow-200 rounded-xl p-4">
          <p className="text-xs text-yellow-800 leading-relaxed">
            <strong>⚠️ Important:</strong> This information was generated by AI and may not reflect the latest scheme guidelines.
            Always verify eligibility and application details on the official government portal before applying.
          </p>
        </div>

        {/* CTA */}
        <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
          <div className="flex flex-col sm:flex-row gap-4">
            <a
              href={details.applicationUrl || details.officialUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="flex-1 py-3 bg-green-600 text-white text-center rounded-xl font-bold hover:bg-green-700 transition shadow"
            >
              Apply on Official Portal →
            </a>
            <a
              href={details.officialUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="flex-1 py-3 border-2 border-gray-300 text-gray-700 text-center rounded-xl font-semibold hover:bg-gray-50 transition text-sm"
            >
              View Official Scheme Page
            </a>
          </div>
          <p className="text-xs text-gray-400 mt-3 text-center">
            You will be redirected to the official government portal. We do not collect applications.
          </p>
        </div>
      </div>
    </div>
  );
}
