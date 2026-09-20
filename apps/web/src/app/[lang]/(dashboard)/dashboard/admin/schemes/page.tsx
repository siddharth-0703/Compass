import React from 'react';
import { SchemeAdminClient } from './SchemeAdminClient';

export default function AdminSchemeDashboardPage() {
  return (
    <div className="flex-1 space-y-8 p-4 md:p-8 pt-6 max-w-7xl mx-auto w-full">
      <div className="flex items-center justify-between space-y-2">
        <h2 className="text-3xl font-bold tracking-tight">Government Scheme Administration</h2>
      </div>
      
      {/* 
        The Client Component handles the interactivity:
        - Triggering Sync Jobs
        - Reviewing Pending Schemes
        - Approving/Rejecting
      */}
      <SchemeAdminClient />
    </div>
  );
}
