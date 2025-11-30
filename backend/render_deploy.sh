#!/bin/bash
# Render deployment script

echo "🚀 Starting Render deployment..."

# Install dependencies
echo "📦 Installing dependencies..."
pip install -r requirements.txt

# Initialize database
echo "🔄 Initializing database..."
python init_db.py

# Run database migrations
echo "🔄 Running migrations..."
python init_models.py

echo "✅ Deployment complete!"
echo "🌐 Admin credentials: +919876543210 / admin"
