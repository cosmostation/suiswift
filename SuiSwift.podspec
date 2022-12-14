Pod::Spec.new do |s|
  s.name = 'SuiSwift'
  s.version = '0.0.1'
  s.license = 'MIT'
  s.summary = 'Sui iOS SDK'
  s.homepage = 'https://github.com/cosmostation/suiswift'
  s.authors = { 'Cosmostation' => 'support@cosmostation.io' }
  s.source = { :git => 'https://github.com/cosmostation/suiswift.git', :tag => s.version }
  s.documentation_url = 'https://github.com/cosmostation/suiswift.git'

  s.ios.deployment_target = '13.0'

  s.swift_versions = ['5']

  s.source_files = 'Source/*.swift'

  s.dependency 'Alamofire'
  s.dependency 'SwiftyJSON'
  s.dependency 'web3swift'
  s.dependency 'ed25519swift'
end
