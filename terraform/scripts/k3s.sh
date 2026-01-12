#!/bin/bash

until ping -c 1 google.com; do
  echo "Waiting for internet..."
  sleep 5
done

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

kubectl create ns argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

sleep 60

kubectl patch cm argocd-cmd-params-cm -n argocd -p '{"data": {"server.insecure": "true"}}'
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort", "ports": [{"port": 80, "nodePort": 30001}]}}'
kubectl rollout restart deployment argocd-server -n argocd

echo "# ++++++++++++++++++++++ ARGOCD OUPUT BEGIN ++++++++++++++++++++++"
echo "$(kubectl get all -n argocd)"
echo "# ++++++++++++++++++++++ ARGOCD OUPUT END ++++++++++++++++++++++"

echo "# ++++++++++++++++++++++ ARGOCD PASSWORD END ++++++++++++++++++++++"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
echo "# ++++++++++++++++++++++ ARGOCD PASSWORD END ++++++++++++++++++++++"

echo "$(kubectl apply -f https://raw.githubusercontent.com/ebad-arshad/aws-devops-gitops-platform/master/argocd/project.yaml -n argocd)"

echo "$(kubectl apply -f https://raw.githubusercontent.com/ebad-arshad/aws-devops-gitops-platform/master/argocd/app-of-apps.yaml -n argocd)"

sleep 60

echo "$(kubectl get all -n ecommerce-dev)"