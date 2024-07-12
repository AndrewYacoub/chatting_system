class Application < ApplicationRecord
    has_many :chats, dependent: :destroy
    
    before_create :generate_token
  
    private
  
    def generate_token
      self.token = SecureRandom.hex(10)
    end
  end