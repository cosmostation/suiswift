//
//  SuiModel.swift
//  
//
//  Created by y on 2022/12/09.
//

import Foundation
import SwiftyJSON

public struct FaucetRequest: Encodable {
    let FixedAmountRequest: FixedAmountRequest
}

public struct FixedAmountRequest: Encodable {
    let recipient: String
}

public struct JsonRpcResponse: Decodable {
    let id: Int
    var jsonrpc: String
    let result: JSON?
    let error: JSON?
}

public struct JsonRpcRequest: Codable {
    public init(_ method: String, _ params: JSON) {
        self.method = method
        self.params = params
    }
    var id: Int = Int(arc4random())
    var method: String = ""
    var jsonrpc: String = "2.0"
    let params: JSON
}
