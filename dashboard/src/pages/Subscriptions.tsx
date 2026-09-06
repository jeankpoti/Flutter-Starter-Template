import { CreditCard, TrendingUp, Users, DollarSign } from 'lucide-react'
import { Header } from '@/components/layout/Header'

export function Subscriptions() {
  // Note: Actual subscription data would come from RevenueCat API
  // This would require setting up Cloud Functions to fetch from RevenueCat

  return (
    <div>
      <Header
        title="Subscriptions"
        subtitle="Revenue and subscription analytics"
      />

      <div className="p-6">
        {/* Stats */}
        <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-4">
          <div className="card p-6">
            <div className="flex items-center gap-4">
              <div className="rounded-lg bg-green-100 p-3">
                <DollarSign className="h-6 w-6 text-green-600" />
              </div>
              <div>
                <p className="text-sm text-gray-500">Monthly Revenue</p>
                <p className="text-2xl font-semibold text-gray-900">--</p>
              </div>
            </div>
          </div>

          <div className="card p-6">
            <div className="flex items-center gap-4">
              <div className="rounded-lg bg-blue-100 p-3">
                <Users className="h-6 w-6 text-blue-600" />
              </div>
              <div>
                <p className="text-sm text-gray-500">Active Subscribers</p>
                <p className="text-2xl font-semibold text-gray-900">--</p>
              </div>
            </div>
          </div>

          <div className="card p-6">
            <div className="flex items-center gap-4">
              <div className="rounded-lg bg-purple-100 p-3">
                <CreditCard className="h-6 w-6 text-purple-600" />
              </div>
              <div>
                <p className="text-sm text-gray-500">Trial Users</p>
                <p className="text-2xl font-semibold text-gray-900">--</p>
              </div>
            </div>
          </div>

          <div className="card p-6">
            <div className="flex items-center gap-4">
              <div className="rounded-lg bg-yellow-100 p-3">
                <TrendingUp className="h-6 w-6 text-yellow-600" />
              </div>
              <div>
                <p className="text-sm text-gray-500">Conversion Rate</p>
                <p className="text-2xl font-semibold text-gray-900">--</p>
              </div>
            </div>
          </div>
        </div>

        {/* Info Card */}
        <div className="mt-8 card p-6">
          <div className="flex items-start gap-4">
            <div className="rounded-lg bg-blue-100 p-3">
              <CreditCard className="h-6 w-6 text-blue-600" />
            </div>
            <div>
              <h3 className="font-semibold text-gray-900">
                RevenueCat Integration Required
              </h3>
              <p className="mt-2 text-gray-600">
                To view subscription analytics, you need to set up a Cloud Function
                that connects to the RevenueCat API. This will allow you to:
              </p>
              <ul className="mt-3 list-inside list-disc space-y-1 text-gray-600">
                <li>View active subscriber counts by plan type</li>
                <li>Track monthly recurring revenue (MRR)</li>
                <li>Monitor trial conversion rates</li>
                <li>See churn and retention metrics</li>
              </ul>
              <p className="mt-4 text-sm text-gray-500">
                You can access this data directly from the{' '}
                <a
                  href="https://app.revenuecat.com"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-primary-600 hover:underline"
                >
                  RevenueCat Dashboard
                </a>{' '}
                in the meantime.
              </p>
            </div>
          </div>
        </div>

        {/* Subscription Plans */}
        <div className="mt-8">
          <h2 className="mb-4 text-lg font-semibold text-gray-900">
            Subscription Plans
          </h2>
          <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
            <div className="card p-6">
              <h3 className="font-medium text-gray-900">Weekly</h3>
              <p className="mt-1 text-2xl font-bold text-gray-900">$2.99</p>
              <p className="text-sm text-gray-500">per week</p>
              <div className="mt-4 border-t pt-4">
                <p className="text-sm text-gray-600">
                  <span className="font-medium">--</span> active subscribers
                </p>
              </div>
            </div>

            <div className="card border-primary-200 bg-primary-50 p-6">
              <h3 className="font-medium text-gray-900">Monthly</h3>
              <p className="mt-1 text-2xl font-bold text-gray-900">$9.99</p>
              <p className="text-sm text-gray-500">per month</p>
              <div className="mt-4 border-t border-primary-200 pt-4">
                <p className="text-sm text-gray-600">
                  <span className="font-medium">--</span> active subscribers
                </p>
              </div>
            </div>

            <div className="card p-6">
              <h3 className="font-medium text-gray-900">Yearly</h3>
              <p className="mt-1 text-2xl font-bold text-gray-900">$59.99</p>
              <p className="text-sm text-gray-500">per year</p>
              <div className="mt-4 border-t pt-4">
                <p className="text-sm text-gray-600">
                  <span className="font-medium">--</span> active subscribers
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
