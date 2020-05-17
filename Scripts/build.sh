#! /bin/sh

project="sonic-realms"

echo "whoami: $(whoami)"
ls -lha $(pwd)

buildWindows(){

  echo "Attempting to build $project for Windows"
  /Applications/Unity/Unity.app/Contents/MacOS/Unity \
    -batchmode \
    -nographics \
    -silent-crashes \
    -logFile $(pwd)/unity.log \
    -projectPath $(pwd) \
    -buildWindowsPlayer "$(pwd)/Build/windows/$project.exe" \
    -quit

  echo 'Attempting to windows zip builds'
  pushd $(pwd)/Build
  zip -9 -r windows.zip windows/
  popd

}

buildLinux(){

  echo "Attempting to build $project for Linux"
  /Applications/Unity/Unity.app/Contents/MacOS/Unity \
    -batchmode \
    -nographics \
    -silent-crashes \
    -logFile $(pwd)/unity.log \
    -projectPath $(pwd) \
    -buildLinuxUniversalPlayer "$(pwd)/Build/linux/$project.exe" \
    -quit

  echo 'Attempting to Linux zip builds'
  pushd $(pwd)/Build
  zip -9 -r linux.zip linux/
  popd

}

buildOSX(){
  echo "Attempting to build $project for OS X"
  /Applications/Unity/Unity.app/Contents/MacOS/Unity \
    -batchmode \
    -nographics \
    -silent-crashes \
    -logFile $(pwd)/unity.log \
    -projectPath $(pwd) \
    -buildOSXUniversalPlayer "$(pwd)/Build/osx/$project.app" \
    -quit

  echo 'Attempting to OSX zip builds'
  pushd $(pwd)/Build
  zip -9 -r osx.zip osx/
  popd
}

buildWegGL(){
  echo "Attempting to build $project for WebGL"
  /Applications/Unity/Unity.app/Contents/MacOS/Unity \
    -batchmode \
    -nographics \
    -silent-crashes \
    -logFile $(pwd)/unity.log \
    -projectPath $(pwd) \
    -executeMethod PerformBuild.CommandLineBuildWebGL \
    +buildlocation "$(pwd)/Build/webgl/$project" \
    -quit  

  if [ $? = 0 ] ; then
     echo "Building WebGL completed successfully."
     echo "Zipping..."
     pushd $(pwd)/Build
     zip -9 -r webgl.zip webgl/
     popd
     error_code=0
   else
     echo "Building WebGL failed. Exited with $?."
     error_code=1
   fi
}

buildAndroid(){

  export JAVA_HOME=$(/usr/libexec/java_home -version 1.8)
  # avoiding error : java.lang.NoClassDefFoundError: javax/xml/bind/annotation/XmlSchema
  # export JAVA_OPTS='-XX:+IgnoreUnrecognizedVMOptions --add-modules java.se.ee'

  echo "ANDROID_SDK_ROOT: $ANDROID_SDK_ROOT"
  echo "ANDROID_NDK_ROOT: $ANDROID_NDK_ROOT"
  echo "JAVA_HOME: $JAVA_HOME"

  echo "Attempting to build $project for Android"
  /Applications/Unity/Unity.app/Contents/MacOS/Unity \
    -batchmode \
    -nographics \
    -silent-crashes \
    -logFile $(pwd)/unity.log \
    -projectPath $(pwd) \
    -executeMethod PerformBuild.CommandLineBuildAndroid \
    +buildlocation "$(pwd)/Build/android/$project.apk" \
    -quit  

  if [ $? = 0 ] ; then
     echo "Building Android binaries completed successfully."
     error_code=0
   else
     echo "Building Android binaries failed. Exited with $?."
     error_code=1
   fi

  rm $(pwd)/Build/android/*.zip



}

buildiOS(){
  echo "Attempting to build $project for iOS"
  /Applications/Unity/Unity.app/Contents/MacOS/Unity \
    -batchmode \
    -nographics \
    -silent-crashes \
    -force-free \
    -logFile $(pwd)/unity.log \
    -projectPath $(pwd) \
    -executeMethod PerformBuild.CommandLineBuildiOS \
    +buildlocation "$(pwd)/Build/ios/$project.ipa" \
    -quit  

  if [ $? = 0 ] ; then
     echo "Building iOS binaries completed successfully."
     echo "Zipping binaries..."
     zip -9 -r ios.zip . -i "$(pwd)/Build/ios"
     error_code=0
   else
     echo "Building iOS binaries failed. Exited with $?."
     error_code=1
   fi

}

export EVENT_NOKQUEUE=1

[ -z "$SKIP_IOS" ] && buildiOS || echo "Skipping build for iOS"
[ -z "$SKIP_ANDROID" ] && buildAndroid || echo "Skipping build for Android"
[ -z "$SKIP_WINDOWS" ] && buildWindows || echo "Skipping build for Windows"
[ -z "$SKIP_LINUX" ] && buildLinux || echo "Skipping build for Linux"
[ -z "$SKIP_OSX" ] && buildOSX || echo "Skipping build for OSX"
[ -z "$SKIP_WEBGL" ] && buildWegGL || echo "Skipping build for WebGL"

echo 'Logs from build'
cat $(pwd)/unity.log
