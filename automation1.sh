#Functions
function change-to-directory() {
	cd $1
}

function install-apache2() {
	sudo apt-get install apache2 -y
}

function uninstall-apache2() {
	sudo service apache2 stop
	sudo apt-get purge apache2 apache2-bin apache2-data apache2-utils -y
	sudo apt-get autoremove -y
	sudo rm -rf /etc/apache2
}

#To check updates on system installed packages.
sudo apt update -y
echo "Custom Message: Updated system packages."

#Change to root directory
PWD=$(sudo pwd)
if [ $PWD != "/" ]
	then
		change-to-directory /
		echo $(sudo pwd)
fi
echo "Custom Message: Currently at root directory."

#Check if apache2 is already installed, else install it
apacheFilesCount=$(dpkg-query -l | grep -i "apache2" | wc -l)
echo $apacheFilesCount
if [ $apacheFilesCount -gt 0 ]
	then
		echo "Custom Message: Apache already installed."
else
	echo "Custom Message: Installing apache2 server."
	install-apache2
fi
dpkg-query -l apache2
echo "Custom Message: Apache2 is available."

#Check if apache2 service is running?
statusRunning=$(sudo service apache2 status | grep -i "active" | grep -i "running" | wc -l)
echo $statusRunning
if [ $statusRunning -gt 0 ]
then
	echo "Custom Message: Apache2 is already running."
else 
	echo "Custom Message: Started running Apache2 server."
	sudo service apache2 start
fi

#Achiving the log files
name="Snehit"
timestamp=$(date "+%d%m%Y-%H%M%S")
tarName="$name-httpd-logs-$timestamp.tar"
apacheLogFolderPath="/var/log/apache2"
change-to-directory $apacheLogFolderPath
sudo tar -cf $tarName *.log
sudo mv *.tar /tmp
echo "Custom Message: Completed archiving files and moved to /tmp directory."

#Moving the archive files to S3 bucket.
s3bucketName="upgrad-snehit-tadepalli"
aws s3 cp /tmp/$tarName s3://$s3bucketName/$tarName
