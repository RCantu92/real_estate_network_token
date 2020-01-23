CREATE TABLE tblowner_info (
	owner_code SERIAL PRIMARY KEY,
	first_name VARCHAR (30),
	last_name VARCHAR (30),
	wallet_address VARCHAR (50)
);

CREATE TABLE tblzip_codes (
	zip_code INT PRIMARY KEY,
	city VARCHAR,
	state VARCHAR,
	county VARCHAR
);

CREATE TABLE tblstatus_codes (
	status_code SERIAL PRIMARY KEY,
	status VARCHAR (30)
);

CREATE TABLE tblbuyer_info (
	buyer_code SERIAL PRIMARY KEY,
	wallet_address VARCHAR (50)
);

CREATE TABLE tblsale_info (
	sale_code SERIAL PRIMARY KEY,
	status_code INT NOT NULL,
	property_code INT NOT NULL,
	listing_price MONEY,
	sale_price MONEY,
	buyer_code INT,
	sale_date DATE,
	transaction_hash VARCHAR (50),
	FOREIGN KEY (status_code) REFERENCES tblstatus_codes(status_code),
	FOREIGN KEY (property_code) REFERENCES tblproperty_info(property_code),
	FOREIGN KEY (buyer_code) REFERENCES tblbuyer_info(buyer_code)
);

CREATE TABLE tblproperty_info (
	property_code INT PRIMARY KEY,
	owner_code INT NOT NULL,
	street_address VARCHAR (50),
	zip_code INT NOT NULL,
	subdivision VARCHAR,
	legal_description VARCHAR,
	bedrooms INT,
	full_baths INT,
	half_baths INT,
	garage VARCHAR (30),
	stories DECIMAL,
	year_built INT,
	building_sqft INT,
	lot_sqft INT,
	annual_maintenance_fee MONEY,
	token_hash VARCHAR (50),
	FOREIGN KEY (owner_code) REFERENCES tblowner_info(owner_code),
	FOREIGN KEY (zip_code) REFERENCES tblzip_codes(zip_code)
);