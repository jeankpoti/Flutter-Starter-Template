import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import {
  signInWithEmailAndPassword,
  signOut as firebaseSignOut,
  onAuthStateChanged,
  type User as FirebaseUser
} from 'firebase/auth'
import { doc, getDoc } from 'firebase/firestore'
import { auth, db } from '@/lib/firebase'
import type { User } from '@/types'

interface AuthState {
  user: User | null
  firebaseUser: FirebaseUser | null
  isLoading: boolean
  isAuthenticated: boolean
  isAdmin: boolean
  error: string | null
  signIn: (email: string, password: string) => Promise<boolean>
  signOut: () => Promise<void>
  checkAuth: () => void
  clearError: () => void
}

export const useAuth = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      firebaseUser: null,
      isLoading: true,
      isAuthenticated: false,
      isAdmin: false,
      error: null,

      signIn: async (email: string, password: string) => {
        set({ isLoading: true, error: null })
        try {
          const credential = await signInWithEmailAndPassword(auth, email, password)
          const firebaseUser = credential.user

          // Get user document to check role
          const userDoc = await getDoc(doc(db, 'users', firebaseUser.uid))

          if (!userDoc.exists()) {
            set({ error: 'User not found in database', isLoading: false })
            await firebaseSignOut(auth)
            return false
          }

          const userData = userDoc.data()
          const role = userData.role || 'user'

          if (role !== 'admin' && role !== 'moderator') {
            set({ error: 'Access denied. Admin privileges required.', isLoading: false })
            await firebaseSignOut(auth)
            return false
          }

          const user: User = {
            id: firebaseUser.uid,
            email: firebaseUser.email || '',
            displayName: userData.displayName || userData.fullName || firebaseUser.displayName || '',
            role: role,
            createdAt: userData.createdAt?.toDate() || new Date(),
          }

          set({
            user,
            firebaseUser,
            isAuthenticated: true,
            isAdmin: role === 'admin',
            isLoading: false,
            error: null,
          })

          return true
        } catch (error: unknown) {
          const errorMessage = error instanceof Error ? error.message : 'Sign in failed'
          set({ error: errorMessage, isLoading: false })
          return false
        }
      },

      signOut: async () => {
        await firebaseSignOut(auth)
        set({
          user: null,
          firebaseUser: null,
          isAuthenticated: false,
          isAdmin: false,
          error: null,
        })
      },

      checkAuth: () => {
        set({ isLoading: true })
        onAuthStateChanged(auth, async (firebaseUser) => {
          if (firebaseUser) {
            try {
              const userDoc = await getDoc(doc(db, 'users', firebaseUser.uid))
              if (userDoc.exists()) {
                const userData = userDoc.data()
                const role = userData.role || 'user'

                if (role === 'admin' || role === 'moderator') {
                  const user: User = {
                    id: firebaseUser.uid,
                    email: firebaseUser.email || '',
                    displayName: userData.displayName || userData.fullName || '',
                    role: role,
                    createdAt: userData.createdAt?.toDate() || new Date(),
                  }

                  set({
                    user,
                    firebaseUser,
                    isAuthenticated: true,
                    isAdmin: role === 'admin',
                    isLoading: false,
                  })
                  return
                }
              }
            } catch {
              // Error fetching user doc
            }
          }

          set({
            user: null,
            firebaseUser: null,
            isAuthenticated: false,
            isAdmin: false,
            isLoading: false,
          })
        })
      },

      clearError: () => set({ error: null }),
    }),
    {
      name: 'admin-auth',
      partialize: (state) => ({ user: state.user }),
    }
  )
)
