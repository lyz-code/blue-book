---
title: Scrum
date: 20210302
author: Lyz
---

[Scrum](https://en.wikipedia.org/wiki/Scrum_%28software_development%29) is an
[agile](https://en.wikipedia.org/wiki/Agile_software_development) framework for
developing, delivering, and sustaining complex products, with an initial
emphasis on software development, although it has been used in other fields such
as personal task management.  It is designed for teams of ten or fewer members,
who break their work into goals that can be completed within time-boxed
iterations, called sprints, no longer than one month and most commonly two
weeks. The Scrum Team track progress in 15-minute time-boxed daily meetings,
called daily scrums. At the end of the sprint, the team holds sprint review, to
demonstrate the work done, a sprint retrospective to improve continuously, and
a sprint planning to prepare next sprint's tasks.

For my personal scrum workflow and in the DevOps and DevSecOps teams I've found
that Sprint goals are not operative, as multiple unrelated tasks need to
be done, so it doesn't make sense to define just one goal.

# The meetings

Scrum tries to minimize the time spent in meetings while keeping a clearly
defined direction and a healthy environment between all the people involved in
the project.

To achieve that is uses four types of meetings:

* [Daily](#daily-meetings).
* [Refinement](#refinement-meetings).
* [Retros](#retro-meetings).
* [Reviews](#review-meetings).
* [Plannings](#planning-meetings).

## Daily meetings

Dailies or weeklies are the meetings where the development team exposes at high level of
detail the current work. Similar to the dailies in the scrum terms, in the
meeting each development team member exposes:

* The advances in the assigned tasks, with special interest in the encountered
    problems and deviations from the steps defined in the refinement.
* An estimation of the tasks that are going to be left unfinished by the end of
    the sprint.

The goals of the meeting are:

* Get a general knowledge of what everyone else is doing.
* Learn from the experience gained by the others while doing their tasks.
* Get a clear idea of where we stand in terms of completing the sprint tasks.

As opposed to what it may seem, this meeting is not meant to keep track of the
productivity of each of us, we work based on trust, and know that each of us is
working our best.

## Refinement meetings

Refinement are the meetings where the development team reviews the issues in the
backlog and prepares the tasks that will probably be done in the following
sprint.

The goals of the meeting are:

* Next sprint tasks are ready to be worked upon in the next sprint. That means
    each task:
    * Meets the Definition of Ready.
    * All disambiguation in task description, validation criteria and steps
        is solved.
* Make the Planning meeting more dynamic.

The meeting is composed of the following phases:

* Scrum master preparation.
* Development team refinement.
* Product owner refinement.

### Refinement preparation

To prepare the refinement, the scrum master has to:

* Make a copy of the [Refinement document template](refinement_template.md).
* Open the OKRs document if you have one and for category in OKR categories:
  * Select the category label in the issue tracker and select the milestone of
      the semester.
  * Review which of those issues might enter the next sprint, and set the sprint
      project on them.
  * Remove the milestone from the issue filter to see if there are interesting
      issues without the milestone set.

* Go to the next sprint Kanban board:
  * Order the issues by priority.
  * Make sure there are tasks with the `Good first issue` label.
  * Make sure that there are more tasks than we can probably do so we can remove
      some instead of need to review the backlog and add more in the
      refinement.

* Fill up the sprint goals section of the refinement document.
* Create the Refinement developer team and product owner meeting calendar
    events.

### Development team refinement meeting

In this meeting the development team with the help of the scrum master, reviews
the tasks to be added to the next sprint. The steps are defined in the
refinement template.

### Product owner refinement meeting

In this meeting the product owner with the help of the scrum master reviews
the tasks to be added to the next sprint. With the refinement document as
reference:

* The expected current sprint undone tasks are reviewed.
* The sprint goals are discussed, modified and agreed. If there are many
    changes, we might think of setting the goals together in next sprints.
* The scrum master does a quick description of each issue.
* Each task priority is discussed and updated.

## Retro meetings

Retrospectives or Retros are the meetings where the scrum team plan ways to
increase the quality and effectiveness of the team.

The scrum master conducts different dynamics to help the rest of the scrum team
inspect how the last Sprint went with regards to individuals, interactions,
processes, tools, and their Definition of Done and Ready. Assumptions that led
them astray are identified and their origins explored. The most impactful
improvements are addressed as soon as possible. They may even be added to the
backlog for the next sprint.

Although improvements may be implemented at any time, the sprint
retrospective provides a formal opportunity to focus on inspection and
adaptation.

The sprint retrospective concludes the sprint.

The meeting consists of five phases, all of them conducted by the scrum master:

* *Set the stage*: There is an opening dynamic to give people time to “arrive”
    and get into the right mood.
* *Gather Data*: Help everyone remember. Create a shared pool of information
    (everybody sees the world differently). There is an initial dynamic to
    measure the general feeling of the team and the issues to analyze further.
* *Generate insights*: Analyze why did things happen the way they did, identify
    patterns and see the big picture.
* *Decide what to do*: Pick a few issues to work on and create concrete action
    plans of how you’ll address them. Adding the as issues in the scrum board.
* *Close the retrospective*: Clarify follow-ups, show appreciations, leave the
    meeting with a general good feeling, and analyze how could the
    retrospectives improve.

If you have no idea how to conduct this meeting, you can take ideas from
[retromat](https://retromat.org).

The goals of the meeting are:

* Analyze and draft a plan to iteratively improve the team's well-being, quality
    and efficiency.

## Review meetings

Reviews are the meetings where the product owner presents the sprint work to the
rest of the team and the stakeholders. The idea of what is going to be done in
the next sprint is also defined in this meeting.

The meeting goes as follows:

* The product owner explains what items have been “Done” and what has not been
    “Done”.
* The product owner discuss what went well during the sprint, what problems they
    ran into, and how those problems were solved.
* The developers demonstrate the work that it has “Done” and answers questions.
* The product owner discusses the Product Backlog as it stands in terms of the
    semester OKRs.
* The entire group collaborates on what to do next, so that the Sprint Review
    provides valuable input to subsequent Sprint Planning.

As the target audience are the stakeholders, the language must be changed
accordingly, we should give overall ideas and not get caught in complicated high
tech detailed explanations unless they ask them.

The goals of the meeting are:

* Increase the transparency on what the team has done in the sprint. By
    explaining to the stake holders:

    * What has been done.
    * The reasons why we've implemented the specific outcomes for the tasks.
    * The deviation from the expected plan of action.
    * The status of the unfinished tasks with an explanation of why weren't they
        closed.
    * The meaning of the work done in terms of the semester OKRs.

* Increase the transparency on what the team plans to do for the following
    sprint by explaining to the stakeholders:

    * What do we plan to do in the next semester.
    * How we plan to do it.
    * The meaning of the plan in terms of the semester OKRs.

* Get the feedback from the stakeholders. We expect to gather and process their
    feedback by processing their opinions both of the work done of the past
    sprint and the work to be done in the next one. It will be gathered by the
    scrum master and persisted in the board on the planning meetings.

* Incorporate the stakeholders in the decision making process of the team. By
    inviting them to define with the rest of the scrum team the tasks for the
    next sprint.

## Planning meetings

Plannings are the meetings where the scrum team decides what it's going to do in
the following sprint. The decision is made with the information gathered in the
refinement, retro and review sessions.

Conducted by the scrum master, usually only the members of the scrum team
(developers, product owner and scrum master) are present, but stakeholders can
also be invited.

If the job has been done in the previous sessions, the backlog should be
priorized and refined, so we should only add the newest issues gathered in the
retro and review, refine them and decide what we want to do this sprint.

The meeting goes as follows:

* We add the issues raised in the review to the backlog.
* We analyze the tasks on the top of the backlog, add them to the sprint
    board without assigning it to any developer.
* Once all tasks are added, we the stats of past sprints to see if the scope is
    realistic.

The goals of the meeting are:

* Assert that the tasks added to the sprint follow the global path defined by
    the semester OKRs.
* All team has a clear view of what needs to be done.
* The team makes a realistic work commitment.

# The roles

There are three roles required in the scrum team:

* Product owner.
* Scrum master.
* Developer.

## Product owner

Scrum product owner is accountable for maximizing the value of the product
resulting from the work of the scrum team.

It's roles are:

* Assist the scrum master with:
    * Priorization of the semester OKRs.
    * Monitorization of the status of the semester OKRs on reviews and
        plannings.
    * Priorization of the sprint tasks.

* Conduct the daily meetings:
    * Show the Kanban board in the meeting
    * Remind the number of weeks left until the review meeting.
    * Make sure that the team is aware of what tasks are going to be left undone
        at the end of the sprint.
    * Inform the affected stakeholders of the possible delay.

* Prepare and conduct the review meeting:
    * With the help of the scrum master, prepare the reports:
        * Create the report of the sprint, including:
            * Make sure that the [Definition of Done](#definition-of-done) is
                met for the closed tasks.
            * Explanation of the done tasks.
            * Status of uncompleted tasks, and reason why they weren't complete.
            * The meaning of the work done in terms of the semester OKRs.
        * Create the report of the proposed next sprint's planning, with
            arguments behind why we do each task.
    * Conduct the review meeting presenting the reports to the stakeholders.
* Attend the daily, review, retro and planning meetings.

## Scrum master

Scrum master is accountable for establishing Scrum as defined in this document.

This position is going to be rotated between the members of the scrum team with
a period of two sprints.

It's roles are:

* Monitoring the status of the semester OKRs on reviews and plannings.
    * Create new tasks required to meet the objectives.

* Refining the backlog:
    * Adjust priority.
    * Refine the tasks that are going to enter next sprint.
    * Organize the required meetings to refine the backlog with the team
        members.
    * Delete deprecated tasks.

* Assert that issues that are going to enter the new sprint meet the [Definition
    of Ready](#definition-of-ready).

* Arrange, prepare the daily meetings:
    * Update the calendar events according to the week needs.

* Arrange, prepare and conduct the review meeting:
    * Create the calendar event inviting the scrum team and the stakeholders.
    * With the help of the product owner, prepare the reports:
        * Create the report of the sprint, including:
            * Make sure that the [Definition of Done](#definition-of-done) is
                met for the closed tasks.
            * Explanation of the done tasks.
            * Status of uncompleted tasks, and reason why they weren't complete.
            * The meaning of the work done in terms of the semester OKRs.
        * Create the report of the proposed next sprint's planning, with
            arguments behind why we do each task.
    * Update the planning with the requirements of the stakeholders.
    * Upload the review reports to the documentation repository.

* Arrange, prepare and conduct the refinement meetings:
    * Prepare the tasks that need to be refined:
        * Adjust the priority of the backlog tasks.
        * Select the tasks that are most probably going to enter the next
            sprint.
        * Expand the description of those tasks so it's understandable by any
            team member.
        * If the task need some steps to be done before it can be worked upon,
            do them or create a task to do them before the original task.
    * Create the required refinement calendar events inviting the members of the
        scrum team.
    * Conduct the refinement meeting.
    * Update the tasks with the outcome of the meeting.
    * Prepare the next sprint's Kanban board.

* Arrange, prepare and conduct the retro meeting:
    * Prepare the dynamics of the meeting.
    * Create the retro calendar event inviting the members of the scrum team.
    * Conduct the retro meeting.
    * Update the tasks with the outcome of the meeting.
    * Upload the retro reports to the documentation repository.

* Arrange, prepare and conduct the planning meeting:
    * Make sure that you've done the required refinement sessions to have the
        tasks and Kanban board ready for the next sprint.
    * Create the planning calendar event inviting the members of the scrum team.
    * Conduct the planning meeting.
    * Update the tasks with the outcome of the meeting and start the sprint.

## Developer

Developers are the people in the scrum team that are committed to creating any
aspect of a usable increment each sprint.

It's roles are:

* Attend the daily, refinement, review, retro and planning meetings.
* Focus on completing the assigned sprint tasks.
    * Do the required work or be responsible to coordinate the work that others
        do for the task to be complete.
    * Make sure that the [Definition of Done](#definition-of-done) is met
        before closing the task.

# Inter team workflow

To improve the communication between the teams, you can:

* Present more clearly the team objectives and reasons behind our tasks, and
    make the rest of the teams part of the decision making.
* Be aware of the other team's needs and tasks.

To solve the first point, you can offer the rest of the teams different
solutions depending the time they want to invest in staying informed:

* You can invite the other team members to the sprint reviews, where you show the
    sprint's work and present what you plan to do in the next sprint. This could
    be the best way to stay informed, as you'll try to sum up everything they
    need to know in the shortest time.
* For those that want to be more involved with the decision making inside the
    team, they could be invited to the planning sessions and even the
    refinement ones where they are involved.
* For those that don't want to attend the review, they can either get a summary
    from other members of their team that did attend, or they can read the
    meeting notes that you publish after each one.

The second point means that your team members become more involved in the
other team's work. The different levels of involvement are linked to the amount
of time invested and the quality of the interaction.

The highest level of involvement would be that a member of your team is
also part of the other team. This is easier for those teams that already use
Scrum as their agile framework, that means:

* Attending the team's meetings (retro, review, planning and refinement).
* Inform the rest of your team of the outcomes of those meetings in the
    daily meeting.
* Focus on doing that team's sprint tasks.
* Populate and refine the tasks related to your team in the other team issue
    tracker.

For those teams that are smaller or don't use Scrum as their agile framework,
a your team members could accompany them by:

* Setting periodic meetings (weekly/biweekly/monthly) to discuss what are they
    doing, what do they plan to do and how.
* Create the team related tasks in your backlog, coordinating with the scrum
    master to refine and prioritize them.

# Definitions

## Definition of Ready

The Definition of Ready (DoR) is a list of criteria which must be met before any
task can be added to a sprint. It is agreed by the whole scrum team and reviewed
in the planning sessions.

### Expected Benefits

* Avoids beginning work on features that do not have clearly defined completion
    criteria, which usually translates into costly back-and-forth discussion or
    rework.
* Provides the team with an explicit agreement allowing it to “push back” on
    accepting ill-defined features to work on.
* The Definition of Ready provides a checklist which usefully guides
    pre-implementation activities: discussion, estimation, design.

### Example of a Definition of Ready

A task needs to meet the following criteria before being added to a sprint.

* Have a short title that summarizes the goal of the task.
* Have a description clear enough so any team member can understand why we
    need to do the task
* Have a validation criteria for the task to be done
* Have a checklist of steps required to meet the validation criteria, clear
    enough so that any team member can understand them.
* Have a scope that can be met in one sprint.
* Have the `Priority: ` label set.
* If other teams are involved in the task, add the `Team: ` labels.
* If it's associated to an OKR set the `OKR: ` label.

## Definition of Done

The Definition of Done (DoD) is a list of criteria which must be met before any
task can be closed. It is agreed by the whole scrum team and reviewed in the
planning sessions.

### Expected Benefits

* The Definition of Done limits the cost of rework once a feature has been
    accepted as “done”.
* Having an explicit contract limits the risk of misunderstanding and conflict
    between the development team and the customer or product owner.

### Common Pitfalls

* Obsessing over the list of criteria can be counter-productive; the list needs
    to define the minimum work generally required to get a product increment to
    the “done” state.
* Individual features or user stories may have specific “done” criteria in
    addition to the ones that apply to work in general.
* If the definition of done is merely a shared understanding, rather than
    spelled out and displayed on a wall, it may lose much of its effectiveness;
    a good part of its value lies in being an explicit contract known to all
    members of the team.

### Example of a Definition of Done

A task needs to meet the following criteria before being closed.

* [ ] All changes must be documented.
* [ ] All related pull requests must be merged.
