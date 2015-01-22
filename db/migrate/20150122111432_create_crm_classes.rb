class CreateCrmClasses < ActiveRecord::Migration
  def change
    create_table :crm_classes do |t|

      t.timestamps
    end
  end
end
