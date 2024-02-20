class AddShortContentLengthAndMediumContentLengthToUtility < ActiveRecord::Migration[6.1]
  def change
    add_column :utilities, :short_content_length, :integer, default: 50
    add_column :utilities, :medium_content_length, :integer, default: 100
  end
end
