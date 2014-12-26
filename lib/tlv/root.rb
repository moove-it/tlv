module TLV
  Root = Struct.new(:children) do

    def initialize(attrs = {})
      super()

      self.children = attrs[:children] || []
    end

    def [](tag)
      tag = tag.upcase

      children.find { |child| child.tag.upcase == tag }
    end

    def generate
      result = ''

      children.each { |child| result.concat(child.generate) }

      result
    end

    def pretty_print
      children.each { |child| child.pretty_print }
    end

  end
end