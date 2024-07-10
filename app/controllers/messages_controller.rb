class MessagesController < ApplicationController
  before_action :set_chat
  before_action :set_message, only: [:show, :update, :destroy]

  def create
    message = @chat.messages.build(message_params)
    if message.save
      @redis_service.clear_cache(:messages, @chat.id)
      @redis_service.cache_message(message)
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
    messages = @redis_service.fetch_cached_messages(@chat.id)
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
      @redis_service.clear_cache(:messages, @chat.id)
      @redis_service.cache_message(@message)
      render json: @message
    else
      render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @message.destroy
      @redis_service.clear_cache(:messages, @chat.id)
      @redis_service.clear_cache(:message, @message.id)
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
    @message = @redis_service.fetch_cached_message(params[:id])
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
