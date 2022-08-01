---
title: Grocy Management
date: 20211006
author: Lyz
---

Buying stuff is an unpleasant activity that drains your energy and
time, it's the main perpetrator of the broken capitalist system, but sadly we
have to yield to survive.

This article explores my thoughts and findings on how to optimize the use of
time, money and mental load in grocy management to have enough stuff stored to
live, while following the principles of ecology and sustainability. I'm no
expert at all on either of these topics. I'm learning and making my mind while
writing these lines.

[grocy](https://grocy.info/) is a web-based self-hosted groceries & household
management solution for your home.

My chosen way to deploy grocy has been using
[Docker](https://en.wikipedia.org/wiki/Docker_%28software%29). The hard part
comes when you do the initial load, as you have to add all the:

* User attributes.
* Product locations.
* Product groups.
* Quantity conversions.
* Products.

## Tips

!!! note
    Very recommended to use the [android
    app](https://github.com/patzly/grocy-android)

* Add first the products with less letters, so add first `Toothpaste` and then
  `Toothpaste roommate`.
* Do the filling in iterations:
  * Add the common products: this can be done with the ticket of the last
    groceries, or manually inspecting all the elements in your home.
  * Incrementally add the recipes that you use
  * Add the barcodes in the products that make sense.
* Add the `score` and `shop` userfields for the products, so you can evaluate
  how much you like the product and where to buy it. If you show them in the
  columns, you can also filter the shopping list by shop.

## Minimum quantities

The minimum quantity defines when does the product is going to be added to the
shopping list, it must be enough so we have time to go to the shop to buy more,
so it has to follow:

```
minimum quantity = max_shop_frequency * average_consumption_rate * security_factor
```

Where:
* `max_shop_frequency`: is the maximum number of days between I visit the
  shop where I can obtain that product. If the product can be obtained in
  several shops we'll take the smallest number of days.
* `average_consumption_rate`: is the average number of units consumed per day.
  It can be calculated by the following equation:

  ```
  average_consumption_rate = total_units_consumed / days_since_first_unit_bought
  ```

  The calculation could be improved giving more weight to the recent consumption
  against the overall trend.

* `security_factor`: Is an amount to add to take into account the imprecisions
  on the measures. A starting `security_factor` could be 1.2.

But we won't have most of the required data when we start from scratch,
therefore I've followed the next criteria:

* If the product is critical, I want to always have at least a spare one, so the
  minimum quantity will be 2.
* I roughly evaluate the relationship between the `average_consumption_rate` and
  the `max_shop_frequency`.

Also, I usually have a recipient for the critical products, so I mark the
product as consumed once I transfer it from the original recipient to my
recipient. Therefore I always have a security factor. This also helps to reduce
the management time. For example, for the fruit, instead of marking as consumed each
time I eat a piece, I mark them as consumed when I move them from the fridge to
a recipient I've got in the living room.

## Parent products

Parent products let you group different kind of products under the same roof.
The idea is to set the minimum quantity in the parent product and it will
inherit all the quantities of it's children.

I've used parent products for example to set a minimum amount of red tea, while
storing the different red teas in different products.

The advantage of this approach is that you have a detailed product page for each
kind of product. This allows you to have different purchase - storage ratio,
price evolution, set score and description for the different kinds, set
different store...

The disadvantage is that you have to add and maintain additional products.

So if you expect that the difference between products is relevant split them, if
you don't start with one product that aggregates all, like chocolate bar for all
kinds of chocolate bars, and maybe in the future refactor it to a parent and
child products.

Another good use case is if the different brands of a product sell different
sizes, so the conversion from buy unit to storage unit is different. Then I'll
use a parent product that specifies the minimum and the different sub products
with the different conversion rate.

## On the units

I've been uncertain on what units use on some products.

Imagine you buy a jar of peas, should you use jar or grams? or a bottle of wine
should be in bottles or milliliters?

The rule of thumb I've been using is:

* If the product is going to be used in a recipe, use whatever measure the
  recipe is going to use. For example, grams for the peas.
* If not, use whatever will cost you less management time. For example,
  milliliters for the wine (so I only have to update the inventory when the
  bottle is gone).

## Future ideas

I could monitor the ratio of rotting and when a product gets below the minimum
stock to optimize the units to buy above the minimum quantity so as to minimize
the shopping frequency. It can be saved in the `max_amount` user field.

To calculate it's use I can use the average shelf life, last purchased and last
used specified in the product information


## TODO

* Define the userfields I've used
* Define the workflow for :
  * initial upload
  * purchase
  * consumption
  * cooking
* How to interact with humans that don't use the system but live in the same
  space

# Unclassified

* When creating a child product, copy the parent buy and stock units and
    conversion, also the expiration till it's solved the child creation or
    duplication (search issue)
* Use of pieza de fruta to monitor the amount instead of per product
* Caja de pañuelos solo se cuentan los que están encima de la nevera
* La avena he apuntado lo que implica el rellenar el bote para consumir solo
    cuando lo rellene.
* Locations are going to be used when you review the inventory so make sure you
    don't have to walk far
* Tare weight not supported with transfer

* it makes no sense to ask for the Location sheet to be editable, you've got the
    stock overview for that. If you want to consume do so, if you want to add
    you need to enter information one by one so you can't do it in a batch.
* If you want only to check if an ingredient exist but don't want to consume it
    select `Only check if a single unit is in stock (a different quantity can
    then be used above)`.
* Marcar bayetas como abiertas para recordarte que tienes que cambiarla
* Common userfields should go together
* Acelga o lechuga dificil de medir por raciones o piezas, tirar de gramos
* Use stock units accordingly on how you consume them. 1 ration = 1/2 lemon, and
  adjust the recipes accordingly.
* For example the acelgas are saved as pieces, lettuce, as two rations per
  piece, spinach bought as kg and saved as rations
* Important to specify the location, as you'll use it later for the inventory
  review
* IF you don't know the rations per kilogram, use kilograms till you know it.
* Buy unit the one you are going to encounter in the supermarket, both to input
  in purchase and to see the evolution of price.
* In the shops only put the ones you want to buy to, even if in others the
  product is available
* Things like the spices add them to recipes without consuming stock, and once
  you see you are low on the spice consume the rations
* In the things that are so light that 0.01 means a lot, change the buying unit
  to the equivalent x1000, even if you have to use other unit that is not the
  buying unit (species case)
* When you don't still have the complete inventory and you are cooking with
  someone, annotate in a paper the recipe or at least the elements it needs and
  afterwards transfer them to grocy.
* Evaluate the use of sublocations in grocy, like Freezer:Drawer 1.
* For products that are in two places, (fregadero and stock), consume the stock
    one instead of consuming the other and transfering the product.
* Adapt the due days of the fresh products that don't have it.
* If you hit enter in any field it commits the product (product description,
    purchase)

# Issues

* [Standard consumption location](https://github.com/grocy/grocy/issues/1365):
    Change it in the products that get consumed elsewhere.
* [Allow stock modifications from the location content sheet
    page](https://github.com/grocy/grocy/issues/1532): Nothing to do, start
    using it. He closed them as duplicate of
    [1](https://github.com/grocy/grocy/issues/682),
    [2](https://github.com/grocy/grocy/issues/1188) and
    [3](https://github.com/grocy/grocy/issues/1387).
## Resources

* [Homepage](https://grocy.info/)
