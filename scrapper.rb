require 'nokogiri'
require 'httparty'
require 'byebug'
require 'sqlite3'
require './product.rb'

def scarpper
  db = open_connection
  create_database(db)
  visited_pages = db.execute "select url from products"
  visited_pages.flatten!
  unvisited_pages = ["https://magento-test.finology.com.my/breathe-easy-tank.html"] + visited_pages
  unvisited_pages.each do |url|
    unless visited_pages.include?(url)
      unparsed_page = HTTParty.get(url)
      paresed_page ||= Nokogiri::HTML(unparsed_page.body)
      product = Product.new
      product.title = paresed_page.css('div.product-info-main h1.page-title > span.base').text
      product.price = paresed_page.css('div.product-info-main div.product-info-price span.price').text
      product.description = paresed_page.css('div.detailed div.description > div.value p').map(&:text).join("")
      product.extra_information = paresed_page.css('div.detailed table.additional-attributes > tbody > tr').map { |tr| formated_data(tr.css('th'),tr.css('td'))}.join(" | ")

      puts "\n*********************************************"
      product.to_s
      product_exist = db.execute "select * from products where title='#{product.title}' and price='#{product.price}'"
      db.execute "INSERT INTO Products(Title,Price,Description,Extra_information,Url) VALUES ('#{product.title.gsub("'"){"''"}}','#{product.price.gsub("'"){"''"}}','#{product.description.gsub("'"){"''"}}','#{product.extra_information.gsub("'"){"''"}}','#{url}')" if product_exist.flatten.length == 0
      more_products = paresed_page.css("div.products-related > ol.product-items > li.product-item").map{ |product| product.css('div.product-item-info > a').attr("href").text }
      more_products.each do |link|
        unvisited_pages << link unless unvisited_pages.include?(link)
      end
    else
      product = db.execute "select * from products where url = '#{url}'"
      product&.map do |id,title,price,descrtipion,extra_information,url|
        puts "\n*********************************************"
        p = Product.new(title,price,descrtipion,extra_information)
        p.to_s
      end
    end
  end
end

def formated_data(th,td)
  "#{th.text} : #{td.text}"
end

def create_database(con)
  begin
    con.execute "CREATE TABLE IF NOT EXISTS Products(Id INTEGER PRIMARY KEY, 
          Title TEXT, Price TEXT, Description TEXT, Extra_information TEXT, Url TEXT)"
  rescue SQLite3::Exception => e 
    puts "Exception occurred"
    puts e
  end
end

def open_connection
  db = nil
  begin
    db = SQLite3::Database.open "products.db"
  rescue SQLite3::Exception => e 
    puts "Exception occurred"
    puts e
  end
  db
end

scarpper