#!/bin/bash

## Deleting our main Application Helm chart
echo -e "\nNow Deleting our main helm chart running the golang application...\n"
helm delete gowebapp

## Deleting Cert-manager
echo -e "\nDeleting cert-manager from charts.jetstack.io\n"
kubectl delete -f https://github.com/jetstack/cert-manager/releases/download/v1.0.4/cert-manager.yaml

## Deleting metrics-server
kubectl delete -f metrics-server/

## Deleting ingress controller
kubectl -n ingress-nginx delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.41.2/deploy/static/provider/cloud/deploy.yaml

