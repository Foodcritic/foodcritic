rule "FC024", "Consider adding platform equivalents" do
  tags %w{portability}
  RHEL = %w{centos redhat scientific oracle}.freeze
  recipe do |ast, filename|
    next if Pathname.new(filename).basename.to_s == "metadata.rb"
    metadata_path = Pathname.new(
      File.join(File.dirname(filename), "..", "metadata.rb")).cleanpath
    md_platforms = if File.exist?(metadata_path)
                     supported_platforms(read_ast(
                       metadata_path)).map { |p| p[:platform] }
                   else
                     []
                   end
    md_platforms = RHEL if md_platforms.empty?

    ['//method_add_arg[fcall/ident/@value="platform?"]/
      arg_paren/args_add_block',
     "//when"].map do |expr|
      ast.xpath(expr).map do |whn|
        platforms = whn.xpath('args_add/
                               descendant::tstring_content').map do |p|
          p["value"]
        end.sort
        unless platforms.size == 1 || (md_platforms & platforms).empty?
          whn unless (platforms & RHEL).empty? ||
              ((md_platforms & RHEL) - (platforms & RHEL)).empty?
        end
      end.compact
    end.flatten
  end
end
