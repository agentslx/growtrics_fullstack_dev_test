dart run flutter_flavorizr -p assets:download,assets:extract,android:androidManifest,android:flavorizrGradle,android:buildGradle,android:dummyAssets,android:icons,flutter:flavors,flutter:app,flutter:pages,flutter:main,ios:podfile,ios:xcconfig,ios:buildTargets,ios:schema,ios:dummyAssets,ios:icons,ios:plist,ios:launchScreen,huawei:agconnect,assets:clean,ide:config

rm -rf lib/pages/

# Git revert the main.dart file
git checkout HEAD -- lib/main.dart
git checkout HEAD -- lib/app.dart
