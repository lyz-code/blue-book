After reviewing Aleph Pro, Open Aleph, [DARC](https://dataresearchcenter.org/) and Datashare I feel that the investigative reporting software environment, as of June 2025, is very brittle and under a huge crisis that will have a breaking point on October of 2025, day where OCCRP will do the switch from Aleph to Aleph Pro.

Given this scenario, I think the best thing to do, if you already have an Aleph instance, is to keep using it until things stabilise. As you won\'t have software updates
since October 2025, I suggest that from then on you protect the service
behind an VPN and/or SSL client certificate.

I also feel it\'s also a great moment to make a strategic decision on how you want to use an investigative reporting platform. Some key questions are:

- How much do you care of our data being leaked or lost by third parties?
- How much do you trust OCCRP, DARC or ICIJ?
- Do you want to switch from a self hosted platform to an external
  managed one? Will they be able to give a better service?
- If you want to stay on the self hosted solution. Shall you migrate to
  Datashare instead of Open Aleph?
- How dependent are you on open source software? How fragile are the
  teams that support that software? Can you help change that
  fragility?
- Shall you use the AI for your investigative processes? If so,
  where and when?

I hope the analysis below may help shed some light on some of these
questions. The only one that is not addressed is the AI as it\'s a more
political, philosophical one, that would make the document even longer.

# Analysis of the present

## Development dependent in US government

The two main software are developed by non-profits, Aleph by OCCRP and
Datashare by ICIJ, that received part of their funding from the US
government. This funding was lost after Naranjitler\'s administration funding
cuts:

- [OCCRP lost this year 38% of their operational
  funds](https://www.occrp.org/en/feature/with-a-strike-of-a-pen-trumps-aid-cuts-threaten-independent-journalism-around-the-world):
  \"As a result, we had to lay off 40 people --- one fifth of our
  staff --- and have temporarily reduced some of the salaries of
  others. But there is more. OCCRP has also been funding a number of
  organizations across Europe, in some of the most difficult
  countries. Eighty percent of those sub-grants that we provide to
  other newsrooms have been cut as well.\"
- [ICIJ lost this year 8.6% of their operational
  funds](https://www.icij.org/news/2025/03/unable-to-stay-in-the-country-unable-to-return-home-reporters-face-grim-prospects-after-latest-trump-cuts/)
  with no apparent effects on the software or the staff.

## OCCRP decided to close the source code of Aleph triggering the team split up

With [OCCRP decision to close the source of
Aleph](https://www.occrp.org/en/announcement/occrp-announces-a-new-chapter-for-its-investigative-data-platform-aleph-pro)
an [important part of their
team](https://dataresearchcenter.org/who-we-are/) (the co-leader of the
research and data team, the Chief Data Editor and a developer) decided
to [leave the
project](https://openaleph.org/blog/2025/03/OpenAleph-commits-to-the-commons/3510138e-16b3-4b5d-a06c-41af0aa2d517/)
and fund [DARC](https://dataresearchcenter.org).

Although they look to [be in good
terms](https://openaleph.org/blog/2025/03/OpenAleph-commits-to-the-commons/3510138e-16b3-4b5d-a06c-41af0aa2d517/).
They\'re collaborating, although it could be OCCRP trying to save their
face on this dark turn.

## These software have very few developers and no community behind them

- [Aleph](https://github.com/alephdata/aleph/graphs/contributors)
  looks to be currently developed by 2 developers, and it\'s
  development has stagnated since the main developer (\`pudo\`)
  stopped developing and moved to [Open
  Sanctions](https://github.com/opensanctions/opensanctions/graphs/contributors)
  4 years ago. 3 key members of their team have moved on to Open Aleph
  after the split. We can only guess if this is the same team that is
  developing Aleph Pro. If it\'s not then they are developers we know
  nothing about and can\'t audit.
- [Open
  Aleph](https://github.com/alephdata/aleph/compare/main...openaleph:openaleph:main)
  looks to be developed by 4 people, 3 of them were part of the Aleph
  development team until the break up. The other one created a company
  to host Aleph instances 4 years ago.
- [Datashare](https://github.com/ICIJ/datashare/graphs/contributors)
  seems to be developed by [6
  developers](https://www.icij.org/about/our-team/).

In all projects pull requests by the community have been very scarce.

## The community support is not that great

My experience requesting features, proposing fixes with Aleph before the
split is that they answer well on their slack, but are slow on the
issues and the pull requests that fall outside their planned roadmap.
Even if they are bugs. I\'ve been running a script on each ingest to fix
an UI bug for a year already. I tried to work with them in solving it
without success.

I don\'t have experience with Datashare, but they do answer and fix the
issues the people open.

# Analysis of the available software

## Aleph Pro

The analysis is based on their
[announcement](https://www.occrp.org/en/announcement/occrp-announces-a-new-chapter-for-its-investigative-data-platform-aleph-pro)
and their
[FAQ](https://www.occrp.org/en/announcement/aleph-pro-frequently-asked-questions-on-the-future-of-occrps-investigative-data-platform).

### Pros

- As long as you have less than 1TB of data and are a nonprofit it
  will, for now, cost you way less than hosting your solution
- OCCRP is behind the project

### Cons

- They seem to have an unstable, small and broken development team
- They only offer 1TB of data which is enough for small to medium
  projects but doesn\'t give much space to grow

1.  They lost my trust

    There are several reasons that make me hesitant to trust them:

    - They don\'t want to publish their source code
    - They decided that the path to solve a complicated financial
      situation is to close their source code
    - They advocated in the past (and even now!) that being
      open-sourced was a corner part of the project and yet they close
      their code.
    - They hid that [52% of their funding came from the US
      government](https://report.az/en/analytics/independent-investigation-us-gov-t-funded-occrp-and-appointed-its-leadership/).

    With the next consequences:

    - I would personally not give them my data or host their software.
    - I wouldn\'t be surprised if in the future they retract on their
      promises, such as offering Aleph Pro for free forever for
      nonprofit journalism organizations.

2.  You loose sovereignty of your data

    Either if you upload your data to their servers or host a closed
    sourced program in yours, you have no way of knowing what are they
    doing with your data. Given their economical situation, doing
    business with the data could be an option.

    It could also be potentially difficult to extract your data in the
    future.

3.  You loose sovereignty of your service

    If they host the service you depend on them for any operations such
    as maintenance, upgrades, and keeping the service up.

    You\'ll also no longer be able to change the software to apply
    patches to problems and would depend on them for their
    implementation and application.

    You\'ll no longer have any easy way to know what does the program
    do. This is critical from a security point of view as introduced
    backdoors would go unnoticed. It\'s also worrying as we could not
    audit how they implement the AI. It is known that AI solutions tend
    to be biased and may thwart the investigative process.

    Finally, if they decide to shutdown or change the conditions you\'re
    sold.

4.  I looks like they are selling smoke

    Their development activity has dropped in the recent years, they
    have a weakened team and yet they are promising a complete rewrite
    to create a brand new software. In an announce that is filled with
    buzzwords such as AI without giving any solid evidence.

    I feel that the whole announcement is written to urge people to buy
    their product and to save their face. Its not written to the
    community or their users, is for those that can give them money.

    1.  They offer significant performance upgrades and lower
        infrastructure costs at the same time that they incorporate the
        latest developments in data-analysis and AI

        Depending on how they materialise the data-analysis and AI new
        features it will mean a small to a great increase in
        infrastructure costs. Hosting these processes is very resource
        intensive and expensive.

        The decrease in infra costs may come from:

        - Hosting many aleph instances under the same infrastructure
          is more efficient than each organisation having their own.
        - They might migrate the code to a more efficient language
          like rust or go

        So even though Aleph Pro will require more resources, as they
        are all going to be hosted in OCCRP it will be cheaper overall.

        I\'m not sure how they want to implement the AI, I see two
        potential places:

        - To improve the ingest process.
        - To use LLM (like ChatGPT) to query the data.

        Both features are very, very, very expensive resource wise. The
        only way to give those features at the same time as lowering the
        infra costs is by outsourcing the AI services. If they do this,
        it will mean that your data will be processed by that third
        party, with all the awful consequences it entails.

    2.  They are selling existent features as new or are part of other
        open source projects

        Such as:

        - Rebuilt the ingest pipeline: they recently released it in
          the latest versions of Aleph
        - Modular design: The source is already modular (although it
          can always be improved)
        - Enhanced data models for better linking, filtering, and
          insights. Their model is based on followthemoney which is
          open source.

5.  They are ditching part of their user base

    They only support self-hosted solutions to enterprise license
    clients. This leaves out small organisations or privacy minded
    individuals. Even this solution is said to be maintained in
    partnership with OCCRP.

6.  The new version benefits may not be worth the costs

    They say that Aleph Pro will deliver a faster, smarter, and more
    flexible platform, combining a modern technical foundation with
    user-centered design and major performance gains. But if you do not
    do a heavy use of the service you may not need some of these
    improvements. Although they for sure would be nice to have.

7.  It could be unstable for a while

    A complete platform rewrite is usually good in the long run but
    these kind of migrations tend to have an unstable period of time
    where some of the functionality might be missing

8.  You need to make the decision blindly

    Even though they are going to give a beta if you request it, I\'m
    not sure of this, before doing the switch, you need to make the
    decision beforehand. You may not even like the new software

## Datashare

### Pros

- ICIJ, a more reliable non profit, is behind it.
- Has the biggest and stable development team
- Is the most active project
- Better community support
- You can host it
- It\'s open source

### Cons

- If you have an Aleph instance there is no documented way to migrate
  to Datashare. And there is still not an easy way to do the migration, as they don't yet use the `followthemoney` data schema.
- They won\'t host an instance for you.

## Open Aleph

### Pros

- You can host it
- It\'s open source
- The hosted solution will probably cost you way less than hosting
  your own solution (although [they don\'t show
  prices](https://openaleph.org/managed/))
- The people behind it have proven their ethic values
- I know one of their developers. She is a fantastic person which is
  very involved in putting technology in the service of society, and
  has been active at the CCC.
- They are actively reaching out to give support with the migration

### Cons

- A new small organisation is behind the project
- A small development team with few recent activity. Since their
  creation (3 months ago) their development [pace is
  slow](https://github.com/openaleph/openaleph/pulse/monthly) (the
  contributors don\'t even load). It could be because they are still
  setting up the new organisation and doing the fork.
- It may not have all the features Aleph has. They started the fork on
  November of 2024 and are 137 commits ahead and 510 behind. But they
  could be squash commits.
- Their [community forum](https://darc.social/) doesn\'t have much
  activity
- The remote hosted solution has the same problems as Aleph Pro in
  terms of data and service sovereignty. Although I do trust more DARC
  than OCCRP.
