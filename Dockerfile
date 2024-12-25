FROM ubuntu:22.04

# Arguments and environment variables
ARG BUILD_TOOLS_VERSION=29.0.2
ARG PLATFORM_VERSION=29
ARG COMMAND_LINE_VERSION=8.0
ENV ANDROID_HOME=/home/root/Android/sdk
ENV ANDROID_SDK_TOOLS=$ANDROID_HOME/tools
ENV PATH=$PATH:$ANDROID_HOME/platform-tools:/home/root/flutter/bin

# Installing necessary dependencies
RUN apt update && apt install -y \
    curl \
    git \
    unzip \
    openjdk-8-jdk \
    wget

# Creating Android directories
RUN mkdir -p $ANDROID_HOME
RUN mkdir -p /root/.android && touch /root/.android/repositories.cfg

# Download and set up Android SDK
RUN wget -O sdk-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && \
    unzip sdk-tools.zip -d $ANDROID_HOME && rm sdk-tools.zip

# Install SDK components
RUN yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses
RUN $ANDROID_HOME/tools/bin/sdkmanager \
    "build-tools;${BUILD_TOOLS_VERSION}" \
    "platform-tools" \
    "platforms;android-${PLATFORM_VERSION}" \
    "sources;android-${PLATFORM_VERSION}" \
    "cmdline-tools;${COMMAND_LINE_VERSION}"

# Download Flutter SDK
WORKDIR /home/root
RUN git clone https://github.com/flutter/flutter.git

# Verify Flutter installation
RUN flutter doctor

# Accept Android licenses
RUN yes | flutter doctor --android-licenses

# Start the adb daemon
RUN adb start-server
