#!/bin/bash

# Define variables
DOMAIN_CONTROLLER="192.168.56.10"
DOMAIN="sevenkingdoms.local"
USERNAME="robert.baratheon"

# Prompt for password
read -s -p "Enter password for $USERNAME: " PASSWORD
echo

# Function to pause and wait for user input
pause() {
  read -p "Press Enter to continue..."
}

# Construct Base DN
BASE_DN="dc=$(echo $DOMAIN | sed 's/\./,dc=/g')"

# Enumerate Domain Admins using go-windapsearch
echo "Running go-windapsearch to enumerate Domain Admins..."
pause
CMD="./go-windapsearch -d \"$DOMAIN\" -u \"$USERNAME\" -p \"$PASSWORD\" --group-members \"Domain Admins\" -dc \"$DOMAIN_CONTROLLER\""
echo "Command: $CMD"
eval $CMD

# Enumerate User SPNs using go-windapsearch
echo -e "\nRunning go-windapsearch to enumerate User SPNs..."
pause
CMD="./go-windapsearch -d \"$DOMAIN\" -u \"$USERNAME\" -p \"$PASSWORD\" --spn -dc \"$DOMAIN_CONTROLLER\""
echo "Command: $CMD"
eval $CMD

# Enumerate Domain Admins using ldapsearch
echo -e "\nRunning ldapsearch to enumerate Domain Admins..."
pause
CMD="ldapsearch -LLL -x -H ldap://$DOMAIN_CONTROLLER -D \"${DOMAIN}\\${USERNAME}\" -w \"$PASSWORD\" -b \"$BASE_DN\" \"(memberOf=cn=Domain Admins,cn=Users,$BASE_DN)\" sAMAccountName"
echo "Command: $CMD"
eval $CMD

# Enumerate User SPNs using ldapsearch
echo -e "\nRunning ldapsearch to enumerate User SPNs..."
pause
CMD="ldapsearch -LLL -x -H ldap://$DOMAIN_CONTROLLER -D \"${DOMAIN}\\${USERNAME}\" -w \"$PASSWORD\" -b \"$BASE_DN\" \"(servicePrincipalName=*)\" sAMAccountName servicePrincipalName"
echo "Command: $CMD"
eval $CMD

# Enumerate all users with Domain Admin privileges using matching-rule-in-chain
echo -e "\nRunning ldapsearch to enumerate all users with Domain Admin privileges (including nested groups)..."
pause
CMD="ldapsearch -LLL -x -H ldap://$DOMAIN_CONTROLLER -D \"${DOMAIN}\\${USERNAME}\" -w \"$PASSWORD\" -b \"$BASE_DN\" \"(memberOf:1.2.840.113556.1.4.1941:=cn=Domain Admins,cn=Users,$BASE_DN)\" sAMAccountName"
echo "Command: $CMD"
eval $CMD

# Enumerate all user objects where adminCount=1 and display only the dn
echo -e "\nRunning ldapsearch to enumerate users with adminCount=1..."
pause
CMD="ldapsearch -LLL -x -H ldap://$DOMAIN_CONTROLLER -D \"${DOMAIN}\\${USERNAME}\" -w \"$PASSWORD\" -b \"$BASE_DN\" \"(adminCount=1)\" dn"
echo "Command: $CMD"
eval $CMD
