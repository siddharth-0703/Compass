"use client";
import React, { useState } from 'react';
import { ShieldCheck, RefreshCw, XCircle, FileText, Activity, AlertCircle } from 'lucide-react';

export function SchemeAdminClient() {
  const [isSyncing, setIsSyncing] = useState(false);
  const [syncStatus, setSyncStatus] = useState<string | null>(null);

  const handleSync = async (source: string) => {
    setIsSyncing(true);
    setSyncStatus('Queued...');
    try {
      const res = await fetch('/api/v1/admin/schemes/sync', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${localStorage.getItem('token')}` },
        body: JSON.stringify({ source })
      });
      if (res.ok) {
        setSyncStatus('Sync Job Dispatched Successfully. Check worker logs.');
      } else {
        setSyncStatus('Failed to trigger sync.');
      }
    } catch (error) {
      setSyncStatus('Network error triggering sync.');
    } finally {
      setIsSyncing(false);
    }
  };

  return (
    <div className="space-y-6">
      
      {/* 1. Metrics Overview */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <div className="p-6 bg-white border rounded-xl shadow-sm flex items-center space-x-4">
          <div className="p-3 bg-blue-100 rounded-lg text-blue-600"><Activity size={24} /></div>
          <div><p className="text-sm text-gray-500 font-medium">Total Active</p><p className="text-2xl font-bold">142</p></div>
        </div>
        <div className="p-6 bg-white border rounded-xl shadow-sm flex items-center space-x-4">
          <div className="p-3 bg-yellow-100 rounded-lg text-yellow-600"><AlertCircle size={24} /></div>
          <div><p className="text-sm text-gray-500 font-medium">Pending Review</p><p className="text-2xl font-bold">22</p></div>
        </div>
        <div className="p-6 bg-white border rounded-xl shadow-sm flex items-center space-x-4">
          <div className="p-3 bg-gray-100 rounded-lg text-gray-600"><FileText size={24} /></div>
          <div><p className="text-sm text-gray-500 font-medium">Drafts</p><p className="text-2xl font-bold">18</p></div>
        </div>
        <div className="p-6 bg-white border rounded-xl shadow-sm flex items-center space-x-4">
          <div className="p-3 bg-red-100 rounded-lg text-red-600"><XCircle size={24} /></div>
          <div><p className="text-sm text-gray-500 font-medium">Rejected</p><p className="text-2xl font-bold">4</p></div>
        </div>
      </div>

      {/* 2. Sync Triggers */}
      <div className="p-6 bg-white border rounded-xl shadow-sm">
        <h3 className="text-lg font-semibold mb-4 flex items-center"><RefreshCw className="mr-2" size={20} /> Data Ingestion Sync</h3>
        <p className="text-sm text-gray-600 mb-6">Trigger the asynchronous BullMQ pipeline to fetch, deduplicate, and normalize government records.</p>
        
        <div className="flex gap-4">
          <button 
            onClick={() => handleSync('manual_import')}
            disabled={isSyncing}
            className="px-4 py-2 bg-slate-800 text-white rounded-lg hover:bg-slate-700 disabled:opacity-50 font-medium"
          >
            Sync Manual JSON Dumps
          </button>
          
          <button 
            onClick={() => handleSync('myscheme_gov_in')}
            disabled={isSyncing}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 font-medium"
          >
            Sync from Official API
          </button>
        </div>
        
        {syncStatus && <p className="mt-4 text-sm font-medium text-green-600">{syncStatus}</p>}
      </div>

      {/* 3. Review Table (Mocked structure for MVP) */}
      <div className="p-6 bg-white border rounded-xl shadow-sm">
        <h3 className="text-lg font-semibold mb-4 flex items-center"><ShieldCheck className="mr-2" size={20} /> Schemes Pending Review</h3>
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b">
                <th className="p-3 font-semibold text-gray-600">Scheme Name</th>
                <th className="p-3 font-semibold text-gray-600">Source</th>
                <th className="p-3 font-semibold text-gray-600">Status</th>
                <th className="p-3 font-semibold text-gray-600 text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr className="border-b hover:bg-gray-50">
                <td className="p-3 font-medium">PM Employment Generation (v2)</td>
                <td className="p-3 text-sm text-gray-600">myscheme.gov.in</td>
                <td className="p-3"><span className="px-2 py-1 bg-yellow-100 text-yellow-800 rounded text-xs font-semibold">PENDING_REVIEW</span></td>
                <td className="p-3 text-right">
                  <button className="text-blue-600 hover:underline mr-4 text-sm font-medium">Review Evidence</button>
                  <button className="text-green-600 hover:underline mr-4 text-sm font-medium">Verify & Activate</button>
                  <button className="text-red-600 hover:underline text-sm font-medium">Reject</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      
    </div>
  );
}
