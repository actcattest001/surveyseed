class AddPhoneNumberToLeads < ActiveRecord::Migration
  def change
    add_column :leads, :phone, :string
  end
end
