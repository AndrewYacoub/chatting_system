class MessagesController < ApplicationController
    before_action :set_chat
  
    def create
      message = @chat.messages.new(message_params)
      if message.save
        render json: { number: message.number }, status: :created
      else
        render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def search
      chat = Chat.find_by(id: params[:chat_id], application: Application.find_by(token: params[:application_token]))
      if chat.nil?
        render json: { error: 'Chat not found' }, status: :not_found
        return
      end
  
      query = params[:query]
      messages = chat.messages.where('body LIKE ?', "%#{query}%") # Adjust this line according to your search implementation
  
      render json: messages
    end

    def index
      messages = @chat.messages
      render json: messages
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
  
    def message_params
      params.require(:message).permit(:body, :query)
    end
  end