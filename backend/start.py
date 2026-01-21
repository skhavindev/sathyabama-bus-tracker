#!/usr/bin/env python3
"""
Startup script for Render deployment.
This ensures the app binds to the correct port.
"""
import os
import uvicorn

if __name__ == "__main__":
    # Get port from environment variable (Render sets this)
    port = int(os.environ.get("PORT", 8000))
    
    print(f"🚀 Starting server on port {port}")
    
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=port,
        workers=1
    )