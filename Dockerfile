FROM kalilinux/kali-linux-docker

RUN echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" > /etc/apt/sources.list && \
    echo "deb-src http://http.kali.org/kali kali-rolling main contrib non-free" >> /etc/apt/sources.list
ENV DEBIAN_FRONTEND noninteractive
RUN set -x \
    && apt-get -yqq update \
    && apt-get -yqq dist-upgrade
RUN apt-get -y install openssh-server sudo procps wget unzip mc ca-certificates curl software-properties-common python-software-properties
RUN mkdir /var/run/sshd
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN useradd -u 1000 -G users,sudo -d /home/user --shell /bin/bash -m user
RUN echo "secret\nsecret" | passwd user
RUN add-apt-repository ppa:git-core/ppa
RUN apt-get update
RUN sudo apt-get install git subversion -y
RUN apt-get -y autoremove \
    apt-get -y clean \
    rm -rf /var/lib/apt/lists/* && \
    echo "#! /bin/bash\n set -e\n sudo /usr/sbin/sshd -D &\n exec \"\$@\"" > /home/user/entrypoint.sh && chmod a+x /home/user/entrypoint.sh

ENV LANG en_GB.UTF-8
ENV LANG en_US.UTF-8
USER user
RUN sudo locale-gen en_US.UTF-8 && \
    svn --version && \
    cd /home/user && ls -la && \
    sed -i 's/# store-passwords = no/store-passwords = yes/g' /home/user/.subversion/servers && \
    sed -i 's/# store-plaintext-passwords = no/store-plaintext-passwords = yes/g' /home/user/.subversion/servers
EXPOSE 22 4403
WORKDIR /projects
ENTRYPOINT ["/home/user/entrypoint.sh"]
CMD tail -f /dev/null
