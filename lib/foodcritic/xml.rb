module FoodCritic
  module XML
    private

    def xml_array_node(doc, xml_node, child)
      n = xml_create_node(doc, child)
      xml_node.add_child(build_xml(child, doc, n))
    end

    def xml_create_node(doc, c)
      Nokogiri::XML::Node.new(c.first.to_s.gsub(/[^a-z_]/, ''), doc)
    end

    def xml_document(doc, xml_node)
      if doc.nil?
        doc = Nokogiri::XML('<opt></opt>')
        xml_node = doc.root
      end
      [doc, xml_node]
    end

    def xml_hash_node(doc, xml_node, child)
      child.each do |c|
        n = xml_create_node(doc, c)
        c.drop(1).each do |a|
          xml_node.add_child(build_xml(a, doc, n))
        end
      end
    end

    def xml_position_node(doc, xml_node, child)
      pos = Nokogiri::XML::Node.new('pos', doc)
      pos['line'] = child.first.to_s
      pos['column'] = child[1].to_s
      xml_node.add_child(pos)
    end
  end
end
