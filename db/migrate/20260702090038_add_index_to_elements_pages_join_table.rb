class AddIndexToElementsPagesJoinTable < ActiveRecord::Migration[7.2]
  disable_ddl_transaction! if connection.adapter_name.match?(/postgres/i)

  def change
    add_index :laiss_cms_elements_laiss_cms_pages, :element_id, if_not_exists: true, algorithm: algorithm
    add_index :laiss_cms_elements_laiss_cms_pages, :page_id, if_not_exists: true, algorithm: algorithm
  end

  private

  def algorithm
    connection.adapter_name.match?(/postgres/i) ? :concurrently : nil
  end
end
