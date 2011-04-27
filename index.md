---
title: Home
layout: wikistyle
---

Introduction to CITIEsForRAILS
==============================

Ruby Class Inheritance & Multiple Table Inheritance Embeddings : A full featured solution based on Ruby Class Inheritance & Views

When trying to model a real world problem that needs some information storage into databases, programmers often face the issue which consists in mapping objects to relational databases (see for instance here). After a short (and not exhaustive) review of Rails existing solutions we propose a new solution which has been bundled into a gem called : **CITIEsForRails** **C**lass **I**nheritance & **T**able **I**nheritance **E**mbeddings **For Rails**

This article is deeply inspired by [Multiple Table Inheritance with ActiveRecord by Maxim Chernyak](http://mediumexposure.com/multiple-table-inheritance-active-record/)

Problem Statement
=================
Imagine writing a multimedia library app with different types of media (for example : Audio, Mp3, Video, Book, Novel, Dictionary, Pocket_Dictionary, and Unknown media).

Normally all media would have common attributes such as *name* and *price*

Some attributes will likely differ :

- Audio medias may have a title and a genre,
- Mp3 medias may have a title and a genre,
- Video medias could have a title and a genre,
- Book medias may have an author and a title,
- Dictionary medias may have an author, a title, and two languages language1 and language2.
- Novel medias may have an author, a title, and a summary.
- Pocket_Dictionary medias may have an author, a title, and two languages language1 and language2

You can easily infer that Audio is a Media, MP3 is an Audio Media, Video is a Media, Unknown is a Media, Book is a Media, Dictionary is a Book, Novel is a Book and Pocket Dictionary is a Dictionary. When this type of relationship is being programmed, we generally use inheritance. If we consider that they should be stored into a database, this would look like as follows :

```ruby
class Media < ActiveRecord::Base
end

class Audio < Media
end

class Mp3 < Audio
end

class Video < Media
end

class Book < Media
end

class Novel < Book
end

class Dictionary < Book
end

class PocketDictionary < Dictionary
end

class Unknown < Media
end
```

The inheritance hierarchy would look like this:
![Inheritance Hierarchy](/images/inheritance_heirarchy.gif "Sample Inheritance Hierarchy")

This inheritance looks reasonable, but now we have to come up with relational database structure. We need to find a way to store each class’s own attributes (Audio’s own attributes, Mp3's own attributes, Video's own attributes... as well as their common (Media’s) attributes without unnecessary duplication).

We will first review the current solutions at our disposal,and discuss their advantages and drawbacks. Then we will introduce a new solution which to our mind eliminates drawbacks and extends the features of existing solutions.