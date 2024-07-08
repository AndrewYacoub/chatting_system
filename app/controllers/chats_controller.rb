class ChatsController < ApplicationController
    before_action :set_application
  
    def create
      chat = @application.chats.new
      if chat.save
        render json: { number: chat.number }, status: :created
      else
        render json: { errors: chat.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    def index
      chats = @application.chats
      render json: chats
    end
  
    private
  
    def set_application
      @application = Application.find_by(token: params[:application_token])
      render json: { error: 'Application not found' }, status: :not_found unless @application
    end
  end