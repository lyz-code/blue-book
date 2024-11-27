---
title: Recommender Systems
date: 20200513
author: Lyz
---

A [recommender system, or a recommendation
system](https://en.wikipedia.org/wiki/Recommender_system), is a subclass of
[information
filtering](https://en.wikipedia.org/wiki/Information_filtering_system) system
that seeks to predict the "rating" or "preference" a user would give to an item.

The entity to which the recommendation is provided is referred to as the user,
and the product being recommended is also referred to as an item. Therefore,
recommendation analysis is often based on the previous interaction between users
and items, because past interests and proclivities are often good indicators of
future choices.

These relations can be learned in a data-driven manner from the ratings matrix,
and the resulting model is used to make predictions for target users.The larger
the number of rated items that are available for a user, the easier it is to
make robust predictions about the future behavior of the user.

The problem may be formulated in two ways:

* *Prediction version of problem:* This approach aims to predict the rating
    value for a user-item combination. It is assumed that *training* data is
    available, indicating user preferences for items. For *m* users and *n*
    items, this corresponds to an incomplete *m x n* matrix, hwere the specified
    (or observed) values are used for training. The missing (or unobserved)
    values are predicted using this training model. This problem is also
    referred to as the *matrix completion problem*.
* *Ranking version of problem:* This approach aims to recommend the top-*k*
    items for a particular user, or determine the top-*k* users to target for
    a particular item. Being the first one more common. The problem is also
    referred to as the *top-k recommendation problem*.

# Goals of recommender systems

The common operational and technical goals of recommender systems are:

* *Relevance*: Recommend items that are relevant to the user at hand. Although
    it's the primary operational goal, it is not sufficient in isolation.
* *Novelty*: Recommend items that the user has not seen in the past.
* *Serendipity*: Recommend items that are outside the user's bubble, rather than
    simply something they did not know about before. For example, if a new
    Indian restaurant opens in a neighborhood, then the recommendation of that
    restaurant to a user who normally eats Indian food is novel but not
    necessarily serendipitous. On the other hand, when the same user is
    recommended Ethiopian food, and it was unknown to the user that such food
    might appeal to her, then the recommendation is serendipitous. Serendipity
    has the beneficial side effect of beginning new areas of interest.
* *Increase recommendation diversity:* Recommend items that aren't similar to
    increase the chances that the user likes at least one of these items.

# Basic Models of recommender systems

There are four types of basic models:

* *Collaborative filtering*: Use collaborative power of the ratings provided by
    multiple users to make recommendations.
* *Content-based*: Use the descriptive attributes of the user rated items to
    create a user-specific model that predicts the rating of unobserved items.
* *Knowledge-based*: Use the similarities between customer requirements and item
    descriptions.
* *Hybrid systems*: Combine the above to benefit from the mix of their strengths
    to perform more robustly.

## Collaborative Filtering Models

These models use the collaborative power of the ratings provided by multiple
users to make recommendations. The main challenge is that the underlying ratings
matrices are sparse. To solve it, unspecified ratings are guessed by analyzing
the relations of high correlation across various users and items.

There are two common types of methods.

* *Memory-based methods*: Also referred to as *neighborhood-based collaborative
    filtering algorithms*, predict ratings on the basis of their neighborhoods.
    These can be defined through two ways:

    * *User-based collaborative filtering*: Ratings provided by like-minded
        users of a target user A are used in order to make the recommendations
        for A. Thus, the goal is to determine users who are similar to the
        target user A, and recommend ratings for the unobserved ratings of A by
        computing the averages of the ratings of this peer group.
    * *Item-based collaborative filtering*: In order to make the rating
        predictions for target item B by user A, the first step is to determine
        a set S of items that are most similar to target item B. The ratings in
        the item set S, which are defined by A, are used to predict whether the
        user A will like item B.

    These systems are simple to implement and the resulting recommendations are
    often easy to explain. On the other hand, they do not work very well with
    sparse rating matrices.

* *Model-based methods*: Machine learning and data mining methods are used in
    the context of predictive models. In cases where the model is parameterized,
    the parameters of this model are learned within the context of an
    optimization framework. Some examples of such methods include decision
    trees, rule-based models, Bayesian methods and latent factor models. Many of
    these methods have a high level of coverage even for sparse ratings
    matrices.

### Types of ratings

The design of recommendation algorithms is influenced by the system used for
tracking ratings. There are different types of ratings:

* *interval-based*: A discrete set of ordered numbers are used to quantify like
    or dislike.
* *ordinal*: A discrete set of ordered categorical values, such as agree or
    strongly agree, are used to achieve the same goal.
* *binary*: Only the like or dislike for the item can be specified.
* *unary*: Only liking of an item can be specified.

Another categorization of rating systems is based in the way the feedback is
retrieved:

* *explicit ratings*: Users actively give information on their preferences.
* *implicit ratings*: Users preferences are derived from their behavior. Such as
    visiting a link. Therefore, implicit ratings are usually unary.

## Content-Based Recommender Systems

In content-based recommender systems, descriptive attributes of the user rated
items are used to create a user-specific model that predicts the rating of
unobserved items.

These systems have the following advantages:

* Works well for new items, when sufficient data is not available. If the user
    has rated items with similar attributes.
* Can make recommendations with only the data of one user.

And the following disadvantages:

* As the community knowledge from similar users is not leveraged, it tends to
    reduce the diversity of the recommended items.
* It requires large number of rating user data to produce robust predictions
    without overfitting.

## Knowledge-based Recommender Systems

The recommendation process is performed based on the similarities between user
requirements and item descriptions or the user requirements constrains. The
process is facilitated with the use of knowledge bases, which contain data about
rules and similarity functions to use during the retrieval process.

Knowledge-based systems can be classified by the type of user interface:

* *Constraint-based recommender systems*: Users specify requirements on the
    item attributes or give information about their attributes. Then domain
    specific rules are used to select the items to recommend.
* *Case-based recommender systems*: Specific cases are selected by the user as
    targets or anchor points. Similarity metrics are defined in a domain
    specific way on the item attributes to retrieve similar items to these
    cases.

These user interfaces can interact with the users through several ways:

* *Conversational systems*: User preferences are determined iteratively in
    the context of a feedback loop. It's useful if the item domain is complex.
* *Search-based systems*: User preferences are elicited by using a preset of
    questions.
* *Navigation-based recommendation*: Users specify a number of attribute changes
    to the item being recommended. Also known as *critiquing recommender
    systems*.

The main difference between content-based systems and knowledge-based systems is
that while the former learns from past user behavior, the latter does it from
active user specification of their needs and interests.

These systems have the following advantages:

* Works well for items with varied properties and/or few ratings. Such as in
    cold start scenarios, if it's difficult to capture the user interests with
    historical data or if the item is not often consumed.
* Allows the users to explicitly specify what they want, thus giving them
    a greater control over the recommendation process.
* Allows the user to iteratively change their specified requirements to reach
    the desired items.
* Can make recommendations with only the data of one user.

And the following disadvantages:

* As the community knowledge from similar users is not leveraged, it tends to
    reduce the diversity of the recommended items.

## Domain-Specific recommender systems

### Demographic recommender systems

In these systems the demographic information about the user is leveraged to
learn classifiers that can map specific demographics to ratings.

Although they do not usually provide the best results on a standalone basis,
they enhance and increase robustness if used as a component of hybrid systems.

# Pitfalls to avoid

Pre-substitution of missing ratings is not recommended in explicit rating
matrices as it leads to a significant amount of bias in the analysis. In unary
ratings it's common to substitute the missing data by 0 as even though it adds
some bias, it's not as great because it's assumed that the default behavior.

# Interesting resources

[Bookworm](https://bookwyrm.social) looks to be a promising source to build
book recommender systems.

## Content indexers

* [Open Library](https://openlibrary.org/): Open, editable library catalog,
      building towards a web page for every book ever published. Data can be
      retrieved through their API or [bulk
      downloaded](https://openlibrary.org/developers/dumps).

## Rating Datasets

### Books

* [Book-Crossing](https://grouplens.org/datasets/book-crossing/): 278,858 users
    providing 1,149,780 ratings (explicit / implicit) about 271,379 books.

### Movies

* [MovieLens](https://grouplens.org/datasets/movielens/): 27,000,000 ratings and
    1,100,000 tag applications applied to 58,000 movies by 280,000 users.
* [HetRec 2011 Movielens + IMDB/rotten
    Tomatoes](https://grouplens.org/datasets/hetrec-2011/): 86,000 ratings from
    2113 users.
* [Netflix prize dataset](https://archive.org/details/nf_prize_dataset.tar):
    480,000 users doing 100 million ratings on 17,000 movies.

### Music

* [HetRec 2011 Last.FM](https://grouplens.org/datasets/hetrec-2011/): 92,800 artist listening records from 1892 users.

### Web

* [HetRec 2011 Delicious](https://grouplens.org/datasets/hetrec-2011/): 105,000 bookmarks from 1867 users.

### Miscelaneous

* [Wikilens](https://grouplens.org/datasets/wikilens/): generalized
    collaborative recommender system that allowed its community to define item
    types (e.g. beer) and categories (e.g. microbrews, pale ales, stouts), and
    then rate and get recommendations for items.

## Past Projects

* GroupLens: Pioneer recommender system to recommend Usenet news.
* [BookLens](https://booklens.umn.edu/): Books implementation of Grouplens.
* [MovieLens](https://grouplens.org/datasets/movielens/): Movies implementation of Grouplens.

# References

## Books

* [Recommender Systems by Chary C.Aggarwal](https://www.goodreads.com/book/show/28474669-recommender-systems).
* Recommender systems, an introduction by Dietmar Jannach, Markus Zanker,
    Alexander Felfernig and Gerhard Friedrich.
* Practical Recommender Systems by Kim Falk.
* Hands On recommendation systems in Python by Rounak Banik.

## Awesome recommender systems

* [Grahamjenson](https://github.com/grahamjenson/list_of_recommender_systems)
