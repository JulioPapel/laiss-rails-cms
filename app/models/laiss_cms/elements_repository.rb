# frozen_string_literal: true

module LaissCms
  # Mimics ActiveRecord query interface
  # but does this on the preloaded elements
  class ElementsRepository
    include Enumerable

    # An empty set of elements
    def self.none
      new([])
    end

    # @param [ActiveRecord::Relation]
    def initialize(elements)
      @elements = elements.to_a
    end

    # All visible elements
    # @return [LaissCms::ElementRepository]
    def visible
      self.class.new select(&:public)
    end

    # All publishable elements
    # @return [LaissCms::ElementRepository]
    def publishable
      self.class.new select(&:publishable?)
    end

    # All not fixed elements
    # @return [LaissCms::ElementRepository]
    def hidden
      self.class.new reject(&:public)
    end

    # All elements with given name(s)
    # @param [Array<String|Symbol>|String|Symbol]
    # @return [LaissCms::ElementRepository]
    def named(*names)
      names.flatten!
      self.class.new(select { |e| e.name.in?(names.map!(&:to_s)) })
    end

    # Filter elements by given attribute and value
    # @param [Array|Hash]
    # @return [LaissCms::ElementRepository]
    def where(attrs)
      self.class.new(
        select do |element|
          attrs.all? do |attr, value|
            element.public_send(attr) == value
          end
        end
      )
    end

    # All elements excluding those wth given name(s)
    # @param [Array<String|Symbol>|String|Symbol]
    # @return [LaissCms::ElementRepository]
    def excluded(*names)
      names.flatten!
      self.class.new(reject { |e| e.name.in?(names.map!(&:to_s)) })
    end

    # All fixed elements
    # @return [LaissCms::ElementRepository]
    def fixed
      self.class.new select(&:fixed)
    end

    # All not fixed elements
    # @return [LaissCms::ElementRepository]
    def unfixed
      self.class.new reject(&:fixed)
    end

    # All folded elements
    # @return [LaissCms::ElementRepository]
    def folded
      self.class.new select(&:folded)
    end

    # All expanded elements
    # @return [LaissCms::ElementRepository]
    def expanded
      self.class.new reject(&:folded)
    end

    # All not nested top level elements
    # @return [LaissCms::ElementRepository]
    def not_nested
      self.class.new(select { |e| e.parent_element_id.nil? })
    end

    # Elements in reversed order
    # @return [LaissCms::ElementRepository]
    def reverse
      self.class.new elements.reverse
    end

    # Elements in random order
    # @return [LaissCms::ElementRepository]
    def random
      self.class.new Array(elements).shuffle
    end

    # Elements off setted by
    # @return [LaissCms::ElementRepository]
    def offset(offset)
      self.class.new elements[offset.to_i..]
    end

    # Elements limitted by
    # @return [LaissCms::ElementRepository]
    def limit(limit)
      self.class.new elements[0..(limit.to_i - 1)]
    end

    def children_of(parent)
      self.class.new(select { |e| e.parent_element_id == parent.id })
    end

    def each(&)
      elements.each(&)
    end

    # Allows the repository to be passed to the ActionView collection renderer
    # (+render repository+), which detects a collection by +to_ary+.
    def to_ary
      elements
    end

    def size
      elements.size
    end
    alias_method :length, :size

    private

    attr_reader :elements
  end
end
