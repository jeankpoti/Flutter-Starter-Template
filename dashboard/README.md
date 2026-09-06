# Admin Dashboard

A React admin dashboard for managing users, subscriptions, and content reports.

## Tech Stack

- React 19 + TypeScript
- Vite
- TailwindCSS
- Firebase (Auth + Firestore)
- React Query
- Recharts
- Zustand

## Setup

1. Install dependencies:
   ```bash
   cd dashboard
   npm install
   ```

2. Configure Firebase:
   ```bash
   cp .env.example .env
   # Edit .env with your Firebase config
   ```

3. Run development server:
   ```bash
   npm run dev
   ```

## Pages

- **Dashboard**: Overview stats and charts
- **Users**: User management
- **Subscriptions**: Subscription tracking
- **Reports**: Content reports moderation
- **Settings**: Admin settings

## Scripts

```bash
npm run dev      # Start development server
npm run build    # Build for production
npm run preview  # Preview production build
npm run lint     # Run ESLint
```
