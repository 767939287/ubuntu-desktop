FROM kasmweb/core-ubuntu-noble:1.17.0

# LABEL version="1.0" maintainer="colinchang<zhangcheng5468@gmail.com>"

USER root

# 替换阿里云系统源
COPY $PWD/sources.list /etc/apt/sources.list

ENV NEO_VERSION=24.39.31294.12
ENV GMMLIB_VERSION=22.5.2
ENV IGC_VERSION=1.0.17791.9
ENV LEVEL_ZERO_VERSION=1.6.31294.12

RUN apt update && \
    apt install -y --no-install-recommends --no-install-suggests iproute2 openssl locales fonts-noto-cjk fonts-noto-cjk-extra && \
# install intel driver
    mkdir intel-compute-runtime && \
    cd intel-compute-runtime && \
    wget https://github.com/intel/compute-runtime/releases/download/${NEO_VERSION}/libigdgmm12_${GMMLIB_VERSION}_amd64.deb && \
    wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-${IGC_VERSION}/intel-igc-core_${IGC_VERSION}_amd64.deb  && \
    wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-${IGC_VERSION}/intel-igc-opencl_${IGC_VERSION}_amd64.deb  && \
    wget https://github.com/intel/compute-runtime/releases/download/${NEO_VERSION}/intel-opencl-icd_${NEO_VERSION}_amd64.deb  && \
    wget https://github.com/intel/compute-runtime/releases/download/${NEO_VERSION}/intel-level-zero-gpu_${LEVEL_ZERO_VERSION}_amd64.deb  && \
    apt-get install --no-install-recommends --no-install-suggests -y ./*.deb  && \
    cd ..  && \
# clean up
    rm -rf intel-compute-runtime  && \
    apt-get remove gnupg wget apt-transport-https -y  && \
    apt-get clean autoclean -y  && \
    apt-get autoremove -y  && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* && \
    mkdir -p /cache /config /media && \
    chmod 777 /cache /config /media && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen

# COPY $PWD/xunlei_1.0.0.1-myubuntu_amd64.deb /home/kasm-user
RUN apt update && mkdir -p /home/kasm-user/Desktop \

# Chrome
&& apt install -y xdg-utils fonts-liberation libu2f-udev \
&& wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
&& dpkg -i google-chrome-stable_current_amd64.deb \
&& sed -i 's/Exec=\/usr\/bin\/google-chrome-stable/Exec=\/usr\/bin\/google-chrome-stable --no-sandbox/g' /usr/share/applications/google-chrome.desktop \
&& ln -s /usr/share/applications/google-chrome.desktop /home/kasm-user/Desktop/google-chrome.desktop \

# BaiduNetDisk
# && wget https://issuepcdn.baidupcs.com/issue/netdisk/LinuxGuanjia/4.17.7/baidunetdisk_4.17.7_amd64.deb \
# && dpkg -i baidunetdisk_4.17.7_amd64.deb \
# && ln -s /usr/share/applications/baidunetdisk.desktop /home/kasm-user/Desktop/baidunetdisk.desktop \

# Thunder
# && apt install -y libgtk2.0-0 libdbus-glib-1-2 \
# && dpkg -i xunlei_1.0.0.1-myubuntu_amd64.deb \
# && sed -i 's/Exec=\/opt\/thunder\/xunlei\/start.sh/Exec=\/opt\/thunder\/xunlei\/start.sh --no-sandbox/g' /usr/share/applications/xunlei.desktop \
# && ln -s /usr/share/applications/xunlei.desktop /home/kasm-user/Desktop/xunlei.desktop \

# qBittorrent
# && add-apt-repository -y ppa:qbittorrent-team/qbittorrent-stable \
# && apt update \
# && apt install -y qbittorrent \
# && ln -s /usr/share/applications/org.qbittorrent.qBittorrent.desktop /home/kasm-user/Desktop/org.qbittorrent.qBittorrent.desktop \

# Visual Studio Code
# && wget https://az764295.vo.msecnd.net/stable/1a5daa3a0231a0fbba4f14db7ec463cf99d7768e/code_1.84.2-1699528352_amd64.deb \
# && dpkg -i code_1.84.2-1699528352_amd64.deb \
# && sed -i 's/Exec=\/usr\/share\/code\/code/Exec=\/usr\/share\/code\/code --no-sandbox/g' /usr/share/applications/code.desktop \
# && sed -i 's/Icon=com.visualstudio.code/Icon=\/usr\/share\/code\/resources\/app\/resources\/linux\/code.png/g' /usr/share/applications/code.desktop \
# && ln -s /usr/share/applications/code.desktop /home/kasm-user/Desktop/code.desktop \

&& apt autoremove -y \
&& apt clean \
&& rm -rf *.deb
