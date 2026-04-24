module QuantityParser
  module_function

  # Parses "1 taza", "1/2 taza", "100g", "200 gr", etc. into [number, unit].
  # Returns [nil, nil] for blank input and [nil, original] when unparseable.
  def parse(str)
    return [nil, nil] if str.blank?
    m = str.to_s.strip.match(/\A([\d.,]+(?:\/\d+)?)\s*(.*)\z/)
    return [nil, str.to_s.strip] unless m

    number = parse_number(m[1])
    return [nil, str.to_s.strip] if number.nil?

    unit = m[2].to_s.strip.downcase
    [number, unit]
  end

  # Aggregates an array of quantity strings. Groups numeric entries by unit
  # and sums them; unparseable entries are appended verbatim with " + ".
  def aggregate(quantities)
    parseable = []
    freeform  = []

    quantities.each do |q|
      next if q.blank?
      num, unit = parse(q)
      if num
        parseable << [num, unit]
      else
        freeform << q.to_s.strip
      end
    end

    summed =
      parseable
        .group_by { |_, unit| unit }
        .map { |unit, arr|
          total = arr.sum { |n, _| n }
          format_part(total, unit)
        }

    (summed + freeform).join(" + ")
  end

  def format_part(number, unit)
    num = format_number(number)
    unit.empty? ? num : "#{num} #{unit}"
  end

  def format_number(n)
    rounded = n.round(3)
    rounded == rounded.to_i ? rounded.to_i.to_s : rounded.to_s
  end

  def parse_number(str)
    if str.include?("/")
      num, den = str.split("/", 2).map { |s| Float(s, exception: false) }
      return nil if num.nil? || den.nil? || den.zero?
      num / den
    else
      Float(str.tr(",", "."), exception: false)
    end
  end
end
