FROM ubuntu:14.04

# Dependencies we just need for building phantomjs
ENV buildDependencies\
  wget unzip python build-essential g++ flex bison gperf \
  ruby perl libsqlite3-dev libssl-dev libpng-dev git

# Dependencies we need for running phantomjs
ENV phantomJSDependencies\
  libicu-dev libfontconfig1-dev libjpeg-dev libfreetype6

# Installing phantomjs
RUN apt-get update -yqq \
    && apt-get install -fyqq ${buildDependencies} ${phantomJSDependencies}

## Downloading src, unzipping & removing zip
RUN git clone git://github.com/ariya/phantomjs.git \
    && cd phantomjs \
    && git checkout 2.1.1
#
## Building phantom
RUN cd phantomjs \
    && git submodule init \
    && git submodule update \
    && yes | python build.py

#
## Removing everything but the binary
RUN cd phantomjs \
    && ls -A | grep -v bin | xargs rm -rf \
    && ln -s /phantomjs/bin/phantomjs /usr/bin/phantomjs
#
## Removing build dependencies, clean temporary files
RUN apt-get purge -yqq ${buildDependencies} \
    && apt-get autoremove -yqq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
#
## Checking if phantom works
RUN /usr/bin/phantomjs -v

#
CMD echo "phantomjs binary is located at /phantomjs/bin/phantomjs"\
    && echo "just run 'phantomjs' (version `phantomjs -v`)"
