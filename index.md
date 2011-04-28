---
title: Home
layout: wikistyle
---

Introduction to CITIER
======================


> NOTE: This was a project originally started by ALTRABio. I have done substantial fixes, improvements and code refactoring to get it running smoothly and modified and changed the code a lot whilst developing my own projects, but the initial work and planning (including a fair amount of this documentation) was done by them.
> To quote the often heard phrase in academia: We stand on the shoulders of giants

**Ruby Class Inheritance & Multiple Table Inheritance Embeddings : A full featured solution based on Ruby Class Inheritance & Views**

When trying to model a real world problem that needs some information storage into databases, programmers often face the issue which consists in mapping objects to relational databases. After a long review of Rails' existing solutions, I along with the original authors propose a new solution which has been bundled into a gem called : **CITIER** **C**lass **I**nheritance & **T**able **I**nheritance **E**mbeddings for **R**ails

This project is inspired by many articles and previous attempts that I and the original authors had already looked into, some of which include:

- [Multiple Table Inheritance with ActiveRecord by Maxim Chernyak](http://mediumexposure.com/multiple-table-inheritance-active-record/)
- [Heritage Repo](https://github.com/BenjaminMedia/Heritage)
- [class-table-inheritance Repo](https://github.com/brunofrank/class-table-inheritance)
- [inherits_from Repo](https://github.com/rwl4/inherits_from)
- [Mikel - lindsaar.net](http://lindsaar.net/2008/3/12/multi-table-inheritance-in-rails-when-two-tables-are-one)
- [Xavier Shay](http://rhnh.net/2010/08/15/class-table-inheritance-and-eager-loading)
- [Xavier Shay #2](http://rhnh.net/2010/07/02/3-reasons-why-you-should-not-use-single-table-inheritance)
- [Gerry](http://techspry.com/ruby_and_rails/multiple-table-inheritance-in-rails-3/)

But does it do "X"?
-------------------
I have a list of things I want to be able to do when handling models, which most of the other solutions *kind* of cover. Usually managing one but failing on another.
This solution already builds on ruby's class inheritance so brings with it all the OO goodness! Hurrah!

- *Multi Table Inheritance* - **YES**
- *Single Table Inheritance* - **YES**
- *Class Inheritance* - **YES**
- *Validators inherited from parents* - **YES**
- *Functions inherited from parents* - **YES**
- *Stuff which is really cool but I haven't thought of yet* - **Probably!**

**Enough! This sounds awesome! Show me how it works!**

Oh ok, go on then... ;)

First install citier & add to Gemfile

{% highlight bash %}
$ gem install citier
{% endhighlight %}

{% highlight ruby %}

# Models
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

# Migrations
class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string :type # Needed for citier
      t.string :name
      t.decimal :price
    end
  end
  def self.down
    drop_table :medias
  end
end

class CreateBooks < ActiveRecord::Migration
  def self.up
    create_table :books do |t|
      t.string :title
      t.string :author
    end
    create_citier_view(Book)
  end
  def self.down
    drop_citier_view(Book)
    drop_table :books
  end
end

class CreateDictionaries < ActiveRecord::Migration
  def self.up
    create_table :dictionaries do |t|
      t.string :language
    end
    create_citier_view(Dictionary)
  end
  def self.down
    drop_citier_view(Dictionary)
    drop_table :dictionaries
  end
end
{% endhighlight %}


You will see some code below only visible in development mode, preceeded by "citier -> "
Shows examples of creation, automatic child class identification and deletion. Also works with "delete_all", destroy and destroy\_all functions.

A very simple app has been created as a branch to this project if you wish to have a play. It will also be used to test future functionality
{% highlight bash %}

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
 => [#<Dictionary id: 1, type: "Dictionary", name: "Ox. Eng. Dict", price: 25, created_at: "2011-04-28 22:46:23", updated_at: "2011-04-28 22:46:23">] 
>> :010 > d = Dictionary.all().first()
 => #<Dictionary id: 1, type: "Dictionary", name: "Ox. Eng. Dict", price: 25, created_at: "2011-04-28 22:46:23", updated_at: "2011-04-28 22:46:23", title: "The Oxford English Dictionary", author: nil, language: "English"> 
>> :011 > d.delete()
citier -> Deleting Dictionary with ID 1
citier -> Deleting back up hierarchy Dictionary
citier -> Deleting back up hierarchy Book
 => true 
>> :012 > Dictionary.all()
 => []
{% endhighlight %}