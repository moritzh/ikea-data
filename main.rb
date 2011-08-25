require './lib.rb'


doc = Nokogiri::HTML(open('http://www.ikea.com/de/de/catalog/allproducts/'))
$redis = Redis.new(:host => 'localhost', :port => 6379)
$redis.flushdb
doc.css('div.productCategoryContainer').each do |link|
  # parent category.
  c = Category.create(:name=>link.css('span.header')[0].content.strip)
  c.toplevel = "1"
  link.css('a').each do |childEntry|
    child = Category.create(:name=>childEntry.content.strip, :url=>childEntry["href"])
    child.category = c
    child.save
    c.children << child
  end
  c.save
  
end

Category.all.each do |category| 
  puts category.name
  if ( !category.url.nil? )
    children_page = Nokogiri::HTML(open("http://www.ikea.com/" + category.url + "?pageNumber=0"))
    children_page.css('div.parentContainer div.productPadding a:first-child').each do |link|
      p = Product.find(:url => link["href"]).first
      p ||= Product.create( :url=>link["href"], :category=>category)
      name = link.css('.prodName')[0]
      if ( name )
      p.name = name.content.strip
      puts "   #{p.name} - #{link.css('.prodDesc')[0].content.strip}"
      p.save
      end
    end
  end
end

