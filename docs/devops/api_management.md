---
title: API Management
date: 20200310
author: Lyz
---

[API management](https://en.wikipedia.org/wiki/API_management) is the process of
creating and publishing web application programming interfaces (APIs) under
a service that:

* Enforces the usage of policies.
* Controls access.
* Collects and analyzes usage statistics.
* Reports on performance.

# Components

While solutions vary, components that provide the following functionality are
typically found in API management products:

* *Gateway*: a server that acts as an API front-end, receives API requests,
    enforces throttling and security policies, passes requests to the back-end
    service and then passes the response back to the requester. A gateway often
    includes a transformation engine to orchestrate and modify the requests and
    responses on the fly. A gateway can also provide functionality such as
    collecting analytics data and providing caching. The gateway can provide
    functionality to support authentication, authorization, security, audit and
    regulatory compliance.
* *Publishing tools*: a collection of tools that API providers use to define
    APIs, for instance using the OpenAPI or RAML specifications, generate API
    documentation, manage access and usage policies for APIs, test and debug the
    execution of API, including security testing and automated generation of
    tests and test suites, deploy APIs into production, staging, and quality
    assurance environments, and coordinate the overall API lifecycle.
* *Developer portal/API store*: community site, typically branded by an API
    provider, that can encapsulate for API users in a single convenient source
    information and functionality including documentation, tutorials, sample
    code, software development kits, an interactive API console and sandbox to
    trial APIs, the ability to subscribe to the APIs and manage subscription
    keys such as OAuth2 Client ID and Client Secret, and obtain support from the
    API provider and user and community.
* *Reporting and analytics*: functionality to monitor API usage and load
    (overall hits, completed transactions, number of data objects returned,
    amount of compute time and other internal resources consumed, volume of data
    transferred). This can include real-time monitoring of the API with alerts
    being raised directly or via a higher-level network management system, for
    instance, if the load on an API has become too great, as well as
    functionality to analyze historical data, such as transaction logs, to
    detect usage trends.  Functionality can also be provided to create synthetic
    transactions that can be used to test the performance and behavior of API
    endpoints. The information gathered by the reporting and analytics
    functionality can be used by the API provider to optimize the API offering
    within an organization's overall continuous improvement process and for
    defining software Service-Level Agreements for APIs.
* *Monetization*: functionality to support charging for access to commercial
    APIs. This functionality can include support for setting up pricing rules,
    based on usage, load and functionality, issuing invoices and collecting
    payments including multiple types of credit card payments.
