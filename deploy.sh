#!/bin/bash

# Graviton vs Intel Demo Deployment Script
set -e

STACK_NAME="graviton-demo-stack"
REGION="us-east-1"
KEY_NAME=""

echo "🚀 Graviton vs Intel Performance Demo Deployment"
echo "================================================"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if user is authenticated
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS CLI is not configured. Please run 'aws configure' first."
    exit 1
fi

# Get key pair name
if [ -z "$KEY_NAME" ]; then
    echo "📋 Available EC2 Key Pairs:"
    aws ec2 describe-key-pairs --region $REGION --query 'KeyPairs[].KeyName' --output table 2>/dev/null || {
        echo "❌ No key pairs found. Please create one first:"
        echo "   aws ec2 create-key-pair --key-name my-demo-key --query 'KeyMaterial' --output text > my-demo-key.pem"
        echo "   chmod 400 my-demo-key.pem"
        exit 1
    }
    read -p "Enter your EC2 Key Pair name: " KEY_NAME
fi

echo "🔍 Checking if stack already exists..."
if aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION &>/dev/null; then
    echo "⚠️  Stack $STACK_NAME already exists."
    read -p "Do you want to update it? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🔄 Updating stack..."
        aws cloudformation update-stack \
            --stack-name $STACK_NAME \
            --template-body file://graviton-demo.yaml \
            --parameters ParameterKey=KeyName,ParameterValue=$KEY_NAME \
            --capabilities CAPABILITY_IAM \
            --region $REGION
        
        echo "⏳ Waiting for stack update to complete..."
        aws cloudformation wait stack-update-complete --stack-name $STACK_NAME --region $REGION
    else
        echo "❌ Deployment cancelled."
        exit 0
    fi
else
    echo "🚀 Creating new stack..."
    aws cloudformation create-stack \
        --stack-name $STACK_NAME \
        --template-body file://graviton-demo.yaml \
        --parameters ParameterKey=KeyName,ParameterValue=$KEY_NAME \
        --capabilities CAPABILITY_IAM \
        --region $REGION
    
    echo "⏳ Waiting for stack creation to complete (this may take 5-10 minutes)..."
    aws cloudformation wait stack-create-complete --stack-name $STACK_NAME --region $REGION
fi

echo "✅ Stack deployment completed!"
echo ""

# Get outputs
echo "📊 Getting instance information..."
INTEL_IP=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION --query 'Stacks[0].Outputs[?OutputKey==`IntelInstancePublicIP`].OutputValue' --output text)
GRAVITON_IP=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION --query 'Stacks[0].Outputs[?OutputKey==`GravitonInstancePublicIP`].OutputValue' --output text)

echo ""
echo "🖥️  Instance Details:"
echo "=================="
echo "Intel Instance:    $INTEL_IP"
echo "Graviton Instance: $GRAVITON_IP"
echo ""
echo "🔗 Test URLs:"
echo "============"
echo "Intel Health:      http://$INTEL_IP:8080/actuator/health"
echo "Graviton Health:   http://$GRAVITON_IP:8080/actuator/health"
echo "Intel Compute:     http://$INTEL_IP:8080/compute?iterations=1000000"
echo "Graviton Compute:  http://$GRAVITON_IP:8080/compute?iterations=1000000"
echo ""
echo "📱 SSH Commands:"
echo "==============="
echo "Intel:    ssh -i $KEY_NAME.pem ec2-user@$INTEL_IP"
echo "Graviton: ssh -i $KEY_NAME.pem ec2-user@$GRAVITON_IP"
echo ""
echo "🐳 ECR Repository URI:"
ECR_URI=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION --query 'Stacks[0].Outputs[?OutputKey==`ECRRepository`].OutputValue' --output text)
echo "   $ECR_URI"
echo ""
echo "📦 To build and push your image:"
echo "   ./build-and-push.sh [tag]"
echo ""
echo "💰 Estimated Cost: ~$30-35/month for both instances"
echo "⚠️  Remember to run './cleanup.sh' when done to avoid charges!"
echo ""