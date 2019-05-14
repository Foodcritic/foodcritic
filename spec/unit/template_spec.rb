require "spec_helper"

describe FoodCritic::Template::ExpressionExtractor do
  let(:extractor) { FoodCritic::Template::ExpressionExtractor.new }
  describe "#expressions" do
    it "returns empty if the template is empty" do
      expect(extractor.extract("")).to be_empty
    end
    it "returns empty if the template contains no erb at all" do
      expect(extractor.extract(%q{
        Hello World!
      })).to be_empty
    end
    it "returns erb conditionals" do
      expect(extractor.extract(%q{
        <% if true %>
          Hello World!
        <% end %>
      })).to eq [{ type: :statement, code: "if true", line: 2 },
                 { type: :statement, code: "end", line: 4 }]
    end
    it "does not evaluate erb statements" do
      extractor.extract(%q{
        <% raise 'Should not have been evaluated' %>
      })
    end
    it "extracts an expression from within the template" do
      expect(extractor.extract(%q{
        <%= foo %>
      })).to eq [{ type: :expression, code: "foo", line: 2 }]
    end
    it "does not evaluate erb expressions" do
      extractor.extract(%q{
        <%= raise 'Should not have been evaluated' %>
      })
    end
    it "extracts multiple expressions" do
      expect(extractor.extract(%q{
        <Connector port="<%= node["tomcat"]["port"] %>" protocol="HTTP/1.1"
                   connectionTimeout="20000"
                   URIEncoding="UTF-8"
                   redirectPort="<%= node["tomcat"]["ssl_port"] %>" />
      })).to eq [
        { type: :expression, code: 'node["tomcat"]["port"]', line: 2 },
        { type: :expression, code: 'node["tomcat"]["ssl_port"]', line: 5 },
      ]
    end
    it "excludes comment-only expressions" do
      expect(extractor.extract("<%# A comment %>")).to be_empty
    end
  end

end
