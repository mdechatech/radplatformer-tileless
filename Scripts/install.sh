#! /bin/sh

BASE_URL=http://netstorage.unity3d.com/unity

#HASH=649f48bbbf0f
#VERSION=5.4.1f1

HASH=21ae32b5a9cb
VERSION=2017.4.3f1

#HASH=d4d99f31acba
#VERSION=2018.1.0f2

#HASH=b8cbb5de9840
#VERSION=2018.1.1f1

#HASH=292b93d75a2c
#VERSION=2019.1.0f2

download() {
  file=$1
  url="$BASE_URL/$HASH/$package"

  echo "Downloading from $url: "
  curl -o `basename "$package"` "$url"
}

install() {
  package=$1
  download "$package"

  echo "Installing "`basename "$package"`
  sudo installer -dumplog -package `basename "$package"` -target /
}

installFromBrew() {
  package=$1
  brew install $package
}

# See $BASE_URL/$HASH/unity-$VERSION-$PLATFORM.ini for complete list
# of available packages, where PLATFORM is `osx` or `win`

# http://netstorage.unity3d.com/unity/21ae32b5a9cb/unity-2017.4.3f1-osx.ini 
# http://netstorage.unity3d.com/unity/d4d99f31acba/unity-2018.1.0f2-osx.ini 
# http://netstorage.unity3d.com/unity/b8cbb5de9840/unity-2018.1.1f1-osx.ini 
# http://netstorage.unity3d.com/unity/292b93d75a2c/unity-2019.1.0f2-osx.ini


install "MacEditorInstaller/Unity-$VERSION.pkg"

# Scripting Backend
install "MacEditorTargetInstaller/UnitySetup-Mac-IL2CPP-Support-for-Editor-$VERSION.pkg"
install "MacEditorTargetInstaller/UnitySetup-Windows-Mono-Support-for-Editor-$VERSION.pkg"

# Cleanup
rm *.pkg

installAndroid(){

  brew cask install homebrew/cask-versions/java8

  # Aditionals
  installFromBrew gradle
  installFromBrew p7zip
  installFromBrew ant

  install "MacEditorTargetInstaller/UnitySetup-Android-Support-for-Editor-$VERSION.pkg"

  export JAVA_HOME=$(/usr/libexec/java_home -version 1.8)
  # avoiding error : java.lang.NoClassDefFoundError: javax/xml/bind/annotation/XmlSchema
  # export JAVA_OPTS='-XX:+IgnoreUnrecognizedVMOptions --add-modules java.se.ee'

  brew cask install android-sdk
  export ANDROID_HOME=/usr/local/share/android-sdk
  export ANDROID_SDK_ROOT=/usr/local/share/android-sdk
  export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin
  export PATH=$PATH:$ANDROID_HOME/platform-tools

  brew tap homebrew/cask && brew cask install android-ndk
  curl -o android-ndk-r13b-darwin-x86_64.zip https://dl.google.com/android/repository/android-ndk-r13b-darwin-x86_64.zip
  unzip -qq android-ndk-r13b-darwin-x86_64.zip -d /usr/local/share/ 
  ln -s /usr/local/share/android-ndk-r13b /usr/local/share/android-ndk
  export ANDROID_NDK_ROOT=/usr/local/share/android-ndk

  mkdir "$ANDROID_HOME/licenses";
  echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > "$ANDROID_HOME/licenses/android-sdk-license";
  echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" > "$ANDROID_HOME/licenses/android-sdk-preview-license";
  echo y | sdkmanager "platform-tools";
  echo y | sdkmanager "build-tools;25.0.2";
  echo y | android update sdk --no-ui --all --filter tool,platform-tool,android-24,build-tools-25.0.2

  gradle -v
  java -version
  sdkmanager --version
  echo "JAVA_HOME=$JAVA_HOME"
  echo "ANDROID_HOME=$ANDROID_HOME"
  echo "ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT"
  echo "ANDROID_NDK_ROOT=$ANDROID_NDK_ROOT"
}

installiOS(){
  install "MacEditorTargetInstaller/UnitySetup-iOS-Support-for-Editor-$VERSION.pkg"
}

installWebGL(){
  install "MacEditorTargetInstaller/UnitySetup-WebGL-Support-for-Editor-$VERSION.pkg"
}

installForDesktop(){
  install "MacEditorTargetInstaller/UnitySetup-Linux-Support-for-Editor-$VERSION.pkg"
  install "MacEditorTargetInstaller/UnitySetup-Windows-Support-for-Editor-$VERSION.pkg"
  # Not Required for MacOSX
  #install "MacEditorTargetInstaller/UnitySetup-Mac-Support-for-Editor-$VERSION.pkg"
}

export EVENT_NOKQUEUE=1

installAndroid
installiOS
installForDesktop
installWebGL
