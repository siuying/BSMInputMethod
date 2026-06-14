require "rubygems"
require "sequel"

class BsmConverter
  attr_accessor :db

  def initialize(db=':memory:', frequency=nil)
    @db = Sequel.sqlite(db)
    @frequency = frequency
    setup
  end

  def setup
    @db.create_table? :ime do
      primary_key :id
      String :code, :fixed => true, :size => 6, :index => true
      String :word, :fixed => true, :size => 1
      Integer :frequency, :default => 6000, :index => true
    end
  end

  def ime
    @ime ||= @db[:ime]
  end

  def add(code, word)
    ime.insert(:code => code, :word => word, :frequency => @frequency[word])
  end
end