import Foundation
import CoreBluetooth

struct CBUUIDs{
    static let mac_UUID = UUID(uuidString: "4669804C-4E4A-7CE0-F6EF-D4142815BD53")
    
    static let mac_service_cbuuid = CBUUID(string: "6e400001-b5a3-f393-e0a9-e50e24dcca9e")
    static let mac_txCharacteristic_cbuuid = CBUUID(string: "6e400002-b5a3-f393-e0a9-e50e24dcca9e")
    static let mac_rxCharacteristic_cbuuid = CBUUID(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e")
}
