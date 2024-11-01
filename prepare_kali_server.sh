#!/bin/bash

DIR="Windows_Tools_hosting"

if [ -d "$DIR" ]; then
	echo "Directory $DIR exists. Deleting it..."
	rm -rf "$DIR"
fi

echo "Creating new empty directory $DIR..."
mkdir "$DIR"
echo "Done."

ADMODULE_REPO_LINK="https://github.com/samratashok/ADModule.git"
name="ADModule"
git clone "$ADMODULE_REPO_LINK" "$DIR/$name"
if [ $? -eq 0 ]; then
	echo "Cloning Complete."
else
	echo "Error:Failed to Clone the ADModule repository."
	exit 1
fi

zip -r "$DIR/$name.zip" "$DIR/$name"
echo "Creating zip archive for ADMODULE"
rm -rf "$DIR/$name"

PowerView_REPO_Link="https://github.com/PowerShellMafia/PowerSploit.git"
PVname="PowerView"
git clone "$PowerView_REPO_Link" "$DIR/$PVname"
if [ $? -eq 0 ]; then
        echo "Cloning Complete."
else
        echo "Error:Failed to Clone the PowerView repository."
        exit 1
fi

mv "$DIR/$PVname/Recon" "$DIR/"
rm -rf "$DIR/$PVname"
mv "$DIR/Recon" "$DIR/$PVname"
zip -r "$DIR/$PVname.zip" "$DIR/$PVname"
echo "Creating zip archive for PowerView"
rm -rf "$DIR/$PVname"

echo "Starting Pythohn HTTP server on $DIR..."
cd "$DIR" || exit 1
python3 -m http.server 8080