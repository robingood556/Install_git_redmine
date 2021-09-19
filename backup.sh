#!/bin/bash

#vars
dir=/mnt/backup
log_file=log.txt
first_disk=/dev/sdc*
second_disk=/dev/sdd*
uuid_firstdisk=$(sudo blkid -s UUID -o value $first_disk)
uuid_seconddisk=$(sudo blkid -s UUID -o value $second_disk)

#backup gitlabm, redmine
function backup_del_old {

   sudo mysqldump -u root --databases redmine_default redminedb | gzip > $dir/redmine/redmine_`date +%y_%m_%d_%s`.gz
   sudo gitlab-backup create
   find $dir/redmine/ -name "*.gz" -mtime +14 -exec rm -f {} \;
   find $dir/gitlab/ -name "*.tar" -mtime +14 -exec rm -f {} \;

}



if findmnt $dir
then
   backup_del_old
else
   if sudo blkid -s UUID -o value $first_disk
   then
      sudo mount --uuid="$uuid_firstdisk" $dir
      backup_del_old
   elif sudo blkid -s UUID -o value $second_disk
   then
      sudo mount --uuid="$uuid_seconddisk" $dir
      backup_del_old
   else
      echo "fail backup" > $log_file
   fi
fi
