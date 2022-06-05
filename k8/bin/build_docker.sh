eval $(minikube -p minikube docker-env)
docker build -f ../dockerfiles/Dockerfile -t spark-hadoop:3.2.0 .
