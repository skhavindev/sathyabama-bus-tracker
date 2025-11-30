# Notification Fixes

## Issues Fixed

### 1. Bell Icon Not Showing Radius Selector
**Problem**: Clicking the bell icon in bus details was just sending a notification immediately without asking for radius.

**Solution**: 
- Bell icon now shows the same radius selector popup as the Track button
- User can choose: 100m, 300m, 500m, or 700m
- After selecting radius, bus is added to tracked buses
- Notification will be sent when bus enters the selected radius

**How It Works Now**:
1. Tap bus on map or in list
2. Tap bell icon (🔔)
3. Select notification radius (100m, 300m, 500m, 700m)
4. Bus is tracked with that radius
5. You'll be notified when bus enters your radius

### 2. "Bus is Near" Notification Sent Incorrectly
**Problem**: 
- Notification was being sent even when bus was offline
- Notification was sent for buses not being tracked
- Notification was sent when bus wasn't actually near

**Solution**:
- Removed the automatic "bus is near" notification
- Now only sends proximity notifications based on user-selected radius
- Only sends notifications for buses that are:
  - Being tracked by the user
  - Actively sharing location (status = 'active')
  - Within the user-selected radius

**Notification Logic**:
```
IF bus is tracked by user
  AND bus is actively sharing location
  AND bus is within user's selected radius
  AND user hasn't been notified yet
THEN send proximity notification
```

### 3. Bell Icon Visual Feedback
**Problem**: No visual indication if bus is already being tracked.

**Solution**:
- Bell icon turns gray when bus is already tracked
- Bell icon is disabled when bus is already tracked
- Tooltip shows "Already tracking" vs "Set notification"
- Prevents duplicate tracking of same bus

## User Experience Improvements

### Before
- ❌ Bell icon sent notification immediately
- ❌ No radius selection
- ❌ Notifications sent for offline buses
- ❌ Could track same bus multiple times
- ❌ Confusing behavior

### After
- ✅ Bell icon shows radius selector
- ✅ User chooses notification distance
- ✅ Only notifies for active buses
- ✅ Visual feedback for tracked buses
- ✅ Clear, predictable behavior

## Testing

### Test Bell Icon
1. Open student app
2. Tap any bus on map
3. Tap bell icon (🔔)
4. **Expected**: Radius selector popup appears
5. Select a radius (e.g., 300m)
6. **Expected**: "You will be notified when Bus XX is within 300m"
7. Tap bell icon again
8. **Expected**: Bell is gray and disabled (already tracking)

### Test Notifications
1. Track a bus with 500m radius
2. Wait for bus to come within 500m
3. **Expected**: Notification "Bus XX is nearby! Your bus is XXXm away"
4. Bus moves away (>500m)
5. **Expected**: Notification state resets
6. Bus comes back within 500m
7. **Expected**: Notification sent again

### Test Offline Buses
1. Track a bus
2. Driver ends shift (bus goes offline)
3. **Expected**: No notifications sent
4. Notification state is cleared
5. Driver starts shift again
6. **Expected**: Notifications resume when within radius

## Technical Details

### Notification Types
Now we have only ONE notification type:
- **Proximity Notification**: User-selected radius (100m-700m)

Removed:
- ~~"Bus is near" notification (automatic 500m)~~

### State Management
```dart
_notifiedBuses: Set<String>  // Tracks which buses have been notified
_trackedBuses: List<TrackedBus>  // Buses user is tracking
```

### Proximity Check Logic
```dart
// Every 10 seconds
for each tracked bus:
  if bus is active:
    calculate distance
    if distance <= radius AND not notified:
      send notification
      mark as notified
    else if distance > radius:
      clear notified state
  else:
    clear all notification states
```

## Files Modified
- `flutter_app/lib/screens/student/student_home_screen.dart`
  - Fixed `_notifyBusNear()` to show radius selector
  - Updated `_startProximityChecking()` to only notify for active buses
  - Updated bell icon to show tracking state

## Summary
The notification system is now simpler and more predictable:
- One notification type (proximity with user-selected radius)
- Only notifies for active buses
- Clear visual feedback
- No duplicate tracking
- Proper state management
