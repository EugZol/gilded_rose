require_relative 'quality_dsl'

module GildedRose
  class Collection
    extend QualityDSL

    QUALITIES = [
      # Order matters in the array and in the internal hashes
      # Each hash represents mutually exclusive set of qualities
      {
        legendary: tag?('Sulfuras'),
        noble: tag?('Aged Brie'),
        conjured: tag?('Conjured'),
        backstage_pass: tag?('Backstage passes'),
        ordinary: set(true)
      },
      {
        expired: -> (item) { item.sell_in <= 0 },
        good: -> (item) { item.sell_in > 0 }
      },
      {
        very_hot: -> (item) { item.sell_in <= 5 },
        hot: -> (item) { item.sell_in <= 10},
        cold: set(true)
      },
    ]

    # Keys: qualities, nested in the order defined in QUALITIES
    # End value: if single proc, then procedure which receives quality
    #            and returns quality;
    #            if array with two values, then first one is quality
    #            update procedure, second one sells-in update procedure
    UPDATE = {
      legendary: [set(80), constant],
      noble: {
        expired: plus_clamp(2),
        good: plus_clamp(1)
      },
      conjured: {
        expired: minus_clamp(4),
        good: minus_clamp(2)
      },
      backstage_pass: {
        expired: set(0),
        good: {
          very_hot: plus_clamp(3),
          hot: plus_clamp(2),
          cold: plus_clamp(1)
        }
      },
      ordinary: {
        expired: minus_clamp(2),
        good: minus_clamp(1)
      }
    }

    def initialize(items)
      @items = items
    end

    def qualities_of(item)
      QUALITIES.map do |quality_set|
        result = quality_set.find { |quality, criteria| criteria.(item) }
        if result.nil?
          raise RuntimeError.new("Not a single quality from #{quality_set.keys.inspect} selected for #{item.inspect}")
        end
        result[0]
      end
    end

    def update_quality
      @items.zip(@items.map(&method(:qualities_of))).each do |item, qualities|
        q_update, sell_in_update = Array(update_procedure_for(qualities))
        item.quality = q_update.(item.quality)
        item.sell_in = (sell_in_update || self.class.minus(1)).(item.sell_in)
      end
    end

    private

    def update_procedure_for(qualities)
      qualities.length.downto(1).each do |l|
        keys =
          qualities.combination(l).
            find do |keys|
              UPDATE.dig(*keys)
            rescue TypeError
              false
            end
        return UPDATE.dig(*keys) if keys
      end

      raise NameError.new("Can't find method for the set of qualities #{qualities.inspect}")
    end
  end
end
