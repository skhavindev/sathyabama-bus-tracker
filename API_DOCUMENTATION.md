# API Documentation - Sathyabama Bus Tracker

## Base URL
- **Local**: `http://localhost:8000`
- **Production**: `https://your-app.onrender.com`

## Authentication
All protected endpoints require JWT token in Authorization header:
```
Authorization: Bearer <token>
```

---

## 📱 Authentication Endpoints

### POST /api/v1/auth/register
Register a new driver account.

**Request Body:**
```json
{
  "name": "John Doe",
  "phone": "+919876543210",
  "email": "john@example.com",
  "password": "password123",
  "is_admin": false
}
```

**Response:** `201 Created`
```json
{
  "driver_id": 1,
  "name": "John Doe",
  "phone": "+919876543210",
  "email": "john@example.com",
  "is_active": true,
  "is_admin": false,
  "created_at": "2024-01-01T00:00:00Z"
}
```

### POST /api/v1/auth/login
Login with phone and password.

**Request Body:**
```json
{
  "phone": "+919876543210",
  "password": "admin"
}
```

**Response:** `200 OK`
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "token_type": "bearer",
  "driver": {
    "driver_id": 1,
    "name": "Admin",
    "phone": "+919876543210",
    "email": "admin@sathyabama.edu",
    "is_active": true,
    "is_admin": true,
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

**Errors:**
- `401`: Invalid credentials
- `403`: Account inactive
- `422`: Validation error (invalid phone format or missing fields)

---

## 👨‍💼 Admin Endpoints

### GET /api/admin/statistics
Get dashboard statistics (requires admin).

**Headers:**
```
Authorization: Bearer <admin_token>
```

**Response:** `200 OK`
```json
{
  "total_drivers": 10,
  "active_drivers": 8,
  "total_routes": 15,
  "active_buses": 5,
  "last_updated": "2024-01-01T00:00:00Z"
}
```

### GET /api/admin/drivers
List all drivers with pagination (requires admin).

**Query Parameters:**
- `page` (int, default: 1)
- `per_page` (int, default: 10)
- `search` (string, optional)

**Response:** `200 OK`
```json
{
  "drivers": [
    {
      "driver_id": 1,
      "name": "John Doe",
      "phone": "+919876543210",
      "email": "john@example.com",
      "is_active": true,
      "is_admin": false,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": null
    }
  ],
  "total": 10,
  "page": 1,
  "pages": 1
}
```

### POST /api/admin/drivers
Create new driver (requires admin).

**Request Body:**
```json
{
  "name": "Jane Doe",
  "phone": "+919876543211",
  "email": "jane@example.com",
  "password": "password123",
  "is_admin": false,
  "is_active": true
}
```

**Response:** `200 OK`
```json
{
  "driver_id": 2,
  "name": "Jane Doe",
  "phone": "+919876543211",
  "email": "jane@example.com",
  "is_active": true,
  "is_admin": false,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": null
}
```

**Errors:**
- `409`: Phone or email already exists

### PUT /api/admin/drivers/{driver_id}
Update driver information (requires admin).

**Request Body:**
```json
{
  "name": "Jane Smith",
  "phone": "+919876543211",
  "email": "jane.smith@example.com",
  "password": "newpassword123",
  "is_admin": false,
  "is_active": true
}
```

**Response:** `200 OK`
```json
{
  "driver_id": 2,
  "name": "Jane Smith",
  "phone": "+919876543211",
  "email": "jane.smith@example.com",
  "is_active": true,
  "is_admin": false,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-02T00:00:00Z"
}
```

### DELETE /api/admin/drivers/{driver_id}
Delete driver (requires admin).

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Driver deleted successfully"
}
```

### GET /api/admin/routes
List all bus routes (requires admin).

**Response:** `200 OK`
```json
[
  {
    "route_id": 1,
    "sl_no": 1,
    "bus_route": "Guduvancherry-(Via)-Urapakkam-Kilambakkam...",
    "route_no": "3A",
    "vehicle_no": "BW1212",
    "driver_id": 1,
    "driver_name": "PANNEER",
    "phone_number": "9789845536",
    "is_active": true,
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": null
  }
]
```

### POST /api/admin/routes
Create new bus route (requires admin).

**Request Body:**
```json
{
  "bus_route": "Guduvancherry-(Via)-Urapakkam...",
  "route_no": "3A",
  "vehicle_no": "BW1212",
  "driver_id": 1,
  "driver_name": "PANNEER",
  "phone_number": "9789845536",
  "is_active": true
}
```

**Response:** `200 OK`
```json
{
  "route_id": 1,
  "sl_no": 1,
  "bus_route": "Guduvancherry-(Via)-Urapakkam...",
  "route_no": "3A",
  "vehicle_no": "BW1212",
  "driver_id": 1,
  "driver_name": "PANNEER",
  "phone_number": "9789845536",
  "is_active": true,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": null
}
```

### PUT /api/admin/routes/{route_id}
Update bus route (requires admin).

**Request Body:** (all fields optional)
```json
{
  "bus_route": "Updated route description",
  "route_no": "3B",
  "vehicle_no": "BW1213",
  "driver_name": "NEW DRIVER",
  "phone_number": "9876543210"
}
```

### DELETE /api/admin/routes/{route_id}
Delete bus route (requires admin).

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Route deleted successfully"
}
```

