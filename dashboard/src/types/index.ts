// User types
export interface User {
  id: string
  email: string
  displayName?: string
  role: 'admin' | 'moderator' | 'user'
  createdAt: Date
  isDisabled?: boolean
}

export interface UserWithStats extends User {
  homeworkCount: number
  materialsCount: number
  quizzesCount: number
  subscription?: SubscriptionInfo
}

// Subscription types
export interface SubscriptionInfo {
  isSubscribed: boolean
  type: 'none' | 'weekly' | 'monthly' | 'yearly'
  expirationDate?: Date
  isInTrialPeriod: boolean
}

// Content Report types
export type ReportType = 'inappropriate' | 'incorrect' | 'harmful' | 'spam' | 'other'
export type ReportStatus = 'pending' | 'reviewing' | 'resolved' | 'dismissed'
export type ContentType = 'mathSolution' | 'quizQuestion' | 'quizAnswer' | 'studyMaterial'

export interface ContentReport {
  id: string
  userId: string
  contentId: string
  contentType: ContentType
  reportType: ReportType
  description: string
  contentSnapshot: string
  createdAt: Date
  status: ReportStatus
  adminNotes?: string
  reviewedAt?: Date
  reviewedBy?: string
}

// Dashboard Stats
export interface DashboardStats {
  totalUsers: number
  newUsersThisWeek: number
  newUsersThisMonth: number
  activeSubscriptions: {
    weekly: number
    monthly: number
    yearly: number
    total: number
  }
  pendingReports: number
  contentStats: {
    totalHomework: number
    totalMaterials: number
    totalQuizzes: number
  }
}

// Study Material types
export interface StudyMaterial {
  id: string
  userId: string
  title: string
  description?: string
  type: 'image' | 'text' | 'document'
  status: 'processing' | 'completed' | 'failed'
  createdAt: Date
}

// Homework/Collection types
export interface Collection {
  id: string
  userId: string
  imageUrl: string
  solution: string
  createdAt: Date
}

// Pagination
export interface PaginatedResponse<T> {
  data: T[]
  total: number
  page: number
  pageSize: number
  hasMore: boolean
}
