import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  collection,
  query,
  where,
  orderBy,
  getDocs,
  doc,
  updateDoc,
  Timestamp,
} from 'firebase/firestore'
import { Flag, Check, X, Clock, AlertTriangle } from 'lucide-react'
import { Header } from '@/components/layout/Header'
import { db } from '@/lib/firebase'
import { useAuth } from '@/hooks/useAuth'
import { formatRelativeTime, cn } from '@/lib/utils'
import type { ContentReport, ReportStatus } from '@/types'

const statusColors: Record<ReportStatus, string> = {
  pending: 'bg-yellow-100 text-yellow-700',
  reviewing: 'bg-blue-100 text-blue-700',
  resolved: 'bg-green-100 text-green-700',
  dismissed: 'bg-gray-100 text-gray-700',
}

const reportTypeLabels: Record<string, string> = {
  inappropriate: 'Inappropriate Content',
  incorrect: 'Incorrect Information',
  harmful: 'Harmful Content',
  spam: 'Spam',
  other: 'Other',
}

async function fetchReports(status?: ReportStatus) {
  let q = query(
    collection(db, 'content_reports'),
    orderBy('createdAt', 'desc')
  )

  if (status) {
    q = query(
      collection(db, 'content_reports'),
      where('status', '==', status),
      orderBy('createdAt', 'desc')
    )
  }

  const snapshot = await getDocs(q)
  return snapshot.docs.map((doc) => {
    const data = doc.data()
    return {
      id: doc.id,
      userId: data.userId,
      contentId: data.contentId,
      contentType: data.contentType,
      reportType: data.reportType,
      description: data.description,
      contentSnapshot: data.contentSnapshot,
      createdAt: data.createdAt?.toDate() || new Date(),
      status: data.status,
      adminNotes: data.adminNotes,
      reviewedAt: data.reviewedAt?.toDate(),
      reviewedBy: data.reviewedBy,
    } as ContentReport
  })
}

async function updateReportStatus(
  reportId: string,
  status: ReportStatus,
  adminId: string,
  adminNotes?: string
) {
  const reportRef = doc(db, 'content_reports', reportId)
  await updateDoc(reportRef, {
    status,
    adminNotes: adminNotes || null,
    reviewedAt: Timestamp.now(),
    reviewedBy: adminId,
  })
}

export function Reports() {
  const { user } = useAuth()
  const queryClient = useQueryClient()

  const { data: reports, isLoading } = useQuery({
    queryKey: ['reports'],
    queryFn: () => fetchReports(),
  })

  const mutation = useMutation({
    mutationFn: ({
      reportId,
      status,
      adminNotes,
    }: {
      reportId: string
      status: ReportStatus
      adminNotes?: string
    }) => updateReportStatus(reportId, status, user?.id || '', adminNotes),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['reports'] })
      queryClient.invalidateQueries({ queryKey: ['dashboard-stats'] })
    },
  })

  const pendingReports = reports?.filter((r) => r.status === 'pending') || []
  const reviewedReports = reports?.filter((r) => r.status !== 'pending') || []

  return (
    <div>
      <Header
        title="Content Reports"
        subtitle={`${pendingReports.length} pending reports`}
      />

      <div className="p-6">
        {/* Pending Reports */}
        <div className="mb-8">
          <h2 className="mb-4 flex items-center gap-2 text-lg font-semibold text-gray-900">
            <AlertTriangle className="h-5 w-5 text-yellow-500" />
            Pending Reports ({pendingReports.length})
          </h2>

          {isLoading ? (
            <div className="space-y-4">
              {[...Array(3)].map((_, i) => (
                <div key={i} className="card h-32 animate-pulse bg-gray-100" />
              ))}
            </div>
          ) : pendingReports.length === 0 ? (
            <div className="card p-12 text-center">
              <Flag className="mx-auto h-12 w-12 text-gray-300" />
              <p className="mt-4 text-gray-500">No pending reports</p>
            </div>
          ) : (
            <div className="space-y-4">
              {pendingReports.map((report) => (
                <div key={report.id} className="card p-6">
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center gap-3">
                        <span
                          className={cn(
                            'inline-flex rounded-full px-2 py-1 text-xs font-medium',
                            statusColors[report.status]
                          )}
                        >
                          {report.status}
                        </span>
                        <span className="text-sm text-gray-500">
                          {reportTypeLabels[report.reportType]}
                        </span>
                        <span className="text-sm text-gray-400">
                          {formatRelativeTime(report.createdAt)}
                        </span>
                      </div>

                      <p className="mt-2 text-gray-900">{report.description}</p>

                      <div className="mt-3 rounded-lg bg-gray-50 p-3">
                        <p className="text-xs font-medium text-gray-500">
                          Content Snapshot ({report.contentType})
                        </p>
                        <p className="mt-1 text-sm text-gray-600 line-clamp-3">
                          {report.contentSnapshot}
                        </p>
                      </div>

                      <div className="mt-3 text-xs text-gray-400">
                        Report ID: {report.id} | Content ID: {report.contentId}
                      </div>
                    </div>

                    <div className="ml-4 flex gap-2">
                      <button
                        onClick={() =>
                          mutation.mutate({
                            reportId: report.id,
                            status: 'resolved',
                            adminNotes: 'Content removed',
                          })
                        }
                        disabled={mutation.isPending}
                        className="btn btn-primary h-9 px-3"
                        title="Resolve (remove content)"
                      >
                        <Check className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() =>
                          mutation.mutate({
                            reportId: report.id,
                            status: 'dismissed',
                            adminNotes: 'No violation found',
                          })
                        }
                        disabled={mutation.isPending}
                        className="btn btn-secondary h-9 px-3"
                        title="Dismiss"
                      >
                        <X className="h-4 w-4" />
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Recent Activity */}
        <div>
          <h2 className="mb-4 flex items-center gap-2 text-lg font-semibold text-gray-900">
            <Clock className="h-5 w-5 text-gray-400" />
            Recent Activity
          </h2>

          {reviewedReports.length === 0 ? (
            <p className="text-gray-500">No reviewed reports yet</p>
          ) : (
            <div className="card overflow-hidden">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                      Report
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                      Status
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                      Reviewed
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200 bg-white">
                  {reviewedReports.slice(0, 10).map((report) => (
                    <tr key={report.id}>
                      <td className="px-6 py-4">
                        <p className="text-sm text-gray-900 truncate max-w-md">
                          {report.description}
                        </p>
                        <p className="text-xs text-gray-500">
                          {reportTypeLabels[report.reportType]}
                        </p>
                      </td>
                      <td className="px-6 py-4">
                        <span
                          className={cn(
                            'inline-flex rounded-full px-2 py-1 text-xs font-medium',
                            statusColors[report.status]
                          )}
                        >
                          {report.status}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-500">
                        {report.reviewedAt
                          ? formatRelativeTime(report.reviewedAt)
                          : '-'}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
