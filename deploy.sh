#!/bin/bash
set -e
echo "Deploying TaskFlow..."
kubectl apply -f namespaces/
kubectl apply -f backend/
kubectl wait --for=condition=ready pod -l tier=backend \
  -n taskflow-backend --timeout=120s
kubectl apply -f frontend/
kubectl wait --for=condition=ready pod -l tier=frontend \
  -n taskflow-frontend --timeout=120s
echo "Deployment complete!"
