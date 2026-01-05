class AddVendorToConversationContexts < ActiveRecord::Migration[8.0]
  def change
    add_column :conversation_contexts, :vendor, :string
  end
end
