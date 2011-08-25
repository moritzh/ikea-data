require 'rubygems'
require 'bundler/setup'
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
    # the index check prevents so-called series ( like the malm bed ) from being processed. need to handle them somewhere else.
    if ( self.url && self.url.index("product"))
      begin
        doc = Nokogiri::HTML(open("http://www.ikea.com/#{self.url}"))
        $redis = Redis.new(:host => 'localhost', :port => 6379)
        # only the script is interesting, and hopefully it's location never changes.
        script = doc.css('div#main script')[5]

        # rkelly parses the javascript thats inside the script tag. we use it to retrieve the "jProductData"-field
        parser = RKelly::Parser.new
        ast    = parser.parse(
        script.content
        )

        ast.each do |node|
          self.json = node.to_ecma if ( node.respond_to?(:name) && node.name == "jProductData" )
        end
      rescue
        # some info in case something goes wrong 
        puts "had an error with #{self.name}"
      end
      self.save

    else
      # we dont want any unparseable products to appear, so delete them
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

