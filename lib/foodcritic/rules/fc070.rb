rule "FC070", "Ensure supports metadata defines valid platforms" do
  tags %w{metadata supermarket}
  metadata do |ast, filename|
    # Where did this come from? We pulled every unique platform for supermarket cookbooks
    # and then looked at all the invalid names. Lots of typos and bad characters and then
    # a few entirely made up platforms
    bad_chars = [" ", "'", ",", "\"", "/", "]", "[", "{", "}", "-", "=", ">"]
    invalid_platforms = %w{
      aws
      archlinux
      amazonlinux
      darwin
      debian
      mingw32
      mswin
      mac_os_x_server
      linux
      oel
      oraclelinux
      rhel
      schientific
      scientificlinux
      sles
      solaris
      true
      ubundu
      ubunth
      ubunutu
      windwos
      xcp
    }
    matches = false

    metadata_platforms = supported_platforms(ast).map { |x| x[:platform] }

    metadata_platforms.each do |plat|
      break if matches # we found one on the previous run so stop looking

      # see if the platform is uppercase, which is invalid
      unless plat.scan(/[A-Z]/).empty?
        matches = true
        break # stop looking
      end

      # search for platform strings with bad strings in them
      # these can't possibly be valid platforms
      bad_chars.each do |char|
        unless plat.scan(char).empty?
          matches = true
          break # stop looking
        end
      end

      # see if the platform is a commonly mistaken platform string
      if invalid_platforms.include?(plat)
        matches = true
        break # stop looking
      end
    end

    [file_match(filename)] if matches
  end
end
