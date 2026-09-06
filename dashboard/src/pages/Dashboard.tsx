import { useQuery } from '@tanstack/react-query'
import {
  collection,
  getCountFromServer,
  query,
  where,
  Timestamp,
  getDocs,
  orderBy,
  limit,
} from 'firebase/firestore'
import {
  Users,
  BookOpen,
  Brain,
  FileText,
  Layers,
  GraduationCap,
  ClipboardList,
  History,
  TrendingUp,
  TrendingDown,
  Activity,
} from 'lucide-react'
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  BarChart,
  Bar,
  Legend,
} from 'recharts'
import { Header } from '@/components/layout/Header'
import { db } from '@/lib/firebase'
import { cn } from '@/lib/utils'

interface StatCardProps {
  title: string
  value: string | number
  change?: number
  icon: React.ElementType
  iconBg: string
  iconColor: string
}

function StatCard({ title, value, change, icon: Icon, iconBg, iconColor }: StatCardProps) {
  return (
    <div className="card p-6 hover:shadow-lg transition-shadow">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm font-medium text-gray-500">{title}</p>
          <p className="mt-1 text-3xl font-bold text-gray-900">{value}</p>
          {change !== undefined && (
            <div className="mt-2 flex items-center gap-1">
              {change >= 0 ? (
                <TrendingUp className="h-4 w-4 text-green-500" />
              ) : (
                <TrendingDown className="h-4 w-4 text-red-500" />
              )}
              <span
                className={cn(
                  'text-sm font-medium',
                  change >= 0 ? 'text-green-600' : 'text-red-600'
                )}
              >
                {change >= 0 ? '+' : ''}
                {change}%
              </span>
              <span className="text-sm text-gray-500">vs last week</span>
            </div>
          )}
        </div>
        <div className={cn('rounded-xl p-4', iconBg)}>
          <Icon className={cn('h-7 w-7', iconColor)} />
        </div>
      </div>
    </div>
  )
}

const COLORS = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899', '#06b6d4', '#84cc16']

async function fetchDashboardStats() {
  const now = new Date()
  const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
  const twoWeeksAgo = new Date(now.getTime() - 14 * 24 * 60 * 60 * 1000)

  // Fetch all collection counts
  const [
    usersSnapshot,
    homeworkSnapshot,
    studyMaterialsSnapshot,
    studyPlansSnapshot,
    quizzesSnapshot,
    flashcardDecksSnapshot,
    flashcardsSnapshot,
    reviewSessionsSnapshot,
  ] = await Promise.all([
    getCountFromServer(collection(db, 'users')),
    getCountFromServer(collection(db, 'homework')),
    getCountFromServer(collection(db, 'studyMaterials')),
    getCountFromServer(collection(db, 'studyPlans')),
    getCountFromServer(collection(db, 'quizzes')),
    getCountFromServer(collection(db, 'flashcardDecks')),
    getCountFromServer(collection(db, 'flashcards')),
    getCountFromServer(collection(db, 'reviewSessions')),
  ])

  // Get new users this week
  const weekQuery = query(
    collection(db, 'users'),
    where('createdAt', '>=', Timestamp.fromDate(weekAgo))
  )
  const weekSnapshot = await getCountFromServer(weekQuery)
  const newUsersThisWeek = weekSnapshot.data().count

  // Get new users last week (for comparison)
  const lastWeekQuery = query(
    collection(db, 'users'),
    where('createdAt', '>=', Timestamp.fromDate(twoWeeksAgo)),
    where('createdAt', '<', Timestamp.fromDate(weekAgo))
  )
  const lastWeekSnapshot = await getCountFromServer(lastWeekQuery)
  const newUsersLastWeek = lastWeekSnapshot.data().count

  // Calculate growth percentage
  const userGrowth = newUsersLastWeek > 0
    ? Math.round(((newUsersThisWeek - newUsersLastWeek) / newUsersLastWeek) * 100)
    : newUsersThisWeek > 0 ? 100 : 0

  // Get recent users for activity chart
  const recentUsersQuery = query(
    collection(db, 'users'),
    orderBy('createdAt', 'desc'),
    limit(100)
  )
  const recentUsersDocs = await getDocs(recentUsersQuery)

  // Group users by day for the last 7 days
  const dailySignups: Record<string, number> = {}
  const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']

  for (let i = 6; i >= 0; i--) {
    const date = new Date(now.getTime() - i * 24 * 60 * 60 * 1000)
    const dayName = days[date.getDay()]
    dailySignups[dayName] = 0
  }

  recentUsersDocs.docs.forEach(doc => {
    const createdAt = doc.data().createdAt?.toDate()
    if (createdAt && createdAt >= weekAgo) {
      const dayName = days[createdAt.getDay()]
      if (dailySignups[dayName] !== undefined) {
        dailySignups[dayName]++
      }
    }
  })

  const userActivityData = Object.entries(dailySignups).map(([day, count]) => ({
    day,
    signups: count,
  }))

  return {
    totalUsers: usersSnapshot.data().count,
    totalHomework: homeworkSnapshot.data().count,
    totalStudyMaterials: studyMaterialsSnapshot.data().count,
    totalStudyPlans: studyPlansSnapshot.data().count,
    totalQuizzes: quizzesSnapshot.data().count,
    totalFlashcardDecks: flashcardDecksSnapshot.data().count,
    totalFlashcards: flashcardsSnapshot.data().count,
    totalReviewSessions: reviewSessionsSnapshot.data().count,
    newUsersThisWeek,
    userGrowth,
    userActivityData,
  }
}

