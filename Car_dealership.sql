
CREATE TABLE customer(
	customer_id SERIAL PRIMARY KEY,
	first_name VARCHAR(45) NOT NULL,
	last_name VARCHAR(45) NOT NULL,
	phone VARCHAR(20),
	email VARCHAR(45)
);

CREATE TABLE salesperson(
	salesperson_id SERIAL PRIMARY KEY,
	first_name VARCHAR(45) NOT NULL,
	last_name VARCHAR(45) NOT NULL,
	phone VARCHAR(20),
	email VARCHAR(45)
);

CREATE TABLE mechanic(
	mechanic_id SERIAL PRIMARY KEY,
	first_name VARCHAR(45) NOT NULL,
	last_name VARCHAR(45) NOT NULL,
	phone VARCHAR(20),
	email VARCHAR(45)
);

CREATE TABLE cars(
	cars_id SERIAL PRIMARY KEY,
	make VARCHAR(45) NOT NULL,
	model VARCHAR(45) NOT NULL,
	year_made INT NOT NULL,
);

ALTER TABLE cars 
ADD inventory INT; 

CREATE TABLE dealership(
	dealership_id SERIAL PRIMARY KEY,
	customer_id INT NOT NULL,
	salesperson_id INT NOT NULL,
	mechanic_id INT NOT NULL,
	cars_id INT NOT NULL,
	dealership_name VARCHAR(45) NOT NULL,
	address VARCHAR(45) NOT NULL,
	FOREIGN KEY(customer_id) REFERENCES customer(customer_id),
	FOREIGN KEY(salesperson_id) REFERENCES salesperson(salesperson_id),
	FOREIGN KEY(mechanic_id) REFERENCES mechanic(mechanic_id),
	FOREIGN KEY(cars_id) REFERENCES cars(cars_id)
);

DROP TABLE IF EXISTS invoices;
CREATE TABLE invoices(
	invoices_id SERIAL PRIMARY KEY,
	customer_id INT NOT NULL,
	salesperson_id INT NOT NULL,
	cars_id INT NOT NULL,
	sale_date VARCHAR(25),
	sale_price FLOAT,
	FOREIGN KEY(customer_id) REFERENCES customer(customer_id),
	FOREIGN KEY(salesperson_id) REFERENCES salesperson(salesperson_id),
	FOREIGN KEY(cars_id) REFERENCES cars(cars_id)
);
 
ALTER TABLE invoices
ADD quantity INT;


CREATE TABLE mechanic_assignment(
	mechanic_assignment_id SERIAL PRIMARY KEY,
	mechanic_id INT NOT NULL,
	cars_id INT NOT NULL,
	FOREIGN KEY(mechanic_id) REFERENCES mechanic(mechanic_id),
	FOREIGN KEY(cars_id) REFERENCES cars(cars_id)
);


CREATE TABLE service_ticket(
	service_ticket_id SERIAL PRIMARY KEY,
	customer_id INT NOT NULL,
	mechanic_assignment_id INT NOT NULL,
	date_in VARCHAR(25), 
	date_out VARCHAR(25), 
	total_cost FLOAT,
	FOREIGN KEY(customer_id) REFERENCES customer(customer_id),
	FOREIGN KEY(mechanic_assignment_id) REFERENCES mechanic_assignment(mechanic_assignment_id)
);



INSERT INTO customer (first_name, last_name, phone, email)
VALUES ('John', 'Doe', '213-222-4584', 'johnnyisdoe@gmail.com'),('Max', 'Shmitty', '808-458-7845', 'shmitty@max.com');

INSERT INTO customer (first_name, last_name, phone, email)
VALUES ('Josh', 'Tho', '218-458-7415', 'joshhi@gmail.com'),('Matt', 'Yetty', '808-458-7845', 'Yetty@yahoo.com');

SELECT * 
FROM customer;

INSERT INTO salesperson (first_name, last_name, phone, email)
VALUES ('Tyler', 'Paine', '949-456-7854', 'tylerpaine@auto.com'), ('Mike', 'Toot', '451-852-7895', 'miketoot@auto.com'), ('Connor', 'Cox', '878-548-5215', 'connorcox@auto.com');

SELECT *
FROM salesperson s; 

INSERT INTO mechanic (first_name, last_name, phone, email)
VALUES ('Ryan', 'Paine', '213-546-8547', 'ryanpaine@auto.com'), ('Steve', 'Commerce', '714-845-7896', 'stevecommerce@auto.com'), ('Mike', 'Fixit', '878-584-8521', 'mikefixit@auto.com');

SELECT *
FROM mechanic;

INSERT INTO cars(make, model, year_made)
VALUES ('Audi', 'A4', 2018), ('Audi', 'A3', 2022), ('Acura', 'Integra', 2023), ('BMW', '3 Series', 2015), ('BMW', '5 Series', 2023);

