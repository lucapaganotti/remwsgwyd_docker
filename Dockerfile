FROM lucapaganotti/es1501_docker
LABEL name="remwsgwyd"
LABEL version="1.0"
LABEL decription="image for remwsgwyd"
# Create directory structure
RUN mkdir -p /root/dev/eiffel/collect && \
    mkdir -p /root/dev/eiffel/library && \
    mkdir -p /root/dev/eiffel/unlog_remws && \
    mkdir -p /root/dev/eiffel/library/msg && \
    mkdir -p /root/dev/eiffel/collect/scripts && \
    mkdir -p /root/.collect && \
    mkdir -p /root/log 

# Define GC ISE environment
ENV EIF_FULL_COALESCE_PERIOD="4"
ENV EIF_FULL_COLLECTION_PERIOD="2"
ENV EIF_MEMORY_CHUNK="1048576"
ENV EIF_TENURE_MAX="2"

# Add ISE ES 15.01
# ADD Eiffel_15.01_gpl_96535-linux-x86-64.tar.bz2 /usr/local

# ADD collect code
ADD collect.tar.gz /root/dev/eiffel/collect
RUN sed -i 's#\\home\\buck#\\root#g' /root/dev/eiffel/collect/collect.ecf
# ADD msg code
ADD msg.tar.gz /root/dev/eiffel/library/msg
RUN sed -i 's#\\home\\buck#\\root#g' /root/dev/eiffel/library/msg/msg.ecf
# ADD unlog_remws code
ADD unlog_remws.tar.gz /root/dev/eiffel/unlog_remws
RUN sed -i 's#\\home\\buck#\\root#g' /root/dev/eiffel/unlog_remws/unlog.ecf 

# Melt msg library
RUN cd /root/dev/eiffel/library/msg && \
    ec -config ./msg.ecf && \
    cd /root

# Build collect executable
RUN cd /root/dev/eiffel/collect && \
    ec -batch -finalize -config ./collect.ecf && \
    cd /root/dev/eiffel/collect/EIFGENs/collect/F_code && \
    finish_freezing && \
    strip -s ./collect && \
    cp ./collect /sbin/remwsgwyd && \
    cd /root

# Build unlogremws executable
RUN cd /root/dev/eiffel/unlog_remws && \
    ec -batch -finalize -config ./unlog.ecf && \
    cd /root/dev/eiffel/unlog_remws/EIFGENs/unlog/F_code && \
    finish_freezing && \
    strip -s ./unlogremws && \
    cp ./unlogremws /sbin && \
    cd /root

# Put credentials file
COPY credentials.conf /root/.collect

# Temporarily add remwsgwyd scripts
ADD remwsgwyd_scripts.tar.gz /root/dev/eiffel/collect/scripts

# Deploy collect as remwsgwyd service
# RUN cd /root/dev/eiffel/collect/scripts && \
#     ./deploy_collect && \
#     cd /root

# Set working dir

# Put entrypoint.sh
COPY entrypoint.sh /

WORKDIR /

# Run remwsgwd
CMD ./entrypoint.sh

