require 'rubygems'
require 'csv'
require 'roo'
require 'activerecord-import'
class MeterReader < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  has_secure_password
  validates :name, presence: true
  validates :username, :email, presence: true, uniqueness: true
  has_many :meter_readings
  has_many :tasks
  has_many :issues

  def authenticate(unencrypted_password)
    BCrypt::Password.new(password_digest).is_password?(unencrypted_password) && self
  end

  def to_builder
    Jbuilder.new do |meter_reader|
      meter_reader.(self, :id, :name)
    end
  end

  def self.save_the_day(file)
    readers = []
    spread_sheet = open_spreadsheet(file)
    header = spread_sheet.row(1)
    counter = 0
    (2..spread_sheet.last_row).each do |i|
      row = Hash[[header, spread_sheet.row(i)].transpose]
      name = row["Name"]
      password = row["Zone"]
      username = name.gsub(/\s+/, "").downcase
   email = Forgery(:internet).email_address
      reader = MeterReader.new(name: name, username: username, email: email, password: password)

      readers << reader
    end
    MeterReader.import(readers)

    # Customer.import(customers)
  end
  def self.convert x
    Float(x)
    i, f = x.to_i, x.to_f
    i == f ? i : f
  rescue ArgumentError
    x
  end

  def remove_space str
    str.gsub(/\s+/, "")
  end

  def generate_username str
    remove_space(str).down_case
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
      when '.csv' then
        Roo::CSV.new(file.path, nil, :ignore)
      when '.xls' then
        Roo::Excel.new(file.path, nil, :ignore)
      when '.xlsx' then
        Roo::Excelx.new(file.path)
      else
        raise "Unknown file type: #{file.original_filename}"
    end
  end
end
