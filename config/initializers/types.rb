ActiveSupport.on_load(:active_record) do
  ActiveRecord::Type.register(:color_type, ColorType)
end
