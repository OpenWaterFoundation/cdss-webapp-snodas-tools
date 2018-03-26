rem Copy the site/* contents to the Google Cloud Platform snodas.cdss.state.co.us/app folder.
rem - replace all the files on the web with local files
rem - refer to the `Additional Instructions on how to Deploy the State server` section of the repository README.md for information about how to run this script

call gsutil -m rsync -r -d ../site/css gs://snodas.cdss.state.co.us/app/css 
call gsutil cp ../site/index.html gs://snodas.cdss.state.co.us/app/index.html 
call gsutil -m rsync -r -d ../site/fonts gs://snodas.cdss.state.co.us/app/fonts 
call gsutil -m rsync -r -d ../site/images gs://snodas.cdss.state.co.us/app/images 
call gsutil -m rsync -r -d ../site/javascript gs://snodas.cdss.state.co.us/app/javascript 
call gsutil -m rsync -r -d ../site/json gs://snodas.cdss.state.co.us/app/json 