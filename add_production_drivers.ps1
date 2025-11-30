# Add test drivers to production

# Login as admin
$body = @{phone="+919876543210";password="admin"} | ConvertTo-Json
$response = Invoke-RestMethod -Uri "https://sathyabama-bus-tracker.onrender.com/api/v1/auth/login" -Method Post -ContentType "application/json" -Body $body
$token = $response.access_token
Write-Host "✅ Logged in as admin"

# Add Driver 1 - Rajesh Kumar
Write-Host "`n📝 Adding Driver 1: Rajesh Kumar..."
$driver1 = @{
    name="Rajesh Kumar"
    phone="+919876543211"
    email="rajesh@sathyabama.edu"
    password="driver123"
    is_active=$true
    is_admin=$false
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "https://sathyabama-bus-tracker.onrender.com/api/v1/auth/register" -Method Post -ContentType "application/json" -Body $driver1 -Headers @{Authorization="Bearer $token"}
    Write-Host "✅ Driver 1 created"
} catch {
    Write-Host "⚠️  Driver 1 might already exist"
}

# Add Driver 2 - Suresh Babu
Write-Host "`n📝 Adding Driver 2: Suresh Babu..."
$driver2 = @{
    name="Suresh Babu"
    phone="+919876543212"
    email="suresh@sathyabama.edu"
    password="driver123"
    is_active=$true
    is_admin=$false
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "https://sathyabama-bus-tracker.onrender.com/api/v1/auth/register" -Method Post -ContentType "application/json" -Body $driver2 -Headers @{Authorization="Bearer $token"}
    Write-Host "✅ Driver 2 created"
} catch {
    Write-Host "⚠️  Driver 2 might already exist"
}

# Add Driver 3 - Vijay Kumar
Write-Host "`n📝 Adding Driver 3: Vijay Kumar..."
$driver3 = @{
    name="Vijay Kumar"
    phone="+919876543213"
    email="vijay@sathyabama.edu"
    password="driver123"
    is_active=$true
    is_admin=$false
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "https://sathyabama-bus-tracker.onrender.com/api/v1/auth/register" -Method Post -ContentType "application/json" -Body $driver3 -Headers @{Authorization="Bearer $token"}
    Write-Host "✅ Driver 3 created"
} catch {
    Write-Host "⚠️  Driver 3 might already exist"
}

Write-Host "`n🎉 Done! Test drivers added to production."
Write-Host "`n📝 Test Credentials:"
Write-Host "   Driver 1: +919876543211 / driver123"
Write-Host "   Driver 2: +919876543212 / driver123"
Write-Host "   Driver 3: +919876543213 / driver123"
