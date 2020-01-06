FROM openjdk:11-jdk-slim

# Install .NET CLI dependencies

ARG NB_USER=afoone
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

RUN apt update
RUN apt install -y python3 jupyter
RUN apt install -y wget unzip curl
RUN wget https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip
RUN unzip ijava-1.3.0.zip
RUN python3 install.py
# RUN mkdir javascript && cd /javascript
# RUN wget "https://nodejs.org/dist/v12.14.0/node-v12.14.0-linux-x64.tar.xz"
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash -
RUN apt-get install -y nodejs
#RUN npm install -g ijavascript
#RUN ijsinstall

RUN mkdir dotnet && cd dotnet
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.asc.gpg
RUN mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/
RUN wget -q https://packages.microsoft.com/config/debian/10/prod.list
RUN mv prod.list /etc/apt/sources.list.d/microsoft-prod.list
RUN chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg
RUN chown root:root /etc/apt/sources.list.d/microsoft-prod.list
ENV DOTNET_RUNNING_IN_CONTAINER=true \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    # Skip extraction of XML docs - generally not useful within an image/container - helps performance
    NUGET_XMLDOC_MODE=skip \
    # Opt out of telemetry until after we install jupyter when building the image, this prevents caching of machine id
    DOTNET_TRY_CLI_TELEMETRY_OPTOUT=true

RUN apt update && apt install -y apt-transport-https dotnet-sdk-3.1 aspnetcore-runtime-3.1 dotnet-runtime-3.1 
#RUN dotnet tool install -g dotnet-interactive
RUN dotnet tool install -g dotnet-try 
ENV PATH="${PATH}:${HOME}/.dotnet/tools"
# Enable detection of running in a container

RUN echo "$PATH"
RUN cd ${HOME}/.dotnet/tools
# Install kernel specs
#RUN /root/.dotnet/tools/dotnet-try jupyter install
# Install kernel specs
#RUN dotnet try jupyter install


# Enable telemetry once we install jupyter for the image
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=false

WORKDIR /home

EXPOSE 8080


CMD ["jupyter", "notebook", "--kernel=java", "--ip=0.0.0.0", "--allow-root", "--port=8080"]
