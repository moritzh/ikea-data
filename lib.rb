require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'redis'
require 'ohm'
require 'rkelly'

class Product < Ohm::Model
  attribute :name
  attribute :url
  attribute :image
  attribute :json
  reference :category, Category

  index :url

  def retrieve
    if ( self.url && self.url.index("product"))
      begin
        doc = Nokogiri::HTML(open("http://www.ikea.com/#{self.url}"))
        $redis = Redis.new(:host => 'localhost', :port => 6379)
        # only the script is interesting.
        script = doc.css('div#main script')[5]
        parser = RKelly::Parser.new
        ast    = parser.parse(
        script.content
        )
        ast.each do |node|
          self.json = node.to_ecma if ( node.respond_to?(:name) && node.name == "jProductData" )
        end
      rescue
        puts "had an error with #{self.name}"
      end
      self.save

    else
      puts "deleting"
      self.delete
  end
end
def to_hash
  super.merge(:name => name, :json=>json)
end
end

class Category < Ohm::Model
  attribute :url
  attribute :name
  attribute :toplevel

  collection :children, Category
  reference :category, Category
  collection :productGroups, Product

  def dump
    puts "Category"
    puts " Name: #{self.name}"
    puts " Products"
    self.productGroups.all.count
  end

  def to_hash
    super.merge(:name => name, :children=>children.all)
  end

end

