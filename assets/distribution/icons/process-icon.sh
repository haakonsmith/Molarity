echo 'Note this needs to be run after package-macos'

echo 'Converting to png'
convert -background none icon.svg -resize 1024x1024 icon.png

echo 'Converting rounding it for bigsur'
iconsur -c 1A1F2C -i icon.png -o iconsur.png set ../../../build/packages/Molarity.app

echo 'Creating icon.icns'
mkdir icon.iconset
sips -z 16 16     iconsur.png --out icon.iconset/icon_16x16.png
sips -z 32 32     iconsur.png --out icon.iconset/icon_16x16@2x.png
sips -z 32 32     iconsur.png --out icon.iconset/icon_32x32.png
sips -z 64 64     iconsur.png --out icon.iconset/icon_32x32@2x.png
sips -z 128 128   iconsur.png --out icon.iconset/icon_128x128.png
sips -z 256 256   iconsur.png --out icon.iconset/icon_128x128@2x.png
sips -z 256 256   iconsur.png --out icon.iconset/icon_256x256.png
sips -z 512 512   iconsur.png --out icon.iconset/icon_256x256@2x.png
sips -z 512 512   iconsur.png --out icon.iconset/icon_512x512.png
cp iconsur.png icon.iconset/icon_512x512@2x.png
iconutil -c icns icon.iconset

echo 'Generating .ico'
convert -background none icon.svg -resize 1024x1024 icon-clear.png

convert -size 1024x1024 -fill "#1A1F2C" canvas:transparent -draw "circle 512,512 1024,512" \
    -draw 'image SrcOver 100,100 800,800 icon-clear.png' \
    icon-windows.png

convert icon-windows.png -resize 256x256 icon.ico 

echo 'Cleaning up..'
# rm icon.png
rm iconsur.png
rm icon-clear.png
rm icon-windows.png
rm -R icon.iconset
echo 'Done'
