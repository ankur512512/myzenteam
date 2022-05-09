#!/bin/bash

## Downloading & Installing Cert-manager
echo -e "\nInstalling cert-manager from charts.jetstack.io\n"
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.0.4/cert-manager.yaml

## Installing metrics-server
echo -e "\nInstalling metrics-server for HPA (Horizontal Pod Autoscaler)\n"
kubectl apply -f metrics-server/

## Deploying ingress controller
kubectl create ns ingress-nginx
kubectl -n ingress-nginx apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.41.2/deploy/static/provider/cloud/deploy.yaml

## Waiting for ingress pods to be ready
while [[ $(kubectl get pods -n ingress-nginx -l app.kubernetes.io/component=controller -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo -e "\nwaiting for nginx controller pod to get ready..." && sleep 4; done

## Port-forwarding the ingress service as we are using k8s on local server
kubectl -n ingress-nginx --address 0.0.0.0 port-forward svc/ingress-nginx-controller 80 > /dev/null 2>&1 &
kubectl -n ingress-nginx --address 0.0.0.0 port-forward svc/ingress-nginx-controller 443 > /dev/null 2>&1 &

## Installing our main Application Helm chart
echo -e "\nNow installing our main helm chart running the golang application...\n"
helm upgrade --install gowebapp helm/ --set "ingress.hosts[0].host=$hostname" --set "ingress.tls[0].hosts[0]=$hostname" --values=helm/values.yaml

## Waiting for our application "gowebapp" to get ready
while [[ $(kubectl get pods -l app.kubernetes.io/instance=gowebapp -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo -e "\nwaiting for gowebapp pod to get ready..." && sleep 4; done

## Checking with curl command
echo -e "\nUsing curl command with https to see if everything working fine..."
sleep 10
curl -L https://"$hostname"