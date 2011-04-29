CITIER
======

What is it?
-----------
CITIER (Class Inheritance & Table Inheritance Embeddings for Rails) is a very simple way of implementing Multiple Table inheritance in Rails.

Built upon/fixed/cleaned and evolved into to CITIER for my own (And potentially other's) needs.

In short it allows you (finally) to do this:

```ruby
class Product < ActiveRecord::Base
  acts_as_citier
  validates_presence_of :name
  def an_awesome_product
    puts "I #{name} am an awesome product"
  end
end

class Book < Product
  acts_as_citier
  validates_presence_of :title
  
  def an_awesome_book
    self.an_awesome_product
    puts "A book to be precise"
  end
end

class Dictionary < Book
  acts_as_citier
  validates_presence_of :language
  
  def is_awesome
    self.an_awesome_book
    puts "I am a dictionary. Yeah!"
  end
end
```
There are two lines you need to add to your migration files as well, see [Here](http://peterejhamilton.github.com/citier/) for full information

```bash
$ rails console
Loading development environment (Rails 3.0.7)
>> :001 > d = Dictionary.new(:name=>nil,:price=>25.99,:title=>nil,:language=>nil)
citier -> Root Class
citier -> table_name -> products
citier -> Non Root Class
citier -> table_name -> books
citier -> tablename (view) -> view_books
citier -> Non Root Class
citier -> table_name -> dictionaries
citier -> tablename (view) -> view_dictionaries
 => #<Dictionary id: nil, type: "Dictionary", name: nil, price: 25, created_at: nil, updated_at: nil, title: nil, author: nil, language: nil> 
>> :002 > d.valid?
 => false 
>> :003 > d.errors
 => #<OrderedHash {:language=>["can't be blank"], :name=>["can't be blank"], :title=>["can't be blank"]}> 
>> :004 > d = Dictionary.new(:name=>"Ox. Eng. Dict",:price=>25.99,:title=>"The Oxford English Dictionary",:language=>"English")
 => #<Dictionary id: nil, type: "Dictionary", name: "Ox. Eng. Dict", price: 25, created_at: nil, updated_at: nil, title: "The Oxford English Dictionary", author: nil, language: "English"> 
>> :005 > d.valid?
 => true
>> :006 > d.is_awesome()
I Ox. Eng. Dict am an awesome product
A book to be precise
I am a dictionary. Yeah!
=> nil
>> :007 > d.save()
citier -> Non-Root Class Dictionary
citier -> Non-Root Class Book
citier -> UPDATE products SET type = 'Product' WHERE id = 1
citier -> SQL : UPDATE products SET type = 'Book' WHERE id = 1
citier -> SQL : UPDATE products SET type = 'Dictionary' WHERE id = 1
 => true 
>> :008 > Dictionary.all()
 => [#<Dictionary id: 1, type: "Dictionary", name: "Ox. Eng. Dict", price: 25, created_at: "2011-04-28 22:46:23", updated_at: "2011-04-28 22:46:23", title: "The Oxford English Dictionary", author: nil, language: "English">] 
>> :009 > Product.all()
 => [#<Dictionary id: 1, type: "Dictionary", name: "Ox. Eng. Dict", price: 25, created_at: "2011-04-28 22:46:23", updated_at: "2011-04-28 22:46:23", title: "The Oxford English Dictionary", author: nil, language: "English">] 
>> :010 > d = Dictionary.all().first()
 => #<Dictionary id: 1, type: "Dictionary", name: "Ox. Eng. Dict", price: 25, created_at: "2011-04-28 22:46:23", updated_at: "2011-04-28 22:46:23", title: "The Oxford English Dictionary", author: nil, language: "English"> 
>> :011 > d.delete()
citier -> Deleting Dictionary with ID 1
citier -> Deleting back up hierarchy Dictionary
citier -> Deleting back up hierarchy Book
 => true 
>> :012 > Dictionary.all()
 => []
```

Cool huh?

It is based on original code by ALTRABio (www.github.com/altrabio/)

**For full information please go to the github page:**
**http://peterejhamilton.github.com/citier/**