rm -rf "obj"
echo "compiling for armv6"
haxelib run hxcpp Build.xml -Diphoneos -DHXCPP_CLANG
echo "compiling for armv7"
haxelib run hxcpp Build.xml -Diphoneos -DHXCPP_ARMV7 -DHXCPP_CLANG
echo "compiling for simulator"
haxelib run hxcpp Build.xml -Diphonesim -DHXCPP_CLANG
echo "Copying sim"
cp ../ndll/iPhone/libHypFacebook.iphonesim.a ../../../Export/ios/Tests/lib/i386/libHypFacebook.a
echo "Copying sim debug"
cp ../ndll/iPhone/libHypFacebook.iphonesim.a ../../../Export/ios/Tests/lib/i386-debug/libHypFacebook.a
echo "Copying v6"
cp ../ndll/iPhone/libHypFacebook.iphoneos.a ../../../Export/ios/Tests/lib/armv6/libHypFacebook.a
echo "Copying v7"
cp ../ndll/iPhone/libHypFacebook.iphoneos-v7.a ../../../Export/ios/Tests/lib/armv7/libHypFacebook.a
echo "Copying v7 debug"
cp ../ndll/iPhone/libHypFacebook.iphoneos-v7.a ../../../Export/ios/Tests/lib/armv7-debug/libHypFacebook.a
echo "Done !"