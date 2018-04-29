#!/bin/bash
################################################################################
# Script o transfer the relavant parts of the ONF git Centenial to onap gerrit

# rm -rf CENTENNIAL
rm -rf apps/

git clone --quiet https://github.com/OpenNetworkingFoundation/CENTENNIAL > /dev/null
git clone --quiet https://gerrit.onap.org/r/sdnc/apps > /dev/null

cd CENTENNIAL
git pull
cd ..

cd apps
git pull
cd ..

mkdir apps/common
cd apps/common
cp -rL ../../CENTENNIAL/code-Carbon-SR1/* .

# rename java packages
find ./ -type f -exec sed -i "s/com.highstreet.technologies.odl/org.onap.sdnc.apps.sdnr/g" {} \;
find ./ -type f -exec sed -i "s/com.highstreet.technologies/org.onap.sdnc.apps.sdnr/g" {} \;
find ./ -type f -exec sed -i "s/com.highstreet/org.onap.sdnc.apps/g" {} \;
find ./ -type f -exec sed -i "s/system.com/system.org/g" {} \;
find ./ -type f -exec sed -i "s/ONF :: Wireless/ONAP :: SDNC/g" {} \;

grep -anr "com.highstreet"
grep -anr "system.com"

# cleanup help bundle issue in ux feature.xml
find ./ -type f -exec sed -i "s/<bundle>mvn:org.onap.sdnc.apps.sdnr.dlux.help-bundle...project.version.<.bundle>//g" {} \;

# remove unnessesary projects
declare -a uxProjects=(
    "ethService"
    "mwtnClosedLoop"
    "mwtnCompare"
    "mwtnSpectrum"
    "mwtnTdm"
    "odlChat"
    "otnBrowser"
)
for uxProject in "${uxProjects[@]}"
do
    rm -rf ./ux/$uxProject
    find ./ -type f -exec sed -i "s/<module>$uxProject<\/module>//g" {} \;
    find ./ -type f -exec sed -i "s/<bundle>mvn:org.onap.sdnc.apps.sdnr.dlux.$uxProject-bundle...project.version.<.bundle>//g" {} \;
done

# build
rm -rf $HOME/.m2/repository/org/onap/sdnc/apps
mvn clean install -DskipTests -Dmaven.javadoc.skip=true

cd ../..

echo "finished!"