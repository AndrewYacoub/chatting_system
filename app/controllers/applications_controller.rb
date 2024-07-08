class ApplicationsController < ApplicationController
    def create
      application = Application.new(application_params)
      if application.save
        render json: { token: application.token }, status: :created
      else
        render json: { errors: application.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    def show
      application = Application.find_by(token: params[:token])
      if application
        render json: application
      else
        render json: { error: 'Application not found' }, status: :not_found
      end
    end
  
    private
  
    def application_params
      params.require(:application).permit(:name)
    end
  end