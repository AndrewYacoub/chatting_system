class Chat < ApplicationRecord
  belongs_to :application, counter_cache: true
  has_many :messages

  before_create :assign_number

  private

  def assign_number
    max_number = application.chats.maximum(:number) || 0
    self.number = max_number + 1
  end
end