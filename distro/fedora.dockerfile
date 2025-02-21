FROM docker.io/library/alpine:3.17.2 as gvisor-tap-vsock
WORKDIR /app/bin
RUN wget https://github.com/containers/gvisor-tap-vsock/releases/download/v0.6.1/gvproxy-windows.exe && \
    wget https://github.com/containers/gvisor-tap-vsock/releases/download/v0.6.1/vm && \
    chmod +x ./gvproxy-windows.exe ./vm
RUN find . -type f -exec sha256sum {} \;

FROM docker.io/library/fedora:37
RUN dnf upgrade -y && \
    dnf install -y iproute iptables-legacy iputils bind-utils wget nano less openssh-server podman procps net-tools && \
    dnf clean all
WORKDIR /app
COPY --from=gvisor-tap-vsock /app/bin/vm ./wsl-vm
COPY --from=gvisor-tap-vsock /app/bin/gvproxy-windows.exe ./wsl-gvproxy.exe
COPY ./wsl-vpnkit ./
COPY ./wsl-vpnkit.service /etc/systemd/system/wsl-vpnkit.service
COPY ./distro/wsl.conf /etc/wsl.conf
RUN ln -s /app/wsl-vpnkit /usr/bin/
RUN systemctl enable wsl-vpnkit.service
