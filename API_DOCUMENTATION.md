# Bus Tracker API Documentation

## Base URL
- **Production:** `https://sathyabama-bus-tracker.onrender.com/api/v1`
- **Local:** `http://localhost:8000/api/v1`

## Authentication

All driver endpoints require authentication using JWT Bearer token.

### Headers
```
Authorization: Bearer <token>
Content-Type: application/json
```

---

## Authentication Endpoints

### POST /auth/login
Login for drivers and admin.

**Request Body:**
```json
{
  "phone": "+919876543211",
  "password": "driver123"
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "driver": {
    "driver_id": 2,
    "name": "Rajesh Kumar",
    "phone": "+919876543211",
    "email": "rajesh@sathyabama.edu",
    "is_active": true,
    "is_admin": false
  }
}
```

---

## Driver Endpoints

### GET /driver/profile
Get current driver's profile with assigned bus and route.

**Headers:** Requires authentication

**Response:**
```json
{
  "driver_id": 2,
  "name": "Rajesh Kumar",
  "phone": "+919876543211",
  "email": "rajesh@sathyabama.edu",
  "is_active": true,
  "assigned_bus": "TN01AB1234",
  "assigned_route": "R1",
  "recent_buses": ["TN01AB1234"]
}
```

### POST /driver/start-shift
Driver starts their shift.

**Headers:** Requires authentication

**Request Body:**
```json
{
  "bus_number": "TN01AB1234",
  "route": "Tambaram - Sathyabama"
}
```

**Response:**
```json
{
  "status": "shift_started",
  "bus_number": "TN01AB1234",
  "route": "Tambaram - Sathyabama",
  "driver_name": "Rajesh Kumar"
}
```

### POST /driver/end-shift
Driver ends their shift.

**Headers:** Requires authentication

**Response:**
```json
{
  "status": "shift_ended",
  "message": "Shift ended successfully"
}
```

### POST /driver/location/update
Update bus location (called every 5 seconds by driver app).

**Headers:** Requires authentication

**Request Body:**
```json
{
  "bus_number": "TN01AB1234",
  "latitude": 12.9716,
  "longitude": 80.2476,
  "speed": 25.5,
  "heading": 90.0,
  "accuracy": 10.0
}
```

**Response:**
```json
{
  "status": "location_updated",
  "bus_number": "TN01AB1234"
}
```

---

## Student Endpoints

### GET /student/buses/active
Get all active buses currently sharing location.

**Query Parameters:**
- `bounds` (optional): Map bounds for filtering `lat1,lng1,lat2,lng2`

**Response:**
```json
{
  "buses": [
    {
      "busNumber": "TN01AB1234",
      "route": "Tambaram - Sathyabama",
      "latitude": 12.9716,
      "longitude": 80.2476,
      "speed": 25.5,
      "heading": 90.0,
      "lastUpdate": "2025-11-30T05:30:00",
      "status": "moving",
      "driverName": "Rajesh Kumar"
    }
  ],
  "timestamp": "2025-11-30T05:30:15",
  "count": 1
}
```

### GET /student/buses/{bus_number}
Get specific bus location and details.

**Response:**
```json
{
  "busNumber": "TN01AB1234",
  "route": "Tambaram - Sathyabama",
  "latitude": 12.9716,
  "longitude": 80.2476,
  "speed": 25.5,
  "heading": 90.0,
  "lastUpdate": "2025-11-30T05:30:00",
  "status": "moving",
  "driverName": "Rajesh Kumar"
}
```

---

## Admin Endpoints

All admin endpoints require admin authentication.

### GET /admin/routes
List all bus routes.

**Headers:** Requires admin authentication

**Response:**
```json
[
  {
    "route_id": 1,
    "sl_no": 1,
    "bus_route": "Tambaram - Sathyabama",
    "route_no": "R1",
    "vehicle_no": "TN01AB1234",
    "driver_id": 2,
    "driver_name": "Rajesh Kumar",
    "phone_number": "+919876543211",
    "is_active": true,
    "created_at": "2025-11-30T00:00:00",
    "updated_at": null
  }
]
```

### POST /admin/routes
Create new bus route.

**Headers:** Requires admin authentication

**Request Body:**
```json
{
  "bus_route": "Guindy - Sathyabama via Velachery",
  "route_no": "R6",
  "vehicle_no": "TN01EF1234",
  "driver_name": "New Driver",
  "phone_number": "+919876543220",
  "is_active": true
}
```

### GET /admin/statistics
Get dashboard statistics.

