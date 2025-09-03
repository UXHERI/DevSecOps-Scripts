#!/bin/bash

<< task
Install and Configure Prometheus & Grafana via Helm for Kubernetes Monitoring.
Also opens necessary ports in EC2 security group for public access.
Used in DevSecOps Projects.
task

# Colors for output
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
BOLD='\033[1m'
RESET='\033[0m'

install_helm() {
    echo -e "${YELLOW}${BOLD}Installing Helm...${RESET}"
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    sleep 20
    echo -e "${GREEN}${BOLD}✔ Helm installation complete.${RESET}"
}

add_helm_repos() {
    echo -e "${YELLOW}${BOLD}Adding Helm repositories...${RESET}"
    helm repo add stable https://charts.helm.sh/stable
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    echo -e "${GREEN}${BOLD}✔ Helm repositories added successfully.${RESET}"
}

create_prometheus_namespace() {
    echo -e "${YELLOW}${BOLD}Creating prometheus namespace...${RESET}"
    kubectl create namespace prometheus
    echo -e "${GREEN}${BOLD}✔ Prometheus namespace created.${RESET}"
}

install_kube_prometheus_stack() {
    echo -e "${YELLOW}${BOLD}Installing Prometheus stack using Helm...${RESET}"
    helm install stable prometheus-community/kube-prometheus-stack -n prometheus
    echo -e "${YELLOW}${BOLD}Waiting for pods to start...${RESET}"
    sleep 20
    echo -e "${GREEN}${BOLD}✔ Prometheus stack installation complete.${RESET}"
}

verify_pods() {
    echo -e "${YELLOW}${BOLD}Verifying pods in prometheus namespace...${RESET}"
    kubectl get pods -n prometheus
    echo -e "${GREEN}${BOLD}✔ Pods verification complete.${RESET}"
}

get_services() {
    echo -e "${YELLOW}${BOLD}Getting services in prometheus namespace...${RESET}"
    kubectl get svc -n prometheus
    echo -e "${GREEN}${BOLD}✔ Services listed successfully.${RESET}"
}

expose_prometheus_nodeport() {
    echo -e "${YELLOW}${BOLD}Patching Prometheus service to NodePort...${RESET}"
    kubectl patch svc stable-kube-prometheus-sta-prometheus -n prometheus \
        -p '{"spec": {"type": "NodePort"}}'
    echo -e "${GREEN}${BOLD}✔ Prometheus service exposed via NodePort.${RESET}"
}

expose_grafana_nodeport() {
    echo -e "${YELLOW}${BOLD}Patching Grafana service to NodePort...${RESET}"
    kubectl patch svc stable-grafana -n prometheus \
        -p '{"spec": {"type": "NodePort"}}'
    echo -e "${GREEN}${BOLD}✔ Grafana service exposed via NodePort.${RESET}"
}

get_ports() {
    PROMETHEUS_PORT=$(kubectl get svc stable-kube-prometheus-sta-prometheus -n prometheus -o jsonpath='{.spec.ports[0].nodePort}')
    GRAFANA_PORT=$(kubectl get svc stable-grafana -n prometheus -o jsonpath='{.spec.ports[0].nodePort}')
    echo -e "${GREEN}${BOLD}✔ Ports fetched successfully.${RESET}"
}

get_grafana_password() {
    echo -e "${YELLOW}${BOLD}Fetching Grafana admin password...${RESET}"
    GRAFANA_PASSWORD=$(kubectl get secret --namespace prometheus stable-grafana -o jsonpath="{.data.admin-password}" | base64 --decode)
    echo -e "${GREEN}${BOLD}✔ Grafana admin password retrieved.${RESET}"
}

get_worker_node_public_ip() {
    echo -e "${YELLOW}${BOLD}Fetching worker node public IP...${RESET}"
    NODE_DNS_NAMES=$(kubectl get nodes -o jsonpath='{range .items[*]}{.status.addresses[?(@.type=="InternalDNS")].address}{"\n"}{end}')
    for dns in $NODE_DNS_NAMES; do
        ip=$(aws ec2 describe-instances \
          --filters "Name=private-dns-name,Values=$dns" \
          --query "Reservations[*].Instances[*].PublicIpAddress" \
          --output text)
        if [[ -n "$ip" ]]; then
            PUBLIC_IP="$ip"
            break
        fi
    done
    echo -e "${GREEN}${BOLD}✔ Worker node public IP fetched: $PUBLIC_IP${RESET}"
}

open_ports_in_sg() {
    echo -e "${YELLOW}${BOLD}Opening NodePorts in Security Group via AWS CLI...${RESET}"

    INSTANCE_ID=$(aws ec2 describe-instances \
        --filters "Name=ip-address,Values=$PUBLIC_IP" \
        --query "Reservations[*].Instances[*].InstanceId" \
        --output text)

    SG_ID=$(aws ec2 describe-instances \
        --instance-ids "$INSTANCE_ID" \
        --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" \
        --output text)

    for port in "$PROMETHEUS_PORT" "$GRAFANA_PORT"; do
        aws ec2 authorize-security-group-ingress \
            --group-id "$SG_ID" \
            --protocol tcp \
            --port "$port" \
            --cidr 0.0.0.0/0 2>/dev/null
    done

    echo -e "${GREEN}${BOLD}✔ Ports $PROMETHEUS_PORT and $GRAFANA_PORT opened on SG $SG_ID${RESET}"
}

# --------- MAIN EXECUTION ---------

echo -e "${GREEN}${BOLD}********** PROMETHEUS & GRAFANA INSTALLATION STARTED **********${RESET}"

install_helm
add_helm_repos
create_prometheus_namespace
install_kube_prometheus_stack
verify_pods
get_services
expose_prometheus_nodeport
expose_grafana_nodeport
get_ports
get_grafana_password
get_worker_node_public_ip
open_ports_in_sg

# Final Output
echo -e "${GREEN}${BOLD}********** MONITORING SETUP COMPLETED SUCCESSFULLY **********${RESET}"
echo -e "${GREEN}✅ Prometheus and Grafana are now exposed via NodePort${RESET}"
echo -e "${YELLOW}${BOLD}🔗 Access Prometheus:${RESET} ${GREEN}http://$PUBLIC_IP:$PROMETHEUS_PORT${RESET}"
echo -e "${YELLOW}${BOLD}🔗 Access Grafana:${RESET}    ${GREEN}http://$PUBLIC_IP:$GRAFANA_PORT${RESET}"
echo -e "${YELLOW}${BOLD}🔐 Grafana Login Credentials:${RESET}"
echo -e "${GREEN}Username:${RESET} admin"
echo -e "${GREEN}Password:${RESET} $GRAFANA_PASSWORD"