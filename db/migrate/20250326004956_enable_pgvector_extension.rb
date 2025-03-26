class EnablePgvectorExtension < ActiveRecord::Migration[8.0]
  def up
    ActiveRecord::Base.connection.execute 'CREATE EXTENSION IF NOT EXISTS vector'
  end

  def down
    ActiveRecord::Base.connection.execute 'DROP EXTENSION IF EXISTS vector'
  end
end
