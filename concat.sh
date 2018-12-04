#!/bin/bash
#set -x
echo "-------Welcome to Log Concatenation----------"
read -p 'Enter start URL: ' startVar
read -p 'Enter end URL: ' endVar

tempStart=$(echo $startVar | awk -F'_' '{ print $2 }')
tempEnd=$(echo $endVar | awk -F'_' '{ print $2 }')

modStart=$(echo $tempStart | sed 's/-/\//g')
modend=$(echo $tempEnd | sed 's/-/\//g')

input_start=$(echo $modStart | awk -F / '{print ""$3"-"$2"-"$1}')
input_end=$(echo $modend | awk -F / '{print ""$3"-"$2"-"$1}')


startdate=$(date -I -d "$input_start") || exit -1
enddate=$(date -I -d "$input_end")     || exit -1

d="$startdate"
while [ "$d" != "$enddate" ]; do


       #endDate=$(echo $startVar | awk -F'_' '{ print $2 }')
       temp=$startVar
       tempDate=$d

       tempDate=$(echo $tempDate | awk -F - '{print ""$3"-"$2"-"$1}')
       echo "Temp date is " $tempDate

       pattern=$(echo $startVar | awk -F'_' '{ print $2 }')
       startVar=$(echo $temp | sed "s/$pattern/$tempDate/")
       temphours=$(echo $startVar | awk -F'_' '{ print $NF }' | awk -F'.' '{print $1}')
       echo $startVar
       startVar=$(echo $startVar | sed "s/$temphours/00/")
       echo start variable is $startVar
       excep=$(echo $startVar | awk -F'_' '{ print $2 }' | awk -F'-' '{ print $1 }')
       if [[ "$excep" -eq 00 ]]; then
            startVar=$(echo $startVar | sed '0,/00/ s//24/')
	          startVar=$(echo $startVar | sed 's/\(.*\)24/\100/')
	          echo Exception condition is $startVar
       fi
       threads=$(echo $startVar | awk -F'_' '{ print $NF }' | awk -F'.' '{print $1}')
       #threads=00

	while [ $threads -lt 24 ]; do
  	  wget -O - $startVar --append-output=append.log >> append.log
  	  hours=$(echo $startVar | awk -F'_' '{ print $NF }' | awk -F'.' '{print $1}')

  	  echo Hours is $hours


          #hours="${hours#0}"
	  echo Hours after modification $hours
          if [[ "$inc" -le 8 ]]; then

	     hours="${hours#0}"
             #echo "Magic happens"
	     inc=$(echo "$((hours+1))")
	     startVar=$(echo $startVar | sed "s/\(.*\)$hours/\1$inc/")
	     #echo start variable inside if less tahn 10 is  $startVar
	     pretrail=$(echo $startVar | awk -F'_' '{ print $NF }' | awk -F'.' '{print $1}')

	     if [[ ${#pretrail} -eq 1 ]]; then
		postTrail=0${pretrail}
	        startVar=$(echo $startVar | sed "s/\(.*\)$pretrail/\1$postTrail/")
		#echo start variable inside after lots of modification  $startVar
	     fi

          else

	     hours="${hours#0}"
	     inc=$(echo "$((hours+1))")
             #echo increment is $inc
  	     startVar=$(echo $startVar | sed "s/\(.*\)$hours/\1$inc/")
             #echo start variable inside if more than 10 is  $startVar
             trail=$(echo $startVar | awk -F'_' '{ print $NF }' | awk -F'.' '{print $1}')
             replTrail="${trail#0}"
	     startVar=$(echo $startVar | sed "s/\(.*\)$trail/\1$replTrail/")
             #echo start variable inside after lots of modification  $startVar
	     pretrailGT=$(echo $startVar | awk -F'_' '{ print $NF }' | awk -F'.' '{print $1}')

             if [[ ${#pretrailGT} -eq 1 ]]; then
                postTrailGT=0${pretrailGT}
                startVar=$(echo $startVar | sed "s/\(.*\)$pretrailGT/\1$postTrailGT/")
                #echo start variable inside after lots of modification  $startVar
             fi

          fi

          echo starting  $startVar
  	  threads=$[$threads+1]
          echo $threads
	done

  echo $d
  d=$(date -I -d "$d + 1 day")
done
