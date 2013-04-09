rm -rf "obj"
rm ../ndll/Android/libHypFacebook.so
echo "Compiling for armv6"
haxelib run hxcpp Build.xml -Dandroid
