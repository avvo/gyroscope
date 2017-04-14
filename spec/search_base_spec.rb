require 'spec_helper'

module Rails
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end

class MyTestModel
  class Scope
    def initialize(attrs)
      @scope = attrs
    end

    def order(ordering)
      self.class.new @scope.merge(order: ordering)
    end

    def paginate(pagination_options)
      self.class.new @scope.merge(pagination_options)
    end

    def to_h
      @scope
    end
  end

  def self.table_name
    "my_test"
  end

  def initialize
    @scope = {}
  end

  def self.paginate(pagination_options)
    Scope.new(pagination_options)
  end

  def persistable_attribute_names
    ["created_at", "foo", "bar"]
  end
end

module Search
  class MyTestModel < Gyroscope::SearchBase
  end
end

describe Gyroscope::SearchBase do
  it "parses a hash for the order arg" do
    expect(Search::MyTestModel.new(order: {"created_at" => "desc", "foo" => "asc"}).search.to_h[:order]).
      to eq("my_test.created_at desc,my_test.foo asc")
  end

  it "parses a string for the order arg" do
    expect(Search::MyTestModel.new(order: "foo desc").search.to_h[:order]).
      to eq("my_test.foo desc")
  end


  it "handles nothing well" do
    expect(Search::MyTestModel.new({}).search.to_h).
      to eq({page: 1, per_page: 30})
  end

  it "handles order string key too" do
    expect(Search::MyTestModel.new("order" => "foo desc").search.to_h[:order]).
      to eq("my_test.foo desc")
  end
end
