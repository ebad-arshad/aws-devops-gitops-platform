#!/bin/bash

sleep 30

echo "# ++++++++++++++++++++++ APT UPDATE BEGIN ++++++++++++++++++++++"
apt update
echo "# ++++++++++++++++++++++ APT UPDATE END ++++++++++++++++++++++"

OPENJDK="openjdk-21-jre"

apt install -y "$OPENJDK"

if [ $? -eq 0 ]; then
    echo "Successfully installed $OPENJDK."
else
    echo "Failed to install $OPENJDK. Exiting script."
    exit 1
fi

FONTCONFIG="fontconfig"

apt install -y "$FONTCONFIG"

if [ $? -eq 0 ]; then
    echo "Successfully installed $FONTCONFIG."
else
    echo "Failed to install $FONTCONFIG. Exiting script."
    exit 1
fi

wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | tee /etc/apt/sources.list.d/jenkins.list > /dev/null
apt update

JENKINS="jenkins"

echo "# ++++++++++++++++++++++ APT INSTALL JENKINS BEGIN ++++++++++++++++++++++"
apt install -y "$JENKINS"
echo "# ++++++++++++++++++++++ APT INSTALL JENKINS END ++++++++++++++++++++++"

if [ $? -eq 0 ]; then
    echo "Successfully installed $JENKINS."
else
    echo "Failed to install $JENKINS. Exiting script."
    exit 1
fi

echo "# ++++++++++++++++++++++ SYSTEMCTL ENABLE JENKINS ++++++++++++++++++++++"
systemctl enable jenkins

echo "# ++++++++++++++++++++++ SYSTEMCTL EDIT JENKINS ++++++++++++++++++++++"
sudo systemctl edit jenkins

mkdir -p /etc/systemd/system/jenkins.service.d/
cat <<EOF > /etc/systemd/system/jenkins.service.d/override.conf
[Service]
Environment="JENKINS_OPTS=--prefix=/jenkins"
EOF

echo "# ++++++++++++++++++++++ SYSTEMCTL DEAMON RELOAD ++++++++++++++++++++++"
systemctl daemon-reload

echo "# ++++++++++++++++++++++ SYSTEMCTL RESTART JENKINS ++++++++++++++++++++++"
systemctl restart jenkins

echo "# ++++++++++++++++++++++ SYSTEMCTL STATUS JENKINS BEGIN ++++++++++++++++++++++"
systemctl status jenkins
echo "# ++++++++++++++++++++++ SYSTEMCTL STATUS JENKINS END ++++++++++++++++++++++"

echo "# ++++++++++++++++++++++ SLEEP 30 Seconds ++++++++++++++++++++++"
sleep 30

echo "# ++++++++++++++++++++++ JENKINS DEFAULT PASSWORD BEGIN ++++++++++++++++++++++"
echo "$(cat /var/lib/jenkins/secrets/initialAdminPassword)"
echo "# ++++++++++++++++++++++ JENKINS DEFAULT PASSWORD END ++++++++++++++++++++++"