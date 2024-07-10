class ApplicationsController < ApplicationController
  before_action :initialize_redis
  before_action :set_application, only: [:show, :update, :destroy]

  def index
    applications = fetch_cached_applications
    render json: applications
  end

  def create
    application = Application.new(application_params)
    if application.save
      clear_cache
      cache_application(application)
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
      clear_cache
      cache_application(@application)
      render json: @application
    else
      render json: { errors: @application.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @application.destroy
      clear_cache
      @redis.del("application:#{@application.token}")
      render json: { message: 'Application deleted successfully' }, status: :ok
    else
      render json: { error: 'Failed to delete application' }, status: :unprocessable_entity
    end
  end

  private

  def application_params
    params.require(:application).permit(:name)
  end

  def initialize_redis
    redis_host = ENV.fetch("REDIS_HOST", 'localhost')
    redis_port = ENV.fetch("REDIS_PORT", 6379)
    @redis = Redis.new(host: redis_host, port: redis_port)
  end

  def set_application
    @application = fetch_cached_application(params[:token])
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

  def fetch_cached_applications
    cached_applications = @redis.get("applications")
    if cached_applications
      Application.where(token: JSON.parse(cached_applications).map { |app| app["token"] })
    else
      applications = Application.all
      @redis.set("applications", applications.to_json)
      applications
    end
  end

  def cache_application(application)
    @redis.set("application:#{application.token}", application.to_json)
  end

  def clear_cache
    @redis.del("applications")
  end
end
