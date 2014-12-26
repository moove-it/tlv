module TLV
  Node = Struct.new(:tag, :description, :length, :value, :children) do

    def initialize(attrs = {})
      super()

      self.children = attrs[:children] || []
    end

    def [](tag)
      tag = tag.upcase

      children.find { |child| child.tag.upcase == tag }
    end

    def hex_value
      return '' unless value

      result = value.unpack("H*")[0]
      if result.length > 1
        result
      else
        '  '
      end
    end

    def extract(tags = [])
      tags = Array(tags).map(&:upcase)
      extracted = children.select { |child| tags.include?(child.tag.upcase) }

      extracted_tags = extracted.map(&:tag).map(&:upcase)

      not_found_tags = tags - extracted_tags
      if not_found_tags.any?
        warn "Some tags could not be found in the children tlv: #{not_found_tags.join(', ')}"
      end

      TLV::Root.new({ children: extracted })
    end

    def generate
      return tag unless length

      result = "#{tag}#{"%02x" % [length]}"

      if self.children.any?
        children.each { |child| result.concat(child.generate) }
      elsif value
        result.concat(value.unpack("H*").first)
      end

      result
    end

    def pretty_print(indentation_level = nil)
      if self.children.any?
        puts "#{indentation_level}#{tag}:\t#{length}"

        self.children.each do |child|
          child.pretty_print("#{indentation_level}\t")
        end
      else
        pretty_value = if value
                          value.unpack("H*").first
                        end

        puts "#{indentation_level}#{tag}\t:#{length}\t:#{pretty_value}"
      end
    end

  end
end