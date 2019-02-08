#!/bin/bash
#---------------------------------------------------------
#Script reporting the PODs deployed and their state   
#during ONAP instantiation on K8s
#A. Soleil - TMobile - 2018 - alain.soleil1@t-mobile.com
#Simply run the script on the rancher node, no aparameters
#---------------------------------------------------------

display_frame ()
{
   tput clear
   #tput setaf 7
   echo "+-----------------------------------------------------------------------+"
   echo "| Total ONAP Pods =                                                     |"
   echo "+---------------------+-----+( 0% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 100% )+"
   echo "| Running             |     |                                           |"
   echo "| Pending             |     |                                           |"
   echo "| ContainerCreating   |     |                                           |"
   echo "| CrashLoopBackOff    |     |                                           |"
   echo "| PodInitializing     |     |                                           |"
   echo "| Error               |     |                                           |"
   echo "| Terminating         |     |                                           |"
   echo "| ImagePullBackOff    |     |                                           |"
   echo "| Init                |     |                                           |"
   echo "+---------------------+-----+-------------------------------------------+"
   echo ""
}

display_line ()
{
   # $1 is the line in the screen to use
   # $2 is the value to pass for the graphbar
   tput cup $1 24
   echo "   "
   tput cup $1 24
   echo $2

   tput cup $1 30
   echo "                                         "

   if [[ $2 -ne 0 ]]; then
      L=$(($2 * 40 / Total))
      for (( c=30; c<=$((30 + L)); c++ ))
      do
         tput cup $1 $c
         tput smso;  echo " "; tput rmso
      done
   fi
}


display_frame

# Main loop -------------------------------------------------------------------------------------------------------

while [ : ]
do

   Running=0
   Pending=0
   Creating=0
   Crashing=0
   Initializing=0
   Terminating=0
   Back=0
   Error=0
   Init=0
   Total=0

   kubectl get pods --all-namespaces -o=wide | grep onap > output.txt

   file="output.txt"
   while IFS=: read -r var
   do
      status=$(echo $var | awk '{ print $4 }')
      if [[ "$status" == "Running" ]] ; then
         Running=$((Running + 1))
      elif [[ "$status" == "Pending" ]] ; then
         Pending=$((Pending + 1))
      elif [[ "$status" == "ContainerCreating" ]] ; then
         Creating=$((Creating + 1))
      elif [[ "$status" == "CrashLoopBackOff" ]] ; then
         Crashing=$((Crashing + 1))
      elif [[ "$status" == "PodInitializing" ]] ; then
         Initializing=$((Initializing + 1))
      elif [[ "$status" == "Error" ]] ; then
         Error=$((Error + 1))
      elif [[ "$status" == "Terminating" ]] ; then
         Terminating=$((Terminating + 1))
      elif [[ "$status" == "ImagePullBackOff" ]] ; then
         Back=$((Back + 1))
      else
         Init=$((Init + 1))
      fi
      Total=$((Total + 1))
 
#echo $status

  done <"$file"

   tput cup 1 20
   echo "   "   
   tput cup 1 20
   echo $Total   

   display_line 3  $Running
   display_line 4  $Pending
   display_line 5  $Creating
   display_line 6  $Crashing
   display_line 7  $Initializing
   display_line 8  $Error
   display_line 9  $Terminating
   display_line 10 $Back          
   display_line 11 $Init
  
   sleep 5
 
done
