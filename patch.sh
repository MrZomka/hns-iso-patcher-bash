#!/bin/bash

set -e

clear
echo "Hide and Seek ISO Builder"
echo "by damysteryman, edited by CLF78"
echo "Ported to bash by Zomka"
echo "Powered by WIT by Wiimm"
read -p "Press any key to continue..."

echo
echo "Checking resources..."

if [ ! -d "hns" ]; then
    echo
    echo "Cannot find the hns folder."
    echo
    echo "Please make sure you have it in the same directory"
    echo "as this script. Exiting..."
    echo
    read -p "Press any key to exit..."
    exit 1
fi

if [ ! -d "mkw.d" ]; then
    echo
    echo "Unpacking the original game..."
    wit extract -s ../ -1 -n RMC.01 . mkw.d --psel=DATA -ovv
fi

echo
if [ -f "mkw.d/files/Scene/UI/Race_E.szs" ]; then
    GAMEID="RMCP01"
    LETTER="P"
    echo "Detected version: PAL"
elif [ -f "mkw.d/files/Scene/UI/Race_U.szs" ]; then
    GAMEID="RMCE01"
    LETTER="E"
    echo "Detected version: NTSC-U"
elif [ -f "mkw.d/files/Scene/UI/Race_J.szs" ]; then
    GAMEID="RMCJ01"
    LETTER="J"
    echo "Detected version: NTSC-J"
elif [ -f "mkw.d/files/Scene/UI/Race_K.szs" ]; then
    GAMEID="RMCK01"
    LETTER="K"
    echo "Detected version: NTSC-K"
else
    echo "Cannot find a valid Mario Kart Wii ISO/WBFS file."
    echo
    echo "Please make sure you have one in the same directory"
    echo "as this script. Exiting..."
    read -p "Press any key to exit..."
    exit 1
fi

echo
echo "The script will now pause to let you replace any file on the disc."
echo "DO NOT patch this game with the Wiimmfi patcher, or it'll break the game."
read -p "Press any key to resume the procedure..."

echo
echo "Copying mod files..."

mkdir -p mkw.d/files/hns
cp -f hns/code/HideNSeek"$LETTER".bin mkw.d/files/hns
cp -f hns/Patch.szs mkw.d/files/Scene/UI

if [ "$LETTER" == "P" ]; then
    cp -f hns/Patch_E.szs mkw.d/files/Scene/UI
    cp -f hns/Patch_F.szs mkw.d/files/Scene/UI
    cp -f hns/Patch_G.szs mkw.d/files/Scene/UI
    cp -f hns/Patch_I.szs mkw.d/files/Scene/UI
    cp -f hns/Patch_S.szs mkw.d/files/Scene/UI
elif [ "$LETTER" == "E" ]; then
    cp -f hns/Patch_M.szs mkw.d/files/Scene/UI
    cp -f hns/Patch_Q.szs mkw.d/files/Scene/UI
    cp -f hns/Patch_U.szs mkw.d/files/Scene/UI
elif [ "$LETTER" == "J" ]; then
    cp -f hns/Patch_J.szs mkw.d/files/Scene/UI
elif [ "$LETTER" == "K" ]; then
    cp -f hns/Patch_K.szs mkw.d/files/Scene/UI
fi

echo
read -p "Disable Music? (Y/N): " NOMUS
if [[ "$NOMUS" =~ ^[Yy]$ ]]; then
    wit dolpatch mkw.d/sys/main.dol 80004000=01 -q
else
    wit dolpatch mkw.d/sys/main.dol 80004000=00 -q
fi

echo
read -p "Force 30 FPS? (Y/N): " FRAMERATE
if [[ "$FRAMERATE" =~ ^[Yy]$ ]]; then
    wit dolpatch mkw.d/sys/main.dol 8000400F=01 -q
else
    wit dolpatch mkw.d/sys/main.dol 8000400F=00 -q
fi

wit dolpatch mkw.d/sys/main.dol 8000629C=4BFFDF4C load=80004010,hns/Loader.bin -q

echo
echo "Format Selection:"
echo "1. WBFS"
echo "2. ISO"
echo "3. Extracted Filesystem (ADVANCED USERS ONLY)"
read -p "Enter the number corresponding to the format you want: " EXTINPUT

case "$EXTINPUT" in
    1)
        FILEEXT="wbfs"
        ;;
    2)
        FILEEXT="iso"
        ;;
    3)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid option selected."
        exit 1
        ;;
esac

DESTPATH="Hide and Seek [$GAMEID].$FILEEXT"
echo
echo "Rebuilding game..."
wit copy mkw.d "$DESTPATH" -ovv --id=....01 --name="Hide and Seek"

echo
echo "File saved as $DESTPATH"
echo "Cleaning up..."
rm -rf mkw.d

echo
echo "All done!"
read -p "Press any key to exit..."

