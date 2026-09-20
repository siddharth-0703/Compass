"use client"
import React from 'react';
import { SchemeRecommender } from '@/features/schemes/components/SchemeRecommender';
import { useDictionary } from '@/components/providers/DictionaryProvider';

export default function SchemesPage() {
  const { dict } = useDictionary();
  return (
    <div className="container mx-auto py-8">
      <div className="mb-8">
        <h1 className="text-4xl font-bold text-gray-900 mb-2">{dict.governmentSchemes?.pageTitle || "Government Schemes Made for You"}</h1>
        <p className="text-lg text-gray-600">{dict.governmentSchemes?.pageDescription || "Discover schemes, subsidies, financial support and training opportunities matched to your profile."}</p>
      </div>
      <SchemeRecommender />
    </div>
  );
}
