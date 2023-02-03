#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~ Welcome to our salon!~~~\n"

MAIN_MENU(){
SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
echo "$SERVICE_LIST"
echo -e "\nHello, how may we help you? Select a number to start an appointment:"
echo "$SERVICE_LIST" | while read SERVICE_ID NAME
do
echo $(echo "$SERVICE_ID $NAME" | sed 's/|\+/\) /g')
done
read SERVICE_ID_SELECTED
SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
if [[ -z $SERVICE_ID ]]
then
echo -e "\nI could not find that service, please select a new one:"
echo "$SERVICE_LIST" | while read SERVICE_ID NAME
do
echo $(echo "$SERVICE_ID $NAME" | sed 's/|\+/\) /g')
done
else
echo -e "\nTo register for an appointment please enter your phone number:"
read CUSTOMER_PHONE
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_ID ]]
then
echo -e "\nYou have not registered before, to begin please enter your name:"
read CUSTOMER_NAME
echo -e "\nNow enter the time you would like the appointment:"
read SERVICE_TIME
NEW_CUSTOMER_RESULTS=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
NEW_APPOINTMENT_TIME=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
else
echo -e "\nPlease enter the time you would like the appointment:"
read SERVICE_TIME
NEW_APPOINTMENT_TIME=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
fi
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
fi
}

MAIN_MENU
