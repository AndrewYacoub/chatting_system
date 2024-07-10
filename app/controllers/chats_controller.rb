class ChatsController < ApplicationController
  before_action :set_application
  before_action :set_chat, only: [:show, :destroy]

  def create
    chat = @application.chats.new
    if chat.save
      @redis_service.clear_cache(:chats, @application.token)
      @redis_service.cache_chat(chat)
      render json: { number: chat.number }, status: :created
    else
      render json: { errors: chat.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    chats = @redis_service.fetch_cached_chats(@application.token, @application.id)
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
      @redis_service.clear_cache(:chats, @application.token)
      @redis_service.clear_cache(:chat, @chat.id)
      render json: { message: 'Chat deleted successfully' }, status: :ok
    else
      render json: { error: 'Failed to delete chat' }, status: :unprocessable_entity
    end
  end

  private

  def set_application
    @application = @redis_service.fetch_cached_application(params[:application_token])
    render json: { error: 'Application not found' }, status: :not_found unless @application
  end

  def set_chat
    @chat = @redis_service.fetch_cached_chat(@application.token, @application.id, params[:id])
    render json: { error: 'Chat not found' }, status: :not_found unless @chat
  end
end
