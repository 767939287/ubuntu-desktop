# FROM kasmweb/core-ubuntu-noble:1.17.0
# FROM kasmweb/core-ubuntu-resolute-wkde:develop
# FROM kasmweb/core-ubuntu-noble:1.19.0
FROM kasmweb/core-ubuntu-noble:1.19.0-rolling-weekly

# LABEL version="1.0" maintainer="colinchang<zhangcheng5468@gmail.com>"
ENV VNCOPTIONS="${VNCOPTIONS} -disableBasicAuth -DLP_Log off"
ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh

USER root

# 替换阿里云系统源
# COPY $PWD/sources.list /etc/apt/sources.list
# COPY $PWD/xunlei_1.0.0.1-myubuntu_amd64.deb /home/kasm-user

# 使用 BuildKit 缓存挂载，确保 APT 缓存不会写入镜像层
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -ex \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && mkdir -p /home/kasm-user/Desktop \
    && cd /tmp \
    && apt-get update \

# Chrome 及系统依赖库 (包含解析 JSON 所需的 jq 和 curl)
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests \
        pip iproute2 openssl locales fonts-noto-cjk fonts-noto-cjk-extra xdg-utils fonts-liberation libu2f-udev smbclient cifs-utils wget curl jq \
        libxcb-cursor0 \
        libxcb-xinerama0 \
        libxcb-icccm4 \
        libxcb-image0 \
        libxcb-keysyms1 \
        libxcb-render-util0 \
        libxcb-shape0 \
        libxkbcommon-x11-0 \

# 下载 Chrome 150
    && wget -q https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_150.0.7871.46-1_amd64.deb -O google-chrome-stable_150_amd64.deb \

# ----------------- 自动获取最新 Intel 显卡驱动 -----------------
    && curl -s https://api.github.com/repos/intel/compute-runtime/releases/latest \
        | jq -r '.assets[].browser_download_url' | grep '\.deb$' | xargs -n 1 wget -q \
    && curl -s https://api.github.com/repos/intel/intel-graphics-compiler/releases/latest \
        | jq -r '.assets[].browser_download_url' | grep '\.deb$' | xargs -n 1 wget -q \
# ----------------------------------------------------------------

# && dpkg -i google-chrome-stable_current_amd64.deb \
    && apt-get install --no-install-recommends --no-install-suggests -y ./*.deb \
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

    && apt-get purge -y --auto-remove wget curl jq \
    && rm -rf /tmp/* /var/tmp/*