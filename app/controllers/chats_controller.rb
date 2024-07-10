class ChatsController < ApplicationController
  before_action :initialize_redis
  before_action :set_application
  before_action :set_chat, only: [:show, :destroy]

  def create
    chat = @application.chats.new
    if chat.save
      clear_cache(@application.token)
      cache_chat(chat)
      render json: { number: chat.number }, status: :created
    else
      render json: { errors: chat.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    chats = fetch_cached_chats(@application.token)
    render json: chats
  end

  def show
    if @chat
      render json: @chat
    else
      render json: { error: 'Chat not found' }, status: :not_found
    end
  end

  def destroy
    if @chat.destroy
      clear_cache(@application.token)
      @redis.del("chat:#{@application.token}:#{@chat.number}")
      render json: { message: 'Chat deleted successfully' }, status: :ok
    else
      render json: { error: 'Failed to delete chat' }, status: :unprocessable_entity
    end
  end

  private

  def initialize_redis
    redis_host = ENV.fetch("REDIS_HOST") { 'localhost' }
    redis_port = ENV.fetch("REDIS_PORT") { 6379 }
    @redis = Redis.new(host: redis_host, port: redis_port)
  end

  def set_application
    @application = fetch_cached_application(params[:application_token])
    render json: { error: 'Application not found' }, status: :not_found unless @application
  end

  def set_chat
    @chat = fetch_cached_chat(@application.token, params[:id])
    render json: { error: 'Chat not found' }, status: :not_found unless @chat
  end

  def fetch_cached_application(token)
    cached_application = @redis.get("application:#{token}")
    if cached_application
      Application.find_by(token: token)
    else
      application = Application.find_by(token: token)
      if application
        cache_application(application)
        application
      end
    end
  end

  def fetch_cached_chat(application_token, chat_number)
    cached_chat = @redis.get("chat:#{application_token}:#{chat_number}")
    if cached_chat
      Chat.find_by(application_id: @application.id, number: chat_number)
    else
      chat = Chat.find_by(application_id: @application.id, number: chat_number)
      if chat
        cache_chat(chat)
        chat
      end
    end
  end

  def fetch_cached_chats(application_token)
    cached_chats = @redis.get("chats:#{application_token}")
    if cached_chats
      Chat.where(application_id: @application.id, number: JSON.parse(cached_chats).map { |chat| chat["number"] })
    else
      chats = @application.chats
      @redis.set("chats:#{application_token}", chats.to_json)
      chats
    end
  end

  def cache_chat(chat)
    @redis.set("chat:#{chat.application.token}:#{chat.number}", chat.to_json)
  end

  def clear_cache(application_token)
    @redis.del("chats:#{application_token}")
  end
end
