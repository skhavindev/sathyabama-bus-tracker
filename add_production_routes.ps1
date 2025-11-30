# Add test routes to production

# Login as admin
$body = @{phone="+919876543210";password="admin"} | ConvertTo-Json
$response = Invoke-RestMethod -Uri "https://sathyabama-bus-tracker.onrender.com/api/v1/auth/login" -Method Post -ContentType "application/json" -Body $body
$token = $response.access_token
Write-Host "✅ Logged in as admin"

# Add Route 1
Write-Host "`n📝 Adding Route 1: TN01AB1234..."
$route1 = @{
    bus_route="Tambaram - Sathyabama"
    route_no="R1"
    vehicle_no="TN01AB1234"
    driver_name="Rajesh Kumar"
    phone_number="+919876543211"
    is_active=$true
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "https://sathyabama-bus-tracker.onrender.com/api/admin/routes" -Method Post -ContentType "application/json" -Body $route1 -Headers @{Authorization="Bearer $token"}
    Write-Host "✅ Route 1 created"
} catch {
    Write-Host "⚠️  Route 1 might already exist"
}

# Add Route 2
Write-Host "`n📝 Adding Route 2: TN01AB5678..."
$route2 = @{
    bus_route="Velachery - Sathyabama"
    route_no="R2"
    vehicle_no="TN01AB5678"
    driver_name="Suresh Babu"
    phone_number="+919876543212"
    is_active=$true
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "https://sathyabama-bus-tracker.onrender.com/api/admin/routes" -Method Post -ContentType "application/json" -Body $route2 -Headers @{Authorization="Bearer $token"}
    Write-Host "✅ Route 2 created"
} catch {
    Write-Host "⚠️  Route 2 might already exist"
}

# Add Route 3
Write-Host "`n📝 Adding Route 3: TN01AB9012..."
$route3 = @{
    bus_route="Adyar - Sathyabama"
    route_no="R3"
    vehicle_no="TN01AB9012"
    driver_name="Vijay Kumar"
    phone_number="+919876543213"
    is_active=$true
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "https://sathyabama-bus-tracker.onrender.com/api/admin/routes" -Method Post -ContentType "application/json" -Body $route3 -Headers @{Authorization="Bearer $token"}
    Write-Host "✅ Route 3 created"
} catch {
    Write-Host "⚠️  Route 3 might already exist"
}

Write-Host "`n🎉 Done! Test routes added to production."
