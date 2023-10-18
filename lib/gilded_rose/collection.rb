module GildedRose
  class Collection
    def initialize(items)
      @items = items
    end

    def update_quality
      @items.each { update_item(_1) }
    end

    private

    def update_item(item)
      return if item.name =~ /Sulfuras/

      score = -1

      score *= -1 if item.name =~ /Aged Brie/ || item.name =~ /Backstage/
      score *= 2 if item.name =~ /Conjured/

      if item.name =~ /Backstage/
        score *=
          if item.sell_in <= 0
            -50
          elsif item.sell_in <= 5
            3
          elsif item.sell_in <= 10
            2
          else
            1
          end
      else
        score *= 2 if item.sell_in <= 0
      end

      item.quality += score
      item.quality = 50 if item.quality > 50
      item.quality = 0 if item.quality < 0
      item.sell_in -= 1
    end
  end
end
