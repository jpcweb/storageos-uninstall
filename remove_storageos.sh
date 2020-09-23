#!/bin/bash

#JPC############################################################

NS_ETCD="storageos-etcd"
NS_OPERATOR="storageos-operator"
NS_SYS="kube-system"
FILE="./storageos-operator.yaml"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

get_names(){
  k_type=$1
  k_ns=$2
  kubectl get $k_type -n $k_ns -o jsonpath='{range .items[*]}{.metadata.name}{" "}'
}

echo "#  53 74 6F 72 61 67 65 4F 53  75 6E 69 6E 73 74 61 6C 6C 2E 73 68 "
echo "#  6A 70 63 77 65 62"

#DEPLOYMENTS#####################################################
echo -e "\n${RED}[x] Remove all deployments"
echo -e "${NC}"
kubectl delete deploy etcd-operator -n $NS_ETCD
kubectl delete deploy storageos-cluster-operator -n $NS_OPERATOR
kubectl delete deploy storageos-csi-helper storageos-scheduler -n $NS_SYS

#DAEMONSETS######################################################
kubectl delete daemonsets storageos-daemonset -n $NS_SYS

#PODS############################################################
echo -e "\n${GREEN}[i] Existing pods in $NS_ETCD"
kubectl get pods -n $NS_ETCD

echo -e "\n${RED}[x] Remove all remaining pods"
echo -e "${NC}"
pods=$(get_names pods $NS_ETCD)
echo $pods
[ ! -z "$pods" ] && kubectl delete pods $pods -n $NS_ETCD || echo 'No pods to remove' 

#SERVICES########################################################
echo -e "\n${GREEN}[i] Existing services in $NS_ETCD and $NS_OPERATOR"
kubectl get svc -n $NS_ETCD
kubectl get svc -n $NS_OPERATOR

echo -e "\n${RED}[x] Remove all services"
echo -e "${NC}"
svc_etcd=$(get_names svc $NS_ETCD)
svc_operator=$(get_names svc $NS_OPERATOR)
[ ! -z "$svc_etcd" ] && kubectl delete svc $svc_etcd -n $NS_ETCD || echo 'No services to remove in $NS_ETCD'
[ ! -z "$svc_operator" ] && kubectl delete svc $svc_operator -n $NS_OPERATOR || echo 'No services to remove in $NS_OPERATOR'

kubectl delete svc storageos -n $NS_SYS

#NS AND CUSTOM RESOURCES#########################################
echo -e "\n${RED}[x] Remove all namespaces and custom resources"
echo -e "${NC}" 
kubectl delete ns storageos-etcd storageos-operator 
kubectl delete customresourcedefinitions.apiextensions.k8s.io storageosupgrades.storageos.com

echo -e "\n${RED}[x] Remove all cluster roles & cluster role bindings"
echo -e "${NS}"
kubectl delete clusterrolebindings.rbac.authorization.k8s.io etcd-operator
kubectl delete clusterroles.rbac.authorization.k8s.io etcd-operator 

if [[ -f "$FILE" ]]; then
  echo -e "\n${RED}[x] Remove the operator resources"
  echo -e "${NC}"
  kubectl delete -f $FILE
fi

echo -e "\n${RED}[x] Remove storage datas"
echo -e "${NC}"
curl -s https://docs.storageos.com/sh/permanently-delete-storageos-data.sh | bash
