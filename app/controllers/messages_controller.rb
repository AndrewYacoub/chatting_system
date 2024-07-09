class MessagesController < ApplicationController
    before_action :set_chat
  
    def create
      chat = Chat.find(params[:chat_id])
      message = chat.messages.build(message_params)
      if message.save
        render json: message, status: :created
      else
        render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    def search
      chat = Chat.find(params[:chat_id])
      if chat
        messages = Message.search(query: { match: { body: params[:query] } }).records.where(chat_id: chat.id)
        render json: messages
      else
        render json: { error: 'Chat not found' }, status: :not_found
      end
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