export function Dashboard() {
  const { data: stats, isLoading } = useQuery({
    queryKey: ['dashboard-stats'],
    queryFn: fetchDashboardStats,
    refetchInterval: 60000,
  })

  // Content distribution for pie chart
  const contentDistribution = stats ? [
    { name: 'Homework', value: stats.totalHomework, color: '#3b82f6' },
    { name: 'Study Materials', value: stats.totalStudyMaterials, color: '#10b981' },
    { name: 'Study Plans', value: stats.totalStudyPlans, color: '#f59e0b' },
    { name: 'Quizzes', value: stats.totalQuizzes, color: '#ef4444' },
    { name: 'Flashcard Decks', value: stats.totalFlashcardDecks, color: '#8b5cf6' },
    { name: 'Flashcards', value: stats.totalFlashcards, color: '#ec4899' },
  ].filter(item => item.value > 0) : []

  // Learning activity for bar chart
  const learningActivity = stats ? [
    { name: 'Homework', count: stats.totalHomework },
    { name: 'Materials', count: stats.totalStudyMaterials },
    { name: 'Plans', count: stats.totalStudyPlans },
    { name: 'Quizzes', count: stats.totalQuizzes },
    { name: 'Decks', count: stats.totalFlashcardDecks },
    { name: 'Cards', count: stats.totalFlashcards },
    { name: 'Reviews', count: stats.totalReviewSessions },
  ] : []

  return (
    <div>
      <Header
        title="Dashboard"
        subtitle="Overview of app performance"
      />

      <div className="p-6 space-y-8">
        {isLoading ? (
          <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-4">
            {[...Array(8)].map((_, i) => (
              <div key={i} className="card h-32 animate-pulse bg-gray-100" />
            ))}
          </div>
        ) : (
          <>
            {/* Primary Stats */}
            <div>
              <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
                <Activity className="h-5 w-5 text-primary-500" />
                Overview
              </h2>
              <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-4">
                <StatCard
                  title="Total Users"
                  value={stats?.totalUsers.toLocaleString() || 0}
                  change={stats?.userGrowth}
                  icon={Users}
                  iconBg="bg-blue-100"
                  iconColor="text-blue-600"
                />
                <StatCard
                  title="New This Week"
                  value={stats?.newUsersThisWeek.toLocaleString() || 0}
                  icon={TrendingUp}
                  iconBg="bg-green-100"
                  iconColor="text-green-600"
                />
                <StatCard
                  title="Homework Solved"
                  value={stats?.totalHomework.toLocaleString() || 0}
                  icon={FileText}
                  iconBg="bg-purple-100"
                  iconColor="text-purple-600"
                />
                <StatCard
                  title="Review Sessions"
                  value={stats?.totalReviewSessions.toLocaleString() || 0}
                  icon={History}
                  iconBg="bg-orange-100"
                  iconColor="text-orange-600"
                />
              </div>
            </div>

            {/* Learning Content Stats */}
            <div>
              <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
                <BookOpen className="h-5 w-5 text-primary-500" />
                Learning Content
              </h2>
              <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-4">
                <StatCard
                  title="Study Materials"
                  value={stats?.totalStudyMaterials.toLocaleString() || 0}
                  icon={BookOpen}
                  iconBg="bg-emerald-100"
                  iconColor="text-emerald-600"
                />
                <StatCard
                  title="Study Plans"
                  value={stats?.totalStudyPlans.toLocaleString() || 0}
                  icon={ClipboardList}
                  iconBg="bg-cyan-100"
                  iconColor="text-cyan-600"
                />
                <StatCard
                  title="Quizzes Created"
                  value={stats?.totalQuizzes.toLocaleString() || 0}
                  icon={GraduationCap}
                  iconBg="bg-rose-100"
                  iconColor="text-rose-600"
                />
                <StatCard
                  title="Flashcard Decks"
                  value={stats?.totalFlashcardDecks.toLocaleString() || 0}
                  icon={Layers}
                  iconBg="bg-violet-100"
                  iconColor="text-violet-600"
                />
              </div>
            </div>

            {/* Flashcard Stats */}
            <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
              <div className="card p-6">
                <div className="flex items-center justify-between mb-4">
                  <h3 className="text-lg font-semibold text-gray-900 flex items-center gap-2">
                    <Brain className="h-5 w-5 text-pink-500" />
                    Flashcard Statistics
                  </h3>
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div className="bg-gradient-to-br from-violet-50 to-purple-50 rounded-xl p-4">
                    <p className="text-sm text-gray-600">Total Decks</p>
                    <p className="text-3xl font-bold text-violet-600">
                      {stats?.totalFlashcardDecks.toLocaleString() || 0}
                    </p>
                  </div>
                  <div className="bg-gradient-to-br from-pink-50 to-rose-50 rounded-xl p-4">
                    <p className="text-sm text-gray-600">Total Cards</p>
                    <p className="text-3xl font-bold text-pink-600">
                      {stats?.totalFlashcards.toLocaleString() || 0}
                    </p>
                  </div>
                  <div className="bg-gradient-to-br from-orange-50 to-amber-50 rounded-xl p-4">
                    <p className="text-sm text-gray-600">Review Sessions</p>
                    <p className="text-3xl font-bold text-orange-600">
                      {stats?.totalReviewSessions.toLocaleString() || 0}
                    </p>
                  </div>
                  <div className="bg-gradient-to-br from-blue-50 to-cyan-50 rounded-xl p-4">
                    <p className="text-sm text-gray-600">Avg Cards/Deck</p>
                    <p className="text-3xl font-bold text-blue-600">
                      {stats?.totalFlashcardDecks
                        ? Math.round(stats.totalFlashcards / stats.totalFlashcardDecks)
                        : 0}
                    </p>
                  </div>
                </div>
              </div>

              {/* User Signups Chart */}
              <div className="card p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
                  <TrendingUp className="h-5 w-5 text-green-500" />
                  User Signups (Last 7 Days)
                </h3>
                <ResponsiveContainer width="100%" height={200}>
                  <AreaChart data={stats?.userActivityData || []}>
                    <defs>
                      <linearGradient id="colorSignups" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.3}/>
                        <stop offset="95%" stopColor="#3b82f6" stopOpacity={0}/>
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                    <XAxis dataKey="day" stroke="#6b7280" fontSize={12} />
                    <YAxis stroke="#6b7280" fontSize={12} />
                    <Tooltip
                      contentStyle={{
                        backgroundColor: '#fff',
                        border: '1px solid #e5e7eb',
                        borderRadius: '8px',
                        boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)',
                      }}
                    />
                    <Area
                      type="monotone"
                      dataKey="signups"
                      stroke="#3b82f6"
                      strokeWidth={2}
                      fillOpacity={1}
                      fill="url(#colorSignups)"
                    />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </div>

            {/* Charts Row */}
            <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
              {/* Content Distribution Pie Chart */}
              <div className="card p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">
                  Content Distribution
                </h3>
                {contentDistribution.length > 0 ? (
                  <ResponsiveContainer width="100%" height={300}>
                    <PieChart>
                      <Pie
                        data={contentDistribution}
                        cx="50%"
                        cy="50%"
                        innerRadius={60}
                        outerRadius={100}
                        paddingAngle={5}
                        dataKey="value"
                      >
                        {contentDistribution.map((entry, index) => (
                          <Cell key={`cell-${index}`} fill={entry.color} />
                        ))}
                      </Pie>
                      <Tooltip
                        contentStyle={{
                          backgroundColor: '#fff',
                          border: '1px solid #e5e7eb',
                          borderRadius: '8px',
                          boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)',
                        }}
                        formatter={(value: number) => [value.toLocaleString(), 'Count']}
                      />
                      <Legend
                        verticalAlign="bottom"
                        height={36}
                        formatter={(value) => (
                          <span className="text-sm text-gray-600">{value}</span>
                        )}
                      />
                    </PieChart>
                  </ResponsiveContainer>
                ) : (
                  <div className="flex items-center justify-center h-[300px] text-gray-500">
                    No content data available
                  </div>
                )}
              </div>

              {/* Learning Activity Bar Chart */}
              <div className="card p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">
                  Learning Activity Overview
                </h3>
                <ResponsiveContainer width="100%" height={300}>
                  <BarChart data={learningActivity} layout="vertical">
                    <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                    <XAxis type="number" stroke="#6b7280" fontSize={12} />
                    <YAxis
                      type="category"
                      dataKey="name"
                      stroke="#6b7280"
                      fontSize={12}
                      width={80}
                    />
                    <Tooltip
                      contentStyle={{
                        backgroundColor: '#fff',
                        border: '1px solid #e5e7eb',
                        borderRadius: '8px',
                        boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)',
                      }}
                      formatter={(value: number) => [value.toLocaleString(), 'Total']}
                    />
                    <Bar
                      dataKey="count"
                      fill="#3b82f6"
                      radius={[0, 4, 4, 0]}
                      barSize={24}
                    >
                      {learningActivity.map((_, index) => (
                        <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </div>

            {/* Quick Stats Summary */}
            <div className="card p-6 bg-gradient-to-r from-primary-500 to-primary-600">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="text-xl font-bold text-white">
                    Platform Summary
                  </h3>
                  <p className="text-primary-100 mt-1">
                    Total content created across all categories
                  </p>
                </div>
                <div className="text-right">
                  <p className="text-4xl font-bold text-white">
                    {(
                      (stats?.totalHomework || 0) +
                      (stats?.totalStudyMaterials || 0) +
                      (stats?.totalStudyPlans || 0) +
                      (stats?.totalQuizzes || 0) +
                      (stats?.totalFlashcardDecks || 0) +
                      (stats?.totalFlashcards || 0)
                    ).toLocaleString()}
                  </p>
                  <p className="text-primary-100 mt-1">Total Items</p>
                </div>
              </div>
              <div className="mt-6 grid grid-cols-2 md:grid-cols-4 lg:grid-cols-7 gap-4">
                {[
                  { label: 'Users', value: stats?.totalUsers || 0 },
                  { label: 'Homework', value: stats?.totalHomework || 0 },
                  { label: 'Materials', value: stats?.totalStudyMaterials || 0 },
                  { label: 'Plans', value: stats?.totalStudyPlans || 0 },
                  { label: 'Quizzes', value: stats?.totalQuizzes || 0 },
                  { label: 'Decks', value: stats?.totalFlashcardDecks || 0 },
                  { label: 'Cards', value: stats?.totalFlashcards || 0 },
                ].map((item) => (
                  <div key={item.label} className="text-center">
                    <p className="text-2xl font-bold text-white">
                      {item.value.toLocaleString()}
                    </p>
                    <p className="text-xs text-primary-100">{item.label}</p>
                  </div>
                ))}
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  )
}
