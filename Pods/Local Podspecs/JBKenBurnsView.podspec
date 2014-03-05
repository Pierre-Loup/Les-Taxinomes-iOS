Pod::Spec.new do |s|
  s.name     = 'JBKenBurnsView'
  s.version  = '0.4'
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.summary  = 'UIView that can generate a Ken Burns transition.'
  s.framework = 'QuartzCore'
  s.homepage = 'https://github.com/jberlana/iOSKenBurns'
  s.author   = { 'Javier Berlana' => 'jberlana@gmail.com' }
  s.source   = { :git => 'https://github.com/Pierre-Loup/JBKenBurns.git', :tag => '0.4' }
  s.platform = :ios
  s.ios.deployment_target = '6.0'
  s.source_files = 'KenBurns/*.{h,m}'
  s.requires_arc = true
end
