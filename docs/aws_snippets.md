---
title: AWS Snippets
date: 20220221
author: Lyz
---

# [Invalidate a cloudfront distribution](https://docs.aws.amazon.com/cli/latest/reference/cloudfront/create-invalidation.html)

```bash
aws cloudfront create-invalidation --paths "/pages/about" --distribution-id my-distribution-id
```

# [Get EC2 metadata from within the instance](https://towardsthecloud.com/amazon-ec2-instance-metadata)

The quickest way to fetch or retrieve EC2 instance metadata from within a running EC2 instance is to log in and run the command:

Fetch metadata from IPv4:

```bash
curl -s http://169.254.169.254/latest/dynamic/instance-identity/document
```

You can also download the `ec2-metadata` tool to get the info:

```bash
# Download the ec2-metadata script
wget http://s3.amazonaws.com/ec2metadata/ec2-metadata

# Modify the permission to execute the bash script
chmod +x ec2-metadata

./ec2-metadata --all
```

# [Find if external IP belongs to you](https://aws.amazon.com/premiumsupport/knowledge-center/vpc-find-owner-unknown-ip-addresses/)

You can list the network interfaces that match the IP you're searching for

```bash
aws ec2 describe-network-interfaces --filters Name=association.public-ip,Values="{{ your_ip_address}}"
```
