mkdir build/packages

echo "Building Release Target..."
# flutter build macos --release
echo "Built!"

# rsync -r --progress build/macos/Build/Products/Release/molarity.app build/packages/
mv build/macos/Build/Products/Release/molarity.app build/packages/
mv build/packages/molarity.app build/packages/Molarity.app

echo "Changing Icon..."
cp assets/distribution/icons/icon.icns build/packages/Molarity.app/Contents/Resources/AppIcon.icns

# echo 'Zipping'
# zip -qr -X - build/packages/Molarity.app | pv -s $(($(du -sk build/packages/Molarity.app | awk '{print $1}') * 1024 )) > build/packages/Molarity.zip
# rm build/packages/Molarity.zip
# zip -qdgr -X --display-bytes build/packages/Molarity.zip build/packages/Molarity.app
# zip -qr - build/packages/Molarity.app | pv -bep -s $(du -bs build/packages/Molarity.app | awk '{print $1}') > build/packages/Molarity.zip

# $D=build/packages/Molarity.app
# tar pcf - build/packages/Molarity.app | pv -s $(du -sb build/packages/Molarity.app | awk '{print $1}') --rate-limit 500k | gzip > build/packages/Molarity.tar.gz

# tar cf - build/packages/Molarity.app -P | pv -s $(($(du -sk build/packages/Molarity.app | awk '{print $1}' * 1024))) | gzip > build/packages/Molarity.tar.gz



echo 'Deleting DMG'
rm build/packages/Molarity.dmg

echo 'Creating DMG'
hdiutil create -format UDZO -srcfolder build/packages/Molarity.app build/packages/Molarity.dmg