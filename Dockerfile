FROM microsoft/aspnetcore-build:2.0 AS build

# Install mono for Cake (https://andrewlock.net/building-asp-net-core-apps-using-cake-in-docker/)
ENV MONO_VERSION 5.4.1.6

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF

RUN echo "deb http://download.mono-project.com/repo/debian stretch/snapshots/$MONO_VERSION main" > /etc/apt/sources.list.d/mono-official.list \  
  && apt-get update \
  && apt-get install -y mono-runtime \
  && rm -rf /var/lib/apt/lists/* /tmp/*

RUN apt-get update \  
  && apt-get install -y binutils curl mono-devel ca-certificates-mono fsharp mono-vbnc nuget referenceassemblies-pcl \
  && rm -rf /var/lib/apt/lists/* /tmp/*

WORKDIR /src
#ENTRYPOINT ["/src/build.sh", "--Target=Build"]
#https://github.com/SharpeRAD/Cake.WebDeploy/pull/24
#CMD ./build.sh -Target=Build --settings_skipverification=true
CMD ./build.sh -Target=Default --settings_skipverification=true
