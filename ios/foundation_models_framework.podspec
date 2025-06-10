Pod::Spec.new do |s|
  s.name             = 'foundation_models_framework'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for integrating with Apple\'s Foundation Models framework.'
  s.description      = <<-DESC
A Flutter plugin that provides access to Apple's Foundation Models framework for on-device AI capabilities including text summarization and embedding generation.
                       DESC
  s.homepage         = 'https://github.com/your-username/foundation_models_framework'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '26.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # Foundation Models framework is available in iOS 26.0+ Beta
  s.weak_frameworks = 'FoundationModels'
end 