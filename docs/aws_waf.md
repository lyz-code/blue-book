---
title: AWS WAF
date: 20220221
author: Lyz
---

[AWS WAF](https://aws.amazon.com/waf/) is a web application firewall that helps
protect your web applications or APIs against common web exploits and bots that
may affect availability, compromise security, or consume excessive resources.
AWS WAF gives you control over how traffic reaches your applications by enabling
you to create security rules that control bot traffic and block common attack
patterns, such as SQL injection or cross-site scripting. You can also customize
rules that filter out specific traffic patterns.


# Extracting information

You can configure the WAF to write it's logs into S3, Kinesis or a Cloudwatch
log group. S3 saves the data in small compressed files which are difficult to
analyze, Kinesis makes sense if you post-process the data on a log system such
as [graylog](graylog.md), the last one allows you to use the WAF's builtin
cloudwatch log insights which has the next interesting reports:
            .
* Top 100 Ip addresses
* Top 100 countries
* Top 100 hosts
* Top 100 terminating rules
            .
Nevertheless, it still lacks some needed reports to analyze the traffic. But
it's quite easy to build them yourself in Cloudwatch Log Insights. If you have
time I'd always suggest to avoid using proprietary AWS tools, but sadly it's the
quickest way to get results.

## Creating Log Insights queries

Inside the Cloudwatch site, on the left menu you'll see the `Logs` tab, and
under it `Log Insights`. There you can write the query you want to run. Once it
returns the expected result, you can save it. Saved queries can be seen on the
right menu, under `Queries`.

If you later change the query, you'll see a blue dot beside the query you last
run. The query will remain changed until you click on `Actions` and then
`Reset`.

### Useful Queries

#### Top IPs

Is a directory to save the queries to analyze a count of requests aggregated by ips.

##### Top IPs query

```
fields httpRequest.clientIp
| stats count(*) as requestCount by httpRequest.clientIp
| sort requestCount desc
| limit 100
```

##### Top IPs by uri

```
fields httpRequest.clientIp
| filter httpRequest.uri like "/"
| stats count(*) as requestCount by httpRequest.clientIp
| sort requestCount desc
| limit 100
```

#### Top URIs

Is a directory to save the queries to analyze a count of requests aggregated by
uris.

##### Top URIs query

This report shows all the uris that are allowed to pass the WAF.

```
fields httpRequest.uri
| filter action like "ALLOW"
| stats count(*) as requestCount by httpRequest.uri
| sort requestCount desc
| limit 100
```

##### Top URIs of a termination rule

```
fields httpRequest.uri
| filter terminatingRuleId like "AWS-AWSManagedRulesUnixRuleSet"
| stats count(*) as requestCount by httpRequest.uri
| sort requestCount desc
| limit 100
```

##### Top URIs of an IP

```
fields httpRequest.uri
| filter @message like "6.132.241.132"
| stats count(*) as requestCount by httpRequest.uri
| sort requestCount desc
| limit 100
```

##### Top URIs of a Cloudfront ID

```
fields httpRequest.uri
| filter httpSourceId like "CLOUDFRONT_ID"
| stats count(*) as requestCount by httpRequest.uri
| sort requestCount desc
| limit 100
```

#### WAF Top terminating rules

Report that shows the top rules that are blocking the content.

```
fields terminatingRuleId
| filter terminatingRuleId not like "Default_Action"
| stats count(*) as requestCount by terminatingRuleId
| sort requestCount desc
| limit 100
```

#### Top blocks by Cloudfront ID

```
fields httpSourceId
| filter terminatingRuleId not like "Default_Action"
| stats count(*) as requestCount by httpSourceId
| sort requestCount desc
| limit 100
```

#### Top allows by Cloudfront ID

```
fields httpSourceId
| filter terminatingRuleId like "Default_Action"
| stats count(*) as requestCount by httpSourceId
| sort requestCount desc
| limit 100
```
#### WAF Top countries

```
fields httpRequest.country
| stats count(*) as requestCount by httpRequest.country
| sort requestCount desc
| limit 100
```


#### Requests by

Is a directory to save the queries to show the requests filtered by a criteria.

##### Requests by IP

```
fields @timestamp, httpRequest.uri, httpRequest.args, httpSourceId
| sort @timestamp desc
| filter @message like "6.132.241.132"
| limit 100
```

##### Requests by termination rule

```
fields @timestamp, httpRequest.uri, httpRequest.args, httpSourceId
| sort @timestamp desc
| filter terminatingRuleId like "AWS-AWSManagedRulesUnixRuleSet"
| limit 100
```

##### Requests by URI

```
fields @timestamp, httpRequest.uri, httpRequest.args, httpSourceId
| sort @timestamp desc
| filter httpRequest.uri like "wp-json"
| limit 100
```

#### WAF Top Args of an URI

```
fields httpRequest.args
| filter httpRequest.uri like "/"
| stats count(*) as requestCount by httpRequest.args
| sort requestCount desc
| limit 100
```

## Analysis workflow

To analyze the WAF insights you can:

* [Analyze the traffic of the top IPs](#analyze-the-traffic-of-the-top-ips)
* [Analyze the top URIs](#analyze-the-top-uris)
* [Analyze the terminating rules](#analyze-the-terminating-rules)

### Analyze the traffic of the top IPS

For IP in the [WAF Top IPs](#top-ips-query) report, do:

* Analyze the [top uris of that IP](#top-uris-of-an-ip) to see if they are
    legit requests or if it contains malicious requests. If you want to get the
    details of a particular request, you can use the [requests by
    uri](#requests-by-uri) report.

    For request in malicious requests:

    * If it's not being filtered by the WAF update your WAF rules.

* If the IP is malicious [mark it as problematic](#mark-ip-as-problematic).

### Analyze the top uris

For uri in the [WAF Top URIs](#top-uris) report, do:

* For argument in the [top arguments of that uri](#waf-top-args-of-an-uri)
    report, see if they are legit requests or if it's malicious. If you want to
    get the details of a particular request, you can use the [requests by
    uri](#waf-requests-by-uri) report.

    For request in malicious requests:

    * If it's not being filtered by the WAF update your WAF rules.
    * For IP in [top uris by IP](#top-uris-by-ip) report:
        * [Mark IP as problematic](#mark-ip-as-problematic).

### Analyze the terminating rules

For terminating rule in the [WAF Top terminating rules](#waf-top-terminating-rules) report, do:

* For IP in the [top ips by termination rule](#top-ips-by-termination-rule)
    [mark it as problematic](#mark-ip-as-problematic).

After some time you can see which rules are not being triggered and remove them.
With the [requests by termination rule](#requests-by-termination-rule) you can
see which requests are being blocked and try to block it in another rule set and
merge both.

### Mark IP as problematic

To process an problematic IP:

* Add it to the captcha list.
* If it is already in the captcha list and is still triggering problematic
    requests, add it to the block list.
* Add a task to remove the IP from the block or captcha list X minutes or
    hours in the future.

# References

* [Homepage](https://aws.amazon.com/waf/)
