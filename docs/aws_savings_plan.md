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

!!! warning "When doing the savings plan reservations always use the reservation rates instead of the on-demand rates!"

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

# EC2 Instance savings plan versus reserved instances

I've been comparing the EC2 Reserved Instances and of the EC2 instance family savings plans and decided to go with the second because:

- They both have almost the same rates. Reserved instances round the price at the 3rd decimal and the savings plan at the fourth, but this difference is neglegible.
- Savings plan are easier to calculate, as you just need to multiply the number of instances you want times the current rate and add them all up.
- Easier to understand: To reserve instances you need to take into account the instance flexibility and the normalization factors which makes it difficult both to make the plans and also to audit how well you're using it.
- Easier to audit: In addition to the above point, you have nice dashboards to see the coverage and utilization over time of your ec2 instance savings plans, which are at the same place as the other savings plans.

# [Understanding how reserved instances are applied](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/apply_ri.html)

WARNING: Don't use reserved instances, use EC2 family savings plans.

A Reserved Instance that is purchased for a Region is called a regional Reserved Instance, and provides Availability Zone and instance size flexibility.

- The Reserved Instance discount applies to instance usage in any Availability Zone in that Region.
- The Reserved Instance discount applies to instance usage within the instance family, regardless of size—this is known as instance size flexibility.

With instance size flexibility, the Reserved Instance discount applies to instance usage for instances that have the same family, generation, and attribute. The Reserved Instance is applied from the smallest to the largest instance size within the instance family based on the normalization factor.

The discount applies either fully or partially to running instances of the same instance family, depending on the instance size of the reservation, in any Availability Zone in the Region. The only attributes that must be matched are the instance family, tenancy, and platform.

The following table lists the different sizes within an instance family, and the corresponding normalization factor. This scale is used to apply the discounted rate of Reserved Instances to the normalized usage of the instance family.

| Instance size | 	Normalization factor |
| --- | --- |
| nano | 	0.25 |
| micro | 	0.5 |
| small | 	1 |
| medium | 	2 |
| large | 	4 |
| xlarge | 	8 |
| 2xlarge | 	16 |
| 3xlarge | 	24 |
| 4xlarge | 	32 |
| 6xlarge | 	48 |
| 8xlarge | 	64 |
| 9xlarge | 	72 |
| 10xlarge | 	80 |
| 12xlarge | 	96 |
| 16xlarge | 	128 |
| 18xlarge | 	144 |
| 24xlarge | 	192 |
| 32xlarge | 	256 |
| 48xlarge | 	384 |
| 56xlarge | 	448 |
| 112xlarge | 	896 |

For example, a `t2.medium` instance has a normalization factor of `2`. If you purchase a `t2.medium` default tenancy Amazon Linux/Unix Reserved Instance in the US East (N. Virginia) and you have two running `t2.small` instances in your account in that Region, the billing benefit is applied in full to both instances.

Or, if you have one `t2.large` instance running in your account in the US East (N. Virginia) Region, the billing benefit is applied to 50% of the usage of the instance.

Limitations:

- *Supported*: Instance size flexibility is only supported for Regional Reserved Instances.
- *Not supported*: Instance size flexibility is not supported for the following Reserved Instances:
    - Reserved Instances that are purchased for a specific Availability Zone (zonal Reserved Instances)
    - Reserved Instances for G4ad, G4dn, G5, G5g, and Inf1 instances
    - Reserved Instances for Windows Server, Windows Server with SQL Standard, Windows Server with SQL Server Enterprise, Windows Server with SQL Server Web, RHEL, and SUSE Linux Enterprise Server
    - Reserved Instances with dedicated tenancy

## [Examples of applying reserved instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/apply_ri.html)

### Scenario 1: Reserved Instances in a single account

You are running the following On-Demand Instances in account A:

- 4 x `m3.large` Linux, default tenancy instances in Availability Zone us-east-1a
- 2 x `m4.xlarge` Amazon Linux, default tenancy instances in Availability Zone us-east-1b
- 1 x `c4.xlarge` Amazon Linux, default tenancy instances in Availability Zone us-east-1c

You purchase the following Reserved Instances in account A:

- 4 x `m3.large` Linux, default tenancy Reserved Instances in Availability Zone us-east-1a (capacity is reserved)
- 4 x `m4.large` Amazon Linux, default tenancy Reserved Instances in Region us-east-1
- 1 x `c4.large` Amazon Linux, default tenancy Reserved Instances in Region us-east-1

The Reserved Instance benefits are applied in the following way:

- The discount and capacity reservation of the four `m3.large` zonal Reserved Instances is used by the four `m3.large` instances because the attributes (instance size, Region, platform, tenancy) between them match.
- The `m4.large` regional Reserved Instances provide Availability Zone and instance size flexibility, because they are regional Amazon Linux Reserved Instances with default tenancy.

  An `m4.large` is equivalent to 4 normalized units/hour.

  You've purchased four `m4.large` regional Reserved Instances, and in total, they are equal to `16` normalized units/hour (4x4). Account A has two `m4.xlarge` instances running, which is equivalent to `16` normalized units/hour (2x8). In this case, the four `m4.large` regional Reserved Instances provide the full billing benefit to the usage of the two `m4.xlarge` instances.

  The `c4.large` regional Reserved Instance in us-east-1 provides Availability Zone and instance size flexibility, because it is a regional Amazon Linux Reserved Instance with default tenancy, and applies to the `c4.xlarge` instance. A `c4.large` instance is equivalent to `4` normalized units/hour and a `c4.xlarge` is equivalent to `8` normalized units/hour.

  In this case, the `c4.large` regional Reserved Instance provides partial benefit to `c4.xlarge` usage. This is because the `c4.large` Reserved Instance is equivalent to `4` normalized units/hour of usage, but the `c4.xlarge` instance requires `8` normalized units/hour. Therefore, the `c4.large` Reserved Instance billing discount applies to 50% of `c4.xlarge` usage. The remaining `c4.xlarge` usage is charged at the On-Demand rate.

