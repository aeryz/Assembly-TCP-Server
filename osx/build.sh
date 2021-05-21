
FILES=(helper socket main)

if [ "PLATFORM_OSX" = "$1" ]
then
    FORMAT="macho64"
    PLATFORM="$1"
else
    FORMAT="elf64"
    PLATFORM="PLATFORM_LINUX"
fi

OBJ_FILES=""

for f in ${FILES[@]}
do
    echo 'Building: ' $f
    nasm -d$PLATFORM -f $FORMAT $f.s
    OBJ_FILES+="$f.o "
done

echo "Linking $OBJ_FILES"
if [ "PLATFORM_OSX" = "$PLATFORM" ]
then
    gcc -Wl,-no_pie $OBJ_FILES -o server
else
    gcc $OBJ_FILES -o server
fi
