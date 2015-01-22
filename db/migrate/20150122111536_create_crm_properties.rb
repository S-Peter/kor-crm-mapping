class CreateCrmProperties < ActiveRecord::Migration
  def change
    create_table :crm_properties do |t|

      t.timestamps
    end
  end
end
