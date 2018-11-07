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
# Add Tini. Tini operates as a process subreaper for jupyter. This prevents
# kernel crashes.
# install tini for alpine linux
# https://github.com/krallin/tini
RUN apk add --no-cache tini
# Tini is now available at /sbin/tini


# Install Tini.. this is required because CMD (below) doesn't play nice with notebooks for some reason: https://github.com/ipython/ipython/issues/7062, https://github.com/jupyter/notebook/issues/334
#RUN apk add --no-cache curl
#RUN curl -L https://github.com/krallin/tini/releases/download/v0.10.0/tini > tini && \
#    echo "1361527f39190a7338a0b434bd8c88ff7233ce7b9a4876f3315c22fce7eca1b0 *tini" | sha256sum -c - && \
#    mv tini /usr/local/bin/tini
#RUN chmod +x /usr/local/bin/tini

# Add a notebook profile.
RUN mkdir -p -m 700 /root/.jupyter/ && \
echo "c.NotebookApp.ip = '*'" >> /root/.jupyter/jupyter_notebook_config.py

# set working directory
WORKDIR /usr/local/

# setup scripts and python codes - these are to be automatically updated on the github
#ADD https://github.com/garethkennedy/MECSim_Analytics/archive/master.tar.gz /usr/local/git_codes.tar.gz
#RUN tar xvfz git_codes.tar.gz
# outputs to ~/MECSim_Analytics-master
RUN rm -rf git_codes.tar.gz
#RUN mv MECSim_Analytics-master/* .
#RUN rm -rf MECSim_Analytics-master

# setup directory structure (additional python directory for user mapping?)
# scripting directory?
# set working directory
COPY src/*.f /usr/local/src/

WORKDIR /usr/local/MECSim_Analytics-master/
# copy required directories
COPY input/* /usr/local/input/
COPY python/* /usr/local/python/
COPY docs/* /usr/local/docs/
COPY input_templates/* /usr/local/input_templates/
COPY script/* /usr/local/script/
# copy specific files
COPY entry_script/entry_script.sh /usr/local/

# back to base directory
WORKDIR /usr/local/
# some issues with opkda1 and opkda2 warnings
RUN gfortran -O3 -o MECSim.exe src/MECSim.f src/AddReaction.f src/Solve_EChem.f src/Setup_Geo.f src/SetupPreEqm.f src/LinearSubs.f src/lubksb.f src/ludcmp.f src/svdcmp.f src/svbksb.f src/pythag.f src/INTtoCHR.f src/MHSubs.f src/ConcUpdate.f src/CalcCurrent.f src/ODEjacobn.f src/ODEFront.f src/opkdmain.f src/opkda1.f src/opkda2.f src/SortInsertion.f

# remove source files
RUN rm -rf src/
RUN mkdir output

# test MECSim
RUN echo "Will test MECSim now"
RUN dos2unix input/Master.inp
RUN head input/Master.inp
RUN ./MECSim.exe
RUN head output/log.txt
RUN tail output/log.txt

# create py versions of default notebooks
RUN jupyter nbconvert --to python --template=python.tpl python/*

# prepare and test entry script
#COPY MECSim_Analytics-master/entry_script/entry_script.sh .
RUN chmod +x entry_script.sh
RUN dos2unix entry_script.sh
#RUN ./entry_script.sh --help
#RUN rm -f python/*.py

# create directories to map onto external directories (output is fine as is)
#%cd%/input:/usr/local/input -v %cd%/output:/usr/local/output -v %cd%/python:/usr/local/python -v %cd%/script:/usr/local/script
RUN mkdir external
WORKDIR /usr/local/external/
RUN mkdir input
RUN mkdir python
RUN mkdir script
RUN mkdir input_templates
RUN mkdir docs

WORKDIR /usr/local/

# cleanup
RUN rm -rf bin/ lib/ share/ MECSim_Analytics-master/

# expose notebook port
EXPOSE 8888

# setup entry point and default command switch
ENTRYPOINT ["/sbin/tini", "--", "./entry_script.sh"]

