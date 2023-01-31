CREATE DATABASE Manufacturer;
USE Manufacturer
GO

CREATE TABLE Product (
  prod_id INT PRIMARY KEY IDENTITY(1,1),
  prod_name VARCHAR(50) NOT NULL,
  quantity INT NOT NULL
);

CREATE TABLE Component (
  comp_id INT PRIMARY KEY IDENTITY(1,1),
  comp_name VARCHAR(50) NOT NULL,
  description VARCHAR(50),
  quantity_comp INT NOT NULL
);

CREATE TABLE Supplier (
  supp_id INT PRIMARY KEY IDENTITY(1,1),
  supp_name VARCHAR(50) NOT NULL,
  supp_location VARCHAR(50) NOT NULL,
  supp_country VARCHAR(50) NOT NULL,
  is_active BIT NOT NULL
);

CREATE TABLE Comp_Supp (
  supp_id INT,
  comp_id INT,
  order_date DATE,
  quantity INT NOT NULL,
  PRIMARY KEY (supp_id, comp_id),
  FOREIGN KEY (supp_id) REFERENCES Supplier (supp_id),
  FOREIGN KEY (comp_id) REFERENCES Component (comp_id)
);

CREATE TABLE Prod_Comp (
  prod_id INT,
  comp_id INT,
  quantity_comp INT,
  PRIMARY KEY (prod_id, comp_id),
  FOREIGN KEY (prod_id) REFERENCES Product (prod_id),
  FOREIGN KEY (comp_id) REFERENCES Component (comp_id)
);