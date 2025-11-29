# Quick Start Guide

## 🚀 Getting Started

### Prerequisites
- Python 3.9+ installed
- PostgreSQL 14+ with PostGIS extension
- Redis server
- Modern web browser

### 1. Clone and Setup Backend

```bash
# Navigate to backend
cd backend

# Install dependencies
pip install -r requirements.txt

# Setup database (Windows PowerShell)
# Make sure PostgreSQL is installed and running
createdb sathyabama_bus_db

# Connect to database and enable PostGIS
psql -d sathyabama_bus_db
CREATE EXTENSION postgis;
\q

# Copy environment file
copy .env.example .env

# Edit .env and add your database credentials
notepad .env
```

Edit `.env`:
```
DATABASE_URL=postgresql://postgres:yourpassword@localhost:5432/sathyabama_bus_db
REDIS_URL=redis://localhost:6379/0
SECRET_KEY=your-secret-key-please-change-this
```

### 2. Start Services

**Terminal 1 - Redis:**
```bash
# Install Redis from https://redis.io/download
# Or use Windows Subsystem for Linux (WSL)
redis-server
```

**Terminal 2 - Backend:**
```bash
cd backend
uvicorn app.main:app --reload
```

Backend will run at http://localhost:8000

### 3. Open Admin Dashboard

**Terminal 3:**
```bash
cd admin-dashboard
python -m http.server 8080
```

Or simply open `admin-dashboard/index.html` in your browser.

Dashboard will run at http://localhost:8080

### 4. Test the System

1. **Open Admin Dashboard**: http://localhost:8080
2. **Add a bus**: Click "Buses" → "+ Add Bus" → Enter "042", capacity 50
3. **Add a driver**: Click "Drivers" → "+  Add Driver" → Fill details
4. **View Live Tracking**: Click "Live Tracking" to see the map
5. **API Docs**: http://localhost:8000/docs for Swagger UI

## 🎯 Quick Testing with cURL

### Register a driver:
```bash
curl -X POST http://localhost:8000/api/v1/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"name\": \"Test Driver\", \"phone\": \"9876543210\", \"password\": \"1234\"}"
```

### Login:
```bash
curl -X POST http://localhost:8000/api/v1/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"phone\": \"9876543210\", \"password\": \"1234\"}"
```

### Add a bus:
```bash
curl -X POST http://localhost:8000/api/v1/buses/create ^
  -H "Content-Type: application/json" ^
  -d "{\"bus_number\": \"042\", \"capacity\": 50}"
```

### Simulate location update:
```bash
curl -X POST http://localhost:8000/api/v1/driver/location/update ^
  -H "Content-Type: application/json" ^
  -d "{\"bus_number\": \"042\", \"latitude\": 12.9716, \"longitude\": 80.2476, \"speed\": 35.5}"
```

### Get active buses:
```bash
curl http://localhost:8000/api/v1/student/buses/active
```

## 📝 Next Steps

1. ✅ Add multiple buses via admin dashboard
2. ✅ Create driver accounts
3. ✅ Test route recording (coming in Flutter app)
4. ⏳ Deploy to Render.com for production
5. ⏳ Build and test Flutter mobile apps

## 🐛 Troubleshooting

### Database connection error
- Ensure PostgreSQL is running
- Check DATABASE_URL in `.env`
- Verify PostGIS extension is installed

### Redis connection error
- Ensure Redis is running
- Check REDIS_URL in `.env`

### Port already in use
- Change port in uvicorn command: `--port 8001`
- Or kill the process using the port

### Admin dashboard not connecting to backend
- Check if backend is running at http://localhost:8000
- Verify CORS_ORIGINS in backend `.env` includes your dashboard URL
- Check browser console for errors

## 🎉 Success!

If you see the admin dashboard with the splash screen and can add buses/drivers, you're all set!

---

**Made by S Khavin** 🚀
