---
title: Home
layout: wikistyle
---

Introduction to CITIER
======================


> NOTE: This was a project originally started by ALTRABio who did most of the underlying work. I have modified and changed this code while developing my own projects, but the hard work and planning was done by them.
> To quote the often heard phrase in science: We stand on the shoulders of giants

**Ruby Class Inheritance & Multiple Table Inheritance Embeddings : A full featured solution based on Ruby Class Inheritance & Views**

When trying to model a real world problem that needs some information storage into databases, programmers often face the issue which consists in mapping objects to relational databases (see for instance here). After a short (and not exhaustive) review of Rails existing solutions we propose a new solution which has been bundled into a gem called : **CITIER** **C**lass **I**nheritance & **T**able **I**nheritance **E**mbeddings **For Rails**

This project is inspired by many articles and previous attempts some of which include:

- [Multiple Table Inheritance with ActiveRecord by Maxim Chernyak](http://mediumexposure.com/multiple-table-inheritance-active-record/)
- [Heritage](https://github.com/BenjaminMedia/Heritage)
- [class-table-inheritance](https://github.com/brunofrank/class-table-inheritance)
- [inherits_from](https://github.com/rwl4/inherits_from)

**Enough! This sounds awesome! Show me how it works!**
Oh ok, go on then ;)

{% highlight ruby %}

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
class CreateMedias < ActiveRecord::Migration
  def self.up
    create_table :medias do |t|
      t.string :inheritance_column_name
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