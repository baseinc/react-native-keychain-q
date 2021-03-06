require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-keychain-q"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  react-native-keychain-q
                   DESC
  s.homepage     = "https://github.com/baseinc/react-native-keychain-q"
  s.license      = package["license"]
  # s.license    = { :type => "MIT", :file => "FILE_LICENSE" }
  s.authors      = { package["author"]["name"] => package["author"]["email"] }
  s.platforms    = { :ios => "9.0" }
  s.source       = { :git => "https://github.com/baseinc/react-native-keychain-q.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,swift}"
  s.requires_arc = true
  s.swift_version = '5.1'

  s.dependency "React"
  # ...
  # s.dependency "..."
end

