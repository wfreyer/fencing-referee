# Fencing Referee App

A mobile application for managing fencing matches with Bluetooth-enabled weapon support.

## App Features

### Scoring System
- Real-time score tracking for two fencers
- Period management (up to 3 periods)
- Manual score adjustment capabilities
- Fencer name customization
- Match reset functionality

### Bluetooth Integration
- Automatic weapon detection and connection
- Real-time score updates from connected weapons
- Connection status monitoring
- Support for multiple weapon connections

## Hardware Requirements

### Bluetooth Specifications
- Bluetooth Low Energy (BLE) 4.0 or higher
- Must support GATT (Generic Attribute Profile)
- Must implement the following service and characteristics:

#### Required Service UUID
```
Service: "FencingWeaponService"
UUID: "0000XXXX-0000-1000-8000-00805F9B34FB"  // Replace XXXX with your service UUID
```

#### Required Characteristics
1. Score Update Characteristic
   - UUID: "0000YYYY-0000-1000-8000-00805F9B34FB"  // Replace YYYY with your characteristic UUID
   - Properties: Notify
   - Data Format: JSON string
   ```json
   {
     "fencer": 1,  // Integer: 1 for left fencer, 2 for right fencer
     "score": 5    // Integer: Current score value
   }
   ```

### Device Requirements
1. **Advertising**
   - Device name must contain "FencingWeapon"
   - Example: "FencingWeapon_Left" or "FencingWeapon_Right"

2. **Connection Parameters**
   - Connection interval: 7.5ms to 4000ms
   - Slave latency: 0 to 499
   - Supervision timeout: 100ms to 32000ms

3. **Power Requirements**
   - Battery life: Minimum 4 hours of continuous operation
   - Low battery indication through BLE

4. **Physical Requirements**
   - Water-resistant design
   - Impact resistant
   - Secure mounting to weapon
   - Weight: Should not affect weapon balance

## Communication Protocol

### Connection Process
1. Device advertises with "FencingWeapon" in name
2. App discovers device during scan
3. App connects to device
4. Device sends score updates through notifications

### Score Update Format
```json
{
  "fencer": 1,     // Integer: 1 or 2
  "score": 5,      // Integer: Current score
  "timestamp": 1234567890  // Optional: Unix timestamp
}
```

### Error Handling
- Device should implement reconnection logic
- App will attempt to reconnect if connection is lost
- Device should handle connection timeouts gracefully

## App Usage

### Connecting Weapons
1. Open the app
2. Tap the Bluetooth icon in the top-right corner
3. Tap "Scan for Weapons"
4. Wait for automatic connection to available weapons

### Manual Score Adjustment
- Use + and - buttons below each fencer's score
- Scores cannot go below 0
- Manual adjustments are possible even with connected weapons

### Period Management
- Current period is displayed at the top
- Use "Next Period" button to advance
- Maximum of 3 periods
- Period resets with match reset

### Match Reset
- "Reset Match" button resets:
  - Both fencers' scores to 0
  - Period to 1
  - Maintains weapon connections

## Score Adjustment History

The app now includes a **Score Adjustment History** feature, which tracks all manual changes made to the fencers' scores during a match. This provides transparency and allows referees or users to review any modifications made throughout the match.

### How It Works
- Every time a score is incremented, decremented, or reset manually, an entry is added to the score adjustment history.
- Each entry records:
  - The fencer whose score was changed
  - The type of adjustment (increment, decrement, reset)
  - The amount of change
  - The reason (if provided)
  - The timestamp of the adjustment

### Viewing the History
- You can view the score adjustment history at any time during a match by tapping the **history** or **info** button (as indicated in the app UI).
- The history dialog displays a list of all adjustments, with the most recent changes at the top. Each entry shows the fencer's name, the adjustment, and how long ago it was made.

This feature helps ensure accurate record-keeping and makes it easy to audit or explain any changes to the match score.

## Bluetooth Connection Resilience & Status

The app now features **automatic reconnection** and a **connection status display** for Bluetooth-connected weapons, improving reliability and user awareness during matches.

### Automatic Reconnection
- If a weapon's Bluetooth connection is lost (e.g., due to range or interference), the app will automatically attempt to reconnect to the device.
- Reconnection attempts are made in the background, and the user does not need to manually restart the connection process.
- This ensures minimal disruption to scoring and match flow.

### Connection Status Display
- The app UI includes a **Connection Status Bar** that shows the current connection state for each weapon (e.g., Connected, Disconnected, Reconnecting).
- Users can quickly see if a weapon is ready, temporarily disconnected, or in the process of reconnecting.
- If a connection error occurs, an **Error Banner** will appear at the top of the screen, providing details and allowing the user to dismiss the message.

These features help referees and users maintain awareness of device connectivity and ensure the app remains robust in real-world conditions.

## Development Notes

### Testing Requirements
1. **Bluetooth Testing**
   - Test with multiple weapon connections
   - Test connection stability
   - Test reconnection scenarios
   - Test battery life impact

2. **Score Accuracy**
   - Verify score synchronization
   - Test manual score adjustments
   - Verify period transitions

3. **Error Scenarios**
   - Connection loss
   - Invalid data format
   - Multiple simultaneous connections
   - Battery depletion

### Future Enhancements
1. **Planned Features**
   - Match history
   - Tournament management
   - Weapon battery monitoring
   - Advanced statistics

2. **Potential Improvements**
   - Custom weapon pairing
   - Weapon calibration
   - Match recording
   - Cloud synchronization

## Testing & Coverage

This project includes comprehensive unit and widget tests for core logic and UI components.

### Running Tests

To run all tests, use:

```bash
flutter test
```

This will execute all unit and widget tests in the `test/` directory.

### Test Coverage
- **Models:** Score adjustment logic is tested in `test/models/score_adjustment_test.dart`.
- **Services:** Match state, scoring, and history logic are tested in `test/services/match_service_test.dart`.
- **Widgets:** UI components such as score display and score history dialog are tested in `test/widgets/score_display_test.dart` and `test/widgets/score_history_dialog_test.dart`.

All tests are designed to ensure correct behavior for scoring, period management, manual adjustments, and UI interactions.

> **Tip:** For continuous integration, consider adding a GitHub Actions workflow to run tests on every push.

## Support

For hardware integration support or app issues, please contact:
[Your Contact Information]

## License

[Your License Information]
