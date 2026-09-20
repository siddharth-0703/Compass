import React, { useState, useCallback } from 'react';
import Link from 'next/link';
import axios from 'axios';
import { SchemeQuestionnaire, SchemeProfile } from './SchemeQuestionnaire';
import { useDictionary } from '@/components/providers/DictionaryProvider';

interface RecommendationTrace {
  schemeId: string;
  matchedRules: any[];
  failedRules: any[];
  score: number;
  eligibilityStatus: string;
}

interface SchemeRecommendation {
  schemeName: string;
  category?: string;
  ministry?: string;
  shortDescription?: string;
  source: 'AI_DISCOVERED' | 'VERIFIED';
  aiConfidence?: number;
  matchScore: number | null;
  eligibilityStatus: 'LIKELY_ELIGIBLE' | 'POTENTIALLY_ELIGIBLE' | 'NOT_ELIGIBLE' | 'INSUFFICIENT_INFORMATION' | 'UNVERIFIED' | 'UNKNOWN';
  officialUrl?: string;
  explanationAvailable: boolean;
  trace?: RecommendationTrace;
  freshness?: {
    status: 'CURRENT' | 'REVIEW_DUE' | 'EXPIRED';
    lastVerifiedAt?: string;
  };
}

interface SchemeRecommendationResponse {
  generatedAt: string;
  profileVersion: string;
  engineVersion: string;
  verifiedRecommendations: SchemeRecommendation[];
  aiDiscoveredSchemes: SchemeRecommendation[];
  metadata: {
    totalVerified: number;
    totalDiscovered: number;
    fromCache: boolean;
    dataFreshness: 'FRESH' | 'STALE' | 'LIMITED';
    aiDiscoveryAvailable: boolean;
  };
}

type PageState = 'initial' | 'loading' | 'results' | 'error';

const CATEGORY_COLORS: Record<string, string> = {
  AGRICULTURE: 'bg-green-100 text-green-800',
  ENTREPRENEURSHIP: 'bg-blue-100 text-blue-800',
  FINANCE: 'bg-yellow-100 text-yellow-800',
  EMPLOYMENT: 'bg-purple-100 text-purple-800',
  EDUCATION: 'bg-indigo-100 text-indigo-800',
  HOUSING: 'bg-orange-100 text-orange-800',
  WOMEN: 'bg-pink-100 text-pink-800',
  MSME: 'bg-cyan-100 text-cyan-800',
  STARTUP: 'bg-violet-100 text-violet-800',
  SOCIAL_WELFARE: 'bg-teal-100 text-teal-800',
  DIGITAL: 'bg-sky-100 text-sky-800',
  OTHER: 'bg-gray-100 text-gray-800',
};

function MatchScoreBar({ value, status, t }: { value: number, status: string, t: any }) {
  if (status === 'INELIGIBLE') {
    return (
      <div className="flex items-center gap-2 mt-2">
        <span className="text-xs font-bold text-red-600">
          {t.ineligibleLabel || "Ineligible (Does not meet strict criteria)"}
        </span>
      </div>
    );
  }

  const color = value >= 85 ? 'bg-green-500' : value >= 70 ? 'bg-yellow-500' : 'bg-orange-400';
  return (
    <div className="flex items-center gap-2 mt-2">
      <div className="flex-1 bg-gray-100 rounded-full h-1.5">
        <div className={`${color} h-1.5 rounded-full transition-all`} style={{ width: `${value}%` }} />
      </div>
      <span className={`text-xs font-bold ${value >= 85 ? 'text-green-700' : value >= 70 ? 'text-yellow-700' : 'text-orange-600'}`}>
        {value}% {t.matchLabel || "Match"}
      </span>
    </div>
  );
}