### Scenario 2: Reserved Instances in a single account using the normalization factor

You are running the following On-Demand Instances in account A:

- 2 x `m3.xlarge` Amazon Linux, default tenancy instances in Availability Zone us-east-1a
- 2 x `m3.large` Amazon Linux, default tenancy instances in Availability Zone us-east-1b

You purchase the following Reserved Instance in account A:

- 1 x `m3.2xlarge` Amazon Linux, default tenancy Reserved Instance in Region us-east-1

The Reserved Instance benefits are applied in the following way:

- The `m3.2xlarge` regional Reserved Instance in us-east-1 provides Availability Zone and instance size flexibility, because it is a regional Amazon Linux Reserved Instance with default tenancy. It applies first to the `m3.large` instances and then to the `m3.xlarge` instances, because it applies from the smallest to the largest instance size within the instance family based on the normalization factor.

- An `m3.large` instance is equivalent to `4` normalized units/hour.
- An `m3.xlarge` instance is equivalent to `8` normalized units/hour.
- An `m3.2xlarge` instance is equivalent to `16` normalized units/hour.

The benefit is applied as follows:

The `m3.2xlarge` regional Reserved Instance provides full benefit to 2 x `m3.large` usage, because together these instances account for `8` normalized units/hour. This leaves `8` normalized units/hour to apply to the `m3.xlarge` instances.

With the remaining `8` normalized units/hour, the `m3.2xlarge` regional Reserved Instance provides full benefit to 1 x `m3.xlarge` usage, because each `m3.xlarge` instance is equivalent to `8` normalized units/hour. The remaining `m3.xlarge` usage is charged at the On-Demand rate.

# [Standard or convertible reserved instances](https://docs.aws.amazon.com/whitepapers/latest/cost-optimization-reservation-models/standard-vs.-convertible-offering-classes.html)

When you purchase a Reserved Instance, you can choose between a Standard or Convertible offering class. 

- Standard Reserved Instance: Enables you to modify Availability Zone, scope, networking type, and instance size (within the same instance type) of your Reserved Instance.
- Convertible Reserved Instance:  Enables you to exchange one or more Convertible Reserved Instances for another Convertible Reserved Instance with a different configuration, including instance family, operating system, and tenancy.

  There are no limits to how many times you perform an exchange, as long as the target Convertible Reserved Instance is of an equal or higher value than the Convertible Reserved Instances that you are exchanging.

Standard Reserved Instances typically provide the highest discount levels. One-year Standard Reserved Instances provide a similar discount to three-year Convertible Reserved Instances. 

Convertible Reserved Instances are useful when:

- Purchasing Reserved Instances in the payer account instead of a subaccount. You can more easily modify Convertible Reserved Instances to meet changing needs across your organization.
- Workloads are likely to change. In this case, a Convertible Reserved Instance enables you to adapt as needs evolve while still obtaining discounts and capacity reservations.
- You want to hedge against possible future price drops.
- You can’t or don’t want to ask teams to do capacity planning or forecasting.
- You expect compute usage to remain at the committed amount over the commitment period.

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

    For example, if you have a 10 $/hour commitment, and your usage billed with
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
    covered by your Savings Plans and how much is not covered by either Savings plan or Reserved instances based on the selected time period. 

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

    The columns are a bit tricky:

    * "Spend covered by Savings Plan": Refers to the on demand usage amount that you would have paid on demand that is being covered by the Savings Plans. Not the Savings Plan amount that is applied to on demand usage.

    The coverage report of the reserved instances has the same trick on the columns:

    * "Reservation covered hours": the column does not refer to your RI hours. This column refers to your on demand hours that was covered by Reserved Instances.

- Using the Reserved Instance Coverage report: In this report the column "Reservation covered hours" is also misleading as it does not refer to your Reserved instance hours. It refers to your on demand hours that was covered by Reserved Instances.
    
# Doing your savings plan

Important notes when doing a savings plan:

- Always use the reservation rates instead of the on-demand rates!
- Analyze your coverage reports. You don't want to have many points of 100% coverage as it means that you're using less resources than you've reserved. On the other hand it's fine to sometimes use less resources than the reserved if that will mean a greater overall savings. It's a tight balance.
- The Savings plan reservation is taken into account at hour level, not at month or year level. That means that if you reserve 1$/hour of an instance type and you use for example 2$/hour half the day and 0$/hour half the day, you'll have a 100% coverage of your plan the first hour and another 1$/hour of on-demand infrastructure cost for the first part of the day. On the second part of the day you'll have a 0% coverage. This means that you should only reserve the amount of resources you plan to be using 100% of the time throughout your savings plan. Again you may want to overcommit a little bit, reducing the utilization percentage of a plan but getting better savings in the end.

Go to the [AWS savings plan
simulator](https://aws.amazon.com/savingsplans/compute-pricing/) and check the
different instances you were evaluating.

