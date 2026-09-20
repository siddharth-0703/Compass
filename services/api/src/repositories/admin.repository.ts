import { ContentReportModel, AdminAuditLogModel, PlatformDailyMetricModel } from '@rural/database';
import { IContentReport, IAdminAuditLog, ReportStatus } from '@rural/types';

export class AdminRepository {
  // Reports
  async getReports(status?: ReportStatus, limit: number = 50) {
    const query = status ? { status } : {};
    return ContentReportModel.find(query).sort({ createdAt: -1 }).limit(limit);
  }

  async resolveReport(reportId: string, adminId: string, resolutionNote: string) {
    return ContentReportModel.findByIdAndUpdate(
      reportId,
      { status: 'Resolved', resolvedByAdminId: adminId, resolutionNote },
      { new: true }
    );
  }

  // Audit Logging
  async logAction(data: Partial<IAdminAuditLog>) {
    const log = new AdminAuditLogModel(data);
    return log.save();
  }

  async getAuditLogs(limit: number = 100) {
    return AdminAuditLogModel.find({}).sort({ createdAt: -1 }).limit(limit);
  }

  // Metrics
  async getDailyMetrics(limit: number = 30) {
    return PlatformDailyMetricModel.find({}).sort({ date: -1 }).limit(limit);
  }
}
