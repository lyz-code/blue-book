# The different levels of abstractions

To be able to manage the complexity of the life roadmap we can use models for different levels of abstraction with different purposes. In increasing level of abstraction:

- [Step](#step)
- [Action](#action)
- [Project](#project)
- [Area](#area)
- [Goal](#goal)
- [Vision](#vision)
- [Purpose and principles](#purpose-and-principles)

## Step

Is the smallest unit in our model, it's a clear representation of an action you need to do. It needs to fit a phrase and usually starts in a verb. The scope of the action has to be narrow enough so that you can follow it without ambiguity. In orgmode they are represented as checklists:

```orgmode
- [ ] Go to the green grocery store
```

Sometimes is useful to add more context to the steps, you can use an indented list. For example:

```orgmode
- [ ] Call dad
  - [2023-12-11] Tried but he doesn't pick up
  - [2023-12-12] He told me to call him tomorrow
```

This is useful when you update waiting actions.

There are cases where it's also interesting to record when you've completed a step, you can append the date at the end.

```orgmode
- [x] Completed step [2023-12-12]
```

## Action

Model an action that is defined by a list of steps that need to be completed. It has two possible representations in orgmode:

- TODO items with checklists: 

  ```orgmode
  * TODO Refill the fridge
    - [ ] Check what's left in the fridge
    - [ ] Make a list of what you want to buy
    - [ ] Go to the green grocery store
  ```

- Nested steps checklists. You may realize that to make the list of what you want to buy you first want to think of what you want to eat. You could then:

  ```orgmode
  - [ ] Make a list of what you want to buy
    - [ ] Think what you want to eat
    - [ ] Write down the list
  ```

Nested lists can also be found inside todo items:

```orgmode
* TODO Refill the fridge
  - [ ] Check what's left in the fridge
  - [ ] Make a list of what you want to buy
    - [ ] Think what you want to eat
    - [ ] Write down the list
  - [ ] Go to the green grocery store
```

This is fine as long as it's manageable, once you start seeing many levels of indentation is a great sign that you need to divide your action in different actions.

### Adding more context to the action

Sometimes a action title is not enough. You need to register more context to be able to deal with the action. In those cases we need the action to be represented as a todo element. Between the title and the step list we can add the description.

```orgmode
* TODO Action title
  This is the description of the action to add more context

  - [ ] Step 1
  - [ ] Step 2
```

If you need to use a list in the context, add a Steps section below to avoid errors on the editor.

```orgmode
* TODO Action title
  This is the description of the action to add more context:
  
  - Context 1
  - Context 2

  Steps:

  - [ ] Step 1
  - [ ] Step 2
```

### Preventing the closing of a action without reading the step list

If you manage your actions from an agenda or only reading the action title, there may be cases where you feel that the action is done, but if you see the step list you may realize that there is still stuff to do. A measure that can prevent this case is to add a mark in the action title that suggest you to check the steps. For example:

```orgmode
* TODO Action title (CHECK)
  - [ ] ...
```

This is specially useful on recurring actions that have a defined workflow that needs to be followed, or on actions that have a defined validation criteria.

## Project

Model an action that gathers a list of actions towards a common greater outcome.

```orgmode
* TODO Guarantee you eat well this week
** TODO Plan what you want to eat
   - [ ] ...
** TODO Refill the fridge
   - [ ] ...
** TODO Batch cook for the week
   - [ ] ...
```

## Area

Model a group of projects and actions that follow the same interest, roles or accountabilities. These are not things to finish but rather to use as criteria for analyzing, defining a specific aspect of your life and to prioritize the projects to reach a higher outcome. We'll use areas to maintain balance and sustainability on our responsibilities as we operate in the world. 

I use specific orgmode files with the next structure:

```orgmode
#+FILETAGS: :area_name:

Objectives:
- [ ] ...

* Area roadmap
  ...
* Area backlog
  ...
```

To find them easily I add a section in the `index.org` of the documentation repository. For example:

```orgmode
* Areas
** [[file:./happiness.org][Happiness]]
*** Project 1 of happiness
** [[file:./activism.org][Activism]]
** [[file:./efficiency.org][Efficiency]]
** [[file:./work.org][Work]]
```

## Objective

An [objective] is an idea of the future or desired result that a person or a group of people envision, plan, and commit to achieve.

## Strategy

[Strategy](strategy.md) is a general plan to achieve one or more long-term or overall objectives under conditions of uncertainty. They can be used to define the direction of the [areas](#area)
## Tactic 
A [tactic](https://en.wikipedia.org/wiki/Tactic_(method)) is a conceptual action or short series of actions with the aim of achieving a short-term goal. This action can be implemented as one or more specific actions.

## Life path

Models the evolution of the principle and objectives throughout time. It's the highest level of abstraction of my life management system so far, and probably will be refactored soon in other documents.

The structure of the [orgmode](orgmode.md) document is as follows:

```orgmode
* Life path
** {year}
*** Principles of {season} {year}
    {Notes on the season}
    - Principle 1
    - Principle 2
    ...
   
**** Objectives of {month} {year}
     - [-] Objective 1
       - [X] SubObjective 1
       - [ ] SubObjective 2
     - [ ] Objective 2
     - [ ] ...
```

Where the principles are usually links to principle documents and the objectives links to actions.
## Goal

Model what you want to be experiencing in various areas of your life one or two years from now. A `goals.org` file with a list of headings may work.

## Vision 

Aggregate group of goals under a three to five year time span common outcome. They help you think about bigger categories: life strategies, environmental trends, political context, career and lifestyle transition circumstances. I haven't reached this level of abstraction yet, so I'm not sure how to implement it.

## Purpose and principles

The purpose defines the reason and meaning of your existence, principles define your morals, the parameters of action and the criteria for excellence of conduct. These are the core definition of what you really are. Visions, goals, objectives, projects and actions derive and lead towards them.

As we increase in the level of abstraction we need more time and energy (both mental and willpower) to adjust the path, it may also mean that the invested efforts so far are not aligned with the new direction, so we may need to throw away some of the advances made. That's why we need to support those changes with a higher levels of analysis and thought.

[![](not-by-ai.svg){: .center}](https://notbyai.fyi)
