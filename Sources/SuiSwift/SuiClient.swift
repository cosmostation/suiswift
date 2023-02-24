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
    
    var rpc_endpoint: String!
    var faucet_endpoint: String!
    
    public static let shared = SuiClient()
    
    public init() { }
    
    public func setConfig(_ chainType: ChainType) {
        switch chainType {
        case .local:
            rpc_endpoint = SuiConstant.LOCAL_RPC_URL
            faucet_endpoint = SuiConstant.LOCAL_FAUCET_URL
        case .devnet:
            rpc_endpoint = SuiConstant.DEV_RPC_URL
            faucet_endpoint = SuiConstant.DEV_FAUCET_URL
        case .testnet:
            rpc_endpoint = SuiConstant.TEST_RPC_URL
            faucet_endpoint = SuiConstant.TEST_FAUCET_URL
        }
    }
    
    public func generateMnemonic() -> String? {
        return try? BIP39.generateMnemonics(bitsOfEntropy: 128)
    }
    
    public func getAddress(_ mnemonic: String)  -> String {
        return SuiKey.getSuiAddress(mnemonic)
    }
    
    public func faucet(_ address: String) {
        AF.request(faucet_endpoint,
                   method: .post,
                   parameters: FaucetRequest(FixedAmountRequest: FixedAmountRequest(recipient: address)),
                   encoder: JSONParameterEncoder.default).response { response in
            debugPrint(response)
        }
    }
    
    public func sign(_ mnemonic: String, _ txBytes: Data) -> (pubKey: Data, signedData: Data) {
        let seedKey = SuiKey.getPrivKeyFromSeed(mnemonic)
        return (SuiKey.getPubKey(mnemonic), SuiKey.sign(seedKey, txBytes))
    }
    
    public func getSuiSystemstate(_ listener: @escaping (JSON?) -> Void) {
        let params = JsonRpcRequest("sui_getSuiSystemState", JSON())
        SuiRequest(params, listener)
    }
    
    public func getTotalSupply(_ coinType: String, _ listener: @escaping (JSON?) -> Void) {
        let params = JsonRpcRequest("sui_getTotalSupply", JSON())
        SuiRequest(params, listener)
    }
    
    public func getAllBalances(_ address: String, _ listener: @escaping (JSON?) -> Void) {
        let params = JsonRpcRequest("sui_getAllBalances", JSON(arrayLiteral: address))
        SuiRequest(params, listener)
    }
    
    public func getAllBalance(_ address: String, _ coinType: String, _ listener: @escaping (JSON?) -> Void) {
        let params = JsonRpcRequest("sui_getBalance", JSON(arrayLiteral: address, coinType))
        SuiRequest(params, listener)
    }
    
    public func getAllCoins(_ owner: String, _ cursor: String? = nil, _ limit: Int? = nil, _ listener: @escaping (JSON?) -> Void) {
        let params = JsonRpcRequest("sui_getAllCoins", JSON(arrayLiteral: owner, cursor, limit))
        SuiRequest(params, listener)
    }
    
    public func getCoins(_ owner: String, _ coinType: String, _ cursor: String? = nil, _ limit: Int? = nil, _ listener: @escaping (JSON?) -> Void) {
        let params = JsonRpcRequest("sui_getCoins", JSON(arrayLiteral: owner, cursor, limit))
        SuiRequest(params, listener)
    }
    
    public func getCoinMetadata(_ coinType: String, _ listener: @escaping (JSON?) -> Void) {
        let params = JsonRpcRequest("sui_getCoinMetadata", JSON(arrayLiteral: coinType))
        SuiRequest(params, listener)
    }
    
    public func getObjectsByOwner(_ address: String, _ listener: @escaping (JSON?) -> Void) {
        let params = JsonRpcRequest("sui_getObjectsOwnedByAddress", JSON(arrayLiteral: address))
        SuiRequest(params, listener)
    }
    
    public func getObject(_ objectIds: [String], _ listener: @escaping ([JSON]?) -> Void) {
        let params = objectIds.map { objectId in JsonRpcRequest("sui_getObject", JSON(arrayLiteral: objectId)) }
        SuiRequests(params, listener)
    }
    
    public func getTransactions(_ transactionQuery: [String: String], _ nextOffset: String? = nil, _ limit: Int? = nil, _ descending: Bool = false, _ listener: @escaping (JSON?) -> Void) {
        let params = JsonRpcRequest("sui_getTransactions", JSON(arrayLiteral: transactionQuery, nextOffset, limit, descending))
        SuiRequest(params, listener)
    }
    
    public func getTransactionDetails(_ digests: [String], _ listener: @escaping ([JSON]?) -> Void) {
        let params = digests.map { digest in JsonRpcRequest("sui_getTransaction", JSON(arrayLiteral: digest)) }
        SuiRequests(params, listener)
    }
    
    public func transferObject(_ objectId: String, _ receiver: String,
                               _ sender: String, _ gasBudget: Int = 1000, _ amount: Int? = nil
                               , _ listener: @escaping (JSON?) -> Void) {
        let params = JsonRpcRequest("sui_transferSui", JSON(arrayLiteral: sender, objectId, gasBudget, receiver))
        SuiRequest(params, listener)
    }
    
    public func executeTransaction(_ txBytes: Data, _ signedBytes: Data, _ pubKey: Data, _ listener: @escaping (JSON?) -> Void) {
        let params = JsonRpcRequest("sui_executeTransactionSerializedSig", JSON(arrayLiteral: txBytes.base64EncodedString(),
                                                                                (Data([0x00]) + signedBytes + pubKey).base64EncodedString(),
                                                                                "WaitForLocalExecution"))
        SuiRequest(params, listener)
    }
    
    private func SuiRequest(_ params: JsonRpcRequest, _ listener: @escaping (JSON?) -> Void) {
        AF.request(rpc_endpoint,
                   method: .post,
                   parameters: params,
                   encoder: JSONParameterEncoder.default).response { response in
            switch response.result {
            case .success(let value):
                if let value = value, let response = try? JSONDecoder().decode(JsonRpcResponse.self, from: value) {
                    listener(response.result)
                }
            case .failure(let error):
                print("error ", error)
                debugPrint(error)
            }
        }
    }
    
    private func SuiRequests(_ params: [JsonRpcRequest], _ listener: @escaping ([JSON]?) -> Void) {
        AF.request(rpc_endpoint,
                   method: .post,
                   parameters: params,
                   encoder: JSONParameterEncoder.default).response { response in
            switch response.result {
            case .success(let value):
                if let value = value, let response = try? JSONDecoder().decode([JsonRpcResponse].self, from: value) {
                    listener(response.map({ res in
                        res.result
                    }))
                }
            case .failure(let error):
                print("error ", error)
                debugPrint(error)
            }
        }
    }
    
    public func postJsonRpcRequest(_ params: JsonRpcRequest) async throws -> JSON {
        return try await AF.request(rpc_endpoint,
                                    method: .post,
                                    parameters: params,
                                    encoder: JSONParameterEncoder.default).serializingDecodable(JSON.self).value
    }
}
