# Scalable webapp infra on AWS ECS

This repository is created to deploy scalable web application infrastructure to AWS using Terraform.

## 1. Components

Following can be deployed from this repository;
- Network components
    - VPC, subnets(public, private)
    - Internet GW, NAT GW
    - Route tables
- ECS
    - ECS cluster
    - ECS service
    - Task definition (sample nginx demo app)
    - Security group
- Elastic LB (ALB)
    - ALB
    - Listener & listener rule
    - Target group
    - Security group
- IAM
- Auto Scaling

## 2. CI/CD 

This repository uses github for automated CI/CD process. When a commit/pull request happen on the "origin/main" branch, github Action pipeline is triggered and build and deploy the infrastruction using Terraform.
Check this repo's [Github Action pipeline file](.github/workflows/pipeline.yml).

## 3. Additional security

This repo provides good level of security and scalability for a common web application except for SSL/TLS on (1) URL, and (2) communication between ELB(ALB) and docker containers.

### 3-1. Securing URL with HTTPS

This is <u>recommended</u> practice for most public web applications.

1. Purchase and register a custom domain. (via Route 53 or 3rd party)
2. Request an SSL/TLS certificate. (via ACM or 3rd party)
3. Modify DNS record to redirect to ELB(ALB) endpoint.
4. Modify ELB(ALB) listener to secure the URL. 
    - Create a listener for HTTPS(443)
    - Modify HTTP(80) listener to redirect traffic to HTTPS(443) listener

### 3-2. End-to-End TLS communication

This is only recommended for application that handles sensitive information such as PII.

1. Create Envoy docker container as a proxy for the main app.
2. Add Envoy proxy image to the main app's task definition.
3. Modify ELB's target group port to 443

Detail steps can be found on this [AWS blog](https://aws.amazon.com/blogs/containers/maintaining-transport-layer-security-all-the-way-to-your-container-using-the-application-load-balancer-with-amazon-ecs-and-envoy/).