### POST /api/admin/routes/import
Bulk import routes from Excel/CSV (requires admin).

**Request:** `multipart/form-data`
```
file: <Excel or CSV file>
```

**File Format:**
```csv
Sl.No,Bus Route,Route No,Vehicle No,Driver Name,Phone Number
1,Guduvancherry-(Via)-Urapakkam...,3A,BW1212,PANNEER,9789845536
```

**Response:** `200 OK`
```json
{
  "imported": 5,
  "failed": 0,
  "errors": []
}
```

### GET /api/admin/routes/export
Export routes as Excel or PDF (requires admin).

**Query Parameters:**
- `format` (string): "excel" or "pdf"

**Response:** File download

### GET /api/admin/audit-log
Get audit log entries (requires admin).

**Query Parameters:**
- `start_date` (datetime, optional)
- `end_date` (datetime, optional)
- `action_type` (string, optional): "CREATE", "UPDATE", "DELETE", or "ALL"
- `page` (int, default: 1)
- `per_page` (int, default: 50)

**Response:** `200 OK`
```json
{
  "logs": [
    {
      "log_id": 1,
      "admin_id": 1,
      "admin_name": "Admin",
      "action_type": "CREATE",
      "entity_type": "driver",
      "entity_id": 2,
      "changes": {"name": "John Doe", "phone": "+919876543210"},
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "total": 10,
  "page": 1,
  "pages": 1
}
```

---

## 🚗 Driver Endpoints

### GET /api/v1/driver/profile
Get current driver's profile (requires authentication).

**Response:** `200 OK`
```json
{
  "driver_id": 1,
  "name": "John Doe",
  "phone": "+919876543210",
  "email": "john@example.com",
  "is_active": true,
  "is_admin": false
}
```

### PUT /api/v1/driver/profile
Update current driver's profile (requires authentication).

**Request Body:**
```json
{
  "name": "John Smith",
  "email": "john.smith@example.com"
}
```

### POST /api/v1/driver/location
Update driver's current location (requires authentication).

**Request Body:**
```json
{
  "latitude": 12.9716,
  "longitude": 77.5946,
  "speed": 45.5,
  "heading": 180.0
}
```

**Response:** `200 OK`
```json
{
  "message": "Location updated successfully"
}
```

---

## 🎓 Student Endpoints

### GET /api/v1/student/buses
Get all active buses with real-time locations.

**Response:** `200 OK`
```json
[
  {
    "bus_number": "BW1212",
    "route_name": "Route 3A",
    "driver_name": "PANNEER",
    "latitude": 12.9716,
    "longitude": 77.5946,
    "speed": 45.5,
    "last_updated": "2024-01-01T00:00:00Z"
  }
]
```

