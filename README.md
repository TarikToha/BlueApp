# BLE Central iOS App

## Project Summary

- An iOS app built with Swift and CoreBluetooth.
- Functions as a BLE Central to connect with a specific BLE peripheral.
- Scans for devices and connects using a predefined UUID.
- Discovers services and characteristics on the connected device.
- Subscribes to notifications via `rxCharacteristic`.
- Sends data to the peripheral using `txCharacteristic`.
- Simple UIKit-based interface with:
  - `UITextField` for user input
  - `UITextView` for real-time debug log
- Designed for easy testing and interaction with custom BLE hardware.
