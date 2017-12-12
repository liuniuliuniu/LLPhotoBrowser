Pod::Spec.new do |s|
s.name         = "LLPhotoBrowser"
s.version      = "0.0.3"
s.summary      = "LLPhotoBrowser."
s.description  = "LLPhotoBrowser.liushaohua"
s.homepage     = "https://github.com/liuniuliuniu/LLPhotoBrowser"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author             = { "liuniuliuniu" => "416997919@qq.com" }
s.source       = { :git => "https://github.com/liuniuliuniu/LLPhotoBrowser.git", :tag => "#{s.version}" }
s.ios.deployment_target = "8.0"
s.source_files  = "LLPhotoBrowser", "LLPhotoBrowser/**/*.{h,m}"
s.requires_arc = true
s.dependency "SDWebImage"
end
