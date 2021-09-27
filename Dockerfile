FROM debian:buster
COPY entrypoint.sh /runner/
    
RUN useradd -d /runner --uid=1000 runner \
    && echo 'runner:runner' | chpasswd \
    && groupadd docker --gid=999 \
    && usermod -aG docker runner \
    && apt-get update && apt-get install -y apt-utils apt-transport-https
    
RUN chmod +x /runner/entrypoint.sh \
    && chown -Rf runner:runner /runner
    
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.asc.gpg \
    && mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/ \
    && wget -q https://packages.microsoft.com/config/debian/9/prod.list \
    && mv prod.list /etc/apt/sources.list.d/microsoft-prod.list \
    && chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg \
    && chown root:root /etc/apt/sources.list.d/microsoft-prod.list \
    && apt-get update && apt-get install -y --no-install-recommends apt-transport-https auto-apt-proxy curl \
    && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs dotnet-sdk-2.2 \
    && npm install -g newman newman-reporter-htmlextra \
    && mkdir /opt/sonarscanner && cd /opt/sonarscanner && wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.2.0.1227-linux.zip && unzip sonar-scanner-cli-3.2.0.1227-linux.zip && rm sonar-scanner-cli-3.2.0.1227-linux.zip && chmod +x sonar-scanner-3.2.0.1227-linux/bin/sonar-scanner && ln -s /opt/sonarscanner/sonar-scanner-3.2.0.1227-linux/bin/sonar-scanner /usr/local/bin/sonar-scanner \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

ENV DOTNET_RUNNING_IN_CONTAINER=true \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    # Skip extraction of XML docs - generally not useful within an image/container - helps performance
    NUGET_XMLDOC_MODE=skip \
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE=true


USER runner

RUN dotnet tool install --global dotnet-sonarscanner 

ENV PATH="$PATH:/runner/.dotnet/tools"

WORKDIR /runner

ENTRYPOINT ["/runner/entrypoint.sh"]
