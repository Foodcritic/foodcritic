rule "FC073", "Root alias file shadowing non-alias file" do
  tags %w{correctness}
  cookbook do |path|
    {
      "attributes.rb" => "default/attributes.rb",
      "recipe.rb" => "recipes/default.rb",
    }.map do |alias_path, folder_path|
      full_alias_path = File.join(path, alias_path)
      full_folder_path = File.join(path, folder_path)
      if File.exist?(full_alias_path) && File.exist?(full_folder_path)
        file_match(full_folder_path)
      else
        nil
      end
    end.compact
  end
end
