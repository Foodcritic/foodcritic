rule "FC090", "Ensure supports metadata defines valid version format(x.y.z or x.y)" do
  tags %w{metadata correctness supermarket}
  metadata do |ast, filename|
    matches = false
    # matches a version method with a string literal with no interpolation
    metadata_platforms_versions = supported_platforms(ast).map { |x| x[:versions] }
    metadata_platforms_versions.each do |plat_vers|
      break if matches # we found one on the previous run so stop looking
      modified_plat_vers = plat_vers.to_s.gsub(/[\"\[<>=~\] ]/,'')
      if (plat_vers && !plat_vers.empty?) && (modified_plat_vers !~ /\A\d+\.\d+(\.\d+)?\z/)
        matches = true
        break # stop looking
      end
    end
    [file_match(filename)] if matches
  end
end
