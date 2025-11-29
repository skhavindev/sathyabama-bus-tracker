# Sathyabama Bus Tracker - Backend API

FastAPI backend for the Sathyabama Bus Tracker mobile application. Provides REST APIs for driver authentication, real-time location tracking, and student bus monitoring.

## Features

- 🔐 JWT-based authentication for drivers
- 📍 Real-time GPS location tracking
- 🚌 Bus and route management
- 👥 Admin dashboard for managing drivers, buses, and routes
- 📊 Live bus status monitoring
- 🔔 Support for proximity notifications

## Tech Stack

- **Framework**: FastAPI
- **Database**: SQLite (development) / PostgreSQL (production)
- **Authentication**: JWT tokens
- **ORM**: SQLAlchemy
- **Validation**: Pydantic

## Quick Start

### Prerequisites

- Python 3.9+
- pip

### Installation

```bash
# Clone the repository
git clone https://github.com/skhavindev/sathyabama-bus-tracker-backend.git
cd sathyabama-bus-tracker-backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run the server
python -m uvicorn app.main:app --reload
```

The API will be available at `http://localhost:8000`

### Admin Dashboard

Access the admin dashboard at `http://localhost:8000/admin`

**Default Admin Credentials:**
- Phone: +919876543210
- Password: admin

## API Documentation

Interactive API documentation is available at:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## API Endpoints

### Authentication
- `POST /api/v1/auth/login` - Driver login
- `POST /api/v1/auth/register` - Register new driver

### Driver Endpoints
- `GET /api/v1/driver/profile` - Get driver profile
- `POST /api/v1/driver/start-shift` - Start driving shift
- `POST /api/v1/driver/location` - Update current location
- `POST /api/v1/driver/end-shift` - End driving shift
- `POST /api/v1/driver/request-bus` - Request custom bus/route

### Student Endpoints
- `GET /api/v1/student/buses` - Get all active buses

### Admin Endpoints
- `GET /api/v1/admin/drivers` - List all drivers
- `GET /api/v1/admin/stats` - Get dashboard statistics
- `PATCH /api/v1/admin/drivers/{id}/approve` - Approve driver
- `DELETE /api/v1/admin/drivers/{id}` - Delete driver

## Environment Variables

Create a `.env` file in the root directory:

```env
# Database
DATABASE_URL=sqlite:///./bus_tracker.db

# JWT
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=43200

# CORS
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

## Database Setup

The database will be created automatically on first run. To create an admin user:

```bash
python scripts/create_admin.py
```

## Deployment

### Deploy to Render

1. Create a new Web Service on [Render](https://render.com)
2. Connect your GitHub repository
3. Set the following:
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
4. Add environment variables
5. Deploy!

### Deploy to Railway

1. Create a new project on [Railway](https://railway.app)
2. Connect your GitHub repository
3. Railway will auto-detect FastAPI and deploy
4. Add environment variables in the dashboard

## Project Structure

```
backend/
├── app/
│   ├── api/           # API endpoints
│   ├── models/        # Database models
│   ├── schemas/       # Pydantic schemas
│   ├── services/      # Business logic
│   ├── static/        # Static files (admin dashboard)
│   └── main.py        # FastAPI application
├── scripts/           # Utility scripts
├── requirements.txt   # Python dependencies
└── README.md
```

## Development

### Running Tests

```bash
pytest
```

### Code Formatting

```bash
black app/
isort app/
```

### Database Migrations

```bash
alembic revision --autogenerate -m "description"
alembic upgrade head
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Support

For issues and questions, please open an issue on GitHub.

## Author

**Khavin S**
- GitHub: [@skhavindev](https://github.com/skhavindev)

---

Built with ❤️ for Sathyabama University
