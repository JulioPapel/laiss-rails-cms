class AddUniqueIndexToPictureDescriptions < ActiveRecord::Migration[7.2]
  disable_ddl_transaction! if connection.adapter_name.match?(/postgres/i)

  def change
    add_index :laiss_cms_picture_descriptions, [:picture_id, :language_id],
      name: "laiss_cms_picture_descriptions_on_picture_id_and_language_id",
      unique: true, algorithm: algorithm
  end

  private

  def algorithm
    connection.adapter_name.match?(/postgres/i) ? :concurrently : nil
  end
end