### GET /api/v1/student/routes
Get all available bus routes.

**Response:** `200 OK`
```json
[
  {
    "route_id": 1,
    "route_no": "3A",
    "route_name": "Guduvancherry Route",
    "stops": ["Stop 1", "Stop 2", "Stop 3"]
  }
]
```

---

## 🌐 WebSocket Endpoints

### WS /ws/live-updates
Real-time bus location updates.

**Connection:**
```javascript
const ws = new WebSocket('ws://localhost:8000/ws/live-updates');
```

**Receive Message:**
```json
{
  "type": "bus_update",
  "buses": [
    {
      "bus_number": "BW1212",
      "latitude": 12.9716,
      "longitude": 77.5946,
      "speed": 45.5
    }
  ],
  "timestamp": "2024-01-01T00:00:00Z"
}
```

---

## 🏥 Health Check

### GET /health
Check if API is running.

**Response:** `200 OK`
```json
{
  "status": "healthy"
}
```

---

## ❌ Common Error Responses

### 400 Bad Request
```json
{
  "detail": "Invalid request data"
}
```

### 401 Unauthorized
```json
{
  "detail": "Invalid authentication credentials"
}
```

### 403 Forbidden
```json
{
  "detail": "Admin access required"
}
```

### 404 Not Found
```json
{
  "detail": "Resource not found"
}
```

### 409 Conflict
```json
{
  "detail": "Phone number already exists"
}
```

### 422 Unprocessable Entity
```json
{
  "detail": [
    {
      "loc": ["body", "phone"],
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

## 📝 Notes

### Phone Number Format
- Must include country code: `+91XXXXXXXXXX`
- Example: `+919876543210`

### Date Format
- ISO 8601: `2024-01-01T00:00:00Z`

### Pagination
- Default page size: 10 (drivers), 50 (audit logs)
- Page numbers start at 1

### File Upload
- Supported formats: `.xlsx`, `.xls`, `.csv`
- Maximum file size: 5MB
- Required columns for route import:
  - Sl.No
  - Bus Route
  - Route No
  - Vehicle No
  - Driver Name
  - Phone Number

---

## 🔧 Testing with cURL

### Login
```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"+919876543210","password":"admin"}'
```

### Get Statistics (with token)
```bash
curl -X GET http://localhost:8000/api/admin/statistics \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Create Driver
```bash
curl -X POST http://localhost:8000/api/admin/drivers \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Driver","phone":"+919999999999","password":"test123","is_admin":false,"is_active":true}'
```

---

## 🚀 Interactive API Documentation

FastAPI provides automatic interactive API documentation:

- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`

These interfaces allow you to:
- View all endpoints
- Test endpoints directly
- See request/response schemas
- Try authentication

---

## 📱 Frontend Integration

### Admin Dashboard (Web)
- Base URL: `/admin`
- Login: `/admin/login`
- Uses: `/api/admin/*` endpoints

### Flutter App (Mobile)
- Driver Interface: Uses `/api/v1/driver/*` and `/api/v1/auth/*`
- Student Interface: Uses `/api/v1/student/*`
- Real-time Updates: Uses WebSocket `/ws/live-updates`

---

## 🔐 Security Best Practices

1. **Always use HTTPS in production**
2. **Store tokens securely** (localStorage for web, secure storage for mobile)
3. **Never commit tokens or credentials** to version control
4. **Rotate SECRET_KEY regularly**
5. **Implement rate limiting** for login endpoints
6. **Validate all inputs** on both client and server
7. **Use strong passwords** (minimum 6 characters, but recommend 8+)
8. **Enable CORS only for trusted domains**

---

## 📞 Support

For issues or questions:
1. Check the logs for error messages
2. Verify request format matches documentation
3. Test with interactive docs at `/docs`
4. Check authentication token is valid
5. Ensure all required fields are provided

Happy coding! 🚀
