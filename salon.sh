#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon ~~~~~\n"

SERVICE_OPTIONS() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # get list of services
  SERVICES_PROVIDED=$($PSQL "SELECT service_id, name FROM services")
  # display list of services
  echo "$SERVICES_PROVIDED" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
} 

SERVICE_MENU() {
  echo -e "\nWelcome to Salon, how can I help you?" 
  # display list of services
  SERVICE_OPTIONS 
  read SERVICE_ID_SELECTED
   # if picked service that doesn't exist
  FIND_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $FIND_SERVICE_NAME ]]
  then
    # show the same list of services again
    SERVICE_OPTIONS "I could not find that service. Choose a service from our list, please:"
  else
    # get customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    # if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get new customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) 
                                      VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
    fi
    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # get time
    echo -e "What time would you like your $(echo $FIND_SERVICE_NAME), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
    read SERVICE_TIME
    # insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) 
                                  VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $(echo $FIND_SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."

  fi
}

SERVICE_MENU