#!/bin/bash

## script to validate external file before insert into database
## dclear the the variable to read the data from the files


## required validation for invoice table
##      1. we pssed the correct number of parameters
##      2. first param is file
##      3. sec param is file
##      4. -r on the first file
##      5. -r on the sec file
##      6. First file has 4 values on each line
##      7. id is uniqe on the first file
##      8. id is integer not zero
##      9. name has no numbers or special char
##      10. total is number
##      11. formate the date field

## 	 skip the iteration rules
#	 line doesn't have the 4 values // continue to get to next line
#	 id of first file is not unique
#	 id of first file is not valid (integer / zero) // continue to get to next line
#      name is not valid
#      total is not a number
#      date with invalid format



## Exit codes:
#	0: Success
#	1: Invalid parameters
#	2: first File not found
#	3: sec File not found
#	4: first File has no read permission
#	5: sec File has no read permission
#	 line doesn't have the 4 values // continue to get to next line
#	 id of first file is not unique
#	 id of first file is not valid (integer / zero) // continue to get to next line
#      name is not valid
#      total is not a number
#      date with invalid format

## declare variables
#first invoice file
INPUT1=${1}
#sec details file
INPUT2=${2}


########### Check if user pass the parameter, ${#} : Total number of parameters
if [ ${#} -ne 2 ]
then
	echo "invalid number of paramters"
	exit 1
fi

########## Check if the first file exists or no
if [ ! -f ${INPUT1} ]
then
	echo "${FILENAME} is not exists"
	exit 2
fi

############# Check if the first file exists or no
if [ ! -f ${INPUT2} ]
then
	echo "${FILENAME} is not exists"
       exit 3
fi

############ Check if the first file has a read permission
if [ ! -r ${INPUT1} ]
then
	echo "${INPUT1} has no read permission"
	exit 4
fi

############ Check if the second file has a read permission
if [ ! -r ${INPUT2} ]
then
	echo "${INPUT2} has no read permission"
	exit 5
fi

########### Read the LINE from first file
while read LINE
do
	ID=0
	NAME=""
	TOTAL=0
	DATE=""


	### loop in each line to get and validate the 4 values
	CO=1
	IFS=":"
	for ELEM in ${LINE}
	do
		#### check the id
		if [ ${CO} -eq 1 ]
		then

			ID=${ELEM}
			## vlidation the type and it's not zero
			if [ ${ID} -eq 0 ] || [[ ! ${ID} =~ ^[0-9]*$ ]]
			then
				echo "invalid ID to insert in the invoice table!!"
				break
			fi

			fi
		#### check the name
		if [ ${CO} -eq 2 ]
		then
			NAME=${ELEM}
			## vlidation the type and it doesn't have special chars
			if [[ ! ${NAME} =~ ^[a-zA-Z-]*$ ]]
			then
				echo "invalid name to insert in the invoice table!!"
				break
			fi

		fi

		#### check the total
		if [ ${CO} -eq 3 ]

		then
			TOTAL=${ELEM}
			## vlidation the type and it's not zero
			if [ ${TOTAL} -eq 0 ] || [[ ! ${TOTAL} =~ ^[0-9]*$ ]]
			then
				echo "invalid TOTAL to insert in the invoice table!!"
				break
			fi
		fi
		#### check the date
		if [ ${CO} -eq 4 ]

		then
			DATE=${ELEM}
			## validating the date
			ITER=1
			IFS="-"
			for TI in ${ELEM}
			do
				## validating the year
				if [ ${ITER} -eq 1 ]
				then
					if [[ ! ${TI} =~ ^[[:digit:]]{4}$ ]]
					then
						break
					fi
				fi
				## validating the month
				if [ $ITER -eq 2 ]
				then
					if [[ ! $TI =~ ^(0[1-9]|1[1-2])$ ]]
					then
						break
					fi
				fi
				## validating the month
				if [ $ITER -eq 3 ]
				then
					if [[ ! $TI =~ ^(0[1-9]|[1-2][0-9]|3[0-1])$ ]]
					then
						break
					fi
				fi
				ITER=$[ITER+1]
			done
			if [ ${ITER} -ne 4 ]
			then
				echo "Invalid Date"
				continue
			fi
		fi
		CO=$[CO+1]
	done

	#### if to validate we have 4 values
	if [ ${CO} -ne 5 ]
	then
		echo "line is not valid, not the correct number of elements"
		continue
	fi
##### interting the vlidated line and check the id from the table before the insertion
### login to the psql with the user name
psql -U 'kholoudmarghany' -d 'kholoudmarghany' -c "do \$\$
declare
val integer;
begin
select count(*)
from invoice
into val
Where id = ${ID};

if val > 1 then
raise exception 'Not Unique';
else
insert into invoice values(${ID},'${NAME}',${TOTAL},'${DATE}');
end if;


end;
\$\$;"

psql -U 'kholoudmarghany' -d 'kholoudmarghany' -c "select * from invoice;"
	###Redirect the input from keyboard to file passed



done < ${INPUT1}




## 	 skip the iteration rules on the table invoice_details
#	 line doesn't have the required 4 values // continue to get to next line
#	 id of file is not unique
#	 id of first file is not valid (integer / zero) // continue to get to next line
#	 inv_id doesn't exist in the invoice table
#      item name is not valid
#      quantity is not a number
#      unit price is not a number

while read LINE
do
	SEQ=0
	ITEM=""
	UNIT=0
	QUANT=0
	INV=0


	### loop in each line to get and validate the 4 values
	CO=1
	IFS=":"
	for ELEM in ${LINE}
	do
		#### check the id
		if [ ${CO} -eq 1 ]
		then

			SEQ=${ELEM}

			## vlidation the type and it's not zero
			if [ ${SEQ} -eq 0 ] || [[ ! ${SEQ} =~ ^[0-9]*$ ]]
			then
				echo "${SEQ}"
				echo "invalid Seq to insert in the invoice table!!"
				break
			fi

			fi

	# 		#### check the Invoice Id is a number
			if [ ${CO} -eq 2 ]

			then
				INV=${ELEM}

				## vlidation the type and it's not zero
				if [ ${INV} -eq 0 ] || [[ ! ${INV} =~ ^[0-9]*$ ]]
				then
					echo "invalid quantity to insert in the invoice table!!"
					break
				fi
			fi

	# 	#### check the item name
		if [ ${CO} -eq 3 ]
		then
			ITEM=${ELEM}
			## vlidation the type and it doesn't have special chars
			if [[ ! ${ITEM} =~ ^[a-zA-Z-]*$ ]]
			then
				echo "invalid Item name to insert in the invoice table!!"
				break
			fi

		fi
	#
	# 	#### check the total
		if [ ${CO} -eq 4 ]

		then
			UNIT=${ELEM}
			## vlidation the type and it's not zero
			if [ ${UNIT} -eq 0 ] || [[ ! ${UNIT} =~ ^[0-9]*$ ]]
			then
				echo "invalid unti price to insert in the invoice table!!"
				break
			fi
		fi
	# 	#### check the quantity
		if [ ${CO} -eq 5 ]

		then
			QUANT=${ELEM}
			## vlidation the type and it's not zero
			if [ ${QUANT} -eq 0 ] || [[ ! ${QUANT} =~ ^[0-9]*$ ]]
			then
				echo "invalid quantity to insert in the invoice table!!"
				break
			fi
		fi
		CO=$[CO+1]
	done
	#
	#
	# #### if to validate we have 4 values
	if [ ${CO} -ne 6 ]
	then
		echo "line is not valid, not the correct number of elements"
		continue
	fi


##### interting the vlidated line and check the id from the table before the insertion
### login to the psql with the user name
psql -U 'kholoudmarghany' -d 'kholoudmarghany' -c "do \$\$
declare
val integer;
val_fk integer;
begin
select count(*)
from invoice_details
into val
Where seq = ${SEQ};

select count(*)
from invoice
into val_fk
Where id = ${INV};

if val > 1 then
raise exception 'Not Unique';
elsif val_fk = 0 then
raise exception 'FK value not matching the main table';
else
insert into invoice_details values(${SEQ},${INV},'${ITEM}',${UNIT},${QUANT});
end if;


end;
\$\$;"

psql -U 'kholoudmarghany' -d 'kholoudmarghany' -c "select * from invoice_details;"
	###Redirect the input from keyboard to file passed

# echo "${SEQ},${INV},'${ITEM}',${UNIT},${QUANT}"

done < ${INPUT2}

exit 0



while read LINE
do
	SEQ=0
	ITEM=""
	UNIT=0
	QUANT=0
	INV=0


	### loop in each line to get and validate the 4 values
	CO=1
	IFS=":"
	for ELEM in ${LINE}
	do
		#### check the id
		if [ ${CO} -eq 1 ]
		then

			SEQ=${ELEM}

			## vlidation the type and it's not zero
			if [ ${SEQ} -eq 0 ]
			then
				echo "${SEQ}"
				echo "invalid Seq to insert in the invoice table!!"
				break
			fi

			fi

			CO=$[CO+1]
	 	done
	 	#
done < ${INPUT2}
