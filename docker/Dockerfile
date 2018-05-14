# alpine is bare bones linux - gfortran on top of this
#FROM cmplopes/alpine-gfortran
# Below are the dependencies required for installing the common combination of numpy, scipy, pandas and matplotlib 
# in an Alpine based Docker image.
FROM alpine:3.4
# add bash
#RUN apk add --no-cache bash gawk sed grep bc coreutils
# add python and gfortran and bash
RUN echo "http://dl-8.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
RUN apk --no-cache --update-cache add bash gcc gfortran python python-dev py-pip build-base wget freetype-dev libpng-dev openblas-dev
RUN pip install --upgrade pip
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h
RUN pip install --no-cache-dir numpy 
RUN pip install --no-cache-dir scipy 
RUN pip install --no-cache-dir matplotlib
RUN pip install --no-cache-dir pandas 
RUN pip install --no-cache-dir jupyter
# install tini for alpine linux
# https://github.com/krallin/tini
RUN apk add --no-cache tini
# Tini is now available at /sbin/tini


# Add Tini. Tini operates as a process subreaper for jupyter. This prevents
# kernel crashes.
# Install Tini.. this is required because CMD (below) doesn't play nice with notebooks for some reason: https://github.com/ipython/ipython/issues/7062, https://github.com/jupyter/notebook/issues/334
RUN apk add --no-cache curl
RUN curl -L https://github.com/krallin/tini/releases/download/v0.10.0/tini > tini && \
    echo "1361527f39190a7338a0b434bd8c88ff7233ce7b9a4876f3315c22fce7eca1b0 *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini
RUN chmod +x /usr/local/bin/tini

# Add a notebook profile.
RUN mkdir -p -m 700 /root/.jupyter/ && \
echo "c.NotebookApp.ip = '*'" >> /root/.jupyter/jupyter_notebook_config.py

# set working directory
WORKDIR /usr/local/

# setup scripts and python codes - these are to be automatically updated on the github
#COPY python/*.py /usr/local/
#COPY script/run_mecsim_script.sh /usr/local/script/
#COPY src/entry_script.sh /usr/local/
#RUN git clone --branch master --single-branch https://github.com/garethkennedy/MECSim_Analytics
ADD https://github.com/garethkennedy/MECSim_Analytics/archive/master.tar.gz /usr/local/git_codes.tar.gz
RUN tar xvfz git_codes.tar.gz
RUN mv MECSim_Analytics-master/* .
RUN rm -rf git_codes.tar.gz MECSim_Analytics-master
# outputs to ~/MECSim_Analytics-master



# setup directory structure (additional python directory for user mapping?)
# scripting directory?
COPY src/*.f /usr/local/src/
#COPY input/Master.inp /usr/local/input/
RUN mkdir output
# some issues with opkda1 and opkda2 warnings
RUN gfortran -O3 -o MECSim.exe src/MECSim.f src/AddReaction.f src/Solve_EChem.f src/Setup_Geo.f src/SetupPreEqm.f src/LinearSubs.f src/lubksb.f src/ludcmp.f src/svdcmp.f src/svbksb.f src/pythag.f src/INTtoCHR.f src/MHSubs.f src/ConcUpdate.f src/CalcCurrent.f src/ODEjacobn.f src/ODEFront.f src/opkdmain.f src/opkda1.f src/opkda2.f src/SortInsertion.f
# remove source files
RUN rm -rf src/


RUN find *


# tests
RUN echo "Will test MECSim now"
RUN dos2unix input/Master.inp
RUN head input/Master.inp
RUN ./MECSim.exe
RUN head output/log.txt
RUN tail output/log.txt

RUN ls -lrt

# prepare and test entry script
RUN chmod +x entry_script.sh
RUN dos2unix entry_script.sh
RUN ./entry_script.sh --help

# expose notebook port
EXPOSE 8888


#ENTRYPOINT ["/usr/local/bin/tini", "--", "./entry_script.sh"]
ENTRYPOINT ["/sbin/tini", "--", "./entry_script.sh"]

# setup entry point and default command switch
# ENTRYPOINT ["./entry_script.sh"]
#CMD ["./entry_script.sh"]
#CMD ["ls -lrt"]

# https://github.com/underworldcode/underworld2/blob/631772a4497f9d355430bca63a13c5b73d985956/docs/development/docker/base/Dockerfile
