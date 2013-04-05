rm -rf "obj"
echo "compiling for armv6"
haxelib run hxcpp Build.xml -Diphoneos
echo "compiling for armv7"
haxelib run hxcpp Build.xml -Diphoneos -DHXCPP_ARMV7
echo "compiling for simulator"
haxelib run hxcpp Build.xml -Diphonesim
echo "Copying sim"
cp ../ndll/iPhone/libHypFacebook.iphonesim.a ../../../Export/ios/hypertest/lib/i386/libHypFacebook.a
echo "Copying v6"
cp ../ndll/iPhone/libHypFacebook.iphoneos.a ../../../Export/ios/hypertest/lib/armv6/libHypFacebook.a
echo "Copying v7"
cp ../ndll/iPhone/libHypFacebook.iphoneos-v7.a ../../../Export/ios/hypertest/lib/armv7/libHypFacebook.a
echo "Setting back hxcpp to 2.10.2"
