CREATE TABLE Address 
    (
     Address_ID INTEGER NOT NULL IDENTITY NOT FOR REPLICATION , 
     Entertance_door INTEGER , 
     Street VARCHAR (128) NOT NULL , 
     Region_ID INTEGER NOT NULL 
    )
GO

ALTER TABLE Address ADD CONSTRAINT Address_PK PRIMARY KEY CLUSTERED (Address_ID)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Car 
    (
     Car_ID INTEGER NOT NULL IDENTITY NOT FOR REPLICATION , 
     Car_brand VARCHAR (256) NOT NULL , 
     Government_number VARCHAR (9) NOT NULL , 
     Tariff_ID INTEGER NOT NULL , 
     Driver_ID INTEGER NOT NULL 
    )
GO 

    


CREATE UNIQUE NONCLUSTERED INDEX 
    Car__IDX ON Car 
    ( 
     Driver_ID 
    ) 
GO

ALTER TABLE Car ADD CONSTRAINT Car_PK PRIMARY KEY CLUSTERED (Car_ID)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Client 
    (
     Client_ID INTEGER NOT NULL IDENTITY NOT FOR REPLICATION , 
     Username VARCHAR (128) NOT NULL , 
     Human_ID INTEGER NOT NULL , 
     Phone_number VARCHAR (12) NOT NULL , 
     Discount_percent INTEGER 
    )
GO 


ALTER TABLE Client 
    ADD 
    CHECK ( Discount_percent>0 AND Discount_percent <101 ) 
GO

    


CREATE UNIQUE NONCLUSTERED INDEX 
    Client__IDX ON Client 
    ( 
     Human_ID 
    ) 
GO

ALTER TABLE Client ADD CONSTRAINT Client_PK PRIMARY KEY CLUSTERED (Client_ID)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Dispatcher 
    (
     Dispatcher_ID INTEGER NOT NULL IDENTITY NOT FOR REPLICATION , 
     Human_ID INTEGER NOT NULL , 
     Salary FLOAT NOT NULL , 
     Percent_order INTEGER NOT NULL 
    )
GO 


ALTER TABLE Dispatcher 
    ADD 
    CHECK (Percent_order >0 AND Percent_order <101 ) 
GO

    


CREATE UNIQUE NONCLUSTERED INDEX 
    Dispatcher__IDX ON Dispatcher 
    ( 
     Human_ID 
    ) 
GO

ALTER TABLE Dispatcher ADD CONSTRAINT Dispatcher_PK PRIMARY KEY CLUSTERED (Dispatcher_ID)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Driver 
    (
     Driver_ID INTEGER NOT NULL IDENTITY NOT FOR REPLICATION , 
     Human_ID INTEGER NOT NULL , 
     Percent_Taxi_Rider INTEGER NOT NULL , 
     Car_ID INTEGER NOT NULL 
    )
GO 


ALTER TABLE Driver 
    ADD 
    CHECK (Percent_Taxi_Rider >0 AND Percent_Taxi_Rider <101 ) 
GO

    


CREATE UNIQUE NONCLUSTERED INDEX 
    Driver__IDX ON Driver 
    ( 
     Human_ID 
    ) 
GO 


CREATE UNIQUE NONCLUSTERED INDEX 
    Driver__IDXv1 ON Driver 
    ( 
     Car_ID 
    ) 
GO

ALTER TABLE Driver ADD CONSTRAINT Driver_PK PRIMARY KEY CLUSTERED (Driver_ID)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE DriverWorkLog 
    (
     Log_ID INTEGER NOT NULL IDENTITY NOT FOR REPLICATION , 
     Start_date DATETIME NOT NULL , 
     End_date DATETIME NOT NULL , 
     Driver_ID INTEGER NOT NULL , 
     Region_ID INTEGER NOT NULL 
    )
GO

ALTER TABLE DriverWorkLog ADD CONSTRAINT DriverWorkLog_PK PRIMARY KEY CLUSTERED (Log_ID)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Human 
    (
     Human_ID INTEGER NOT NULL IDENTITY NOT FOR REPLICATION , 
     First_name VARCHAR (128) NOT NULL , 
     Last_name VARCHAR (128) NOT NULL 
    )
GO

ALTER TABLE Human ADD CONSTRAINT Human_PK PRIMARY KEY CLUSTERED (Human_ID)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE "Order" 
    (
     Order_ID INTEGER NOT NULL IDENTITY NOT FOR REPLICATION , 
     Client_ID INTEGER NOT NULL , 
     Tariff_ID INTEGER NOT NULL , 
     Date_create DATETIME NOT NULL , 
     Distantion_km FLOAT NOT NULL , 
     Waiting_time_minutes INTEGER , 
     Cost FLOAT , 
     Dispatcher_ID INTEGER NOT NULL , 
     Address_distanation_ID INTEGER NOT NULL , 
     Address_departure_ID INTEGER NOT NULL , 
     Ride_time_minutes INTEGER NOT NULL , 
     Driver_ID INTEGER , 
     OrderStatus_ID INTEGER NOT NULL , 
     Start_Ride DATETIME , 
     End_Ride DATETIME 
    )
