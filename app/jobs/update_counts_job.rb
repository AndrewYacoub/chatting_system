class UpdateCountsJob < ApplicationJob
    queue_as :default
  
    def perform
      Application.find_each do |application|
        Application.reset_counters(application.id, :chats)
      end
  
      Chat.find_each do |chat|
        Chat.reset_counters(chat.id, :messages)
      end
    end
  end