class AddOptionsToGenerateImageRequest < ActiveRecord::Migration[7.1]
  def up
    add_column :generate_image_requests, :options, :jsonb, default: {}

    ActiveRecord::Base.connection.execute(<<~SQL)
      UPDATE generate_image_requests
      SET options = jsonb_build_object(
          'dimensions', dimensions,
          'style', style
      );
    SQL

    remove_column :generate_image_requests, :dimensions
    remove_column :generate_image_requests, :style
  end

  def down
    add_column :generate_image_requests, :dimensions, :string, limit: 25
    add_column :generate_image_requests, :style, :string, limit: 50
    ActiveRecord::Base.connection.execute(<<~SQL)
      UPDATE generate_image_requests
      SET dimensions = options->>'dimensions',
          style = options->>'style';
    SQL
    change_column_null :generate_image_requests, :dimensions, true

    remove_column :generate_image_requests, :options
  end
end
