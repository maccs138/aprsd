FROM ubuntu:20.04 as aprsd

ENV VERSION=1.0.0
ENV APRS_USER=aprs
ENV HOME=/home/aprs
ENV VIRTUAL_ENV=$HOME/.venv3

ENV INSTALL=$HOME/install
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update
RUN apt-get install -y wget gnupg git-core
RUN apt-get install -y apt-utils pkg-config sudo vim
RUN apt-get install -y python3 python3-pip python3-virtualenv python3-venv

# Setup Timezone
ENV TZ=US/Eastern
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get install -y tzdata
RUN dpkg-reconfigure --frontend noninteractive tzdata


RUN addgroup --gid 1000 $APRS_USER
RUN useradd -m -u 1000 -g 1000 -p $APRS_USER $APRS_USER

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

USER $APRS_USER
RUN pip3 install wheel
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN echo "export PATH=\$PATH:\$HOME/.local/bin" >> $HOME/.bashrc
VOLUME ["/config", "/plugins"]

WORKDIR $HOME
RUN pip install aprsd
USER root
RUN aprsd sample-config > /config/aprsd.yml
RUN chown -R $APRS_USER:$APRS_USER /config

# override this to run another configuration
ENV CONF default
USER $APRS_USER

ADD build/bin/run.sh $HOME/
ENTRYPOINT ["/home/aprs/run.sh"]
