FROM ubuntu:22.04

RUN apt update && \
apt install -y ca-certificates curl gnupg lsb-release && \
mkdir -p /etc/apt/keyrings && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
apt update && \
apt full-upgrade && \
apt install -y docker-ce docker-ce-cli containerd.io docker-compose python3-pip openjdk-8-jdk openssh-server && \
apt autoremove -y && \
pip install docker && \
pip install ansible && \
update-alternatives --install /usr/bin/python python /usr/bin/python3 100 && \
sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
mkdir -p /var/run/sshd

COPY docker-node.pub /root/.ssh/authorized_keys

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
