#!/bin/bash
##Script that reads invoices from a INVOICEFILE and insert them in datatbase

####validation
   # 1-invoice id is unique
   # 2-Name has no digits
   # 3-parameters are passed
   # 4-id is an integer
   # 5-id >=1
   # 6- has write permission on the database INVOICEFILE
   # 7- has read permission on the database INVOICEFILE
   # 8-total is an integer
   # 9- seq is unique
   # 10- seq is integer
   # 11- inv_id is integer
   # 12- inv_id is an id in invoice table

### Exit codes
	# 0:success
	# 1: Invalid parameters
	# 2: file not exist
	# 4: id is not integer
	# 5: Name has digits
	# 3: INVOICEFILE has no write permission
	# 3: INVOICEFILE has no read permission
	# 4: total is not integer
	# 4:seq is not integer
	# 4: inv_id is  not integer
	# 5:item is invalid
	# 6:date is invalid

#check the number of parameters
if [ ${#} -ne 2 ]
then
	echo "Invalid number of parameters "
	exit 1
fi
INVOICEFILE=${1}
DETAILSFILE=${2}



#check if the files exist
if [ ! -f ${INVOICEFILE} ]
then 
	echo "${INVOICEFILE} not exist"
	exit 2
fi
if [ ! -f ${DETAILSFILE} ]
then
	echo "${DETAILSFILE} not exist"
	exit 2
fi



#check if the files have read permission
if [ ! -r ${INVOICEFILE} ]
then
	echo "${INVOICEFILE} has no read permission"
	exit 3
fi

if [ ! -r ${DETAILSFILE} ] 
then
	echo "${DETAILSFILE} has no read permission"
	exit 3
fi



SEQ=$(awk -F ":" '{print $1}' ${DETAILSFILE})
INV_ID=$(awk -F ":" '{print $2}' ${DETAILSFILE})
ITEM=$(awk -F ":" '{print $3}' ${DETAILSFILE})
QUANTITY=$(awk -F ":" '{print $4}' ${DETAILSFILE})
UNIT=$(awk -F ":" '{print $5}' ${DETAILSFILE})
ID=$(awk -F ":" '{print $1}' ${INVOICEFILE})
NAME=$(awk -F ":" '{print $2}' ${INVOICEFILE})
TOTAL=$(awk -F ":" '{print $3}' ${INVOICEFILE})
DATE=$(awk -F ":" '{print $4}' ${INVOICEFILE})



#check if id seq quantity are integer
COUNT=$(echo ${ID} | egrep -c -v "[^0-9]+")
if [ ${COUNT} -ne 1 ]
then
	echo " ID is not integer"
	exit 4
fi



COUNT=$(echo ${SEQ} | egrep -c -v "[^0-9]")
if [ ${COUNT} -ne 1 ]
then
	echo "SEQ is not integer"
	exit 4
fi



COUNT=$(echo ${QUANTITY} | egrep -c -v "[^0-9]")
if [ ${COUNT} -ne 1 ]
then
	echo "Quantity is not integer"
	exit 4
fi



COUNT=$(echo ${TOTAL} | egrep -c -v "[^0-9]")
if [ ${COUNT} -ne 1 ]
then
	echo "Total is not integer"
	exit 4
fi



COUNT=$(echo ${INV_ID} | egrep -c -v "[^0-9]")
if [ ${COUNT} -ne 1 ]
then
	echo "INV_ID is not integer"
	exit 4
fi

#check for name and items value

COUNT=$(echo ${NAME} | egrep -c -v "[^a-zA-Z]")
if [ ${COUNT} -ne 1 ]
then
	echo "Name is not a valid name."
	exit 5
fi





COUNT=$(echo ${item} | egrep -c -v "[^a-zA-Z]")
if [ ${COUNT} -ne 1 ]
then
	echo "item is not valid."
	exit 5
fi

#Check for date
COUNT=$(echo ${DATE} | egrep -c  "[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}")
if [ ${COUNT} -ne 1 ]
then 
	echo "date is invalid"
	exit 6
fi

psql -d shell_script1 -c "insert into invoice (id, client_name, total, date) values(${ID}, '${NAME}', ${TOTAL}, '${DATE}');"
psql -d shell_script1 -c "insert into invoice_details (seq, inv_id, item, quantity, unit) values(${SEQ}, ${INV_ID}, '${ITEM}', ${QUANTITY}, '${UNIT}');"
exit 0
