//
//  SuiClient.swift
//
//
//  Created by y on 2022/12/09.
//

import Foundation
import Alamofire
import web3swift
import SwiftyJSON

open class SuiClient {
    public static let shared = SuiClient()
    
    public init() {}
    
    public func generateMnemonic() -> String? {
        return try? BIP39.generateMnemonics(bitsOfEntropy: 128)
    }
    
    public func getAddress(_ mnemonic: String)  -> String {
        return SuiKey.getSuiAddress(mnemonic)
    }
    
    public func faucet(_ address: String) {
        AF.request("https://faucet.devnet.sui.io/gas",
                   method: .post,
                   parameters: FaucetRequest(FixedAmountRequest: FixedAmountRequest(recipient: address)),
                   encoder: JSONParameterEncoder.default).response { response in
            debugPrint(response)
        }
    }
    
    public func sign(_ mnemonic: String, _ txBytes: Data) -> (pubKey: Data, signedData: Data) {
        let seedKey = SuiKey.getSeedKey(mnemonic)
        return (SuiKey.getPubKey(mnemonic), SuiKey.sign(seedKey, txBytes))
    }
    
    public func getObjectsByOwner(_ address: String, _ listener: @escaping (JSON?) -> Void) {
        let params = JsonRpcRequest("sui_getObjectsOwnedByAddress", JSON(arrayLiteral: address))
        AF.request(SuiConstant.RPC_URL,
                   method: .post,
                   parameters: params,
                   encoder: JSONParameterEncoder.default).response { response in
            switch response.result {
            case .success(let value):
                if let value = value, let response = try? JSONDecoder().decode(JsonRpcResponse.self, from: value) {
                    listener(response.result)
                }
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    public func getTransactions(_ transactionQuery: [String: String], _ nextOffset: String? = nil, _ limit: Int? = nil, _ descending: Bool = false, _ listener: @escaping (JSON?) -> Void) {
        let params = JsonRpcRequest("sui_getTransactions", JSON(arrayLiteral: transactionQuery, nextOffset, limit, descending))
        AF.request(SuiConstant.RPC_URL,
                   method: .post,
                   parameters: params,
                   encoder: JSONParameterEncoder.default).response { response in
            switch response.result {
            case .success(let value):
                if let value = value, let response = try? JSONDecoder().decode(JsonRpcResponse.self, from: value) {
                    listener(response.result)
                }
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    public func getTransactionDetails(_ digests: [String], _ listener: @escaping (JSON?) -> Void) {
        let params = JsonRpcRequest("sui_getTransaction", JSON(digests))
        AF.request(SuiConstant.RPC_URL,
                   method: .post,
                   parameters: params,
                   encoder: JSONParameterEncoder.default).response { response in
            switch response.result {
            case .success(let value):
                if let value = value, let response = try? JSONDecoder().decode(JsonRpcResponse.self, from: value) {
                    listener(response.result)
                }
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    public func transferObject(_ objectId: String, _ receiver: String,
                               _ sender: String, _ gasBudget: Int = 100, _ amount: Int? = nil
                               , _ listener: @escaping (JSON?) -> Void) {
        let params = JsonRpcRequest("sui_transferSui", JSON(arrayLiteral: sender, objectId, gasBudget, receiver))
        AF.request(SuiConstant.RPC_URL,
                   method: .post,
                   parameters: params,
                   encoder: JSONParameterEncoder.default).response { response in
            switch response.result {
            case .success(let value):
                if let value = value, let response = try? JSONDecoder().decode(JsonRpcResponse.self, from: value) {
                    listener(response.result)
                }
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    public func executeTransaction(_ txBytes: Data, _ signedBytes: Data, _ pubKey: Data, _ listener: @escaping (JSON?) -> Void) {
        let params = JsonRpcRequest("sui_executeTransaction", JSON(arrayLiteral: txBytes.base64EncodedString(),
                                                                   "ED25519",
                                                                   signedBytes.base64EncodedString(),
                                                                   pubKey.base64EncodedString(),
                                                                   "WaitForLocalExecution"))
        AF.request(SuiConstant.RPC_URL,
                   method: .post,
                   parameters: params,
                   encoder: JSONParameterEncoder.default).response { response in
            switch response.result {
            case .success(let value):
                if let value = value, let response = try? JSONDecoder().decode(JsonRpcResponse.self, from: value) {
                    listener(response.result)
                }
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
}
