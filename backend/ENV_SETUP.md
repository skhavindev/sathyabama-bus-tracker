# Environment Setup Instructions

## Backend Environment File

Since `.env` files are gitignored .sensitive credentials, you need to create it manually.

### Step 1: Copy the Example File

**Windows (PowerShell):**
```powershell
cd backend
copy .env.example .env
```

**Mac/Linux:**
```bash
cd backend
cp .env.example .env
```

### Step 2: Edit the Configuration

Open `backend/.env` in your text editor and update these values:

```env
# Database Configuration
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/sathyabama_bus_db
POSTGRES_USER=postgres
POSTGRES_PASSWORD=YOUR_PASSWORD
POSTGRES_DB=sathyabama_bus_db

# Redis Configuration
REDIS_URL=redis://localhost:6379/0

# Security (CHANGE THIS IN PRODUCTION!)
SECRET_KEY=your-very-secret-key-please-change-this-in-production
ALGORITHM=HS256

# CORS Origins (comma-separated)
CORS_ORIGINS=http://localhost:3000,http://localhost:5173,http://localhost:8080,http://127.0.0.1:8080

# Environment
ENVIRONMENT=development
```

### Step 3: Replace Placeholders

- **YOUR_PASSWORD**: Your PostgreSQL password (default is often `postgres`)
- **SECRET_KEY**: Generate a random string (or use: `python -c "import secrets; print(secrets.token_hex(32))"`)

### Example Development Configuration:

```env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/sathyabama_bus_db
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=sathyabama_bus_db
REDIS_URL=redis://localhost:6379/0
SECRET_KEY=dev-secret-key-change-in-production-2024-sathyabama-bus-tracking
ALGORITHM=HS256
CORS_ORIGINS=http://localhost:3000,http://localhost:8080,http://127.0.0.1:8080
ENVIRONMENT=development
```

## Verify Setup

Test your configuration:

```bash
# Test database connection
python -c "from app.database import engine; print('Database connected!' if engine else 'Failed')"

# Test Redis connection
redis-cli ping
# Should return: PONG
```

## Production Configuration

For production (Render.com), use these in the Render dashboard:

```env
DATABASE_URL=<Render PostgreSQL URL>
REDIS_URL=<Render Redis URL>
SECRET_KEY=<Generate new secret key>
ALGORITHM=HS256
CORS_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
ENVIRONMENT=production
```

## Troubleshooting

### "Database connection failed"
- Check if PostgreSQL is running: `pg_isready`
- Verify credentials in `.env`
- Ensure database exists: `createdb sathyabama_bus_db`

### "Redis connection refused"
- Check if Redis is running: `redis-cli ping`
- Start Redis: `redis-server`

### "Module not found"
- Ensure you're in the backend directory
- Activate virtual environment
- Install dependencies: `pip install -r requirements.txt`
