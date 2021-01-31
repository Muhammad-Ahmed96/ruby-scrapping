class Product
  attr_accessor :title
  attr_accessor :price
  attr_accessor :description
  attr_accessor :extra_information

  def initialize(title=nil, price=nil,description=nil,extra_information=nil)
    @title = title
    @price = price
    @description = description
    @extra_information = extra_information
  end
  


  def to_s
    puts "Title = #{@title}"
    puts "Price = #{@price}"
    puts "Description = #{@description}"
    puts "Extra Information  = #{@extra_information}"
  end
end