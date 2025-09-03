#!/bin/bash

<< task
Install and Configure ArgoCD (Worker Node Accessible) for DevSecOps Projects.
task

# Colors
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

create_namespace() {
  echo -e "${YELLOW}${BOLD}Creating ArgoCD namespace...${RESET}"
  kubectl create namespace argocd
  sleep 5
  echo -e "${GREEN}✅ Namespace created${RESET}"
}

apply_manifest() {
  echo -e "${YELLOW}${BOLD}Applying ArgoCD manifest...${RESET}"
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  echo -e "${YELLOW}${BOLD}Waiting for pods to start...${RESET}"
  sleep 20
  echo -e "${GREEN}✅ Manifest applied${RESET}"
}

install_argocd_cli() {
  echo -e "${YELLOW}${BOLD}Installing ArgoCD CLI...${RESET}"
  sudo curl --silent --location -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.4.7/argocd-linux-amd64
  sudo chmod +x /usr/local/bin/argocd
  sleep 2
  echo -e "${GREEN}✅ ArgoCD CLI installed${RESET}"
}

patch_service() {
  echo -e "${YELLOW}${BOLD}Patching ArgoCD service to NodePort...${RESET}"
  kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
  sleep 5
  echo -e "${GREEN}✅ Service patched to NodePort${RESET}"
}

check_services() {
  echo -e "${YELLOW}${BOLD}Checking ArgoCD services...${RESET}"
  kubectl get svc -n argocd
  echo -e "${GREEN}✅ Services listed${RESET}"
}

get_initial_password() {
  echo -e "${YELLOW}${BOLD}Fetching initial ArgoCD admin password...${RESET}"
  PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
  echo -e "${GREEN}✅ Retrieved admin credentials${RESET}"
  echo -e "${YELLOW}Username:${RESET} admin"
  echo -e "${YELLOW}Password:${RESET} $PASSWORD"
}

open_ports_on_worker_nodes() {
  echo -e "${YELLOW}${BOLD}Opening ArgoCD port on Worker Node Security Groups...${RESET}"

  NODE_NAMES=$(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep -v control-plane)
  ARGOCD_PORT=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.spec.ports[0].nodePort}')

  for node in $NODE_NAMES; do
    INSTANCE_ID=$(kubectl get node "$node" -o jsonpath='{.spec.providerID}' | cut -d'/' -f5)
    SG_IDS=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
      --query "Reservations[*].Instances[*].SecurityGroups[*].GroupId" --output text)

    for sg in $SG_IDS; do
      echo -e "${GREEN}→ Opening port $ARGOCD_PORT on SG: $sg${RESET}"
      aws ec2 authorize-security-group-ingress \
        --group-id "$sg" \
        --protocol tcp \
        --port "$ARGOCD_PORT" \
        --cidr 0.0.0.0/0 2>/dev/null || true
    done
  done

  echo -e "${GREEN}✅ ArgoCD NodePort access granted on all worker node SGs${RESET}"
}

get_ports_and_ip() {
  echo -e "${YELLOW}${BOLD}Fetching ArgoCD NodePort & Worker Node Public IPs...${RESET}"

  ARGOCD_PORT=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.spec.ports[0].nodePort}')
  WORKER_DNS_NAMES=$(kubectl get nodes --selector='!node-role.kubernetes.io/master' \
    -o jsonpath='{range .items[*]}{.status.addresses[?(@.type=="InternalDNS")].address}{"\n"}{end}')

  PUBLIC_IPS=""
  for dns in $WORKER_DNS_NAMES; do
    ip=$(aws ec2 describe-instances \
      --filters "Name=private-dns-name,Values=${dns}" \
      --query 'Reservations[*].Instances[*].PublicIpAddress' \
      --output text)
    PUBLIC_IPS="$PUBLIC_IPS $ip"
  done

  echo -e "${GREEN}✅ Retrieved access details${RESET}"
  for ip in $PUBLIC_IPS; do
    echo -e "${YELLOW}${BOLD}🔗 Access ArgoCD:${RESET} ${GREEN}${ip}:${ARGOCD_PORT}${RESET}"
  done
}

watch_pods() {
  echo -e "${YELLOW}${BOLD}Waiting for ArgoCD pods to be in Running state...${RESET}"
  watch kubectl get pods -n argocd
}

echo -e "${YELLOW}${BOLD}********** ARGOCD INSTALLATION STARTED **********${RESET}"

create_namespace
apply_manifest
install_argocd_cli
patch_service
check_services
get_initial_password
open_ports_on_worker_nodes
get_ports_and_ip

echo -e "${GREEN}${BOLD}********** ARGOCD INSTALLATION COMPLETED SUCCESSFULLY **********${RESET}"
echo -e "${YELLOW}You can now run '${GREEN}watch_pods${YELLOW}' to monitor pod readiness.${RESET}"