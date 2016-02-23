module Gyroscope
  class IntegerList < Virtus::Attribute
    strict true
    required false

    def coerce(values)
      return nil if values.nil?

      attr = Virtus::Attribute.build Integer, strict: true
      Array(values).
        map {|value| value.respond_to?(:split) ? value.split(',') : value }.
        flatten.
        map { |v| attr.coerce(v) }
    end
  end
end
