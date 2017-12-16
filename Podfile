# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
use_frameworks!


target 'RushMe' do
  pod 'iCalKit', :git => 'https://github.com/kiliankoe/iCalKit.git'
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks

  pod 'OHMySQL'
  
  pod 'Firebase'
  pod 'Firebase/Auth'
  pod 'Firebase/Messaging'
  pod 'Firebase/Database'

#pod 'Atlas'
#   pod 'Chatto', '>= 3.2.0'
#   pod 'ChattoAdditions', '>= 3.2.0'

  # Pods for RushMe
  target 'RushMeTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'RushMeUITests' do
    inherit! :complete
    # Pods for testing
  end

end
