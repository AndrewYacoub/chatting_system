class ApplicationsController < ApplicationController
  before_action :initialize_redis

  def create
    application = Application.new(application_params)
    if application.save
      render json: { token: application.token }, status: :created
    else
      render json: { errors: application.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    application = fetch_cached_application(params[:token])
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

  def initialize_redis
    @redis = Redis.new(host: 'localhost', port: 6379)
  end

  def fetch_cached_application(token)
    cached_application = @redis.get("application:#{token}")
    if cached_application
      JSON.parse(cached_application)
    else
      application = Application.find_by(token: token)
      if application
        @redis.set("application:#{token}", application.to_json)
        application
      end
    end
  end
end