GO

ALTER TABLE "Order" ADD CONSTRAINT Order_PK PRIMARY KEY CLUSTERED (Order_ID)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE OrderStatus 
    (
     OrderStatus_ID INTEGER NOT NULL IDENTITY NOT FOR REPLICATION , 
     Status_name VARCHAR (14) NOT NULL 
    )
GO 


ALTER TABLE OrderStatus 
    ADD 
    CHECK ( Status_name IN ('Выполняется', 'Завершён', 'Отклонён') ) 
GO

ALTER TABLE OrderStatus ADD CONSTRAINT OrderStatus_PK PRIMARY KEY CLUSTERED (OrderStatus_ID)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Region 
    (
     Region_ID INTEGER NOT NULL IDENTITY NOT FOR REPLICATION , 
     Name VARCHAR (128) NOT NULL 
    )
GO

ALTER TABLE Region ADD CONSTRAINT Region_PK PRIMARY KEY CLUSTERED (Region_ID)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Tariff 
    (
     Tariff_ID INTEGER NOT NULL IDENTITY NOT FOR REPLICATION , 
     Class_car VARCHAR (30) NOT NULL , 
     Cost_km FLOAT NOT NULL , 
     Cost_service FLOAT NOT NULL , 
     Cost_waiting FLOAT NOT NULL 
    )
GO 


ALTER TABLE Tariff 
    ADD 
    CHECK ( Class_car IN ('Бизнес-класс', 'Средний-класс', 'Эконом-класс', 'Элитный-класс') ) 
GO

ALTER TABLE Tariff ADD CONSTRAINT Tariff_PK PRIMARY KEY CLUSTERED (Tariff_ID)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

ALTER TABLE Address 
    ADD CONSTRAINT Address_Region_FK FOREIGN KEY 
    ( 
     Region_ID
    ) 
    REFERENCES Region 
    ( 
     Region_ID 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Car 
    ADD CONSTRAINT Car_Tariff_FK FOREIGN KEY 
    ( 
     Tariff_ID
    ) 
    REFERENCES Tariff 
    ( 
     Tariff_ID 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Client 
    ADD CONSTRAINT Client_Human_FK FOREIGN KEY 
    ( 
     Human_ID
    ) 
    REFERENCES Human 
    ( 
     Human_ID 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Dispatcher 
    ADD CONSTRAINT Dispatcher_Human_FK FOREIGN KEY 
    ( 
     Human_ID
    ) 
    REFERENCES Human 
    ( 
     Human_ID 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Driver 
    ADD CONSTRAINT Driver_Human_FK FOREIGN KEY 
    ( 
     Human_ID
    ) 
    REFERENCES Human 
    ( 
     Human_ID 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE DriverWorkLog 
    ADD CONSTRAINT DriverWorkLog_Driver_FK FOREIGN KEY 
    ( 
     Driver_ID
    ) 
    REFERENCES Driver 
    ( 
     Driver_ID 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE DriverWorkLog 
    ADD CONSTRAINT DriverWorkLog_Region_FK FOREIGN KEY 
    ( 
     Region_ID
    ) 
    REFERENCES Region 
    ( 
     Region_ID 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE "Order" 
    ADD CONSTRAINT Order_Address_FK FOREIGN KEY 
    ( 
     Address_distanation_ID
    ) 
    REFERENCES Address 
    ( 
     Address_ID 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE "Order" 
    ADD CONSTRAINT Order_Address_FKv1 FOREIGN KEY 
    ( 
     Address_departure_ID
    ) 
    REFERENCES Address 
    ( 
     Address_ID 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE "Order" 
    ADD CONSTRAINT Order_Client_FK FOREIGN KEY 
    ( 
     Client_ID
    ) 
    REFERENCES Client 
    ( 
     Client_ID 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE "Order" 
    ADD CONSTRAINT Order_Dispatcher_FK FOREIGN KEY 
    ( 
     Dispatcher_ID
    ) 
    REFERENCES Dispatcher 
    ( 
     Dispatcher_ID 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE "Order" 
    ADD CONSTRAINT Order_Driver_FK FOREIGN KEY 
    ( 
     Driver_ID
    ) 
    REFERENCES Driver 
    ( 
     Driver_ID 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE "Order" 
    ADD CONSTRAINT Order_OrderStatus_FK FOREIGN KEY 
    ( 
     OrderStatus_ID
    ) 
    REFERENCES OrderStatus 
    ( 
     OrderStatus_ID 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE "Order" 
    ADD CONSTRAINT Order_Tariff_FK FOREIGN KEY 
    ( 
     Tariff_ID
    ) 
    REFERENCES Tariff 
    ( 
     Tariff_ID 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO