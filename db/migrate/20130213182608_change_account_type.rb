class ChangeAccountType < ActiveRecord::Migration
  def change
    change_column :mail_models, :account, :string
  end
end
