# Deploy Flutter App to Vercel

## Prerequisites
- Vercel account (free tier works)
- Flutter SDK installed locally

## Steps

### 1. Build Flutter Web App
```bash
cd flutter_app
flutter build web --release --web-renderer canvaskit
```

### 2. Deploy to Vercel

#### Option A: Using Vercel CLI
```bash
# Install Vercel CLI
npm install -g vercel

# Deploy from flutter_app directory
cd flutter_app
vercel --prod
```

#### Option B: Using Vercel Dashboard
1. Go to https://vercel.com/new
2. Import your GitHub repository
3. Set root directory to `flutter_app`
4. Vercel will auto-detect the configuration from `vercel.json`
5. Click Deploy

### 3. Environment Configuration
The Flutter app is already configured to use the production API:
- API URL: `https://sathyabama-bus-tracker.onrender.com/api/v1`
- This is set in `flutter_app/lib/config/constants.dart`

### 4. Custom Domain (Optional)
1. Go to your Vercel project settings
2. Navigate to Domains
3. Add your custom domain
4. Follow DNS configuration instructions

## Notes
- The backend stays on Render (FastAPI + PostgreSQL + Redis)
- Only the Flutter web build is deployed to Vercel
- Mobile apps (Android/iOS) are built separately using `flutter build apk` or `flutter build ios`

## Troubleshooting

### Build fails
- Ensure Flutter SDK is up to date: `flutter upgrade`
- Clear build cache: `flutter clean && flutter pub get`

### App doesn't load
- Check browser console for errors
- Verify API URL is accessible from browser
- Check CORS settings on backend

## System Status
Check if buses are sharing location:
- Visit: `https://sathyabama-bus-tracker.onrender.com/api/admin/system/status`
- Shows Redis status and active buses
