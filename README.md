# Scalable webapp infra on AWS ECS

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