# 🚌 Sathyabama Bus Tracker

A premium, real-time bus tracking system for Sathyabama University with Apple-inspired design.

## 📱 Features

### For Students:
- 🗺️ Real-time bus tracking on interactive map
- 🔔 Proximity notifications (100m-700m radius)
- 🔍 Search buses by number or route
- 📍 Live location updates every 10 seconds
- 🎨 Beautiful Apple-inspired UI with dark mode

### For Drivers:
- 🚀 Quick shift start/end
- 📍 Automatic location sharing
- ⏸️ Pause/resume tracking
- 📊 Live speed and time tracking
- 🚌 Custom bus/route requests

### For Admins:
- 👥 Driver management
- 🚌 Bus and route management
- 📊 Dashboard with statistics
- ✅ Approve/reject drivers
- 📄 PDF export functionality

## 🏗️ Tech Stack

### Backend:
- **Framework**: FastAPI
- **Database**: SQLite (dev) / PostgreSQL (prod)
- **Authentication**: JWT tokens
- **API Docs**: Swagger UI

### Frontend:
- **Framework**: Flutter
- **Maps**: flutter_map with OpenStreetMap
- **State Management**: Provider
- **Notifications**: flutter_local_notifications
- **Storage**: flutter_secure_storage

## 🚀 Quick Start

### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python -m uvicorn app.main:app --reload
```

Backend runs at: http://localhost:8000

**Admin Dashboard**: http://localhost:8000/admin
- Phone: +919876543210
- Password: admin

**Live Bus Map**: http://localhost:8000/map
- Real-time bus tracking on OpenStreetMap

### Flutter App

```bash
cd flutter_app
flutter pub get
flutter run
```

## 📚 Documentation

- [Deployment Guide](DEPLOYMENT_GUIDE.md) - Deploy to Render
- [Implementation Complete](IMPLEMENTATION_COMPLETE.md) - Full feature list
- [Backend README](backend/README.md) - Backend API docs

## 🎨 Screenshots

*Coming soon*

## 🔧 Configuration

### Backend
Edit `backend/.env`:
```env
DATABASE_URL=sqlite:///./bus_tracker.db
SECRET_KEY=your-secret-key
```

### Flutter
Edit `flutter_app/lib/config/constants.dart`:
```dart
static const String apiBaseUrl = 'http://localhost:8000/api/v1';
```

## 📦 Project Structure

```
bus/
├── backend/              # FastAPI backend
│   ├── app/
│   │   ├── api/         # API endpoints
│   │   ├── models/      # Database models
│   │   ├── services/    # Business logic
│   │   └── static/      # Admin dashboard
│   └── requirements.txt
├── flutter_app/         # Flutter mobile app
│   ├── lib/
│   │   ├── config/      # Theme & constants
│   │   ├── models/      # Data models
│   │   ├── screens/     # UI screens
│   │   ├── services/    # API & services
│   │   └── widgets/     # Reusable widgets
│   └── pubspec.yaml
└── README.md
```

## 🌐 Deployment

### Deploy Backend to Render:

1. Push code to GitHub
2. Create new Web Service on Render
3. Connect repository
4. Set build command: `pip install -r requirements.txt`
5. Set start command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
6. Add environment variables
7. Deploy!

See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for detailed instructions.

## 🧪 Testing

### Backend:
```bash
cd backend
pytest
```

### Flutter:
```bash
cd flutter_app
flutter test
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

**Khavin S**
- GitHub: [@skhavindev](https://github.com/skhavindev)

## 🙏 Acknowledgments

- Sathyabama University
- Flutter & FastAPI communities
- OpenStreetMap contributors

---

Built with ❤️ for Sathyabama University
