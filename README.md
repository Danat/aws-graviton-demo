# Graviton vs Intel Performance Demo

Cost-effective AWS demo comparing Intel and Graviton EC2 performance using a Spring Boot Kotlin application.

## Quick Start

1. **Prerequisites:**
   ```bash
   # Install AWS CLI and configure credentials
   aws configure
   
   # Create EC2 key pair if needed
   aws ec2 create-key-pair --key-name my-demo-key --query 'KeyMaterial' --output text > my-demo-key.pem
   chmod 400 my-demo-key.pem
   ```

2. **Deploy:**
   ```bash
   ./deploy.sh
   ```

3. **Test Performance:**
   ```bash
   ./test-performance.sh
   ```

4. **Cleanup:**
   ```bash
   ./cleanup.sh
   ```

## What's Deployed

- **Intel Instance:** t3.small (x86_64) - ~$15-18/month
- **Graviton Instance:** t4g.small (ARM64) - ~$12-15/month  
- **Application:** Spring Boot Kotlin app with CPU-intensive endpoint
- **Monitoring:** CloudWatch logs with structured JSON logging

## Endpoints

- Health: `http://<ip>:8080/actuator/health`
- Performance: `http://<ip>:8080/compute?iterations=1000000`
- Metrics: `http://<ip>:8080/actuator/metrics`

## Expected Results

Graviton instances typically show:
- 20-40% better price/performance ratio
- Lower execution times for CPU-intensive tasks
- Reduced monthly costs

## Cost Control

- Uses smallest production-ready instances (t3.small/t4g.small)
- Estimated total cost: ~$30-35/month for both instances
- **Always run `./cleanup.sh` when done testing**