class AddHeaderCtaEnabledToPageSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :page_settings, :header_cta_enabled, :boolean, default: true
  end
end
