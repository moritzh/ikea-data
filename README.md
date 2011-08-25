Ikea Screenscraper
==================

This set of scripts ( no Rakefile, sorry ) pulls most of the product and category data from the ikea.com website and stores it in a redis store. 

Running
-------
The process is split in 2 parts, the first one is retrieving the category data and creates product stubs, the second step fills the products with data by retrieving every single product site.

To create the categories and insert all products, run
   
   ruby main.rb

after a short while, you should have the categories in your redis. 
To retrieve all products, just execute

	ruby fill_products.rb
	
and wait. This takes some time.

What to do with the data?

I don't know, I guess I just wanted to try nokogiri. But for the curious, there is a sinatra-server ( server.rb ) that will server both a tree at /tree.json and product data for every category. 