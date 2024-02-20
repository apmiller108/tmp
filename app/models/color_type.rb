class ColorType < ActiveRecord::Type::String
  DEFAULT = 'e4f2fe'.freeze

  attr_reader :hex

  def initialize(hex = nil)
    @hex = hex.presence || DEFAULT
  end

  def serialize(value)
    if value.is_a?(ColorType)
      value.hex
    else
      value
    end
  end

  def cast(value)
    if value.is_a?(ColorType)
      super(value.hex)
    else
      super(value)
    end
  end

  def deserialize(value)
    self.class.new(value)
  end

  def to_rgb
    [r, g, b]
  end

  def r = hex[0..1].to_i(16)
  def g = hex[2..3].to_i(16)
  def b = hex[4..5].to_i(16)

  def darkish?
    to_rgb.sum < (255 * 3) / 3.6
  end

  def default?
    hex == DEFAULT
  end
end
