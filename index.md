---
title: Home
layout: wikistyle
---

Introduction to CITIER
======================


> NOTE: This was a project originally started by ALTRABio who did most of the underlying work. I have modified and changed this code while developing my own projects, but the hard work and planning was done by them.
> To quote the often heard phrase in academia: We stand on the shoulders of giants

**Ruby Class Inheritance & Multiple Table Inheritance Embeddings : A full featured solution based on Ruby Class Inheritance & Views**

When trying to model a real world problem that needs some information storage into databases, programmers often face the issue which consists in mapping objects to relational databases (see for instance here). After a short (and not exhaustive) review of Rails existing solutions we propose a new solution which has been bundled into a gem called : **CITIER** **C**lass **I**nheritance & **T**able **I**nheritance **E**mbeddings **For Rails**

This project is inspired by many articles and previous attempts some of which include:

- [Multiple Table Inheritance with ActiveRecord by Maxim Chernyak](http://mediumexposure.com/multiple-table-inheritance-active-record/)
- [Heritage](https://github.com/BenjaminMedia/Heritage)
- [class-table-inheritance](https://github.com/brunofrank/class-table-inheritance)
- [inherits_from](https://github.com/rwl4/inherits_from)

**Enough! This sounds awesome! Show me how it works!**
Oh ok, go on then ;)

{% highlight >> %}

# Models
class Media < ActiveRecord::Base
  acts_as_citier 
end

class Book < Media
  acts_as_citier
end

class Dictionary < Book
  acts_as_citier
end

# Migrations
class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string :type # Needed for citier
      t.string :name
      t.integer :price
    end
  end
  def self.down
    drop_table :medias
  end
end

################################################

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

################################################

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
>> :001 > d = Dictionary.new(:name=>"Ox. Eng. Dict",:price=>25.99,:title=>"The Oxford English Dictionary",:language=>"English")
citier -> Root Class
citier -> table_name -> products
citier -> Non Root Class
citier -> table_name -> books
citier -> tablename (view) -> view_books
citier -> Non Root Class
citier -> table_name -> dictionaries
citier -> tablename (view) -> view_dictionaries
 => #<Dictionary id: nil, type: "Dictionary", name: "Ox. Eng. Dict", price: 25, created_at: nil, updated_at: nil, title: "The Oxford English Dictionary", author: nil, language: "English"> 
>> :002 > d.save()
citier -> Non-Root Class Dictionary
citier -> Non-Root Class Book
citier -> UPDATE products SET type = 'Product' WHERE id = 1
citier -> SQL : UPDATE products SET type = 'Book' WHERE id = 1
citier -> SQL : UPDATE products SET type = 'Dictionary' WHERE id = 1
 => true 
>> :003 > Dictionary.all()
 => [#<Dictionary id: 1, type: "Dictionary", name: "Ox. Eng. Dict", price: 25, created_at: "2011-04-28 21:45:11", updated_at: "2011-04-28 21:45:11", title: "The Oxford English Dictionary", author: nil, language: "English">] 
>> :004 > Product.all()
 => [#<Dictionary id: 1, type: "Dictionary", name: "Ox. Eng. Dict", price: 25, created_at: "2011-04-28 21:45:11", updated_at: "2011-04-28 21:45:11">] 
>> :005 > d = Dictionary.all().first()
 => #<Dictionary id: 1, type: "Dictionary", name: "Ox. Eng. Dict", price: 25, created_at: "2011-04-28 21:45:11", updated_at: "2011-04-28 21:45:11", title: "The Oxford English Dictionary", author: nil, language: "English"> 
>> :006 > d.delete()
citier -> Deleting Dictionary with ID 1
citier -> Deleting back up hierarchy Dictionary
citier -> Deleting back up hierarchy Book
 => true 
>> :007 > Dictionary.all()
 => [] 
{% endhighlight %}