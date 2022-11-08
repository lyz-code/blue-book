---
title: AWS Savings plan
date: 20221108
author: Lyz
---

[Saving
plans](https://docs.aws.amazon.com/savingsplans/latest/userguide/what-is-savings-plans.html)
offer a flexible pricing model that provides savings on AWS usage.
You can save up to 72 percent on your AWS compute workloads.

!!! note "Please don't make Jeff Bezos even richer, try to pay as less money to
AWS as you can."

Savings Plans provide savings beyond On-Demand rates in exchange for
a commitment of using a specified amount of compute power (measured per hour)
for a one or three year period.

When you sign up for Savings Plans, the prices you'll pay for usage stays the
same through the plan term. You can pay for your commitment using All Upfront,
Partial upfront, or No upfront payment options.

Plan types:

* *Compute Savings Plans* provide the most flexibility and prices that are up
    to 66 percent off of On-Demand rates. These plans automatically apply to
    your EC2 instance usage, regardless of instance family (for example, m5, c5,
    etc.), instance sizes (for example, c5.large, c5.xlarge, etc.), Region (for
    example, us-east-1, us-east-2, etc.), operating system (for example,
    Windows, Linux, etc.), or tenancy (for example, Dedicated, default,
    Dedicated Host). With Compute Savings Plans, you can move a workload from C5
    to M5, shift your usage from EU (Ireland) to EU (London). You can continue
    to benefit from the low prices provided by Compute Savings Plans as you make
    these changes.

* *EC2 Instance Savings Plans* provide savings up to 72 percent off On-Demand,
    in exchange for a commitment to a specific instance family in a chosen AWS
    Region (for example, M5 in Virginia). These plans automatically apply to
    usage regardless of size (for example, m5.xlarge, m5.2xlarge, etc.), OS (for
    example, Windows, Linux, etc.), and tenancy (Host, Dedicated, Default)
    within the specified family in a Region.

    With an EC2 Instance Savings Plan, you can change your instance size within
    the instance family (for example, from c5.xlarge to c5.2xlarge) or the
    operating system (for example, from Windows to Linux), or move from
    Dedicated tenancy to Default and continue to receive the discounted rate
    provided by your EC2 Instance Savings Plan.

* *Standard Reserved Instances*: The old reservation system, you reserve an
    instance type and you can get up to 72 percent of discount. The lack of
    flexibility makes them inferior to the new EC2 instance plans.

* *Convertible Reserved Instances*: Same as the Standard Reserved Instances but
    with more flexibility. Discounts range up to 66%, similar to the new Compute
    Savings Plan, which again gives more less the same discounts with more
    flexibility, so I wouldn't use this plan either.

# [Understanding how Savings Plans apply to your AWS usage](https://docs.aws.amazon.com/savingsplans/latest/userguide/sp-applying.html)

If you have active Savings Plans, they apply automatically to your eligible AWS
usage to reduce your bill.

Savings Plans apply to your usage after the Amazon EC2 Reserved Instances (RI)
are applied. Then *EC2 Instance Savings Plans* are applied before *Compute
Savings Plans* because *Compute Savings Plans* have broader applicability.

They calculate your potential savings percentages of each combination of
eligible usage. This percentage compares the Savings Plans rates with your
current On-Demand rates. Your Savings Plans are applied to your highest savings
percentage first. If there are multiple usages with equal savings percentages,
Savings Plans are applied to the first usage with the lowest Savings Plans rate.
Savings Plans continue to apply until there are no more remaining usages, or
your commitment is exhausted. Any remaining usage is charged at the On-Demand
rates.

## Savings plan example

In this example, you have the following usage in a single hour:

* 4x r5.4xlarge Linux, shared tenancy instances in us-east-1, running for the
    duration of a full hour.
* 1x m5.24xlarge Linux, dedicated tenancy instance in us-east-1, running for the
    duration of a full hour.

Pricing example:

| Type        | On-Demand rate | Compute Savings Plans rate | CSP Savings percentage | EC2 Instance Savings Plans rate | EC2IS percentage |
| ---         | ---            | ---                        | ---                    | ---                             | ---              |
| r5.4xlarge  | $1.00          | $0.70                      | 30%                    | $0.60                           | 40%              |
| m5.24xlarge | $10.00         | $8.20                      | 18%                    | $7.80                           | 22%              |

They've included other products in the example but I've removed them for the
sake of simplicity

### Scenario 1: Savings Plan apply to all usage

You purchase a one-year, partial upfront Compute Savings Plan with a $50.00/hour
commitment.

Your Savings Plan covers all of your usage because multiplying each of your
usages by the equivalent Compute Savings Plans is $47.13. This is still less
than the $50.00/hour commitment.

Without Savings Plans, you would be charged at On-Demand rates in the amount of
$59.10.

### Scenario 2: Savings Plans apply to some usage

You purchase a one-year, partial upfront Compute Savings Plan with a $2.00/hour
commitment.

In any hour, your Savings Plans apply to your usage starting with the highest
discount percentage (30 percent).

Your $2.00/hour commitment is used to cover approximately 2.9 units of this
usage. The remaining 1.1 units are charged at On-Demand rates, resulting in
$1.14 of On-Demand charges for r5.

The rest of your usage are also charged at On-Demand rates, resulting in $55.10
of On-Demand charges. The total On-Demand charges for this usage are $56.24.

### Scenario 3: Savings Plans and EC2 reserved instances apply to the usage

You purchase a one-year, partial upfront Compute Savings Plan with an
$18.20/hour commitment. You have two EC2 Reserved Instances (RI) for r5.4xlarge
Linux shared tenancy in us-east-1.

First, the Reserve Instances covers two of the r5.4xlarge instances. Then, the
Savings Plans rate is applied to the remaining r5.4xlarge and the rest of the usage,
which exhausts the hourly commitment of $18.20.

### Scenario 4: Multiple Savings Plans apply to the usage

You purchase a one-year, partial upfront EC2 Instance Family Savings Plan for
the r5 family in us-east-1 with a $3.00/hour commitment. You also have
a one-year, partial upfront Compute Savings Plan with a $16.80/hour commitment.

Your EC2 Instance Family Savings Plan (r5, us-east-1) covers all of the
r5.4xlarge usage because multiplying the usage by the EC2 Instance Family
Savings Plan rate is $2.40. This is less than the $3.00/hour commitment.

Next, the Compute Savings Plan is applied to rest of the resource usage, if it
doesn't cover the whole expense, then On demand rates will apply.

# [Monitoring the savings plan](https://docs.aws.amazon.com/savingsplans/latest/userguide/sp-monitoring.html)

Monitoring is an important part of your Savings Plans usage. Understanding the
Savings Plan that you own, how they are applying to your usage, and what usage
is being covered are important parts of optimizing your costs with Savings
Plans. You can monitor your usage in multiple forms.

* [Using the
    inventory](https://docs.aws.amazon.com/savingsplans/latest/userguide/ce-sp-inventory.html):
    The Savings Plans Inventory page shows a detailed overview of the Savings
    Plans that you own, or have queued for future purchase.

    To view your Inventory page:

    * Open the [AWS Cost Management
        console](https://console.aws.amazon.com/cost-management/home).
    * In the navigation pane, under Savings Plans, choose Inventory.

* [Using the utilization
    report](https://docs.aws.amazon.com/savingsplans/latest/userguide/ce-sp-usingPR.html):
    Savings Plans utilization shows you the percentage of your Savings Plans
    commitment that you're using across your On-Demand usage. You can use your
    Savings Plans utilization report to visually understand how your Savings
    Plans apply to your usage over the configured time period. Along with
    a visualized graph, the report shows high-level metrics based on your
    selected Savings Plan, filters, and lookback periods. Utilization is
    calculated based on how your Savings Plans applied to your usage over the
    lookback period.

    For example, if you have a $10/ hour commitment, and your usage billed with
    Savings Plans rates totals to $9.80 for the hour, your utilization for that
    hour is 98 percent.

    You can find high-level metrics in the Utilization report section:

    * *On-Demand Spend Equivalent*: The amount you would have spent on the same
        usage if you didn’t commit to Savings Plans. This amount is the
        equivalent On-Demand cost based on current On-Demand rates.
    * *Savings Plans spend*: Your Savings Plans commitment spend over the
        lookback period.
    * *Total Net Savings*: The amount you saved using Savings Plans commitments
        over the selected time period, compared to the On-Demand cost estimate.

    To access your utilization report:

    * Open the [AWS Cost Management
        console](https://console.aws.amazon.com/cost-management/home).
    * On the navigation pane, choose Savings Plans.
    * In the left pane, choose Utilization report.

* [Using the coverage
    report](https://docs.aws.amazon.com/savingsplans/latest/userguide/ce-sp-usingCR.html):
    The Savings Plans coverage report shows how much of your eligible spend was
    covered by your Savings Plans, based on the selected time period.

    You can find the following high-level metrics in the Coverage report section:

    * *Average Coverage*: The aggregated Savings Plans coverage percentage based
        on the selected filters and look-back period.
    * *Additional potential savings*: Your potential savings amount based on
        your Savings Plans recommendations. This is shown as a monthly amount.
    * *On-Demand spend not covered*: The amount of eligible savings spend that
        was not covered by Savings Plans or Reserved Instances over the lookback
        period.

    To access your utilization report:

    * Open the [AWS Cost Management
        console](https://console.aws.amazon.com/cost-management/home).
    * On the navigation pane, choose Savings Plans.
    * In the left pane, choose Coverage report.

# [Doing your savings plan]()

Go to the [AWS savings plan
simulator](https://aws.amazon.com/savingsplans/compute-pricing/) and check the
different instances you were evaluating.
