def windows?
  !! RUBY_PLATFORM =~ /mswin|mingw|windows/
end

def has_windows_rights?(version)
  Gem::Version.new(version) >= Gem::Version.new('0.10.10')
end
