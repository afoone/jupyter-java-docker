FROM openjdk:11-jdk-slim
RUN apt update
RUN apt install -y python3 jupyter
RUN apt install -y wget unzip
RUN wget https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip
RUN unzip ijava-1.3.0.zip
RUN python3 install.py


WORKDIR /home

EXPOSE 8080


CMD ["jupyter", "notebook", "--kernel=java", "--ip=0.0.0.0", "--allow-root", "--port=8080"]
