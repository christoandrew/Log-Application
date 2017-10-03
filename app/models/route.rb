class Route < ApplicationRecord
  validates :name, :presence => true
  validates :zone_id, :presence => true
  belongs_to :town
  belongs_to :zone
  has_many :meters
  has_many :customers
  has_one :task

  def self.execute_find_sql(sql)
    self.find_by_sql(sql)
  end
end
