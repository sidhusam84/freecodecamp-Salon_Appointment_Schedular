#! /bin/bash



echo -e "\n~~~~ Welcome to Salon ~~~~"

echo -e "\nBelow are the list of services we are currently offereing"

echo -e "Pick the service, by entering service number"

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

list_of_services(){

  LIST_OF_SERVICES=$($PSQL "SELECT service_id, name FROM services")

  echo "$LIST_OF_SERVICES" | while IFS="|" read service_id name
  do
    echo "$service_id) $name"
  done  
}

list_of_services

read SERVICE_ID_SELECTED

SERVICE_NAME=$($PSQL "SELECT name FROM services where service_id=$SERVICE_ID_SELECTED")

# IF service id not existing

if [[ -z $SERVICE_NAME ]]
then
  # send to main menu
  echo -e "\nservice not existing, choose correct service number"
  list_of_services
else
  # Ask customer info
  echo -e "\nEnter phone number"
  read CUSTOMER_PHONE 
  EXISTING_CUSTOMER_NAME=$($PSQL "select customer_id,name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # if phone number does not exists
  if [[ -z $EXISTING_CUSTOMER_NAME ]]
  then
    echo "That phone number does not exists"
    echo -e "Enter name"
    read CUSTOMER_NAME
    echo -e "Enter the time slot"
    read SERVICE_TIME
    # Insert customer
    INSERT_CUSTOMERS=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')") 
    # Read CUSTOMER ID for newly inserted customer
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers where phone='$CUSTOMER_PHONE'")
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(time,customer_id,service_id) VALUES('$SERVICE_TIME',$CUSTOMER_ID,$SERVICE_ID_SELECTED)")
    echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  else
    echo "Enter time slot"
    read SERVICE_TIME
    echo "$EXISTING_CUSTOMER_NAME" | while IFS='|' read customer_id customer_name
    do
      echo "$customer_id , $customer_name"
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(time,customer_id,service_id) VALUES('$SERVICE_TIME',$customer_id,$SERVICE_ID_SELECTED)")
      echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $customer_name."
    done  
  fi  

fi



