
Pod::Spec.new do |s|

s.name         = "DropMenuBar"
s.version      = "1.0.1"
s.summary      = "A iOS Area multilevel list filtering"
s.description  = "A iOS Area multilevel list filtering, easy to use it."
s.homepage     = "https://github.com/xiaocaoge/DropMenuBarExample.git"
s.license      = "MIT"
s.author             = { "thomas_cao" => "thomas_cao@foxmail.com" }
s.source       = { :git => "https://github.com/xiaocaoge/DropMenuBarExample.git", :tag => "#{s.version}" }
s.source_files  = "DropMenuBar/DropMenu/*.{h,m}"


s.requires_arc  = true
s.platform     = :ios, "9.0"



end
