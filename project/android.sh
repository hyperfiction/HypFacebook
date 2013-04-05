rm -rf "obj"
rm ../ndll/Android/libHypFacebook.so
echo "Compiling for armv6"
haxelib run hxcpp Build.xml -Dandroid
echo "Copying..."
cp ../ndll/Android/libHypFacebook.so ../../../Export/android/bin/libs/armeabi/libHypFacebook.so
