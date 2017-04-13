rule "FC078", "Ensure cookbook shared under an OSI-approved open source license" do
  tags %w{opensource}
  metadata do |ast, filename|
    begin
      license = ast.xpath(%Q{//command[ident/@value='license']/
                            descendant::tstring_content}).attribute("value").to_s

      # list of valid SPDX.org license strings. To build an array run this:
      # require 'json'
      # require 'net/http'
      # json_data = JSON.parse(Net::HTTP.get(URI('https://raw.githubusercontent.com/spdx/license-list-data/master/json/licenses.json')))
      # licenses = json_data['licenses']
      #  .select { |license| license['isOsiApproved'] }
      #  .map {|l| l['licenseId'] }
      #
      osi_approved_licenses = %w{
        AFL-1.1
        AFL-1.2
        AFL-2.0
        AFL-2.1
        AFL-3.0
        APL-1.0
        Apache-1.1
        Apache-2.0
        APSL-1.0
        APSL-1.1
        APSL-1.2
        APSL-2.0
        Artistic-1.0
        Artistic-1.0-Perl
        Artistic-1.0-cl8
        Artistic-2.0
        AAL
        BSL-1.0
        BSD-2-Clause
        BSD-3-Clause
        0BSD
        CECILL-2.1
        CNRI-Python
        CDDL-1.0
        CPAL-1.0
        CPL-1.0
        CATOSL-1.1
        CUA-OPL-1.0
        EPL-1.0
        ECL-1.0
        ECL-2.0
        EFL-1.0
        EFL-2.0
        Entessa
        EUDatagrid
        EUPL-1.1
        Fair
        Frameworx-1.0
        AGPL-3.0
        GPL-2.0
        GPL-3.0
        LGPL-2.1
        LGPL-3.0
        LGPL-2.0
        HPND
        IPL-1.0
        Intel
        IPA
        ISC
        LPPL-1.3c
        LiLiQ-P-1.1
        LiLiQ-Rplus-1.1
        LiLiQ-R-1.1
        LPL-1.02
        LPL-1.0
        MS-PL
        MS-RL
        MirOS
        MIT
        Motosoto
        MPL-1.0
        MPL-1.1
        MPL-2.0
        MPL-2.0-no-copyleft-exception
        Multics
        NASA-1.3
        Naumen
        NGPL
        Nokia
        NPOSL-3.0
        NTP
        OCLC-2.0
        OGTSL
        OSL-1.0
        OSL-2.0
        OSL-2.1
        OSL-3.0
        OSET-PL-2.1
        PHP-3.0
        PostgreSQL
        Python-2.0
        QPL-1.0
        RPSL-1.0
        RPL-1.1
        RPL-1.5
        RSCPL
        OFL-1.1
        SimPL-2.0
        Sleepycat
        SISSL
        SPL-1.0
        Watcom-1.0
        UPL-1.0
        NCSA
        VSL-1.0
        W3C
        Xnet
        Zlib
        ZPL-2.0
        GPL-2.0+
        GPL-2.0-with-autoconf-exception
        GPL-2.0-with-bison-exception
        GPL-2.0-with-classpath-exception
        GPL-2.0-with-font-exception
        GPL-2.0-with-GCC-exception
        GPL-3.0+
        GPL-3.0-with-autoconf-exception
        GPL-3.0-with-GCC-exception
        LGPL-2.1+
        LGPL-3.0+
        LGPL-2.0+
        WXwindows
      }
      [file_match(filename)] unless osi_approved_licenses.include?(license)
    rescue NoMethodError # no license in the metadata
      [file_match(filename)]
    end
  end
end
