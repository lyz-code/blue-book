---
title: Boto3
date: 20210419
author: Lyz
---

[Boto3](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html) is
the AWS SDK for Python to create, configure, and manage AWS services,
such as Amazon Elastic Compute Cloud (Amazon EC2) and Amazon Simple Storage
Service (Amazon S3). The SDK provides an object-oriented API as well as
low-level access to AWS services.

# [Installation](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/quickstart.html#installation)

```bash
pip install boto3
```

# Usage

## S3

### [List the files of a bucket](https://stackoverflow.com/questions/53143521/listing-all-objects-in-an-s3-bucket-using-boto3)

```python
def list_s3_by_prefix(
    bucket: str, key_prefix: str, max_results: int = 100
) -> List[str]:
    next_token = ""
    all_keys = []
    while True:
        if next_token:
            res = s3.list_objects_v2(
                Bucket=bucket, ContinuationToken=next_token, Prefix=key_prefix
            )
        else:
            res = s3.list_objects_v2(Bucket=bucket, Prefix=key_prefix)

        if "Contents" not in res:
            break

        if res["IsTruncated"]:
            next_token = res["NextContinuationToken"]
        else:
            next_token = ""

        keys = [item["Key"] for item in res["Contents"]]

        all_keys.extend(keys)

        if not next_token:
            break
    return all_keys[-1 * max_results :]
```

