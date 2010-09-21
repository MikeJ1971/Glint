#!/bin/bash

tag=$1

if [ "$tag" == "" ]; then
	echo "No tag specified"
	exit
fi

project="Glint"
git_repo="git@github.com:MikeJ1971/Glint.git"
releases_folder=~/Development/releases
src_folder=$releases_folder/source
build_folder=$releases_folder/build
dmg_folder=$releases_folder/dmg/

# clone the repository if necessary
if [ ! -d $src_folder ]; then
	echo "The project folder doesn't exist. Will make and clone the repository"
	mkdir -p $src_folder
	cd $src_folder
	git clone $git_repo $project
fi

# checkout the tagged version we want to release
cd $src_folder/$project
git pull origin master
git fetch --tags
git checkout $tag

# update the version
sed -i "" "s/__VERSION__/'$tag'/g" Glint-Info.plist

# make sure we have a build folder
if [ ! -d $build_folder ]; then
	mkdir -p $build_folder
fi

# build the project
xcodebuild -target $project -configuration Release OBJROOT=$build_folder SYMROOT=$build_folder OTHER_CFLAGS=""

# bail out if we haven't got a clean build
if [ $? != 0 ]; then
	echo "Bad build!"
	exit
fi

filesize=`stat -f %z $build_folder/Release/$project.app`

echo "******************************** $filesize"

# make sure we have a build folder
if [ ! -d $dmg_folder ]; then
	mkdir -p $dmg_folder
fi

dmgcanvas -t $src_folder/$project/glint-template.dmgCanvas -o  $dmg_folder/$project-$tag.dmg -v $project-$tag
