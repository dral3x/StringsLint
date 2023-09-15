Pod::Spec.new do |s|
  s.name           = 'StringsLint'
  s.version        = `make get_version`
  s.summary        = 'A tool to ensure localized strings are complete and never unused.'
  s.homepage       = 'https://github.com/dral3x/StringsLint'
  s.license        = { :type => 'MIT', :file => 'LICENSE' }
  s.author         = { 'Alessandro Calzavara' => 'alessandro.calzavara@gmail.com' }
  s.source         = { :http => "#{s.homepage}/releases/download/#{s.version}/portable_stringslint.zip" }
  s.preserve_paths = '*'
  s.exclude_files  = '**/file.zip'
  s.ios.deployment_target     = '11.0'
  s.macos.deployment_target   = '10.13'
  s.tvos.deployment_target    = '11.0'
  s.watchos.deployment_target = '7.0'
end