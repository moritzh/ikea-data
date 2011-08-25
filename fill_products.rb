require './lib'
require 'progressbar'
threads = []
products = Product.all.all
pbar = ProgressBar.new("Filling Products", products.count)
0.upto(12) do |i|
  slice = products.slice!(0, (products.count/12) )
  threads << Thread.new(slice) { |products|
    products.each do |p|
      pbar.inc
      p.retrieve if p.json.nil?
    end
  }
end

threads.each {|t| t.join }