class MessagesController < ApplicationController
  before_action :initialize_redis
  before_action :set_chat
  before_action :set_message, only: [:show, :update, :destroy]

  def create
    message = @chat.messages.build(message_params)
    if message.save
      clear_cache
      cache_message(message)
      render json: message, status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def search
    if @chat
      messages = Message.search(query: { match: { body: params[:query] } }).records.where(chat_id: @chat.id)
      render json: messages
    else
      render json: { error: 'Chat not found' }, status: :not_found
    end
  end

  def index
    messages = fetch_cached_messages
    render json: messages
  end

  def show
    if @message
      render json: @message
    else
      render json: { error: 'Message not found' }, status: :not_found
    end
  end

  def update
    if @message.update(message_params)
      clear_cache
      cache_message(@message)
      render json: @message
    else
      render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @message.destroy
      clear_cache
      @redis.del("message:#{@message.id}")
      render json: { message: 'Message deleted successfully' }, status: :ok
    else
      render json: { error: 'Failed to delete message' }, status: :unprocessable_entity
    end
  end

  private

  def set_chat
    application = Application.find_by(token: params[:application_token])
    if application
      @chat = application.chats.find_by(number: params[:chat_id])
      render json: { error: 'Chat not found' }, status: :not_found unless @chat
    else
      render json: { error: 'Application not found' }, status: :not_found
    end
  end

  def set_message
    @message = fetch_cached_message(params[:id])
  end

  def message_params
    params.require(:message).permit(:body)
  end

  def initialize_redis
    redis_host = ENV.fetch("REDIS_HOST") { 'localhost' }
    redis_port = ENV.fetch("REDIS_PORT") { 6379 }
    @redis = Redis.new(host: redis_host, port: redis_port)
  end

  def fetch_cached_message(id)
    cached_message = @redis.get("message:#{id}")
    if cached_message
      Message.find_by(id: id)
    else
      message = Message.find_by(id: id)
      if message
        @redis.set("message:#{id}", message.to_json)
        message
      end
    end
  end

  def fetch_cached_messages
    cached_messages = @redis.get("messages:#{@chat.id}")
    if cached_messages
      JSON.parse(cached_messages).map { |msg| Message.new(msg) }
    else
      messages = @chat.messages
      @redis.set("messages:#{@chat.id}", messages.to_json)
      messages
    end
  end

  def cache_message(message)
    @redis.set("message:#{message.id}", message.to_json)
    @redis.del("messages:#{@chat.id}")
  end

  def clear_cache
    @redis.del("messages:#{@chat.id}")
  end
end
