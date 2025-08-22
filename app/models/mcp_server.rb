class McpServer < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :url, presence: true, format: { with: /\Ahttps?:\/\/.*\z/i, message: "must be a valid HTTP or HTTPS URL" }
  
  scope :ordered, -> { order(:created_at) }
  
  before_validation :normalize_fields
  
  private
  
  def normalize_fields
    self.name = name&.strip
    self.url = url&.strip
  end
end