FROM ibmcom/ace


COPY src/ /tmp/src

USER root
RUN  chown -R aceuser:mqbrkrs /tmp/src

USER 1000

RUN  source /opt/ibm/ace-11/server/bin/mqsiprofile && \
     mkdir bars && cd bars && \
     mqsipackagebar -a compiled.bar -w /tmp/src/ -i -k CalculatorTest && \
     rm -rf /tmp/src && \
     ace_compile_bars.sh
