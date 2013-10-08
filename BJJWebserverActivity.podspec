Pod::Spec.new do |s|
  s.name                  = "BJWebserverActivity"
  s.version               = "0.0.1"
  s.summary               = "UIActivity subclass to share via a webserver."
  s.homepage              = "https://github.com/marianoabdala/ZYActivity"
  s.license               = { :type => 'MIT', :file => 'README.md' }
  s.author                = { "Barrett Jacobsen" => "admin@barrettj.com" }
  s.source                = { :git => "https://github.com/marianoabdala/ZYActivity.git", :tag => s.version.to_s }
  s.platform              = :ios
  s.ios.deployment_target = '5.0'
  s.source_files          = 'BJWebserverActivity/*'
  s.dependency			  = 'CocoaHTTPServer'
  s.requires_arc          = true
end
