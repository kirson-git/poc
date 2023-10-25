helm delete runai-backend -n runai-backend
helm delete runai-cluster -n runai
sleep 10
kubectl delete pvc,pv --all -n runai-backend
timeout 10 sh -c "kubectl delete crd $(kubectl get crd | grep run.ai | awk '{print $1}') --force --grace-period=0"
kubectl patch crd projects.run.ai   --type merge -p '{"metadata":{"finalizers":[]}}'
kubectl -n runai delete cm runai-patch
kubectl -n runai-backend delete cm runai-patch

