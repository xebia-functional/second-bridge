Pod::Spec.new do |s|
  s.name        = "SecondBridge"
  s.version     = "0.1"
  s.summary     = "SecondBridge is a Swift library for functional programming."
  s.homepage    = "http://www.47deg.com/"
  s.license     = { :type => "Apache License, Version 2.0" }
  s.authors     = { "47 Degrees, LLC" }
  s.requires_arc = true
  s.ios.deployment_target = "8.0"
  s.source   = { :git => "https://github.com/47deg/second-bridge.git" }
  s.source_files = "SecondBridge/SecondBridge/**/*.swift"
  s.dependency 'Swiftz'
end