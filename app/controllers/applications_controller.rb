class ApplicationsController < ApplicationController
  before_action :set_application, only: [:show, :update, :destroy]

  def index
    applications = @redis_service.fetch_cached_applications
    render json: applications
  end

  def create
    application = Application.new(application_params)
    if application.save
      @redis_service.clear_cache(:applications)
      @redis_service.cache_application(application)
      render json: { token: application.token }, status: :created
    else
      render json: { errors: application.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    if @application
      render json: @application
    else
      render json: { error: 'Application not found' }, status: :not_found
    end
  end

  def update
    if @application.update(application_params)
      @redis_service.clear_cache(:applications)
      @redis_service.cache_application(@application)
      render json: @application
    else
      render json: { errors: @application.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @application.destroy
      @redis_service.clear_cache(:applications)
      @redis_service.clear_cache(:application, @application.token)
      render json: { message: 'Application deleted successfully' }, status: :ok
    else
      render json: { error: 'Failed to delete application' }, status: :unprocessable_entity
    end
  end

  private

  def application_params
    params.require(:application).permit(:name)
  end

  def set_application
    @application = @redis_service.fetch_cached_application(params[:token])
  end
end
