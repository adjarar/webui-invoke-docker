FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu22.04 AS runtime

ENV DEBIAN_FRONTEND noninteractive

RUN useradd -m webui && \
    usermod -aG sudo webui && \
    chown -R webui:webui /home/webui && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN apt-get update && apt-get install -y --no-install-recommends \
software-properties-common \
sudo \
libglib2.0-0 \
libsm6 \
libgl1 \
libxrender1 \
libxext6 \
git \
ffmpeg \
wget \
curl \
psmisc \
nano \
openssh-server \
apt-transport-https ca-certificates && update-ca-certificates

WORKDIR /home/webui

USER webui

RUN git clone https://github.com/adjarar/stable-diffusion-webui.git

WORKDIR /home/webui/stable-diffusion-webui

RUN sudo python -m venv /webui/stable-diffusion-webui/venv
ENV PATH="/webui/stable-diffusion-webui/venv/bin:$PATH"

WORKDIR /home/webui/stable-diffusion-webui

ADD install.py .
RUN sudo python -m install --skip-torch-cuda-test
RUN sudo pip install --upgrade --force-reinstall xformers==0.0.18 torch torchvision torchaudio gdown

RUN sudo apt clean && sudo rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    sudo apt update

ADD start.sh /start.sh
RUN chmod a+x /start.sh

ADD download_models.sh /download_models.sh
RUN chmod a+x /download_models.sh

SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/start.sh", "/download_models.sh" ]
