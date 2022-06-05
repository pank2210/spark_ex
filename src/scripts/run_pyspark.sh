 spark-submit \
  --master k8s://$K8S_SERVER \
  --conf spark.kubernetes.container.image=spark:v3.2.1 \
  --conf spark.kubernetes.context=minikube \
  --conf spark.kubernetes.namespace=spark-demo \
 $1
