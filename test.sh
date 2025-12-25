#!/bin/bash
echo "Tests required by the teacher"
echo ""
echo "STEP 1: Checking pods"
kubectl get pods -n taskflow-backend
kubectl get pods -n taskflow-frontend
echo ""

echo "STEP 2: Checking services"
kubectl get svc -n taskflow-backend
kubectl get svc -n taskflow-frontend
echo ""

echo "STEP 3: Checking NetworkPolicies"
kubectl get networkpolicies -n taskflow-backend
kubectl get networkpolicies -n taskflow-frontend
echo ""

echo "STEP 4: Testing API routes"
read -p "Did you use minikube ? Y/N -> " rep
if [[ $rep == 'Y'|| $rep == 'y' ]]
then
	NODE_IP=$(minikube ip)
else
	read -p "Enter your node ip : " NODE_IP
fi

for path in health auth tasks notifications metrics; do
  echo "=== /api/$path ==="
  curl -s http://$NODE_IP:30080/api/$path
  echo ""
done

echo "STEP 5: Testing NetworkPolicies"
echo "SHOULD WORK :"
kubectl exec -n taskflow-frontend deploy/frontend -- \
  wget -qO- http://api-gateway-svc:3000/health
kubectl exec -n taskflow-frontend deploy/gateway -- \
  wget -qO- http://auth-svc.taskflow-backend.svc.cluster.local:5000
kubectl exec -n taskflow-backend deploy/tasks -c health-checker -- \
  curl -s http://auth-svc:5000
echo "SHOULD TIMEOUT :"
kubectl exec -n taskflow-frontend deploy/frontend -- \
  wget -qO- --timeout=3 http://auth-svc.taskflow-backend:5000
echo ""

echo "STEP 6: Checking Sidecars"
echo "==> Health-Checker Sidecar Logs"
kubectl logs -n taskflow-backend deploy/tasks -c health-checker --tail=10
echo ""
echo "==> Audit Sidecar Accessibility"
kubectl exec -n taskflow-backend deploy/tasks -c health-checker -- \
  curl -s http://auth-svc:5000
echo ""

echo "STEP 7: Checking secrets"
kubectl get secrets -n taskflow-backend
kubectl exec -n taskflow-backend deploy/auth -c auth -- /bin/ls /etc/secrets
