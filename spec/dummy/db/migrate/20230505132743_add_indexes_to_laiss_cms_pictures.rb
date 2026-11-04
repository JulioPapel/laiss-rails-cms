class AddIndexesToLaissCmsPictures < ActiveRecord::Migration[7.2]
  def change
    add_index :laiss_cms_pictures, :name, if_not_exists: true
    add_index :laiss_cms_pictures, :image_file_name, if_not_exists: true
  end
end
