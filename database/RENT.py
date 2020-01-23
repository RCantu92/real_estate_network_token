import pandas as pd
from constants import *

def update_token ():
    property_code = input("What is the property code? ")
    token_hash = input("What is the token transaction hash? ")
    connection.execute(f"UPDATE tblproperty_info SET token_hash = '{token_hash}' WHERE property_code = {property_code};")
    print("Update Complete")

print("Which function do you want to call?")
print("1. Add Token")
print("2. Add Transaction Detail")
choice = input("> ")

if choice == "1":
    update_token()
elif choice == "2":
    print("opition 2")
else:
    print("Please enter a valid function.")