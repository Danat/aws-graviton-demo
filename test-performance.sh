#!/bin/bash

echo "Testing Intel vs Graviton Performance with wrk"
echo "=================================================="

INTEL_DNS="ec2-54-210-186-24.compute-1.amazonaws.com"
GRAVITON_DNS="ec2-54-242-223-87.compute-1.amazonaws.com"
ENDPOINT="/compute?iterations=500000"

# Check if wrk is installed
if ! command -v wrk &> /dev/null; then
    echo "wrk is not installed. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install wrk
    else
        echo "Please install wrk: apt-get install wrk"
        exit 1
    fi
fi

echo "Testing Intel Instance ($INTEL_DNS)..."
echo "Test duration: 30 seconds, 4 threads, 10 connections"
echo ""
wrk -t4 -c10 -d30s --latency http://$INTEL_DNS:8080$ENDPOINT

echo ""
echo "=" 
echo ""

echo "Testing Graviton Instance ($GRAVITON_DNS)..."
echo "Test duration: 30 seconds, 4 threads, 10 connections"
echo ""
wrk -t4 -c10 -d30s --latency http://$GRAVITON_DNS:8080$ENDPOINT
