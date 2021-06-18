
# base image
FROM maven:3.6.3-jdk-8

# 自定义 maven 镜像，加快编译
# ADD settings.xml /usr/share/maven/conf/settings.xml

#RUN git clone --branch dubbo-2.6.0 https://github.com/apache/dubbo \
RUN git clone --branch dubbo-2.6.0 https://gitee.com/apache/dubbo.git \
    && cd dubbo \
    && rm -fr dubbo-config/dubbo-config-spring/src/test \
    && mvn package -DskipTests

# base image
FROM openjdk:8u275-jre

COPY --from=0 /dubbo/dubbo-simple/dubbo-monitor-simple/target/dubbo-monitor-simple-2.6.0-assembly.tar.gz .

RUN tar xvf dubbo-monitor-simple-2.6.0-assembly.tar.gz \
    && mv dubbo-monitor-simple-2.6.0 /usr/local/ \
    && mv /usr/local/dubbo-monitor-simple-2.6.0/lib/dubbo-monitor-simple-2.6.0.jar . \
    && mv /usr/local/dubbo-monitor-simple-2.6.0/lib/dubbo-2.6.0.jar . \
    && rm -f /usr/local/dubbo-monitor-simple-2.6.0/lib/dubbo* \
    && mv ./dubbo*.jar /usr/local/dubbo-monitor-simple-2.6.0/lib \
    && rm -f dubbo-monitor-simple-2.6.0-assembly.tar.gz \
    && sed -i "s/dubbo.registry.address/#dubbo.registry.address /g" /usr/local/dubbo-monitor-simple-2.6.0/conf/dubbo.properties \
    && echo "\ndubbo.registry.address=zookeeper://\${ZOOKEEPER_ADDRESS}" >> /usr/local/dubbo-monitor-simple-2.6.0/conf/dubbo.properties \
    && echo "\ntail -f \$STDOUT_FILE" >> /usr/local/dubbo-monitor-simple-2.6.0/bin/start.sh \
 # 用阿里云的源
 #   && apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 3B4FE6ACC0B21F32 \
 #   && mv /etc/apt/sources.list /etc/apt/sources.list.bak \
 #   && echo 'deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse\ndeb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse\ndeb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse\ndeb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse\ndeb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse\ndeb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse\ndeb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse\ndeb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse\ndeb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse\ndeb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse' > /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y procps net-tools \
    && apt-get clean

CMD ["/usr/local/dubbo-monitor-simple-2.6.0/bin/start.sh"]