import React, { useState } from 'react';
import { useDictionary } from '@/components/providers/DictionaryProvider';

export interface SchemeProfile {
  activity: string;
  state: string;
  income: number;
  age: string;
  gender: string;
  category: string;
}

interface Props {
  onComplete: (profile: SchemeProfile) => void;
  onClose: () => void;
}

const STATES = [
  'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
  'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
  'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur',
  'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
  'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
  'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
  'Delhi', 'Jammu & Kashmir', 'Ladakh', 'Puducherry'
];

export function SchemeQuestionnaire({ onComplete, onClose }: Props) {
  const { dict } = useDictionary();
  const t = dict.governmentSchemes?.questionnaire || {};
  const stepsText = t.steps || {};
  const [step, setStep] = useState(1);
  const TOTAL_STEPS = 6;

  const [formData, setFormData] = useState<Partial<SchemeProfile>>({
    activity: '',
    state: '',
    income: 0,
    age: '',
    gender: '',
    category: 'General',
  });

  const update = (key: keyof SchemeProfile, value: any) =>
    setFormData(prev => ({ ...prev, [key]: value }));

  const canProceed = (): boolean => {
    switch (step) {
      case 1: return !!formData.activity;
      case 2: return !!formData.state;
      case 3: return formData.income! >= 0;
      case 4: return !!formData.age;
      case 5: return !!formData.gender;
      case 6: return !!formData.category;
      default: return true;
    }
  };

  const handleSubmit = () => {
    onComplete(formData as SchemeProfile);
  };

  const steps: { label: string; content: React.ReactNode }[] = [
    {
      label: stepsText.primaryActivity?.label || 'Primary Activity',
      content: (
        <div className="space-y-3">
          <p className="text-sm text-gray-500 mb-4">{stepsText.primaryActivity?.desc || 'What best describes what you do?'}</p>
          {[
            { value: 'FARMER', label: stepsText.primaryActivity?.farmer || '🌾 Farmer / Agriculture', desc: stepsText.primaryActivity?.farmerDesc || 'Crop farming, horticulture, animal husbandry' },
            { value: 'ENTREPRENEUR', label: stepsText.primaryActivity?.entrepreneur || '🏪 Entrepreneur / Business Owner', desc: stepsText.primaryActivity?.entrepreneurDesc || 'Running or starting a business' },
            { value: 'ARTISAN', label: stepsText.primaryActivity?.artisan || '🧵 Artisan / Craftsperson', desc: stepsText.primaryActivity?.artisanDesc || 'Handicrafts, handloom, pottery' },
            { value: 'STUDENT', label: stepsText.primaryActivity?.student || '📚 Student / Job Seeker', desc: stepsText.primaryActivity?.studentDesc || 'Seeking education or employment' },
            { value: 'WOMEN_SHG', label: stepsText.primaryActivity?.womenshg || '👩 Women SHG Member', desc: stepsText.primaryActivity?.womenshgDesc || 'Part of a Self Help Group' },
          ].map(opt => (
            <button
              key={opt.value}
              onClick={() => update('activity', opt.value)}
              className={`w-full text-left p-4 rounded-xl border-2 transition-all ${
                formData.activity === opt.value
                  ? 'border-green-500 bg-green-50'
                  : 'border-gray-200 hover:border-gray-300 bg-white'
              }`}
            >
              <div className="font-semibold text-gray-900">{opt.label}</div>
              <div className="text-xs text-gray-500 mt-0.5">{opt.desc}</div>
            </button>
          ))}
        </div>
      )
    },
    {
      label: stepsText.state?.label || 'State',
      content: (
        <div className="space-y-3">
          <p className="text-sm text-gray-500 mb-4">{stepsText.state?.desc || 'Which state are you located in? This helps find state-specific schemes.'}</p>
          <select
            className="w-full p-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-green-500 bg-white text-gray-900"
            value={formData.state}
            onChange={e => update('state', e.target.value)}
          >
            <option value="">{stepsText.state?.select || 'Select your state...'}</option>
            {STATES.map(s => <option key={s} value={s}>{s}</option>)}
          </select>
        </div>
      )
    },
    {
      label: stepsText.income?.label || 'Annual Income',
      content: (
        <div className="space-y-3">
          <p className="text-sm text-gray-500 mb-4">{stepsText.income?.desc || 'Approximate annual income or business turnover (in ₹). Many schemes have income limits.'}</p>
          <div className="relative">
            <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500 font-semibold">₹</span>
            <input
              type="number"
              min={0}
              placeholder={stepsText.income?.placeholder || 'e.g. 250000'}
              className="w-full pl-8 pr-4 p-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-green-500"
              value={formData.income || ''}
              onChange={e => update('income', parseInt(e.target.value) || 0)}
            />
          </div>
          <div className="grid grid-cols-2 gap-2 mt-3">
            {[
              { label: stepsText.income?.below1L || 'Below ₹1L', val: 80000 },
              { label: stepsText.income?.oneToThreeL || '₹1L – ₹3L', val: 200000 },
              { label: stepsText.income?.threeToFiveL || '₹3L – ₹5L', val: 400000 },
              { label: stepsText.income?.above5L || 'Above ₹5L', val: 600000 },
            ].map(opt => (
              <button
                key={opt.val}
                onClick={() => update('income', opt.val)}
                className={`p-2 rounded-lg text-sm border-2 transition-all ${
                  formData.income === opt.val
                    ? 'border-green-500 bg-green-50 text-green-700 font-semibold'
                    : 'border-gray-200 text-gray-600 hover:border-gray-300'
                }`}
              >
                {opt.label}
              </button>
            ))}
          </div>
        </div>
      )
    },
    {
      label: stepsText.age?.label || 'Age Group',
      content: (
        <div className="space-y-3">
          <p className="text-sm text-gray-500 mb-4">{stepsText.age?.desc || 'Your age group helps filter youth and senior-specific schemes.'}</p>
          {[
            { value: '18-25', label: stepsText.age?.age1825 || '18 – 25 years', desc: stepsText.age?.age1825Desc || 'Youth entrepreneur / recent graduate' },
            { value: '26-40', label: stepsText.age?.age2640 || '26 – 40 years', desc: stepsText.age?.age2640Desc || 'Prime working age' },
            { value: '41-60', label: stepsText.age?.age4160 || '41 – 60 years', desc: stepsText.age?.age4160Desc || 'Experienced professional' },
            { value: '60+', label: stepsText.age?.age60plus || '60+ years', desc: stepsText.age?.age60plusDesc || 'Senior citizen schemes apply' },
          ].map(opt => (
            <button
              key={opt.value}
              onClick={() => update('age', opt.value)}
              className={`w-full text-left p-4 rounded-xl border-2 transition-all ${
                formData.age === opt.value
                  ? 'border-green-500 bg-green-50'
                  : 'border-gray-200 hover:border-gray-300 bg-white'
              }`}
            >
              <div className="font-semibold text-gray-900">{opt.label}</div>
              <div className="text-xs text-gray-500 mt-0.5">{opt.desc}</div>
            </button>
          ))}
        </div>
      )
    },
    {
      label: stepsText.gender?.label || 'Gender',
      content: (
        <div className="space-y-3">
          <p className="text-sm text-gray-500 mb-4">{stepsText.gender?.desc || 'Several schemes have special benefits for women entrepreneurs.'}</p>
          {[
            { value: 'FEMALE', label: stepsText.gender?.female || '👩 Female', desc: stepsText.gender?.femaleDesc || 'Women-specific schemes may apply' },
            { value: 'MALE', label: stepsText.gender?.male || '👨 Male', desc: stepsText.gender?.maleDesc || 'General and targeted schemes' },
            { value: 'OTHER', label: stepsText.gender?.other || '⚧ Other / Prefer not to say', desc: stepsText.gender?.otherDesc || '' },
          ].map(opt => (
            <button
              key={opt.value}
              onClick={() => update('gender', opt.value)}
              className={`w-full text-left p-4 rounded-xl border-2 transition-all ${
                formData.gender === opt.value
                  ? 'border-green-500 bg-green-50'
                  : 'border-gray-200 hover:border-gray-300 bg-white'
              }`}
            >
              <div className="font-semibold text-gray-900">{opt.label}</div>
              {opt.desc && <div className="text-xs text-gray-500 mt-0.5">{opt.desc}</div>}
            </button>
          ))}
        </div>
      )
    },
    {
      label: stepsText.category?.label || 'Social Category',
      content: (
        <div className="space-y-3">
          <p className="text-sm text-gray-500 mb-4">{stepsText.category?.desc || 'Many central and state schemes have reserved benefits for specific social categories.'}</p>
          {[
            { value: 'General', label: stepsText.category?.general || '🟡 General' },
            { value: 'OBC', label: stepsText.category?.obc || '🟠 OBC (Other Backward Class)' },
            { value: 'SC', label: stepsText.category?.sc || '🔵 SC (Scheduled Caste)' },
            { value: 'ST', label: stepsText.category?.st || '🟢 ST (Scheduled Tribe)' },
            { value: 'Minority', label: stepsText.category?.minority || '⚪ Minority' },
          ].map(opt => (
            <button
              key={opt.value}
              onClick={() => update('category', opt.value)}
              className={`w-full text-left p-4 rounded-xl border-2 transition-all ${
                formData.category === opt.value
                  ? 'border-green-500 bg-green-50'
                  : 'border-gray-200 hover:border-gray-300 bg-white'
              }`}
            >
              <div className="font-semibold text-gray-900">{opt.label}</div>
            </button>
          ))}
        </div>
      )
    }
  ];

  const current = steps[step - 1];
  const progress = (step / TOTAL_STEPS) * 100;

  return (
    <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="p-6 border-b">
          <div className="flex justify-between items-center mb-3">
            <h2 className="text-xl font-bold text-gray-900">{t.findYourSchemes || "Find Your Schemes"}</h2>
            <button onClick={onClose} className="text-gray-400 hover:text-gray-600 text-2xl leading-none">×</button>
          </div>
          <div className="flex items-center gap-2 text-sm text-gray-500 mb-3">
            <span className="font-semibold text-green-600">{t.step || "Step"} {step}</span>
            <span>{t.of || "of"} {TOTAL_STEPS}</span>
            <span>—</span>
            <span>{current.label}</span>
          </div>
          <div className="w-full bg-gray-100 rounded-full h-1.5">
            <div
              className="bg-green-500 h-1.5 rounded-full transition-all duration-300"
              style={{ width: `${progress}%` }}
            />
          </div>
        </div>

        {/* Step content */}
        <div className="p-6 min-h-[280px]">
          {current.content}
        </div>

        {/* Footer */}
        <div className="p-6 border-t flex justify-between items-center">
          {step > 1 ? (
            <button
              onClick={() => setStep(s => s - 1)}
              className="px-5 py-2.5 border-2 border-gray-200 rounded-xl font-medium text-gray-600 hover:bg-gray-50 transition"
            >
              {t.back || "Back"}
            </button>
          ) : (
            <div />
          )}
          {step < TOTAL_STEPS ? (
            <button
              onClick={() => setStep(s => s + 1)}
              disabled={!canProceed()}
              className="px-6 py-2.5 bg-green-600 text-white rounded-xl font-semibold hover:bg-green-700 transition disabled:opacity-40 disabled:cursor-not-allowed"
            >
              {t.continue || "Continue →"}
            </button>
          ) : (
            <button
              onClick={handleSubmit}
              disabled={!canProceed()}
              className="px-6 py-2.5 bg-green-600 text-white rounded-xl font-semibold hover:bg-green-700 transition disabled:opacity-40 flex items-center gap-2"
            >
              {t.findMySchemes || "✨ Find My Schemes"}
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
