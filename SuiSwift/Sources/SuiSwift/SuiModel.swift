//
//  SuiModel.swift
//  
//
//  Created by y on 2022/12/09.
//

import Foundation
import SwiftyJSON

struct FaucetRequest: Encodable {
    let FixedAmountRequest: FixedAmountRequest
}

struct FixedAmountRequest: Encodable {
    let recipient: String
}

struct JsonRpcResponse: Decodable {
    let id: Int
    var jsonrpc: String
    let result: JSON
}

struct JsonRpcRequest: Encodable {
    init(_ method: String, _ params: JSON) {
        self.method = method
        self.params = params
    }
    var id: Int = Int(arc4random())
    var method: String = ""
    var jsonrpc: String = "2.0"
    let params: JSON
}