SELECT *
FROM cars;

-- Adjusting Cars Quantity
CREATE OR REPLACE FUNCTION carQuantity(
	carsId INT,
	newQuantity INT
)
RETURNS INT 
LANGUAGE plpgsql AS $$
BEGIN 
	UPDATE cars
	SET inventory = newQuantity
	WHERE cars_id = carsId;
	RETURN carsId;
END;
$$

SELECT carQuantity(1, 87);
SELECT carQuantity(2, 31);
SELECT carQuantity(3, 4);
SELECT carQuantity(4, 12);
SELECT carQuantity(5, 9);

-- Inserting Service Ticket information
CREATE OR REPLACE PROCEDURE insertService(
	customerId INT,
	assignmentId INT,
	dateIn VARCHAR(25),
	dateOut VARCHAR(25),
	totalCost FLOAT
)
LANGUAGE plpgsql AS $$
BEGIN 
	INSERT INTO service_ticket(
		customer_id,
		mechanic_assignment_id,
		date_in,
		date_out,
		total_cost
	)VALUES(
		customerId,
		assignmentId,
		dateIn,
		dateOut,
		totalCost
	);
	COMMIT;
END;
$$

CALL insertService('2', '2', '2/24/2022', '3/10/2022', 2199);
CALL insertService('1', '2', '2/24/2022', '3/10/2022', 2199);
CALL insertService('4', '1', '10/14/2022', '10/30/2022', 1200);

SELECT *
FROM service_ticket st;


-- Assign Mechanic to Servicing
CREATE OR REPLACE PROCEDURE assignMechanic(
	mechanicId INT,
	carId INT
)
LANGUAGE plpgsql AS $$
BEGIN 
	INSERT INTO mechanic_assignment(
		mechanic_id,
		cars_id
	)VALUES(
		mechanicId,
		carId
	);
	COMMIT;
END;
$$

CALL assignMechanic('2', '2');
CALL assignMechanic('1', '2');

SELECT *
FROM mechanic_assignment ma; 


-- Creating Invoices
CREATE OR REPLACE PROCEDURE insertInvoice(
	salesId INT,
	customerId INT,
	carId INT,
	saleDate VARCHAR(25),
	salePrice FLOAT
)
LANGUAGE plpgsql AS $$
BEGIN 
	INSERT INTO invoices(
		salesperson_id,
		customer_id,
		cars_id,
		sale_date,
		sale_price 
	)VALUES(
		salesId,
		customerId,
		carId,
		TO_DATE(saleDate, 'MM/DD/YYYY'),
		salePrice
	);
	COMMIT;
END;
$$

CALL insertInvoice(3, 1, 5, '2/23/2018', 58000);
CALL insertInvoice(1, 3, 1, '6/03/2022', 19000);
CALL insertInvoice(1, 4, 2, '9/10/2021', 21000);


SELECT *
FROM invoices i;


-- Find the sale price for John's car
SELECT first_name, last_name, sale_price
FROM customer c 
JOIN invoices i ON c.customer_id = i.customer_id 
WHERE first_name = 'John';

-- Find the car details of customerId 3 (Josh)
SELECT first_name, last_name, make, model, sale_price
FROM customer c 
JOIN invoices i ON c.customer_id = i.customer_id 
JOIN cars c2  ON i.cars_id = c2.cars_id 
WHERE c.customer_id = '3';


-- Trigger code
CREATE OR REPLACE FUNCTION update_inventory() 
RETURNS TRIGGER AS $$
BEGIN 
	UPDATE cars 
	SET inventory = inventory - NEW.cars_id 
	WHERE cars_id = NEW.cars_id;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER update_inventory_trigger
AFTER INSERT ON invoices
FOR EACH ROW 
EXECUTE FUNCTION update_inventory();


INSERT INTO customer(first_name, last_name, phone, email)
VALUES ('Ace', 'Herra', '949-214-8456', 'aceh@gmail.com'), ('Val', 'Herrera', '714-845-7851', 'valh@gmail.com');

INSERT INTO cars (make, model, year_made, inventory)
VALUES('Tesla', 'Model 3', 2022, 5), ('Tesla', 'Model Y', 2018, 9)

CALL insertInvoice(3, 5, 5, '1/10/2023', 65000);
CALL insertInvoice(3, 6, 7, '8/22/2022', 80000);
CALL insertInvoice(3, 4, 1, '8/22/2017', 32000);

SELECT *
FROM salesperson s 


-- Find all the names of cars that Connor has sold
SELECT first_name, last_name, make, model, sale_price
FROM salesperson s 
JOIN invoices i ON s.salesperson_id = i.salesperson_id 
JOIN cars c ON i.cars_id = c.cars_id 
WHERE first_name = 'Connor'






