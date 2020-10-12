Pod::Spec.new do |s|
  s.name             = 'TrustSDK'
  s.version          = '1.2.5'
  s.summary          = 'Trust Wallet SDK'
  s.homepage         = 'https://github.com/TrustWallet/TrustSDK-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.authors          = { 'Leone Parise' => 'leoneparise', 'Viktor Radchenko' => 'vikmeup' }
  s.source           = { :git => 'https://github.com/TrustWallet/TrustSDK-iOS.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.7'
  s.swift_version = '~>5.1'
  s.default_subspec = 'Client'

  s.subspec 'Client' do |cs|
    cs.resource_bundles = { 
      'TrustSDK' => ['TrustSDK/Resources/**/*.xcassets', 'TrustSDK/Resources/**/*.strings']
    }
    cs.source_files = 'TrustSDK/Classes/Client/**/*'
    cs.dependency 'TrustWalletCore/Types'
    cs.dependency 'BigInt'
  end

  s.subspec 'Wallet' do |cs|
    cs.source_files = 'TrustSDK/Classes/Wallet/**/*'
    cs.dependency 'TrustSDK/Client'
  end
end
