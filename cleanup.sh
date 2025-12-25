#!/bin/bash
kubectl delete namespace taskflow-frontend taskflow-backend --ignore-not-found
echo "Cleanup complete!"
