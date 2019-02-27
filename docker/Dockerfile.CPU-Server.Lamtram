From slt.kit-server

# Eigen, update version as needed
RUN echo "[ui]" > ~/.hgrc && echo "tls = False" >> ~/.hgrc
RUN cd /opt/lib/ && \
        hg clone -r 10723 http://bitbucket.org/eigen/eigen/ && \
        cd eigen && \
        hg update && \
	mkdir build && \
	cd build && \
	cmake -DCMAKE_INSTALL_PREFIX=/opt/lib/eigen/build/ .. && \
	make install


# DyNet, update version as needed
RUN cd /opt/lib/ && \
        git clone http://github.com/jniehues-kit/cnn.git && \
        cd cnn && \
        mkdir build && \
        cd build && \
        cmake .. -DEIGEN3_INCLUDE_DIR=/opt/lib/eigen -DCMAKE_INSTALL_PREFIX:PATH=/opt/lib/cnn/build -DBoost_ADDITIONAL_VERSIONS=1.61 -DBOOST_ROOT=/opt/lib/boost/boost_1_61_0/ && \
        make -j16 install

#Lamtram
RUN cd /opt/lib/ && \
    git clone http://github.com/jniehues-kit/lamtram.git && \
    cd lamtram && \
    git checkout multitask &&  \
    autoreconf -i && \
    mkdir build && cd build && \
    ../configure --with-dynet=/opt/lib/cnn/build/ --with-eigen=/opt/lib/eigen/build/include/eigen3/ --prefix=/opt/lib/lamtram/build && \
    make -j 8 && \
    make install


RUN cd /opt/SLT.KIT/src/server && autoreconf -i && \
    mkdir -p /opt/SLT.KIT/build && cd /opt/SLT.KIT/build && \
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib/:/opt/pv-platform-sample-connector//Linux/lib64/ && \
    ../src/server/configure --with-rapidxml=/opt/rapidxml --with-mongo=/usr/local/ --enable-lmdb --with-lamtram=/opt/lib/lamtram/build/ --with-dynet=/opt/lib/cnn/build/ --with-eigen=/opt/lib/eigen/build/include/eigen3/ --with-mediator=/opt/pv-platform-sample-connector/ \
    && make && make install

CMD /opt/SLT.KIT/src/server/RUN.sh