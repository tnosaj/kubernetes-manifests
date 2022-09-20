kubectl label nodes wrk-master worker="false"
kubectl label nodes wrk-1 worker="true"
kubectl label nodes wrk-2 worker="true"
kubectl label nodes wrk-3 worker="true"
kubectl label nodes wrk-4 worker="true"

kubectl create configmap --namespace monitoring alertmanager-templates --from-file=alertmanager-templates/
