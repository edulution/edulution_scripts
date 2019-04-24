#!/bin/bash

#script to 'disable' autocomplete by appending the contents to an invisible div
# replace the relevant lines in the kalite bundle_common.js file
echo Removing old bundles file
sudo rm /usr/lib/python2.7/dist-packages/kalite/distributed/static/js/distributed/bundles/bundle_common.js*

echo Updating bundles file
sudo cp ~/.scripts/config/bundle_common.js /usr/lib/python2.7/dist-packages/kalite/distributed/static/js/distributed/bundles/

kalite manage collectstatic --noinput

echo Done. Please clear history on your browser to effect this change