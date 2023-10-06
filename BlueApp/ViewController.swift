import CoreBluetooth
import UIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var debug_area: UITextView!
    private var log_text = String()
    private var isReady = false
    
    private var centralManager: CBCentralManager!
    private var discoveredPeripheral: CBPeripheral!
    private var rxCharacteristic: CBCharacteristic!
    private var txCharacteristic: CBCharacteristic!
    
    override func viewDidLoad() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @IBAction func startScanning(_ sender: Any) {
        
        guard isReady else {
            appendLog(log: "Please wait until the central gets ready")
            return
        }
        
        guard let discoveredPeripheral = discoveredPeripheral else {
            appendLog(log: "central is scanning now")
            centralManager.scanForPeripherals(withServices: nil)
            return
        }
        
        guard discoveredPeripheral.state == .connected else {
            appendLog(log: "central is connecting now")
            centralManager.connect(discoveredPeripheral, options: nil)
            return
        }
        
        guard rxCharacteristic != nil else {
            appendLog(log: "central is discovering services now")
            discoveredPeripheral.discoverServices([CBUUIDs.mac_service_cbuuid])
            return
        }
        
        appendLog(log: "pheripheral is already subscribed")
    }
    
    @IBAction func sendData(_ sender: Any) {
        guard let msg = inputText.text else {
            return
        }
        
        if msg.isEmpty {
            return
        }
        writeToPeripheral(msg: msg)
        inputText.text = ""
    }
    
    private func appendLog(log: String){
        log_text.append(log + "\n")
        debug_area.text = log_text
    }
    
}

extension ViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch centralManager.state {
        case .poweredOff:
            appendLog(log: "bluetooth is powered OFF")
        case .poweredOn:
            appendLog(log: "bluetooth is powered ON")
            isReady = true
            appendLog(log: "The central is ready for scanning")
        default:
            appendLog(log: "bluetooth is NOT supported")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if peripheral.identifier == CBUUIDs.mac_UUID {
            centralManager.stopScan()
            
            discoveredPeripheral = peripheral
            discoveredPeripheral.delegate = self
            
            appendLog(log: "Peripheral discovered: \(discoveredPeripheral!)")
            //            print("Peripheral name: \(name)")
            //            print("Advertisement Data : \(advertisementData)")
            
            centralManager.connect(discoveredPeripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        appendLog(log: "Failed to connect: \(peripheral.name!) => \(String(describing: error?.localizedDescription))")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        appendLog(log: "Connected: \(discoveredPeripheral.name!)")
        discoveredPeripheral.discoverServices([CBUUIDs.mac_service_cbuuid])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        appendLog(log: "Disconnected: \(discoveredPeripheral.name!)")
    }
}

extension ViewController: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let error = error {
            appendLog(log: "Error discovering services: \(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        
        appendLog(log: "Discovered services: \(services)")
        //We need to discover the all characteristic
        for service in services {
            discoveredPeripheral.discoverCharacteristics(nil, for: service)
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let error = error {
            appendLog(log: "Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        appendLog(log: "Found \(characteristics.count) characteristics")
        
        for characteristic in characteristics {
            
            //            if characteristic.properties.contains(.notify) {
            //                print("\(characteristic.uuid): properties contains .notify")
            //            }
            //            if characteristic.properties.contains(.writeWithoutResponse) {
            //                print("\(characteristic.uuid): properties contains .writeWithoutResponse")
            //            }
            
            if characteristic.uuid.isEqual(CBUUIDs.mac_rxCharacteristic_cbuuid)  {
                discoveredPeripheral.setNotifyValue(true, for: characteristic)
            }
            
            if characteristic.uuid.isEqual(CBUUIDs.mac_txCharacteristic_cbuuid){
                txCharacteristic = characteristic
                appendLog(log: "Found txCharacteristic: \(txCharacteristic!)")
            }
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // Deal with errors (if any)
        if let error = error {
            appendLog(log: "Error updating notification state for characteristic: \(error.localizedDescription)")
            return
        }
                
        if characteristic.isNotifying {
            rxCharacteristic = characteristic
            appendLog(log: "Subscribed to rxCharacteristic: \(rxCharacteristic!)")
        } else {
            rxCharacteristic = nil
            appendLog(log: "Unsubscribed to rxCharacteristic: \(rxCharacteristic!)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard let characteristicValue = characteristic.value,
              let characteristicValue = String(data: characteristicValue, encoding: .utf8)
        else {
            return
        }
        
        appendLog(log: "Recieved: \(characteristicValue) at \(NSDate())")
    }
    
    private func writeToPeripheral(msg: String){
        
        guard let discoveredPeripheral = discoveredPeripheral,
              let txCharacteristic = txCharacteristic
        else {
            return
        }
        
        discoveredPeripheral.writeValue(
            msg.data(using: .utf8)!,
            for: txCharacteristic,
            type: .withoutResponse
        )
        
        appendLog(log: "Sent: \(msg) at \(NSDate())")
    }
    
}
