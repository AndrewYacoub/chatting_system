class RedisService
    def initialize
      redis_host = ENV.fetch("REDIS_HOST") { 'localhost' }
      redis_port = ENV.fetch("REDIS_PORT") { 6379 }
      @redis = Redis.new(host: redis_host, port: redis_port)
    end
  
    def fetch_cached_application(token)
      cached_application = @redis.get("application:#{token}")
      if cached_application
        Application.find_by(token: token)
      else
        application = Application.find_by(token: token)
        cache_application(application) if application
        application
      end
    end
  
    def fetch_cached_chat(application_token, application_id, chat_number)
      cached_chat = @redis.get("chat:#{application_token}:#{chat_number}")
      if cached_chat
        Chat.find_by(application_id: application_id, number: chat_number)
      else
        chat = Chat.find_by(application_id: application_id, number: chat_number)
        cache_chat(chat) if chat
        chat
      end
    end
  
    def fetch_cached_message(id)
      cached_message = @redis.get("message:#{id}")
      if cached_message
        Message.find_by(id: id)
      else
        message = Message.find_by(id: id)
        cache_message(message) if message
        message
      end
    end
  
    def fetch_cached_applications
      cached_applications = @redis.get("applications")
      if cached_applications
        Application.where(token: JSON.parse(cached_applications).map { |app| app["token"] })
      else
        applications = Application.all
        @redis.set("applications", applications.to_json)
        applications
      end
    end
  
    def fetch_cached_chats(application_token, application_id)
      cached_chats = @redis.get("chats:#{application_token}")
      if cached_chats
        Chat.where(application_id: application_id)
      else
        chats = Application.find_by(token: application_token).chats
        @redis.set("chats:#{application_token}", chats.to_json)
        chats
      end
    end
  
    def fetch_cached_messages(chat_id)
      cached_messages = @redis.get("messages:#{chat_id}")
      if cached_messages
        JSON.parse(cached_messages).map { |msg| Message.new(msg) }
      else
        messages = Chat.find_by(id: chat_id).messages
        @redis.set("messages:#{chat_id}", messages.to_json)
        messages
      end
    end
  
    def cache_application(application)
      @redis.set("application:#{application.token}", application.to_json)
    end
  
    def cache_chat(chat)
      @redis.set("chat:#{chat.application.token}:#{chat.number}", chat.to_json)
    end
  
    def cache_message(message)
      @redis.set("message:#{message.id}", message.to_json)
      @redis.del("messages:#{message.chat.id}")
    end
  
    def clear_cache(type, id = nil)
      case type
      when :applications
        @redis.del("applications")
      when :application
        @redis.del("application:#{id}")
        @redis.del("chats:#{id}")
      when :chat
        @redis.del("chat:#{id}")
        @redis.del("messages:#{id}")
      when :messages
        @redis.del("messages:#{id}")
      end
    end
  end
  