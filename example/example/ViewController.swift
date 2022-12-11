//
//  ViewController.swift
//  example
//
//  Created by y on 2022/12/08.
//

import UIKit
import SuiSwift
import SwiftyJSON

enum MENU {
    case NewMnemonic
    case LoadMnemonic
    case Faucet
    case GetObjectsByOwner
    case GetTransactions
    case GetTransactionDetails
    case TransferObject
    
    static let allValues = [NewMnemonic, LoadMnemonic, Faucet, GetObjectsByOwner, GetTransactions, GetTransactionDetails, TransferObject]
}

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let preloadMnemonic = ""
    var address: String?
    var mnemonic: String?
    var objects: JSON?
    var digests: [String] = []
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MENU.allValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")! as UITableViewCell

        cell.textLabel?.text = "\(MENU.allValues[(indexPath as NSIndexPath).row])"
        cell.detailTextLabel?.text = "\(MENU.allValues[(indexPath as NSIndexPath).row])"

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(MENU.allValues[indexPath.row]) {
        case .NewMnemonic:
            mnemonic = SuiClient.shared.generateMnemonic()
            if let mnemonic = mnemonic {
                address = SuiClient.shared.getAddress(mnemonic)
            }
            return
        case .LoadMnemonic:
            mnemonic = preloadMnemonic
            if let mnemonic = mnemonic {
                address = SuiClient.shared.getAddress(mnemonic)
            }
            return
        case .Faucet:
            if let address = address {
                SuiClient.shared.faucet(address)
            }
            return
        case .GetObjectsByOwner:
            if let address = address {
                SuiClient.shared.getObjectsByOwner(address) { result in
                    self.objects = result
                    print(result)
                }
            }
            return
        case .GetTransactions:
            if let address = address {
                digests.removeAll()
                SuiClient.shared.getTransactions(["FromAddress": address]) { result in
                    if let result = result {
                        print(result)
                        result["data"].arrayValue.forEach { json in
                            self.digests.append(json.stringValue)
                        }
                    }
                }
                SuiClient.shared.getTransactions(["ToAddress": address]) { result in
                    if let result = result {
                        print(result)
                        result["data"].arrayValue.forEach { json in
                            self.digests.append(json.stringValue)
                        }
                    }
                }
            }
            return
        case .GetTransactionDetails:
            SuiClient.shared.getTransactionDetails(digests) { result in
                print(result)
            }
            return
        case .TransferObject:
            if let address = address, let objects = objects {
                let firstObjectId = objects[0]["objectId"].stringValue
                print(firstObjectId)
                SuiClient.shared.transferObject(firstObjectId, address, address) { result in
                    if let result = result,
                       let mnemonic = self.mnemonic,
                       let bytes = Data(base64Encoded: result["txBytes"].stringValue) {
                        let signature = SuiClient.shared.sign(mnemonic, bytes)
                        SuiClient.shared.executeTransaction(bytes, signature.signedData, signature.pubKey) { r in
                            print(r)
                        }
                    }
                }
            }
            return
        }
    }
}
