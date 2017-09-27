rule "FC045", "Metadata does not contain cookbook name" do
  tags %w{correctness metadata chef12}
  cookbook do |filename|
    [file_match(filename)] unless metadata_field(filename, "name", { fail_on_nonexist: false })
  end
end
