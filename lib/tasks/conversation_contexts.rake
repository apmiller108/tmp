# lib/tasks/conversation_contexts.rake
namespace :db do
  desc 'Seeds 100 ConversationContext records for a given user_id'
  task :seed_conversation_contexts, [:user_id] => :environment do |_t, args|
    user_id = args[:user_id]
    if user_id.blank?
      puts 'Usage: rake db:seed_conversation_contexts[user_id]'
      exit 1
    end

    user = User.find_by(id: user_id)
    unless user
      puts "Error: User with ID #{user_id} not found."
      exit 1
    end

    puts "Seeding 100 ConversationContext records for user ID: #{user_id}..."

    100.times do |i|
      ConversationContext.create!(
        user:,
        file_ref: "seeded_file_#{i + 1}",
        filename: "seeded_file_#{i + 1}.txt",
        mime_type: 'text/plain',
        context_type: :file
      )
    end

    puts 'Successfully seeded 100 ConversationContext records.'
  end
end
