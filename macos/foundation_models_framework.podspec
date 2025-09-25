Pod::Spec.new do |s|
  s.name             = 'foundation_models_framework'
  s.version          = '0.1.0'
  s.summary          = 'A Flutter plugin for integrating with Apple\'s Foundation Models framework.'
  s.description      = <<-DESC
A Flutter plugin that provides access to Apple's Foundation Models framework for on-device AI capabilities including session-based language model interactions.
                       DESC
  s.homepage         = 'https://github.com/dmakwt/flutter_foundation_models_framework'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  s.source           = { :path => '.' }
  s.source_files     = '../ios/Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '15.0'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES'
  }
  s.swift_version = '5.0'

  s.weak_frameworks = 'FoundationModels'
end
