module MemoColor
  def border_styles
    return unless color.present?

    "box-shadow: 0 0 0.5rem 0.5rem rgba(#{rgb.join(',')}, 0.5); border: 0.25rem solid rgba(#{rgb.join(',')}, 0.8);"
  end

  private

  def rgb
    [r, g, b]
  end

  def r = color[0..1].to_i(16)
  def g = color[2..3].to_i(16)
  def b = color[4..5].to_i(16)
end
