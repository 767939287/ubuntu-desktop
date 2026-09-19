# FROM kasmweb/core-ubuntu-noble:1.17.0
# FROM kasmweb/core-ubuntu-resolute-wkde:develop
FROM kasmweb/core-ubuntu-noble:1.19.0


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

# Chrome 及系统依赖库 (保留 curl, jq 以及补充 ca-certificates)
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests \
        pip iproute2 openssl ca-certificates locales fonts-noto-cjk fonts-noto-cjk-extra xdg-utils fonts-liberation libu2f-udev smbclient cifs-utils wget curl jq \
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

# 动态获取最新 Intel 显卡驱动
    && curl -s https://api.github.com/repos/intel/compute-runtime/releases/latest \
        | jq -r '.assets[].browser_download_url' | grep '\.deb$' | xargs -n 1 wget -q \
    && curl -s https://api.github.com/repos/intel/intel-graphics-compiler/releases/latest \
        | jq -r '.assets[].browser_download_url' | grep '\.deb$' | xargs -n 1 wget -q \

# 安装所有 deb 包
    && apt-get install --no-install-recommends --no-install-suggests -y ./*.deb \

# 配置 Chrome 启动参数 (禁用沙箱与 GPU 沙箱)
    && sed -i 's/Exec=\/usr\/bin\/google-chrome-stable/Exec=\/usr\/bin\/google-chrome-stable --no-sandbox --disable-dev-shm-usage/g' /usr/share/applications/google-chrome.desktop \
    && ln -s /usr/share/applications/google-chrome.desktop /home/kasm-user/Desktop/google-chrome.desktop \
    && chown -R kasm-user:kasm-user /home/kasm-user/Desktop \

# 保留 curl, jq, wget，仅清理临时垃圾
    && rm -rf /tmp/* /var/tmp/*