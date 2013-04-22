rm -rf "obj"
echo "compiling for armv6"
haxelib run hxcpp Build.xml -Diphoneos -DHXCPP_CLANG
echo "compiling for armv7"
haxelib run hxcpp Build.xml -Diphoneos -DHXCPP_ARMV7 -DHXCPP_CLANG
echo "compiling for simulator"
haxelib run hxcpp Build.xml -Diphonesim -DHXCPP_CLANG
echo "Done ! \n"
echo "Paste this in plist:
--------------------------------------------------------------------------------
<key>FacebookDisplayName</key>
<string>HyperTest</string>
<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>fb494777337211456</string>
			</array>
		</dict>
	</array>
--------------------------------------------------------------------------------
"
