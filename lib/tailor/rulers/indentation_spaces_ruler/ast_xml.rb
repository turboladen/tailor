class Tailor
  module Rulers
    class IndentationSpacesRuler < Tailor::Ruler

      # XXX: Reproducing the ast querying functions from foodcritic here. We
      # either need to re-implement the queries not to rely on these functions
      # or extract these functions to a shared gem.
      module AstXml

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

        def ast_hash_node?(node)
          node.first.respond_to?(:first) and node.first.first == :assoc_new
        end

        def ast_node_has_children?(node)
          node.respond_to?(:first) and ! node.respond_to?(:match)
        end

        # If the provided node is the line / column information.
        def position_node?(node)
          node.respond_to?(:length) and node.length == 2 and
          node.respond_to?(:all?) and node.all? do |child|
            child.respond_to?(:to_i)
          end
        end

        def build_xml(node, doc = nil, xml_node=nil)
          doc, xml_node = xml_document(doc, xml_node)

          if node.respond_to?(:each)
            # First child is the node name
            node.drop(1) if node.first.is_a?(Symbol)
            node.each do |child|
              if position_node?(child)
                xml_position_node(doc, xml_node, child)
              else
                if ast_node_has_children?(child)
                  # The AST structure is different for hashes so we have to treat
                  # them separately.
                  if ast_hash_node?(child)
                    xml_hash_node(doc, xml_node, child)
                  else
                    xml_array_node(doc, xml_node, child)
                  end
                else
                  xml_node['value'] = child.to_s unless child.nil?
                end
              end
            end
          end
          xml_node
        end

      end
    end
  end
end