**Headers:** Requires admin authentication

**Response:**
```json
{
  "total_drivers": 4,
  "active_drivers": 3,
  "total_routes": 5,
  "active_buses": 2,
  "last_updated": "2025-11-30T05:30:00"
}
```

### GET /admin/drivers
List all drivers with pagination.

**Headers:** Requires admin authentication

**Query Parameters:**
- `page` (default: 1): Page number
- `per_page` (default: 10): Items per page
- `search` (optional): Search by name, phone, or email

**Response:**
```json
{
  "drivers": [
    {
      "driver_id": 2,
      "name": "Rajesh Kumar",
      "phone": "+919876543211",
      "email": "rajesh@sathyabama.edu",
      "is_active": true,
      "is_admin": false,
      "created_at": "2025-11-30T00:00:00"
    }
  ],
  "total": 4,
  "page": 1,
  "pages": 1
}
```

---

## Data Models

### Bus Status
- `moving`: Speed > 5 km/h
- `idle`: Speed < 1 km/h
- `stopped`: Speed between 1-5 km/h
- `active`: Bus is sharing location

### Location Update Frequency
- Driver app sends location every **5 seconds**
- Student app refreshes every **10 seconds**
- Redis cache TTL: **60 seconds**

### Available Routes
- **R1**: Tambaram - Sathyabama
- **R2**: Velachery - Sathyabama
- **R3**: Adyar - Sathyabama
- **R4**: Guindy - Sathyabama via Velachery, Medavakkam
- **R5**: T.Nagar - Sathyabama via Saidapet, Guindy

### Test Accounts

**Admin:**
- Phone: +919876543210
- Password: admin

**Drivers:**
1. Phone: +919876543211 / Password: driver123 / Bus: TN01AB1234 / Route: R1
2. Phone: +919876543212 / Password: driver123 / Bus: TN01AB5678 / Route: R2
3. Phone: +919876543213 / Password: driver123 / Bus: TN01AB9012 / Route: R3

---

## Error Responses

### 400 Bad Request
```json
{
  "detail": "Invalid request data"
}
```

### 401 Unauthorized
```json
{
  "detail": "Invalid phone number or password"
}
```

### 404 Not Found
```json
{
  "detail": "Bus TN01AB1234 not found in routes"
}
```

### 422 Unprocessable Entity
```json
{
  "detail": [
    {
      "loc": ["body", "bus_number"],
      "msg": "field required",
      "type": "value_error.missing"
    }
  ]
}
```

### 500 Internal Server Error
```json
{
  "detail": "Internal server error"
}
```

---

## Rate Limiting

No rate limiting currently implemented. Consider adding rate limiting for production:
- Location updates: Max 1 request per 5 seconds per driver
- Active buses: Max 1 request per 10 seconds per student

---

## WebSocket (Future Enhancement)

Currently not implemented. Future versions will include WebSocket support for real-time updates:

```
ws://localhost:8000/ws/live-updates
```

---

## Notes

1. **Authentication Token:** JWT tokens expire in 10 years (permanent session for drivers)
2. **Location Data:** Stored in Redis with 60-second TTL for real-time access
3. **Database:** SQLite for development, PostgreSQL for production
4. **CORS:** Configured to allow requests from Flutter app
5. **Time Zone:** All timestamps in UTC

---

## Testing with cURL

### Login
```bash
curl -X POST https://sathyabama-bus-tracker.onrender.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"+919876543211","password":"driver123"}'
```

### Get Profile
```bash
curl https://sathyabama-bus-tracker.onrender.com/api/v1/driver/profile \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Start Shift
```bash
curl -X POST https://sathyabama-bus-tracker.onrender.com/api/v1/driver/start-shift \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"bus_number":"TN01AB1234","route":"Tambaram - Sathyabama"}'
```

### Update Location
```bash
curl -X POST https://sathyabama-bus-tracker.onrender.com/api/v1/driver/location/update \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"bus_number":"TN01AB1234","latitude":12.9716,"longitude":80.2476,"speed":25.5,"heading":90.0,"accuracy":10.0}'
```

### Get Active Buses
```bash
curl https://sathyabama-bus-tracker.onrender.com/api/v1/student/buses/active
```

---

## Changelog

### Version 1.0.0 (2025-11-30)
- Initial API release
- Driver authentication and profile management
- Location tracking with Redis cache
- Student bus viewing
- Admin dashboard with route management
- Fixed all endpoint compatibility issues with Flutter app
- Removed random bus number generation
- Drivers now only see their assigned buses
