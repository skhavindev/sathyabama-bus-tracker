# Admin Dashboard

The admin dashboard allows you to manage drivers, approve driver requests, and monitor the bus tracking system.

## Features

- **Driver Management**: View all drivers, approve/reject driver requests
- **Real-time Statistics**: Monitor total drivers, active drivers, pending approvals
- **Driver Actions**: Approve, deactivate, or delete drivers
- **Secure Authentication**: Admin-only access with JWT tokens

## Setup

### 1. Create an Admin User

Run the admin creation script:

```bash
cd backend
python scripts/create_admin.py
```

Follow the prompts to create your admin account.

### 2. Access the Dashboard

Once the backend is running, access the dashboard at:

```
http://localhost:8000/admin
```

Or on your deployed Render URL:

```
https://your-app.onrender.com/admin
```

### 3. Login

Use the phone number and password you created to login.

## API Endpoints

### Admin Authentication

All admin endpoints require a Bearer token in the Authorization header:

```
Authorization: Bearer <your_jwt_token>
```

### Available Endpoints

#### Get Dashboard Statistics
```
GET /api/v1/admin/stats
```

Returns:
- Total drivers
- Active drivers
- Pending drivers
- Admin count

#### Get All Drivers
```
GET /api/v1/admin/drivers?status_filter=all|pending|active
```

#### Approve Driver
```
PATCH /api/v1/admin/drivers/{driver_id}/approve
```

#### Reject/Deactivate Driver
```
PATCH /api/v1/admin/drivers/{driver_id}/reject
```

#### Delete Driver
```
DELETE /api/v1/admin/drivers/{driver_id}
```

#### Update Driver
```
PATCH /api/v1/admin/drivers/{driver_id}
Body: {
  "name": "New Name",
  "phone": "+919876543210",
  "email": "email@example.com",
  "password": "newpassword"
}
```

## Dashboard Features

### Statistics Cards
- **Total Drivers**: All registered drivers
- **Active Drivers**: Approved and active drivers
- **Pending Approval**: Drivers waiting for approval
- **Admin Users**: Number of admin accounts

### Driver Table
- View all driver information
- Filter by status (All, Pending, Active)
- Quick actions for each driver

### Actions
- **Approve**: Activate a pending driver
- **Deactivate**: Disable an active driver
- **Delete**: Permanently remove a driver (cannot delete admins)

## Security

- Admin access is required for all endpoints
- JWT tokens expire after 10 years (permanent session)
- Passwords are hashed using bcrypt
- Admin users cannot be deleted through the dashboard

## Deployment on Render

The dashboard is automatically served when you deploy to Render:

1. Deploy your backend to Render
2. Access `https://your-app.onrender.com/admin`
3. Login with your admin credentials

## Troubleshooting

### Cannot Login
- Ensure you created an admin user with `is_admin=True`
- Check that the backend is running
- Verify your phone number and password

### 403 Forbidden
- Your account needs admin privileges
- Run the create_admin script to create an admin account

### Connection Error
- Check that the backend is running on the correct port
- Verify CORS settings in `app/config.py`
