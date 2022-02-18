FROM openjdk:8

WORKDIR /opt

ENV SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip" \
    ANDROID_HOME="/opt/android-sdk" \
    ANDROID_SDK=$ANDROID_HOME \
    ANDROID_VERSION=29 \
    ANDROID_BUILD_TOOLS_VERSION=29.0.2

RUN apt-get --quiet update --yes
RUN apt-get --quiet install --yes file wget tar unzip lib32stdc++6  lib32z1 build-essential dos2unix 
RUN apt-get -qq install curl

RUN mkdir ~/.android \
    && echo 'count=0' > ~/.android/repositories.cfg
## Download Android SDK
RUN mkdir "$ANDROID_HOME" \ 
    && cd "$ANDROID_HOME" \
    && curl -o sdk.zip $SDK_URL \
    && unzip sdk.zip \
    && rm sdk.zip \
    && yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses

## Install Android Build Tool and Libraries
RUN $ANDROID_HOME/tools/bin/sdkmanager --update
RUN $ANDROID_HOME/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    "platforms;android-${ANDROID_VERSION}" \
    "build-tools;28.0.3" \
    "platforms;android-28" \
    "platform-tools" \
    "tools" \
    # "extras;android;m2repository" \
    # "extras;google;google_play_services" \
    # "extras;google;m2repository" \
    # "cmake;3.6.4111459"\

# Install NDK
ENV NDK_VER="21.0.6113669"
RUN $ANDROID_HOME/tools/bin/sdkmanager "ndk;$NDK_VER"
RUN ln -sf $ANDROID_HOME/ndk/$NDK_VER $ANDROID_HOME/ndk-bundle

COPY coreca.crt /usr/local/share/ca-certificates
RUN update-ca-certificates
RUN openssl verify /usr/local/share/ca-certificates/coreca.crt

