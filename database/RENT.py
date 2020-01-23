import pandas as pd
from constants import *

def update_token ():
    property_code = input("What is the property code? ")
    token_hash = input("What is the token transaction hash? ")
    connection.execute(f"UPDATE tblproperty_info SET token_hash = '{token_hash}' WHERE property_code = {property_code};")
    print("Update Complete")
    menu()

def add_buyer():
    wallet_address = input("What is the buyer's wallet address? ")
    check_buyer = f"SELECT buyer_code FROM tblbuyer_info WHERE wallet_address = '{wallet_address}';"
    buyer_df = pd.read_sql(check_buyer, engine)
    try:
        buyer_code = buyer_df['buyer_code'][0]
        print(f"This wallet already exists. Buyer Code: {buyer_code}")
        print("")
        menu()
    except IndexError:
        connection.execute(f"INSERT INTO tblbuyer_info (wallet_address) VALUES ('{wallet_address}')")
        new_buyer = f"SELECT buyer_code FROM tblbuyer_info WHERE wallet_address = '{wallet_address}';"
        buyer_df = pd.read_sql(new_buyer, engine)
        buyer_code = buyer_df['buyer_code'][0]
        print(f"Update Complete. Buyer Code: {buyer_code}")
        print("")
        menu()

def view_sales():
    sales="""
    SELECT p.property_code, p.street_address, p.subdivision, p.legal_description, p.bedrooms, p.full_baths, p.half_baths, p.garage, p.token_hash, s.listing_price
    FROM tblproperty_info p
    JOIN tblsale_info s
    ON p.property_code = s.property_code
    WHERE s.status_code=1;
    """
    sales_df = pd.read_sql(sales, engine)
    print(sales_df)
    print("")
    menu()

def menu():
    print("Which function do you want to call?")
    print("1. Add Token")
    print("2. Add Buyer Wallet")
    print("3. View Properties for Sale")
    choice = input("> ")

    if choice == "1":
        update_token()
    elif choice == "2":
        add_buyer()
    elif choice == "3":
        view_sales()
    else:
        print("Please enter a valid function.")

menu()

