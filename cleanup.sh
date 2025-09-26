#!/bin/bash

# Cleanup script for Graviton vs Intel Demo
set -e

STACK_NAME="graviton-demo-stack"
REGION="us-east-1"

echo "Cleaning up Graviton vs Intel Demo"
echo "====================================="

# Check if stack exists
if ! aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION &>/dev/null; then
    echo "Stack $STACK_NAME does not exist or already deleted."
    exit 0
fi

echo "⚠This will delete all resources and stop billing."
read -p "Are you sure you want to delete the demo stack? (y/n): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo "🗑️  Deleting CloudFormation stack..."
aws cloudformation delete-stack --stack-name $STACK_NAME --region $REGION

echo "Waiting for stack deletion to complete..."
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME --region $REGION

echo "Cleanup completed successfully!"
echo "All resources have been deleted and billing has stopped."

# Clean up local test files
if [ -f "test-performance.sh" ]; then
    rm test-performance.sh
    echo "Removed test-performance.sh"
fi