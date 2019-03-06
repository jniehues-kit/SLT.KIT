# Server

This site explains how to set up a server

1. Build docker

 ```bash 
   docker build -t slt.kit-server -f Dockerfile.CPU-Server .
   docker build -t slt.kit-server.opennmt -f Dockerfile.CPU-Server.OpenNMT-py .
   docker build -t slt.kit-server.lamtram -f Dockerfile.CPU-Server.Lamtram .
```

2. Create /model/Worker.xml to configure service: e.g. 

```

<server>
  <connection>
    <type> Mediator </type>
    <host> #MEDIATOR# </host>
    <port> #PORT# </port>
    <name> #NAME# </name>
    <sourceLanguage> #SL# </sourceLanguage>
    <targetLanguage> #TL# </targetLanguage>
  </connection>
  <data>
    <type> Sentence </type>
    <noIntermediateOutput> 1 </noIntermediateOutput>
  </data>
  <service>
    <type> Smartcase </type>
    <model> /model/Smartcasemodel.de </model>
    <mode> Moses </mode>
    <service>
      <type> BPE </type>
      <codec>  /model/codes </codec>
      <service>
        <type> OpenNMT </type>
        <model> /model/model.conf </model>
      </service>
    </service>
  </service>
</server>


```

3. Start docker container by

 ```bash 
sudo docker run -it -e MEDIATOR=$host -e PORT=$port -t slt.kit-server.opennmt

```
