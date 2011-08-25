require './lib'
require 'sinatra'
require 'json'

get '/tree.json' do
  tree = Category.all.all.collect {|x| x unless !x.toplevel }.compact
  tree.to_json
end

get '/category/:id' do
  products = Product.find(:category_id => params[:id] ).all
  products.to_json
end

get '/products.json' do
  z = Product.all.all
  z.to_json
end