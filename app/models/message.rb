class Message < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :chat, counter_cache: true

  before_create :assign_number
  validates :body, presence: true

  private

  def assign_number
    max_number = chat.messages.maximum(:number) || 0
    self.number = max_number + 1
  end
end