The `boto3` doesn't have any way to sort the outputs of the bucket, you need to
do them [once you've loaded all the
objects](https://github.com/boto/boto3/issues/2248) :S.

## EC2

### Run EC2 instance

Use the
[`run_instances`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html#EC2.Client.run_instances)
method of the `ec2` client. Check their docs for the different configuration
options. The required ones are `MinCount` and `MaxCount`.

```python
import boto3

ec2 = boto3.client('ec2')
instance = ec2.run_instances(MinCount=1, MaxCount=1)
```

### Get instance types

```python
from pydantic import BaseModel
import boto3

class InstanceType(BaseModel):
    """Define model of the instance type.

    Args:
        id_: instance type name
        cpu_vcores: Number of virtual cpus (cores * threads)
        cpu_speed: Sustained clock speed in Ghz
        ram: RAM memory in MiB
        network_performance:
        price: Hourly cost
    """

    id_: str
    cpu_vcores: int
    cpu_speed: Optional[int] = None
    ram: int
    network_performance: str
    price: Optional[float] = None

    @property
    def cpu(self) -> int:
        """Calculate the total Ghz available."""
        if self.cpu_speed is None:
            return self.cpu_vcores
        return self.cpu_vcores * self.cpu_speed



def get_instance_types() -> InstanceTypes:
    """Get the available instance types."""
    log.info("Retrieving instance types")
    instance_types: InstanceTypes = {}
    for type_ in _ec2_instance_types(cpu_arch="x86_64"):
        instance = InstanceType(
            id_=instance_type,
            cpu_vcores=type_["VCpuInfo"]["DefaultVCpus"],
            ram=type_["MemoryInfo"]["SizeInMiB"],
            network_performance=type_["NetworkInfo"]["NetworkPerformance"],
            price=_ec2_price(instance_type),
        )

        with suppress(KeyError):
            instance.cpu_speed = type_["ProcessorInfo"]["SustainedClockSpeedInGhz"]

        instance_types[type_["InstanceType"]] = instance

    return instance_types
```


### [Get instance prices](https://www.saisci.com/aws/how-to-get-the-on-demand-price-of-ec2-instances-using-boto3-and-python/)

```python
import json
import boto3
from pkg_resources import resource_filename

def _ec2_price(
    instance_type: str,
    region_code: str = "us-east-1",
    operating_system: str = "Linux",
    preinstalled_software: str = "NA",
    tenancy: str = "Shared",
    is_byol: bool = False,
) -> Optional[float]:
    """Get the price of an EC2 instance type."""
    log.debug(f"Retrieving price of {instance_type}")
    region_name = _get_region_name(region_code)

    if is_byol:
        license_model = "Bring your own license"
    else:
        license_model = "No License required"

    if tenancy == "Host":
        capacity_status = "AllocatedHost"
    else:
        capacity_status = "Used"

    filters = [
        {"Type": "TERM_MATCH", "Field": "termType", "Value": "OnDemand"},
        {"Type": "TERM_MATCH", "Field": "capacitystatus", "Value": capacity_status},
        {"Type": "TERM_MATCH", "Field": "location", "Value": region_name},
        {"Type": "TERM_MATCH", "Field": "instanceType", "Value": instance_type},
        {"Type": "TERM_MATCH", "Field": "tenancy", "Value": tenancy},
        {"Type": "TERM_MATCH", "Field": "operatingSystem", "Value": operating_system},
        {
            "Type": "TERM_MATCH",
            "Field": "preInstalledSw",
            "Value": preinstalled_software,
        },
        {"Type": "TERM_MATCH", "Field": "licenseModel", "Value": license_model},
    ]

    pricing_client = boto3.client("pricing", region_name="us-east-1")
    response = pricing_client.get_products(ServiceCode="AmazonEC2", Filters=filters)

    for price in response["PriceList"]:
        price = json.loads(price)

        for on_demand in price["terms"]["OnDemand"].values():
            for price_dimensions in on_demand["priceDimensions"].values():
                price_value = price_dimensions["pricePerUnit"]["USD"]

        return float(price_value)
    return None


def _get_region_name(region_code: str) -> str:
    """Extract the region name from it's code."""
    endpoint_file = resource_filename("botocore", "data/endpoints.json")

    with open(endpoint_file, "r", encoding="UTF8") as f:
        endpoint_data = json.load(f)

    region_name = endpoint_data["partitions"][0]["regions"][region_code]["description"]
    return region_name.replace("Europe", "EU")
```

# Type hints

AWS library doesn't have working type hints `-.-`, so you either use `Any` or
dive into the myriad of packages that implement them. I've so far tried
[boto3_type_annotations](https://github.com/alliefitter/boto3_type_annotations),
[boto3-stubs](https://pypi.org/project/boto3-stubs/), and
[mypy_boto3_builder](https://github.com/vemel/mypy_boto3_builder) without
success. `Any` it is for now...

# Testing

Programs that interact with AWS through `boto3` create, change or get
information on real AWS resources.

When developing these programs, you don't want the testing framework to actually
do those changes, as it might break things and cost you money. You need to find
a way to intercept the calls to AWS and substitute them with the data their API
would return. I've found three ways to achieve this:

* Manually mocking the `boto3` methods used by the program with `unittest.mock`.
* Using [moto](https://github.com/spulec/moto).
* Using [Botocore's
    Stubber](https://botocore.amazonaws.com/v1/documentation/api/latest/reference/stubber.html).

!!! note "TL;DR"

    Try to use moto, using the stubber as fallback option.

Using `unittest.mock` forces you to know what the API is going to return and
hardcode it in your tests. If the response changes, you need to update your
tests, which is not good.

[moto](https://github.com/spulec/moto) is a library that allows you to easily
mock out tests based on AWS infrastructure. It works well because it mocks out
all calls to AWS automatically without requiring any dependency injection. The
downside is that it goes behind `boto3` so some of the methods you need to test
won't be still implemented, that leads us to the third option.

[Botocore's
Stubber](https://botocore.amazonaws.com/v1/documentation/api/latest/reference/stubber.html)
is a class that allows you to stub out requests so you don't have to hit an
endpoint to write tests. Responses are returned first in, first out. If
operations are called out of order, or are called with no remaining queued
responses, an error will be raised. It's like the first option but cleaner. If
you go down this path, check [adamj's post on testing
S3](https://adamj.eu/tech/2019/04/22/testing-boto3-with-pytest-fixtures/).

## [moto](https://github.com/spulec/moto)

moto's library lets you fictitiously create and change AWS resources as you
normally do with the `boto3` library. They mimic what the real methods do on
fake objects.

The [Docs](http://docs.getmoto.org/en/latest/docs/getting_started.html) are
awful though.

### [Install](https://github.com/spulec/moto#install)

```bash
pip install moto
```

### Simple usage

To understand better how it works, I'm going to show you an understandable
example, it's not the best way to use it though, go to the [usage
section](#usage) for production ready usage.

Imagine you have a function that you use to launch new ec2 instances:

```python
import boto3


def add_servers(ami_id, count):
    client = boto3.client('ec2', region_name='us-west-1')
    client.run_instances(ImageId=ami_id, MinCount=count, MaxCount=count)
```

To test it we'd use:

```python
from . import add_servers
from moto import mock_ec2

@mock_ec2
def test_add_servers():
    add_servers('ami-1234abcd', 2)

    client = boto3.client('ec2', region_name='us-west-1')
    instances = client.describe_instances()['Reservations'][0]['Instances']
    assert len(instances) == 2
    instance1 = instances[0]
    assert instance1['ImageId'] == 'ami-1234abcd'
```

The decorator `@mock_ec2` tells `moto` to capture all `boto3` calls to AWS. When
we run the `add_servers` function to test, it will create the fake objects on
the memory (without contacting AWS servers), and the `client.describe_instances`
`boto3` method returns the data of that fake data. Isn't it awesome?

### Usage

You can use it with [decorators](https://github.com/spulec/moto#decorator),
[context managers](https://github.com/spulec/moto#context-manager),
[directly](https://github.com/spulec/moto#raw-use) or with
[pytest fixtures](https://github.com/spulec/moto#very-important----recommended-usage).

Being a [pytest](pytest.md) fan, the last option looks the cleaner to me.

To make sure that you don't change the real infrastructure, ensure that your
tests have dummy environmental variables.

!!! note "File: `tests/conftest.py`"

    ```python
    @pytest.fixture()
    def _aws_credentials() -> None:
        """Mock the AWS Credentials for moto."""
        os.environ["AWS_ACCESS_KEY_ID"] = "testing"
        os.environ["AWS_SECRET_ACCESS_KEY"] = "testing"
        os.environ["AWS_SECURITY_TOKEN"] = "testing"
        os.environ["AWS_SESSION_TOKEN"] = "testing"


    @pytest.fixture()
    def ec2(_aws_credentials: None) -> Any:
        """Configure the boto3 EC2 client."""
        with mock_ec2():
            yield boto3.client("ec2", region_name="us-east-1")
    ```

The `ec2` fixture can then be used in the tests to setup the environment or
assert results.

#### Testing EC2

If you want to add security groups to the tests, you need to create the resource
first.

```python
def test_ec2_with_security_groups(ec2: Any) -> None:
    security_group_id = ec2.create_security_group(
        GroupName="TestSecurityGroup", Description="SG description"
    )["GroupId"]
    instance = ec2.run_instances(
        ImageId="ami-xxxx",
        MinCount=1,
        MaxCount=1,
        SecurityGroupIds=[security_group_id],
    )["Instances"][0]

    # Test your code here
```

To add tags, use:

```python
def test_ec2_with_security_groups(ec2: Any) -> None:
    instance = ec2.run_instances(
        ImageId="ami-xxxx",
        MinCount=1,
        MaxCount=1,
        TagSpecifications=[
            {
                "ResourceType": "instance",
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "instance name",
                    },
                ],
            }
        ],
    )["Instances"][0]

    # Test your code here
```

#### Testing RDS

Use the `rds` fixture:

```python
from moto import mock_rds2

@pytest.fixture()
def rds(_aws_credentials: None) -> Any:
    """Configure the boto3 RDS client."""
    with mock_rds2():
        yield boto3.client("rds", region_name="us-east-1")
```

To create an instance use:

```python
instance = rds.create_db_instance(
    DBInstanceIdentifier="db-xxxx",
    DBInstanceClass="db.m3.2xlarge",
    Engine="postgres",
)["DBInstance"]
```

It won't have VPC information, if you need it, [create the subnet group
first](https://github.com/spulec/moto/issues/2183) (you'll need the `ec2`
fixture too):

```python
subnets = [subnet['SubnetId'] for subnet in ec2.describe_subnets()["Subnets"]]
rds.create_db_subnet_group(DBSubnetGroupName="dbsg", SubnetIds=subnets, DBSubnetGroupDescription="Text")
instance = rds.create_db_instance(
    DBInstanceIdentifier="db-xxxx",
    DBInstanceClass="db.m3.2xlarge",
    Engine="postgres",
    DBSubnetGroupName="dbsg",
)["DBInstance"]
```

#### Testing S3

Use the `s3_mock` fixture:

```python
from moto import mock_s3

@pytest.fixture()
def s3_mock(_aws_credentials: None) -> Any:
    """Configure the boto3 S3 client."""
    with mock_s3():
        yield boto3.client("s3")
```

To create an instance use:

```python
s3_mock.create_bucket(Bucket="mybucket")
instance = s3_mock.list_buckets()["Buckets"][0]
```

Check the [official
docs](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/s3.html#S3.Client.create_bucket)
to check the `create_bucket` arguments.

#### Testing Route53

Use the `route53` fixture:

```python
from moto import mock_route53

@pytest.fixture(name='route53')
def route53_(_aws_credentials: None) -> Any:
    """Configure the boto3 Route53 client."""
    with mock_route53():
        yield boto3.client("route53")
```

To create an instance use:

```python
hosted_zone = route53.create_hosted_zone(
    Name="example.com", CallerReference="Test"
)["HostedZone"]
hosted_zone_id = re.sub(".hostedzone.", "", hosted_zone["Id"])
route53.change_resource_record_sets(
    ChangeBatch={
        "Changes": [
            {
                "Action": "CREATE",
                "ResourceRecordSet": {
                    "Name": "example.com",
                    "ResourceRecords": [
                        {
                            "Value": "192.0.2.44",
                        },
                    ],
                    "TTL": 60,
                    "Type": "A",
                },
            },
        ],
        "Comment": "Web server for example.com",
    },
    HostedZoneId=hosted_zone_id,
)
```
You need to first create a hosted zone. The `change_resource_record_sets` order
to create the instance doesn't return any data, so if you need to work on it,
use the `list_resource_record_sets` method of the route53 client (you'll need to
set the `HostedZoneId` argument). If you have more than 300 records, the endpoint gives
you a paginated response, so if the `IsTruncated` attribute is `True`, you need
to call the method again setting the `StartRecordName` and `StartRecordType` to
the `NextRecordName` and `NextRecordType` response arguments. Not nice at all.

Pagination [is not yet supported by
moto](https://github.com/spulec/moto/issues/3879), so you won't be able to test
that part of your code.

Check the official docs to check the method arguments:

* [`create_hosted_zone`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/route53.html#Route53.Client.create_hosted_zone).
* [`change_resource_record_sets`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/route53.html#Route53.Client.change_resource_record_sets).

#### Test VPC

Use the `ec2` fixture defined in the [usage section](#usage).

To create an instance use:

```python
instance = ec2.create_vpc(
    CidrBlock="172.16.0.0/16",
)["Vpc"]
```

Check the official docs to check the method arguments:

* [`create_vpc`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html#EC2.Client.create_vpc).
* [`create_subnet`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html#EC2.Client.create_subnet).

#### Testing autoscaling groups

Use the `autoscaling` fixture:

```python
from moto import mock_autoscaling

@pytest.fixture(name='autoscaling')
def autoscaling_(_aws_credentials: None) -> Any:
    """Configure the boto3 Autoscaling Group client."""
    with mock_autoscaling():
        yield boto3.client("autoscaling")
```

They don't [yet support
LaunchTemplates](https://github.com/spulec/moto/issues/2003), so you'll have to
use LaunchConfigurations. To create an instance use:


```python
autoscaling.create_launch_configuration(LaunchConfigurationName='LaunchConfiguration', ImageId='ami-xxxx', InstanceType='t2.medium')
autoscaling.create_auto_scaling_group(AutoScalingGroupName='ASG name', MinSize=1, MaxSize=3, LaunchConfigurationName='LaunchConfiguration', AvailabilityZones=['us-east-1a'])
instance = autoscaling.describe_auto_scaling_groups()["AutoScalingGroups"][0]
```

Check the official docs to check the method arguments:

* [`create_auto_scaling_group`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/autoscaling.html#AutoScaling.Client.create_auto_scaling_group).
* [`create_launch_configuration`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/autoscaling.html#AutoScaling.Client.create_launch_configuration).
* [`describe_auto_scaling_groups`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/autoscaling.html#AutoScaling.Client.describe_auto_scaling_groups).

#### Test Security Groups

Use the `ec2` fixture defined in the [usage section](#usage).

To create an instance use:

```python
instance_id = ec2.create_security_group(
    GroupName="TestSecurityGroup", Description="SG description"
)["GroupId"]
instance = ec2.describe_security_groups(GroupIds=[instance_id])
```

To add permissions to the security group you need to use the
`authorize_security_group_ingress` and `authorize_security_group_egress`
methods.

```python
ec2.authorize_security_group_ingress(
    GroupId=instance_id,
    IpPermissions=[
        {
            "IpProtocol": "tcp",
            "FromPort": 80,
            "ToPort": 80,
            "IpRanges": [{"CidrIp": "0.0.0.0/0"}],
        },
    ],
)
```

By default, the created security group comes with an egress rule to
allow all traffic. To remove rules use the `revoke_security_group_egress` and
`revoke_security_group_ingress` methods.

```python
ec2.revoke_security_group_egress(
    GroupId=instance_id,
    IpPermissions=[
        {"IpProtocol": "-1", "IpRanges": [{"CidrIp": "0.0.0.0/0"}]},
    ],
)
```

Check the official docs to check the method arguments:

* [`create_security_group`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html#EC2.Client.create_security_group).
* [`describe_security_group`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html#EC2.Client.describe_security_groups).
* [`authorize_security_group_ingress`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html#EC2.Client.authorize_security_group_ingress).
* [`authorize_security_group_egress`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html#EC2.Client.authorize_security_group_egress).
* [`revoke_security_group_ingress`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html#EC2.Client.revoke_security_group_ingress).
* [`revoke_security_group_egress`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html#EC2.Client.revoke_security_group_egress).

#### Test IAM users

Use the `iam` fixture:

```python
from moto import mock_iam

@pytest.fixture(name='iam')
def iam_(_aws_credentials: None) -> Any:
    """Configure the boto3 IAM client."""
    with mock_iam():
        yield boto3.client("iam")
```

To create an instance use:


```python
instance = iam.create_user(UserName="User")["User"]
```

Check the official docs to check the method arguments:

* [`create_user`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/iam.html#IAM.Client.create_user)
* [`list_users`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/iam.html#IAM.Client.list_users)

#### Test IAM Groups

Use the `iam` fixture defined in the [test IAM users section](#test-iam-users):

To create an instance use:

```python
user = iam.create_user(UserName="User")["User"]
instance = iam.create_group(GroupName="UserGroup")["Group"]
iam.add_user_to_group(GroupName=instance["GroupName"], UserName=user["UserName"])
```

Check the official docs to check the method arguments:

* [`create_group`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/iam.html#IAM.Client.create_group)
* [`add_user_to_group`](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/iam.html#IAM.Client.add_user_to_group)

# Issues

* [Support LaunchTemplates](https://github.com/spulec/moto/issues/2003): Once
    they are, test [clinv](https://github.com/lyz-code/clinv) autoscaling group
    adapter support for launch templates.
* [Support Route53 pagination](https://github.com/spulec/moto/issues/3879): test
    clinv route53 update and update the [test route53](#test-route53) section.
* [`cn-north-1` rds and autoscaling
    errors](https://github.com/spulec/moto/issues/3894): increase the timeout of
    clinv, and test if the coverage has changed.

# References

* [Git](https://github.com/boto/boto3)
* [Docs](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html)
