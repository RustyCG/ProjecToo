CREATE DATABASE project_2

CREATE TABLE supplier_items (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    supplier TEXT,
    org_id INTEGER,
    manufacturer TEXT,
    item_name TEXT, 
    manufacturer_ref_num TEXT,
    quantity INTEGER,
    item_type TEXT,
    item_desc TEXT,
    item_url TEXT, 
    item_expiry_date DATE,
    date_available_from DATE,
    date_available_to DATE,
    storage_location TEXT,
    storage_req TEXT,
    requester_user_id TEXT,
    requester_org_id TEXT
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    org_type TEXT,
    regulatory_authority TEXT,
    registration_num TEXT, 
    org_name TEXT,
    org_id SERIAL UNIQUE,
    individual_name TEXT,
    phone_num TEXT,
    email TEXT,
    password_digest TEXT
);


org_type - NGO, NFP, Manufacturer, Distributor, 
Aus reg bodies - TGA, ACNC