# sui swift

iOS SDK for SUI

## Requirement

* iOS 13
* Swift

## Dependency

#### Swift Package Manager

You can use [The Swift Package Manager](https://swift.org/package-manager) to install `SuiSwift` by adding the proper description to your `Package.swift` file:
```swift
dependencies: [
    .package(url: "https://github.com/cosmostation/suiswift.git", .branch("main"))
]
```

#### CocoaPods

You can use [CocoaPods](http://cocoapods.org/) to install `SuiSwift` by adding it to your `Podfile`:

```ruby
platform :ios, '13.0'
use_frameworks!

target 'MyApp' do
    pod 'SuiSwift'
end
```


## API

Using api like below.
```swift
SuiCLient.shared.{API}
```

### Generate new mnemonic
```swift
public func generateMnemonic() -> String?
```

### Get address from mnemonic
```swift
public func getAddress(_ mnemonic: String)  -> String
```

### Sign data
```swift
public func sign(_ mnemonic: String, _ txBytes: Data) -> (pubKey: Data, signedData: Data)
```

### Get objects by address
```swift
public func getObjectsByOwner(_ address: String, _ listener: @escaping (JSON?) -> Void)
```

### Get transactions
```swift
public func getTransactions(
        _ transactionQuery: [String: String],
        _ nextOffset: String? = nil,
        _ limit: Int? = nil,
        _ descending: Bool = false,
        _ listener: @escaping (JSON?) -> Void
    )
```

### Get transaction details from transaction digests
```swift
public func getTransactionDetails(_ digests: [String], _ listener: @escaping (JSON?) -> Void)
```

### Faucet
```swift
public func faucet(_ address: String)
```

### Transfer sui object
```swift
public func transferObject(
        _ objectId: String,
        _ receiver: String,
        _ gasBudget: Int = 100,
        _ amount: Int? = nil,
        _ listener: @escaping (JSON?) -> Void
    )
```

### Execute signed transaction
```swift
public func executeTransaction(
        _ txBytes: Data,
        _ signedBytes: Data,
        _ pubKey: Data,
        _ listener: @escaping (JSON?) -> Void
    )
```
