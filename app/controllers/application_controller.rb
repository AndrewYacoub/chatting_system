class ApplicationController < ActionController::API
    before_action :set_redis_service
  
    private
  
    def set_redis_service
      @redis_service = RedisService.new
    end
  end