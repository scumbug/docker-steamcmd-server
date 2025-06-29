FROM debian:12-slim

LABEL org.opencontainers.image.authors="admin@minenet.at"
LABEL org.opencontainers.image.source="https://github.com/ich777/docker-steamcmd-server"

ENV HOME "/serverdata"
ENV GE_PROTON_VERSION="8-30"
ENV GE_PROTON_URL="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton${GE_PROTON_VERSION}/GE-Proton${GE_PROTON_VERSION}.tar.gz"
ENV DATA_DIR="/serverdata"
ENV GAME_ID="2278520"
ENV GAME_PARAMS=""
ENV STEAMCMD_DIR="${DATA_DIR}/steamcmd"
ENV SERVER_DIR="${DATA_DIR}/serverfiles"
ENV ASTEAM_PATH="${DATA_DIR}/Steam"
ENV STEAM_COMPAT_CLIENT_INSTALL_PATH="${ASTEAM_PATH}"
ENV STEAM_COMPAT_DATA_PATH="${ASTEAM_PATH}/steamapps/compatdata/${GAME_ID}"
ENV ENSHROUDED_CONFIG "${SERVER_DIR}/enshrouded_server.json"
ENV SERVER_NAME="Enshrouded Docker"
ENV QUERY_PORT="15637"
ENV SERVER_SLOTS="16"
ENV ULWGL_ID=0
ENV BACKUP="false"
ENV BACKUP_INTERVAL=120
ENV BACKUPS_TO_KEEP=12
ENV VALIDATE=""
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV USERNAME=""
ENV PASSWRD=""
ENV USER="steam"
ENV DATA_PERM=770

RUN useradd -d $DATA_DIR -s /bin/bash -g $GID -u $UID $USER && \ 
    sed -i 's#^Components: .*#Components: main non-free contrib#g' /etc/apt/sources.list.d/debian.sources \
    && echo steam steam/question select "I AGREE" | debconf-set-selections \
    && echo steam steam/license note '' | debconf-set-selections \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        procps \
        ca-certificates \
        winbind \
        dbus \
        libfreetype6 \
        curl \
        wget \
        jq \
        locales \
        lib32gcc-s1 \
    && echo 'LANG="en_US.UTF-8"' > /etc/default/locale \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && rm -f /etc/machine-id \
    && dbus-uuidgen --ensure=/etc/machine-id \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoremove -y

RUN  echo "* hard nice -20" | tee -a /etc/security/limits.conf 

RUN mkdir $DATA_DIR && \
    chown -R $USER $DATA_DIR

ADD /scripts/ /opt/scripts/
ADD /config/ /opt/config/
RUN chmod -R 770 /opt/scripts/
RUN chmod -R 770 /opt/config/
RUN chown -R $USER /opt/config/

RUN mkdir $STEAMCMD_DIR && \
    mkdir $SERVER_DIR && \
    wget "$GE_PROTON_URL" -O "${DATA_DIR}/GE-Proton${GE_PROTON_VERSION}.tgz"

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]
