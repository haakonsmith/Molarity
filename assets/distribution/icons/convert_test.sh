iconbackground1="#1A1F2C"
iconbackground2="#221b33"

convert -size 1024x1024 -sparse-color Barycentric "0,0 $iconbackground1 %w,%h $iconbackground2" canvas:transparent \
    -draw 'image SrcOver 100,100 800,800 icon-clear.png' \
    \( -size 1024x1024 xc:none -fill white -draw "circle 512,512 1024,512" \) -compose copy_opacity -composite goat_method_one.png
