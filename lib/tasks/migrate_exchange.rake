namespace :conversations do
  desc 'Migrates storing conversation history on the conversations.exchanges jsonb column '\
       'to each generate_text_requests record'
  task migrate_exchange: :environment do
    Conversation.find_each do |conversation|
      requests = conversation.generate_text_requests.order(:created_at)
      conversation.read_attribute(:exchange).select { |e| e['role'] == 'assistant' }
                  .each_with_index do |exchange, i|
        next if requests[i].response.present?

        requests[i].response = {
          'id' => "migrated_#{Time.current}",
          'type' => 'message',
          'role' => 'assistant',
          'content' => [{
            'type' => 'text',
            'text' => exchange['content']
          }],
          'model' => 'unknown:migrated',
          'stop_reason' => 'end_turn',
          'stop_sequence' => nil,
          'usage' => {
            'input_tokens' => 0, 'output_tokens' => 0
          }
        }
        if requests[i].save
          puts "Updated generate_text_request: #{requests[i].id}, conversation: #{conversation.id}"
        else
          puts "Something went wrong for conversation: #{conversation.id}"
        end
      end
    end
  end
end
