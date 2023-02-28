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
    case GetSuiSystemState
    case GetTotalSupply
    case GetAllBalances
    case GetAllBalance
    case GetAllCoin
    case GetCoins
    case GetCoinMetadata
    case GetObjectsByOwner
    case GetObject
    case GetTransactions
    case GetTransactionDetails
    case TransferObject
    
    static let allValues = [NewMnemonic, LoadMnemonic, Faucet, GetSuiSystemState, GetTotalSupply,
                            GetAllBalances, GetAllBalance, GetAllCoin, GetCoins, GetCoinMetadata,
                            GetObjectsByOwner, GetObject, GetTransactions, GetTransactionDetails, TransferObject]
}

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let preloadMnemonic = "wing mammal best spend that cave decline zone legal affair demand pulp"
    var address: String?
    var mnemonic: String?
    var objects: JSON?
    var digests: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SuiClient.shared.setConfig(ChainType.devnet)
    }
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
                Task {
                    let resut = try? await SuiClient.shared.faucet(address)
                }
            }
            return
        case .GetSuiSystemState:
            SuiClient.shared.getSuiSystemstate() { result in
                self.objects = result
                print(result)
            }
            return
        case .GetTotalSupply:
            SuiClient.shared.getTotalSupply("0x2::sui::SUI") { result in
                self.objects = result
                print(result)
            }
            return
        case .GetAllBalances:
            if let address = address {
                SuiClient.shared.getAllBalances(address) { result in
                    self.objects = result
                    print(result)
                }
            }
            return
        case .GetAllBalance:
            if let address = address {
                SuiClient.shared.getAllBalance(address, "0x2::sui::SUI") { result in
                    self.objects = result
                    print(result)
                }
            }
            return
        case .GetAllCoin:
            if let address = address {
                SuiClient.shared.getAllCoins(address) { result in
                    self.objects = result
                    print(result)
                }
            }
            return
        case .GetCoins:
            if let address = address {
                SuiClient.shared.getCoins(address, "0x2::sui::SUI") { result in
                    self.objects = result
                    print(result)
                }
            }
            return
        case .GetCoinMetadata:
            SuiClient.shared.getCoinMetadata("0x2::sui::SUI") { result in
                self.objects = result
                print(result)
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
        case .GetObject:
            SuiClient.shared.getObject(["0x0515b8025a1e9c4abf8f0e8b068a9e8ff7e7aa84","0x0c5865cfb88a3099dfeb367fa503080502bccb0e","0x0efe84ff97ead1dc88ac227ea07e0b623ced8168"]) { result in
                print(result)
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
            SuiClient.shared.getTransactionDetails(["E9dJqeCPtyaB2N5VJ5FFNBm4qkoWfDUKKZDpnPD5k3Xk", "D88hBzVTQojx3PvpzcB423w7Mx4pyYJmnDey7NKJnXKW"]) { result in
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
                        let signature = SuiClient.shared.sign(mnemonic, Data([0, 0, 0]) + bytes)
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
