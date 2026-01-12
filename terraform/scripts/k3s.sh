#!/bin/bash

sleep 30

echo "# ++++++++++++++++++++++ APT UPDATE BEGIN ++++++++++++++++++++++"
apt update
echo "# ++++++++++++++++++++++ APT UPDATE END ++++++++++++++++++++++"

CURL="curl"

echo "# ++++++++++++++++++++++ CURL INSTALL BEGIN ++++++++++++++++++++++"
apt install -y "$CURL"
echo "# ++++++++++++++++++++++ CURL INSTALL END ++++++++++++++++++++++"

if [ $? -eq 0 ]; then
    echo "Successfully installed $CURL."
else
    echo "Failed to install $CURL. Exiting script."
    exit 1
fi

echo "# ++++++++++++++++++++++ K3S INSTALL BEGIN ++++++++++++++++++++++"
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --disable traefik --write-kubeconfig-mode 644" sh -
echo "# ++++++++++++++++++++++ K3S INSTALL END ++++++++++++++++++++++"

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

echo "# ++++++++++++++++++++++ SLEEP 30 SECONDS ++++++++++++++++++++++"
sleep 30

echo "# ++++++++++++++++++++++ K3S NODE OUPUT BEGIN ++++++++++++++++++++++"

echo "Waiting for K3s to be ready..."
until kubectl get nodes | grep -q "Ready"; do
  sleep 5
done

echo "$(kubectl get nodes)"
echo "# ++++++++++++++++++++++ K3S NODE OUPUT END ++++++++++++++++++++++"

echo "# ++++++++++++++++++++++ CREATING DEPLOYMENT.YAML ++++++++++++++++++++++"
echo "# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
cat <<EOT > /tmp/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
EOT

echo "# ++++++++++++++++++++++ CREATING SERVICE.YAML ++++++++++++++++++++++"
echo "# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

cat <<EOT > /tmp/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 30001
EOT

echo "# ++++++++++++++++++++++ CREATING NAMESPACE, DEPLOYMENT, SERVICE ++++++++++++++++++++++"
echo "$(kubectl create ns nginx || true)"
echo "$(kubectl apply -f /tmp/service.yaml -n nginx)"
echo "$(kubectl apply -f /tmp/deployment.yaml -n nginx)"
echo "# ++++++++++++++++++++++ CREATED NAMESPACE, DEPLOYMENT, SERVICE ++++++++++++++++++++++"

echo "# ++++++++++++++++++++++ SLEEP 30 SECONDS ++++++++++++++++++++++"
sleep 30

echo "# ++++++++++++++++++++++ NGINX OUPUT BEGIN ++++++++++++++++++++++"
echo "$(kubectl get all -n nginx)"
echo "# ++++++++++++++++++++++ NGINX OUPUT END ++++++++++++++++++++++"















# #!/bin/bash

# sleep 30

# echo "# ++++++++++++++++++++++ APT UPDATE BEGIN ++++++++++++++++++++++"
# apt update
# echo "# ++++++++++++++++++++++ APT UPDATE END ++++++++++++++++++++++"

# CURL="curl"

# echo "# ++++++++++++++++++++++ CURL INSTALL BEGIN ++++++++++++++++++++++"
# apt install -y "$CURL"
# echo "# ++++++++++++++++++++++ CURL INSTALL END ++++++++++++++++++++++"

# if [ $? -eq 0 ]; then
#     echo "Successfully installed $CURL."
# else
#     echo "Failed to install $CURL. Exiting script."
#     exit 1
# fi

# echo "# ++++++++++++++++++++++ K3S INSTALL BEGIN ++++++++++++++++++++++"
# curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --disable traefik --write-kubeconfig-mode 644" sh -
# echo "# ++++++++++++++++++++++ K3S INSTALL END ++++++++++++++++++++++"

# export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# echo "# ++++++++++++++++++++++ SLEEP 30 SECONDS ++++++++++++++++++++++"
# sleep 30

# echo "# ++++++++++++++++++++++ K3S NODE OUPUT BEGIN ++++++++++++++++++++++"

# echo "Waiting for K3s to be ready..."
# until kubectl get nodes | grep -q "Ready"; do
#   sleep 5
# done

# echo "$(kubectl get nodes)"
# echo "# ++++++++++++++++++++++ K3S NODE OUPUT END ++++++++++++++++++++++"

# kubectl create ns argocd
# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.2.3/manifests/core-install.yaml

# sleep 60

# echo "# ++++++++++++++++++++++ ARGOCD OUPUT BEGIN ++++++++++++++++++++++"
# echo "$(kubectl get all -n argocd)"
# echo "# ++++++++++++++++++++++ ARGOCD OUPUT END ++++++++++++++++++++++"

# echo "# ++++++++++++++++++++++ ARGOCD PASSWORD END ++++++++++++++++++++++"
# kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
# echo "# ++++++++++++++++++++++ ARGOCD PASSWORD END ++++++++++++++++++++++"

# kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort", "ports": [{"port": 80, "nodePort": 30001}]}}'