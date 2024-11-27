---
title: Cooking software
date: 20220827
author: Lyz
---

While using [grocy](https://grocy.info/) to manage my recipes I've found what
I want from a recipe manager:

* Write recipes in plaintext files.
* Import recipes from urls.
* Import other recipes in a recipe. To avoid code repetition. For example if
    I want to do raviolis carbonara, I want to have a basic recipe to create raviolis
    and another for carbonara, then a normal recipe that imports both.
* Define processes that can be imported as steps in recipes, for example boil
    water
* Change the number the servings
* Annotate lessons learned
* Translate common cooking units (spoonful, a piece) into metric system units of
    volume and weight.
* Helper to follow the recipe while cooking
* Keep track of the evolution of the recipe each time you cook it with
    deviations from plan, evaluation of the result dish, lessons learned and
    changes made to the recipe.
* Attach image to the recipe
* Specify the storage size (a ration of lentils uses 2cm of a tupper).
* Give rating to recipes
* Track the number of times you do a recipe
* Grade the maturity level of a recipe by the number of times done and the
    number of changes.
* Browse all available recipes with the possibility of:
    * Search by name
    * Search by ingredient
    * Filter by season
    * Filter by meal type (lunch, dinner, dessert...)
    * Sort by rating
    * Sort by number of times cooked
    * Sort by last time cooked
    * Show never cooked recipes
* Do a meal plan
* Create reusable meal plans
* Be able to talk to the inventory management tool to:
    * See if there are enough ingredients.
    * Fill up the shopping list.
* Select which recipes I want to cook this month, the program should show me the
    available ones taking into account the season.
* Keep track of the season of the ingredients, so you can mark an ingredient as
    in season or out of season, and that will allow you to select which recipes
    to add, or tell you which recipes are no longer going to be available.
* Define variations of a recipe, imagine that instead of red pepper you have
    green
* Be able to tell the brand of an ingredient
* Define the cooking tools to use, which will be shown when preparing a recipe
* Define the preparing and clean steps of a cooking tool.
* Show the number of inactivity interruptions, their time and the total amount
    of inactive time.
* Calculate the recipe time from the times of the processes involved and
    subsequent recipes
* Be able to define where each process is carried out, what is the distance
    between the places
* Suggest optimizations in the cooking process:
    * Reorder of steps to reduce waiting time and movement
* Be able to start from the basic features and incrementally add on it

# Software review

## [Grocy](https://grocy.info/)

Grocy is an awesome software to manage your inventory, it's also a good one to
manage your recipes, with an awesome integration with the inventory management.
In fact, I've been using it for some years.

Nevertheless, you can't:

* Write them in plaintext.
* Reuse recipes with other recipes in a pleasant way.
* Do variations of a recipe.
* Track the variations of a recipe.

So I think whatever I choose to manage recipes needs to be able to speak to
a Grocy instance at least to get an idea of the stock available and to complete
the shopping list.

## [Cooklang](https://cooklang.org/)

`Cooklang` looks real good, you write the recipes in plaintext but the syntax is
not as smooth as I'd like:

```
Then add @salt and @ground black pepper{} to taste.
```

I'd like the parser to be able to detect the ingredient `salt` without the need
of the `@`, and I don't either like how to specify the measurements:

```
Place @bacon strips{1%kg} on a baking sheet and glaze with @syrup{1/2%tbsp}.
```

On the other side there is more less popular:

* Their [spec](https://github.com/cooklang) has their spec 400 stars.
* It has a cli, and an Android and ios apps
* There is a [vim plugin](https://github.com/luizribeiro/vim-cooklang) for the
    syntax.
* You can [import recipes](https://github.com/cooklang/cook-import) from urls.
* There are some [recipe
    books](https://github.com/cooklang/awesome-cooklang-recipes), [some of
    them](https://nicholaswilde.io/recipes/asian/coconut-curried-vegetables-with-rice/#step-4)
    look nice with a [`mkdocs`](mkdocs.md) frontend.

It could be used as part of the system, but it falls short in many of my desired
features.

## [KookBook](https://github.com/KDE/kookbook)

`KookBook` is KDE solution for plaintext recipe management. Their documentation
is sparse and not popular at all. I don't feel like using it.

## [RecipeSage](https://github.com/julianpoy/RecipeSage)
RecipeSage is free personal recipe keeper, meal planner, and shopping list
manager for Web, IOS, and Android.

Quickly capture and save recipes from any website simply by entering the website
URL. Sync your recipes, meal plans, and shopping lists between all of your
devices. Share your recipes, shopping lists, and meal plans with family and
friends.

It looks good, but I'd use `grocy` instead.

## [Mealie](https://github.com/hay-kot/mealie)
Mealie is a self hosted recipe manager and meal planner with a RestAPI backend
and a reactive frontend application built in Vue for a pleasant user experience
for the whole family. Easily add recipes into your database by providing the url
and mealie will automatically import the relevant data or add a family recipe
with the UI editor.

It does have an [API](https://nightly.mealie.io/api/redoc/), but it looks too
complex. Maybe to be used as a backend to retrieve recipes from the internet,
but no plaintext recipes.


## [Chowdown](https://chowdown.io/)

`Chowdown` is a simple, plaintext recipe database for hackers. It has nice
features:

* You write your recipes in Markdown.
* You can easily import recipes in other recipes.

An example would be:

~~~
---

layout: recipe
title:  "Broccoli Beer Cheese Soup"
image: broccoli-beer-cheese-soup.jpg
tags: sides, soups

ingredients:
- 4 tablespoons butter
- 1 cup diced onion
- 1/2 cup shredded carrot
- 1/2 cup diced celery
- 1 tablespoon garlic
- 1/4 cup flour
- 1 quart chicken broth
- 1 cup heavy cream
- 10 ounces muenster cheese
- 1 cup white white wine
- 1 cup pale beer
- 1 teaspoon Worcestershire sauce
- 1/2 teaspoon hot sauce

directions:
- Start with butter, onions, carrots, celery, garlic until cooked down
- Add flour, stir well, cook for 4-5 mins
- Add chicken broth, bring to a boil
- Add wine and reduce to a simmer
- Add cream, cheese, Worcestershire, and hot sauce
- Serve with croutons

---

This recipe is inspired by one of my favorites, Gourmand's Beer Cheese Soup, which uses Shiner Bock. Feel free to use whatever you want, then go to [Gourmand's](http://lovethysandwich.com) to have the real thing.
~~~


Or using other recipes:

~~~
---

layout: recipe
title:  "Red Berry Tart"
image: red-berry-tart.jpg
tags: desserts

directions:
- Bake the crust and let it cool
- Make the custard, pour into crust
- Make the red berry topping, spread over the top

components:
- Graham Cracker Crust
- Vanilla Custard Filling
- Red Berry Dessert Topping

---

A favorite when I go to BBQs (parties, hackathons, your folks' place), this red berry tart is fairly easy to make and packs a huge wow factor.
~~~

Where `Graham Cracker Crust` is another recipe. The outcome [is nice
too](https://chowdown.io/recipes/red-berry-tart.html).

Downsides are:

* It's written in HTML and javascript.
* They [don't answer issues](https://github.com/clarklab/chowdown/issues) so it
    looks unmaintained.

It redirects to an interesting [schema of a recipe](https://schema.org/Recipe).

https://github.com/clarklab/chowdown
https://raw.githubusercontent.com/clarklab/chowdown/gh-pages/_recipes/broccoli-cheese-soup.md
https://www.paprikaapp.com/

## [Recipes](https://github.com/TandoorRecipes/recipes)

https://docs.tandoor.dev/features/authentication/

## [Chef](https://esolangs.org/wiki/Chef)
