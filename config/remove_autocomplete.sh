#!/bin/bash

#script to 'disable' autocomplete by appending the contents to an invisible div
# replace the relevant lines in the kalite bundle_common.js file

file=/usr/lib/python2.7/dist-packages/kalite/distributed/static/js/distributed/bundles/bundle_common.js

#kalite manage collectstatic --noinput
   
 if grep -q 'minLength:2,delay:0,html:!0,appendTo:".login"' "$file"; then
 	#test if a known unique line exists in the original file
 	#make backup of the original bundles file if it has not already been modified
 	sudo cp /usr/lib/python2.7/dist-packages/kalite/distributed/static/js/distributed/bundles/bundle_common.js /usr/lib/python2.7/dist-packages/kalite/distributed/static/js/distributed/bundles/bundle_common.js.bak
 	echo 'Making backup of bundles file'

 	#modify the bundles file to hide autocomplete
 	echo 'Modifying bundles file to remove autocomplete on user login'
 	sudo sed -i 's/minLength:2,delay:0,html:!0,appendTo:".login"/minLength:2,delay:0,html:!0,appendTo:"#hide_autocomplete"/' $file
 	sudo sed -e '/id="loginModalLabel"/ {' -e 'r ~/.scripts/config/bundles_line_16_mod' -e 'd' -e '}' -i $file
 	echo 'Applying removal of autocomplete'
   	kalite manage collectstatic --noinput
 	echo 'Done!'
 	
 elif grep -q 'minLength:2,delay:0,html:!0,appendTo:"#hide_autocomplete"' "$file";then
   echo 'Bundles file already modified. Do nothing'
   #modify the bundles file to hide autocomplete
   # echo 'Modifying bundles file to remove autocomplete on user login'
   # sudo sed -i 's/minLength:2,delay:0,html:!0,appendTo:".login"/minLength:2,delay:0,html:!0,appendTo:"#hide_autocomplete"/' $file
   # sudo sed -e '/id="loginModalLabel"/ {' -e 'r ~/.scripts/config/bundles_line_16_mod' -e 'd' -e '}' -i $file
   # echo done
 fi

