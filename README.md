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

## Support

For hardware integration support or app issues, please contact:
[Your Contact Information]

## License

[Your License Information]
