---
title: Existing Solutions
layout: wikistyle
---

Existing Solutions
==================

Database Management System based solution
-----------------------------------------

Some relational database management systems RDBMS (such as PostgreSQL) provide support for table inheritance (see here), but it’s a specialized feature which ties you down to the given RDBMS.

Single Table Inheritance based solution
---------------------------------------

ActiveRecord provides only one way to handle a is_a relationship which is [Single Table Inheritance](http://en.wikipedia.org/wiki/Single_Table_Inheritance "Single Table Inheritance"). You’d have to create a table looking somewhat like the following.

<table>
	<tbody>
		<tr>
			<td>id</td><td>type</td><td>price</td><td>name</td><td>title</td><td>genre</td><td>author</td><td>language1</td><td>language2</td><td>summary</td>
		</tr>
		<tr>
			<td>1</td><td>Audio</td><td>10</td><td>n1</td><td>t1</td><td>g1</td><td>NULL</td><td>NULL</td><td>NULL</td><td>NULL</td>
		</tr>
		<tr>
			<td>2</td><td>Mp3</td><td>5</td><td>n2</td><td>t2</td><td>g2</td><td>NULL</td><td>NULL</td><td>NULL</td><td>NULL</td>
		</tr>
		<tr>
			<td>3</td><td>Video</td><td>11</td><td>n3</td><td>t3</td><td>g3</td><td>NULL</td><td>NULL</td><td>NULL</td><td>NULL</td>
		</tr>
		<tr>
			<td>4</td><td>Book</td><td>12</td><td>n4</td><td>t4</td><td>NULL</td><td>a4</td><td>NULL</td><td>NULL</td><td>NULL</td>
		</tr>
		<tr>
			<td>5</td><td>Novel</td><td>13</td><td>n5</td><td>t5</td><td>NULL</td><td>a5</td><td>NULL</td><td>NULL</td><td>s5</td>
		</tr>
		<tr>
			<td>6</td><td>Dictionary</td><td>10</td><td>n6</td><td>t6</td><td>NULL</td><td>a6</td><td>l16</td><td>l26</td><td>NULL</td>
		</tr>
		<tr>
			<td>7</td><td>PocketDictionary</td><td>7</td><td>n7</td><td>t7</td><td>NULL</td><td>a7</td><td>l17</td><td>l27</td><td>NULL</td>
		</tr>
		<tr>
			<td>8</td><td>Unknown</td><td>5</td><td>n8</td><td>NULL</td><td>NULL</td><td>NULL</td><td>NULL</td><td>NULL</td><td>NULL</td>
		</tr>
	</tbody>
</table>

The problem here is that all attributes are stored in the same table. It’s likely that soon the number of attributes will grow unmanageable, and most of them will always stay NULL since they’ll be specific to only one type (not really efficient storage).

Polymorphic Has_one Association based solution
----------------------------------------------

A has\_one association allows us to split out medias, audios, mp3s, videos, books, dictionaries, pocket dictionaries, novels and unknowns into different tables. We won't deeply explain drawbacks of this solution but only point out that it creates a "has\_a" relationship whereas we want a is_a relationship.

Multiple Table Inheritance (Simulated) based solution
-----------------------------------------------------

Has\_one association problem is that it creates a *has\_a* relationship, and we want a *is_a*. Since there isn’t much choice, several authors (see [Multiple Table Inheritance (MTI)](http://mediumexposure.com/multiple-table-inheritance-active-record/), or [Class Table Inheritance (CTI)](https://github.com/brunofrank/class-table-inheritance)) decided to make it look like we have an *is_a* relationship. We won't discuss here implementation details and you should refer to the previously given links for more information. But, you should be aware that for these solutions all subclasses would inherit from ActiveRecord::Base and that these solutions consist in doing some clever things to fake some aspects of classes inheritance but not all (for instance, if you use this solution, calling Book.superclass would return ActiveRecord::Base and not Media as we may have desired)

Nevertheless, their authors have done a pretty good work, and solutions proposed would fit to a lot of inheritance cases and would provide users of their plugins with a functional solution to their problems. Yet, in some cases (that we enumerate below) this won't be enough.

- Case 1 : Imagine you have defined some instance methods in the superclass (Media) which all subclasses need to be able to access (for instance price_category which returns « A » if the price is lower than 75, « B » if the price is betwen 75 and 100, « C » if the price is greater than 100). Since the CTI gem doesn't actually use Ruby Inheritance you won't be able to access to the superclass's methods (price_category for instance).

- Case 2 : TODO A VERIFIER Imagine you have a multi-level inheritance hierarchy (as it is the case with our multimedia Library). You can not use CTI plugins to directly model this situation. In fact, MTI plugin has been created to modelize Multiple Inheritance Table only for a one level inheritance hierarchy. This mean that if we want to use this plugin (without any modification) we would need to alter our inheritance hierarchy (into a flat / one level hierarchy) as done below. This may be possible in some cases without problem, but for most cases this would imply some serious drawbacks.

**Flat Class Hierarchy / One level Class Hierarchy :**
![Flat Class Hierarchy](/images/flat_class_hierarchy.gif "Flat Class Hierarchy")














