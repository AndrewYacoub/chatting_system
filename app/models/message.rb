class Message < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  before_create :assign_number
  validates :body, presence: true
  belongs_to :chat, counter_cache: true

  settings index: { number_of_shards: 1 } do
    mappings dynamic: false do
      indexes :body, type: :text, analyzer: 'standard'
    end
  end

  def as_indexed_json(options = {})
    as_json(only: [:body, :chat_id])
  end

  unless Message.__elasticsearch__.index_exists?
    Message.__elasticsearch__.create_index!
    Message.import
  end

  private

  def assign_number
    max_number = chat.messages.maximum(:number) || 0
    self.number = max_number + 1
  end
end