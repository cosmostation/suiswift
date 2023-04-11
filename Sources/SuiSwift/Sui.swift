//
//  SuiConstant.swift
//  
//
//  Created by y on 2022/12/09.
//

import Foundation

class SuiConstant {
    
    static let LOCAL_RPC_URL = "http://127.0.0.1:9000/"
    static let LOCAL_FAUCET_URL = "http://127.0.0.1:5003/gas"
    static let DEV_RPC_URL = "https://explorer-rpc.devnet.sui.io"
    static let DEV_FAUCET_URL = "https://faucet.devnet.sui.io/gas"
    static let TEST_RPC_URL = "https://rpc-sui-testnet.cosmostation.io"
    static let TEST_FAUCET_URL = "https://faucet.testnet.sui.io/gas"
    static let MAIN_RPC_URL = ""
    
}

public enum ChainType: Int {
    case local
    case devnet
    case testnet
}
