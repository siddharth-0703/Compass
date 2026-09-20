'use client';

import React, { useEffect, useState } from 'react';
import axios from 'axios';

interface HealthMetrics {
  status: string;
  services: {
    api: string;
    database: string;
    redis: string;
    ai: string;
  };
  metrics: {
    uptime: number;
    activeSyncConflicts: number;
    aiLatencyAvgMs: number;
  };
}

export default function ObservabilityDashboard() {
  const [metrics, setMetrics] = useState<HealthMetrics | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchHealth = async () => {
      try {
        const token = localStorage.getItem('token');
        const res = await axios.get('http://localhost:4000/api/v1/admin/health', {
          headers: { Authorization: `Bearer ${token}` }
        });
        setMetrics(res.data.data);
      } catch (err) {
        console.error('Failed to fetch health metrics', err);
      } finally {
        setLoading(false);
      }
    };
    
    fetchHealth();
    const interval = setInterval(fetchHealth, 10000);
    return () => clearInterval(interval);
  }, []);

  if (loading && !metrics) return <div className="p-8">Loading Platform Health...</div>;
  if (!metrics) return <div className="p-8 text-red-500">Failed to load platform metrics. Backend might be unreachable.</div>;

  return (
    <div className="p-8 space-y-8">
      <h1 className="text-3xl font-bold text-gray-900 tracking-tight">Platform Observability</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <StatusCard title="Overall Status" status={metrics.status} />
        <MetricCard title="API Uptime" value={`${Math.floor(metrics.metrics.uptime / 60)} mins`} />
        <MetricCard title="Active Sync Conflicts" value={metrics.metrics.activeSyncConflicts.toString()} />
        <MetricCard title="AI Latency (Avg)" value={`${metrics.metrics.aiLatencyAvgMs} ms`} />
      </div>

      <h2 className="text-xl font-semibold mt-12 mb-4">Subsystem Health</h2>
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <StatusCard title="Core API" status={metrics.services.api} />
        <StatusCard title="Database" status={metrics.services.database} />
        <StatusCard title="Redis / Queue" status={metrics.services.redis} />
        <StatusCard title="AI Engine" status={metrics.services.ai} />
      </div>
    </div>
  );
}

function StatusCard({ title, status }: { title: string, status: string }) {
  const isHealthy = status === 'Healthy';
  return (
    <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 flex flex-col items-start space-y-4">
      <div className="text-gray-500 font-medium">{title}</div>
      <div className={`px-4 py-1.5 rounded-full text-sm font-semibold ${isHealthy ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-700'}`}>
        {status}
      </div>
    </div>
  );
}

function MetricCard({ title, value }: { title: string, value: string }) {
  return (
    <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 flex flex-col space-y-2">
      <div className="text-gray-500 font-medium">{title}</div>
      <div className="text-3xl font-bold text-gray-900">{value}</div>
    </div>
  );
}
