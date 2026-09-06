import { useState } from 'react'
import { Settings as SettingsIcon, Save, Loader2 } from 'lucide-react'
import { Header } from '@/components/layout/Header'
import { useAuth } from '@/hooks/useAuth'

export function Settings() {
  const { user } = useAuth()
  const [isSaving, setIsSaving] = useState(false)

  const handleSave = async () => {
    setIsSaving(true)
    // Simulate save
    await new Promise((resolve) => setTimeout(resolve, 1000))
    setIsSaving(false)
  }

  return (
    <div>
      <Header title="Settings" subtitle="Manage dashboard preferences" />

      <div className="p-6">
        <div className="max-w-2xl">
          {/* Profile Section */}
          <div className="card p-6">
            <h2 className="flex items-center gap-2 text-lg font-semibold text-gray-900">
              <SettingsIcon className="h-5 w-5" />
              Admin Profile
            </h2>

            <div className="mt-6 space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Email
                </label>
                <input
                  type="email"
                  value={user?.email || ''}
                  disabled
                  className="input mt-1 bg-gray-50"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Display Name
                </label>
                <input
                  type="text"
                  defaultValue={user?.displayName || ''}
                  className="input mt-1"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Role
                </label>
                <input
                  type="text"
                  value={user?.role || 'admin'}
                  disabled
                  className="input mt-1 bg-gray-50 capitalize"
                />
              </div>
            </div>

            <div className="mt-6 border-t pt-6">
              <button
                onClick={handleSave}
                disabled={isSaving}
                className="btn btn-primary h-10 px-4"
              >
                {isSaving ? (
                  <Loader2 className="h-4 w-4 animate-spin" />
                ) : (
                  <>
                    <Save className="mr-2 h-4 w-4" />
                    Save Changes
                  </>
                )}
              </button>
            </div>
          </div>

          {/* Danger Zone */}
          <div className="mt-6 card border-red-200 p-6">
            <h2 className="text-lg font-semibold text-red-600">Danger Zone</h2>
            <p className="mt-2 text-sm text-gray-600">
              These actions are irreversible. Please be careful.
            </p>

            <div className="mt-4">
              <button className="btn h-10 border border-red-300 bg-white px-4 text-red-600 hover:bg-red-50">
                Sign Out of All Devices
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
