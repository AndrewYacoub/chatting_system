class UpdateCountsWorker
    include Sidekiq::Worker
  
    def perform
      Application.find_each do |application|
        application.update(chats_count: application.chats.count)
      end
  
      Chat.find_each do |chat|
        chat.update(messages_count: chat.messages.count)
      end
    end
  end