module GildedRose
  module QualityDSL
    DEFAULT_MIN = 0
    DEFAULT_MAX = 50

    def clamp(f, min = DEFAULT_MIN, max = DEFAULT_MAX)
      ->(i) do
        result = f.(i)
        return min if result < min
        return max if result > max
        result
      end
    end

    def constant
      :itself.to_proc
    end

    def minus(n)
      plus(-n)
    end

    def minus_clamp(n, min = DEFAULT_MIN, max = DEFAULT_MAX)
      plus_clamp(-n)
    end

    def plus(n)
      ->(i) { i + n }
    end

    def plus_clamp(n, min = DEFAULT_MIN, max = DEFAULT_MAX)
      clamp(plus(n))
    end

    def set(n)
      ->(_) { n }
    end

    def tag?(s)
      -> (item) do
        if item.name =~ /\ABackstage passes to/
          return s == 'Backstage passes'
        end
        item.name =~ /\A#{Regexp.escape(s)}/
      end
    end
  end
end
