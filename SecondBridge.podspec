Pod::Spec.new do |s|
  s.name        = "SecondBridge"
  s.version     = "1.0"
  s.summary     = "SecondBridge is a Swift library for functional programming."
  s.homepage    = "http://47deg.github.io/second-bridge/"
  s.license     = { :type => "Apache License, Version 2.0" }
  s.authors     = { "47 Degrees, LLC"  => "hola@47deg.com" }
  s.requires_arc = true
  s.ios.deployment_target = "8.0"
  s.source   = { :git => "https://github.com/47deg/second-bridge.git", :tag => "v#{s.version}"}
  s.source_files = "SecondBridge/SecondBridge/**/*.swift"
  s.dependency 'Swiftz'
end