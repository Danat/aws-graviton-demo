#!/bin/bash

# Build separate Docker images for Intel (amd64) and Graviton (arm64)
set -e

STACK_NAME="graviton-demo-stack"
REGION="us-east-1"
IMAGE_TAG="${1:-latest}"

echo "Building separate Docker images for Intel and Graviton"
echo "========================================================"

# Get ECR repository URI from CloudFormation stack
echo "🔍 Getting ECR repository URI..."
ECR_URI=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`ECRRepository`].OutputValue' \
    --output text 2>/dev/null)

if [ -z "$ECR_URI" ]; then
    echo "Could not get ECR repository URI. Make sure the stack is deployed first."
    echo "   Run './deploy.sh' to deploy the infrastructure."
    exit 1
fi

echo "ECR Repository: $ECR_URI"

# Login to ECR
echo "Logging in to ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_URI

cd demo-app

# Build Intel/AMD64 image
echo "Building Intel (amd64) image..."
docker build --platform linux/amd64 \
    -t $ECR_URI:intel-$IMAGE_TAG \
    -t $ECR_URI:amd64-$IMAGE_TAG \
    .

# Build Graviton/ARM64 image  
echo "Building Graviton (arm64) image..."
docker build --platform linux/arm64 \
    -t $ECR_URI:graviton-$IMAGE_TAG \
    -t $ECR_URI:arm64-$IMAGE_TAG \
    .

# Push Intel image
echo "Pushing Intel (amd64) image..."
docker push $ECR_URI:intel-$IMAGE_TAG
docker push $ECR_URI:amd64-$IMAGE_TAG

# Push Graviton image
echo "Pushing Graviton (arm64) image..."
docker push $ECR_URI:graviton-$IMAGE_TAG  
docker push $ECR_URI:arm64-$IMAGE_TAG

echo "Successfully built and pushed architecture-specific images!"
echo "Image details:"
echo "   Intel:    $ECR_URI:intel-$IMAGE_TAG"
echo "   Graviton: $ECR_URI:graviton-$IMAGE_TAG"
echo ""
echo "You can now deploy or update your stack:"
echo "   ./deploy.sh"