function SchemeCard({
  rec,
  profile,
  t
}: {
  rec: SchemeRecommendation;
  profile: SchemeProfile | null;
  t: any;
}) {
  const [explanation, setExplanation] = useState<string | null>(null);
  const [loadingExplanation, setLoadingExplanation] = useState(false);
  const schemeSlug = encodeURIComponent(rec.schemeName);

  const [savingScheme, setSavingScheme] = useState(false);
  const [isSaved, setIsSaved] = useState(false);

  const handleSaveScheme = async () => {
    if (isSaved) return;
    setSavingScheme(true);
    try {
      await axios.post('/api/proxy/users/me/saved-schemes', { schemeId: rec.trace?.schemeId || rec.schemeName });
      setIsSaved(true);
    } catch {
      alert('Failed to save scheme.');
    } finally {
      setSavingScheme(false);
    }
  };

  const handleWhyRecommended = async () => {
    if (explanation) { setExplanation(null); return; }
    setLoadingExplanation(true);
    try {
      const res = await axios.post('/api/proxy/ai/explain-scheme', {
        schemeName: rec.schemeName,
        trace: rec.trace,
      });
      setExplanation(res.data?.data?.explanation || 'Could not generate explanation.');
    } catch {
      setExplanation('Unable to fetch explanation. Please try again.');
    } finally {
      setLoadingExplanation(false);
    }
  };

  const categoryColor = CATEGORY_COLORS[rec.category || 'OTHER'] || CATEGORY_COLORS.OTHER;
  const isVerified = rec.source === 'VERIFIED';
  const isReviewDue = rec.freshness?.status === 'REVIEW_DUE';

  return (
    <div className="bg-white border border-gray-200 rounded-2xl shadow-sm hover:shadow-md transition-all duration-200 flex flex-col overflow-hidden">
      {/* Header band */}
      <div className={`px-5 pt-5 pb-4`}>
        <div className="flex items-start justify-between gap-2 mb-3">
          <span className={`text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded ${categoryColor}`}>
            {t.categories?.[rec.category || 'OTHER'] || (rec.category || 'OTHER').replace('_', ' ')}
          </span>
          {isVerified ? (
            <span className="flex items-center gap-1 text-[10px] font-bold text-green-700 bg-green-50 border border-green-200 px-2 py-0.5 rounded">
              {t.verifiedBadge || "✓ Verified"}
            </span>
          ) : (
            <span className="flex items-center gap-1 text-[10px] font-bold text-purple-700 bg-purple-50 border border-purple-200 px-2 py-0.5 rounded">
              {t.aiDiscoveredBadge || "✨ AI Discovered"}
            </span>
          )}
        </div>

        <h3 className="text-base font-bold text-gray-900 leading-tight mb-1">{rec.schemeName}</h3>
        <p className="text-xs text-gray-500 mb-3">{rec.ministry}</p>
        <p className="text-sm text-gray-600 leading-relaxed">{rec.shortDescription}</p>

        {isVerified && rec.matchScore !== null ? (
          <MatchScoreBar value={rec.matchScore} status={rec.eligibilityStatus} t={t} />
        ) : (
          <div className="mt-2 text-xs text-purple-700 bg-purple-50 p-1.5 rounded border border-purple-100">
            <strong>Note:</strong> {t.noteAiUnverified || "This scheme may be relevant to your profile. Eligibility has not been independently verified."}
          </div>
        )}

        {isVerified && isReviewDue && (
          <div className="mt-2 text-xs text-amber-700 bg-amber-50 p-1.5 rounded border border-amber-200">
            {t.reviewDueWarning || "⚠ Scheme information is due for review. Final requirements may differ slightly."}
          </div>
        )}
      </div>

      {/* Reasons from trace */}
      {isVerified && rec.trace?.matchedRules && rec.trace.matchedRules.length > 0 && (
        <div className="px-5 pb-4">
          <p className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">{t.matchedEligibility || "Matched Eligibility"}</p>
          <ul className="space-y-1">
            {rec.trace.matchedRules.slice(0, 3).map((r, i) => (
              <li key={i} className="flex items-start gap-1.5 text-xs text-gray-600">
                <span className="text-green-500 mt-0.5 shrink-0">✓</span>
                {r.field.replace(/([A-Z])/g, ' $1').trim()} {t.requirementMet || "requirement met"}
              </li>
            ))}
          </ul>
        </div>
      )}

      {/* AI Explanation expansion */}
      {explanation && (
        <div className="mx-5 mb-4 p-3 bg-purple-50 border border-purple-100 rounded-xl text-xs text-purple-800 leading-relaxed">
          <p className="font-semibold mb-1">{t.aiExplanation || "💡 AI Explanation"}</p>
          {explanation}
        </div>
      )}

      {rec.eligibilityStatus === 'POTENTIALLY_ELIGIBLE' && (
        <div className="mx-5 mb-4 p-2 bg-yellow-50 border border-yellow-100 rounded-lg text-xs text-yellow-700">
          {t.missingInfoWarning || "⚠️ Missing information — verify eligibility before applying"}
        </div>
      )}

      {/* Actions */}
      <div className="px-5 pb-5 mt-auto grid grid-cols-2 gap-2">
        <Link
          href={`/dashboard/schemes/${schemeSlug}`}
          className="text-center py-2.5 bg-gray-100 text-gray-800 rounded-xl text-sm font-semibold hover:bg-gray-200 transition"
        >
          {t.viewDetails || "View Details"}
        </Link>
        {rec.explanationAvailable && (
          <button
            onClick={handleWhyRecommended}
            disabled={loadingExplanation}
            className="py-2.5 border-2 border-green-600 text-green-700 rounded-xl text-sm font-semibold hover:bg-green-50 transition disabled:opacity-50"
          >
            {loadingExplanation ? '...' : explanation ? (t.hide || 'Hide') : (t.whyRecommended || 'Why Recommended?')}
          </button>
        )}
        <button
          onClick={handleSaveScheme}
          disabled={savingScheme || isSaved || !isVerified}
          className="col-span-2 py-2.5 border border-gray-300 text-gray-700 rounded-xl text-sm font-semibold hover:bg-gray-50 transition disabled:opacity-50"
        >
          {isSaved ? (t.saved || '✓ Saved') : savingScheme ? (t.saving || 'Saving...') : (t.saveScheme || 'Save Scheme')}
        </button>
      </div>

      {/* Apply link */}
      {rec.officialUrl && (
        <div className="border-t px-5 py-3">
          <a
            href={rec.officialUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="text-xs text-blue-600 hover:underline flex items-center gap-1"
          >
            {t.applyOfficial || "🔗 Apply on official government portal"}
          </a>
        </div>
      )}
    </div>
  );
}

export function SchemeRecommender() {
  const { dict } = useDictionary();
  const t = dict.governmentSchemes || {};

  const [pageState, setPageState] = useState<PageState>('initial');
  const [showQuestionnaire, setShowQuestionnaire] = useState(false);
  const [profile, setProfile] = useState<SchemeProfile | null>(null);
  const [verifiedRecommendations, setVerifiedRecommendations] = useState<SchemeRecommendation[]>([]);
  const [aiDiscoveredSchemes, setAiDiscoveredSchemes] = useState<SchemeRecommendation[]>([]);
  const [metadata, setMetadata] = useState<SchemeRecommendationResponse['metadata'] | null>(null);
  const [error, setError] = useState<string>('');

  const handleProfileComplete = useCallback(async (newProfile: SchemeProfile) => {
    setShowQuestionnaire(false);
    setProfile(newProfile);
    setPageState('loading');
    setError('');

    try {
      const response = await axios.post('/api/proxy/ai/recommend-schemes', newProfile);
      if (response.data?.success && response.data.data) {
        const resData = response.data.data as SchemeRecommendationResponse;
        setVerifiedRecommendations(resData.verifiedRecommendations || []);
        setAiDiscoveredSchemes(resData.aiDiscoveredSchemes || []);
        setMetadata(resData.metadata || null);
        setPageState('results');
      } else {
        throw new Error('Invalid response from server');
      }
    } catch (err: any) {
      const msg = err?.response?.data?.error?.message || 'Failed to fetch recommendations. Please try again.';
      setError(msg);
      setPageState('error');
    }
  }, []);

  // ── Loading state ──────────────────────────────────────────────────────────
  if (pageState === 'loading') {
    return (
      <div className="flex flex-col items-center justify-center py-24 gap-6">
        <div className="relative w-20 h-20">
          <div className="absolute inset-0 border-4 border-green-100 rounded-full" />
          <div className="absolute inset-0 border-4 border-green-500 rounded-full border-t-transparent animate-spin" />
        </div>
        <div className="text-center">
          <p className="text-xl font-bold text-gray-900 mb-1">{t.analyzingProfile || "Analyzing your profile…"}</p>
          <p className="text-sm text-gray-500">{t.aiSearching || "Gemini AI is searching for matching government schemes"}</p>
        </div>
        <div className="flex gap-2">
          {[
            t.checkingEligibility || 'Checking eligibility', 
            t.matchingSchemes || 'Matching schemes', 
            t.preparingResults || 'Preparing results'
          ].map((text, i) => (
            <span key={text} className="text-xs bg-green-50 text-green-700 px-3 py-1 rounded-full animate-pulse" style={{ animationDelay: `${i * 0.3}s` }}>
              {text}
            </span>
          ))}
        </div>
      </div>
    );
  }

  // ── Error state ────────────────────────────────────────────────────────────
  if (pageState === 'error') {
    return (
      <div className="flex flex-col items-center justify-center py-20 gap-4">
        <div className="text-5xl">⚠️</div>
        <p className="text-lg font-semibold text-gray-800">{t.somethingWentWrong || "Something went wrong"}</p>
        <p className="text-sm text-gray-500 max-w-sm text-center">{error}</p>
        <button
          onClick={() => { setPageState('initial'); setVerifiedRecommendations([]); setAiDiscoveredSchemes([]); }}
          className="mt-2 px-6 py-2.5 bg-green-600 text-white rounded-xl font-semibold hover:bg-green-700 transition"
        >
          {t.tryAgain || "Try Again"}
        </button>
      </div>
    );
  }

  // ── Results state ──────────────────────────────────────────────────────────
  if (pageState === 'results') {
    return (
      <div>
        {/* Results header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
          <div>
            <h2 className="text-2xl font-bold text-gray-900">
              {verifiedRecommendations.length + aiDiscoveredSchemes.length} {t.schemesFound || "Schemes Found For You"}
            </h2>
            <p className="text-sm text-gray-500 mt-0.5">
              {t.basedOnProfile || "Based on your profile:"} {profile?.activity} · {profile?.state} · {profile?.category}
            </p>
            <div className="flex items-center gap-3 mt-2">
              <span className="flex items-center gap-1 text-xs text-green-700 bg-green-50 border border-green-200 px-2 py-0.5 rounded font-medium">
                {t.verifiedTooltip || "✓ Verified — officially confirmed schemes"}
              </span>
              <span className="flex items-center gap-1 text-xs text-purple-700 bg-purple-50 border border-purple-200 px-2 py-0.5 rounded font-medium">
                {t.aiDiscoveredTooltip || "✨ AI Discovered — pending verification"}
              </span>
            </div>
          </div>
          <button
            onClick={() => setShowQuestionnaire(true)}
            className="shrink-0 px-5 py-2.5 border-2 border-green-600 text-green-700 rounded-xl font-semibold hover:bg-green-50 transition text-sm"
          >
            {t.refineProfile || "Refine Profile"}
          </button>
        </div>

        {metadata?.aiDiscoveryAvailable === false && (
          <div className="mb-6 p-4 bg-amber-50 border border-amber-200 rounded-xl text-sm text-amber-800">
            {t.aiUnavailableWarning || "⚠️ AI discovery is currently unavailable. Showing recommendations from verified government scheme records only."}
          </div>
        )}

        {verifiedRecommendations.length === 0 && aiDiscoveredSchemes.length === 0 ? (
          <div className="text-center py-16 bg-gray-50 rounded-2xl">
            <p className="text-4xl mb-4">🔍</p>
            <p className="text-lg font-semibold text-gray-700">{t.noMatchingSchemes || "No matching schemes found"}</p>
            <p className="text-sm text-gray-500 mt-2">{t.adjustProfilePrompt || "Try adjusting your profile or check back later."}</p>
          </div>
        ) : (
          <div className="space-y-10">
            {verifiedRecommendations.length > 0 && (
              <div>
                <h3 className="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
                  <span>{t.verifiedRecommendations || "Verified Recommendations"}</span>
                  <span className="bg-green-100 text-green-800 text-xs py-0.5 px-2 rounded-full">{verifiedRecommendations.length}</span>
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {verifiedRecommendations.map((rec, idx) => (
                    <SchemeCard key={`verified-${rec.schemeName}-${idx}`} rec={rec} profile={profile} t={t} />
                  ))}
                </div>
              </div>
            )}
            
            {aiDiscoveredSchemes.length > 0 && (
              <div>
                <h3 className="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
                  <span>{t.aiDiscoveredOpportunities || "AI Discovered Opportunities"}</span>
                  <span className="bg-purple-100 text-purple-800 text-xs py-0.5 px-2 rounded-full">{aiDiscoveredSchemes.length}</span>
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 opacity-90">
                  {aiDiscoveredSchemes.map((rec, idx) => (
                    <SchemeCard key={`ai-${rec.schemeName}-${idx}`} rec={rec} profile={profile} t={t} />
                  ))}
                </div>
              </div>
            )}
          </div>
        )}

        {showQuestionnaire && (
          <SchemeQuestionnaire
            onComplete={handleProfileComplete}
            onClose={() => setShowQuestionnaire(false)}
          />
        )}
      </div>
    );
  }

  // ── Initial / landing state ────────────────────────────────────────────────
  return (
    <div>
      {/* Hero CTA */}
      <div className="bg-gradient-to-br from-green-50 to-emerald-50 border border-green-200 rounded-2xl p-8 mb-8 flex flex-col sm:flex-row items-center justify-between gap-6">
        <div>
          <h2 className="text-2xl font-bold text-gray-900 mb-2">
            {t.aiDiscoveryTitle || "🤖 AI-Powered Scheme Discovery"}
          </h2>
          <p className="text-gray-600 max-w-lg text-sm leading-relaxed">
            {t.aiDiscoveryDesc || "Answer 6 quick questions about your profile. Our AI analyses thousands of central and state government schemes to find the ones you're most likely to benefit from."}
          </p>
          <div className="flex flex-wrap gap-2 mt-4">
            {[
              t.tags?.central || 'Central Govt Schemes',
              t.tags?.state || 'State Schemes',
              t.tags?.msme || 'MSME Subsidies',
              t.tags?.agri || 'Agri Support',
              t.tags?.women || 'Women Schemes'
            ].map(tag => (
              <span key={tag} className="text-xs bg-white border border-green-200 text-green-700 px-2.5 py-1 rounded-full font-medium">
                {tag}
              </span>
            ))}
          </div>
        </div>
        <button
          onClick={() => setShowQuestionnaire(true)}
          className="shrink-0 px-8 py-3.5 bg-green-600 text-white rounded-xl font-bold text-base hover:bg-green-700 transition shadow-md hover:shadow-lg"
        >
          {t.findMySchemesBtn || "Find My Schemes →"}
        </button>
      </div>

      {/* Info cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        {[
          { icon: '✓', title: t.verifiedSources || 'Verified Sources', desc: t.verifiedSourcesDesc || 'All scheme links point to official government portals — never third-party sites' },
          { icon: '🔒', title: t.privateSecure || 'Private & Secure', desc: t.privateSecureDesc || 'Your profile is only used to find schemes and is never stored or shared' },
        ].map(card => (
          <div key={card.title} className="bg-white border border-gray-200 rounded-xl p-5">
            <div className="text-3xl mb-3">{card.icon}</div>
            <h3 className="font-semibold text-gray-900 mb-1">{card.title}</h3>
            <p className="text-xs text-gray-500 leading-relaxed">{card.desc}</p>
          </div>
        ))}
      </div>

      {showQuestionnaire && (
        <SchemeQuestionnaire
          onComplete={handleProfileComplete}
          onClose={() => setShowQuestionnaire(false)}
        />
      )}
    </div>
  );
}
