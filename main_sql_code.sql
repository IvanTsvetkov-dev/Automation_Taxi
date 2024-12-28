--������ ��� ���������� checkBox ��������
SELECT d.Dispatcher_ID, (h.Last_name + ' ' + h.First_name) AS 'Name'
FROM Dispatcher d
JOIN Human h
ON (d.Human_ID = h.Human_ID);

--������ ��� checkBox ������
SELECT Client_ID, Username
FROM Client;
--������ ��� checkBox �����
SELECT Tariff_ID, Class_car
FROM Tariff;
--������ ��� checkBox ����� �����������
SELECT 
    Address_ID, 
    (Street + 
     CASE 
         WHEN Entertance_door IS NOT NULL THEN ', ������� ' + CAST(Entertance_door AS VARCHAR)
         ELSE ''
     END) AS Full_Address
FROM 
    Address

--������ ��� checkBox ����� ����������
SELECT 
    Address_ID, 
    (Street + 
     CASE 
         WHEN Entertance_door IS NOT NULL THEN ', ������� ' + CAST(Entertance_door AS VARCHAR)
         ELSE ''
     END) AS Full_Address
FROM 
    Address

--������ ��� ��������� ������ checkBox ������ ������
SELECT *
FROM OrderStatus;


����������� ������ �������(�������� �������������)
CREATE VIEW vw_Orders AS
SELECT 
    o.Date_create AS [����], 
    c.Username AS [������], 
    t.Class_car AS [�����], 
    o.Cost AS [���������],
    (a.Street + 
     CASE 
         WHEN a.Entertance_door IS NOT NULL THEN ', ������� ' + CAST(a.Entertance_door AS VARCHAR)
         ELSE ''
     END) AS [����� ��������],
    (ad.Street + 
     CASE 
         WHEN ad.Entertance_door IS NOT NULL THEN ', ������� ' + CAST(ad.Entertance_door AS VARCHAR)
         ELSE ''
     END) AS [����� ����������],
    (h.First_name + ' ' + h.Last_name) AS [��������],
    os.Status_name AS [������]
FROM 
    [Order] o
JOIN 
    Client c ON c.Client_ID = o.Client_ID
JOIN 
    Tariff t ON t.Tariff_ID = o.Tariff_ID
JOIN 
    [Address] a ON a.Address_ID = o.Address_departure_ID
JOIN
	[Address] ad ON o.Address_distanation_ID = ad.Address_ID
LEFT JOIN 
    [Driver] d ON d.Driver_ID = o.Driver_ID
LEFT JOIN 
    [Human] h ON d.Human_ID = h.Human_ID
JOIN 
    [OrderStatus] os ON o.OrderStatus_ID = os.OrderStatus_ID;

--����� ���������� �������������
SELECT * FROM vw_Orders;

--�������� ���������� �� ������. (������ ������ ����� ���� ������)
SELECT *
FROM Tariff
WHERE Class_car='������-�����';

--�������� ���������� � ��������
SELECT Driver_ID, (h.First_name + ' ' + h.Last_name) AS 'Fullname'
FROM Driver d
JOIN Human h
ON (d.Human_ID = h.Human_ID);

--�������� ����� ������
SELECT *
FROM Region;

�������� ������ � Driver WorkLog(������ view)
CREATE VIEW vw_DriverWorkLog AS
SELECT
	dwk.Start_date AS [�����],
	dwk.End_date AS [����������],
	(h.First_name + ' ' + h.Last_name) AS [��������],
	r.Name AS [����� ������]
FROM DriverWorkLog dwk
JOIN Driver d
ON (dwk.Driver_ID = d.Driver_ID)
JOIN Human h
ON (d.Human_ID = h.Human_ID)
JOIN Region r
ON (dwk.Region_ID = r.Region_ID)

SELECT * FROM vw_DriverWorkLog;


--�������� ������������� ��� ����������� ������ ���������
CREATE VIEW vw_DriverList AS 
SELECT 
    (h.First_name + ' ' + h.Last_name) AS [��������],
    (d.Percent_Taxi_Rider) AS [������� � �������],
    (c.Car_brand) AS [�����],
    (c.Government_number) AS [���.������],
    (t.Class_car) AS [�����]
FROM 
    Driver d
JOIN 
    Human h ON h.Human_ID = d.Human_ID
JOIN 
    Car c ON c.Driver_ID = d.Driver_ID
JOIN 
    Tariff t ON c.Tariff_ID = t.Tariff_ID;
SELECT * FROM vw_DriverList;

������������� ��� ����� �������.������� ��� ��������� ���������. �.�. �� ������� ��������� �� ����� � �� ����� ������� � ����������.
CREATE VIEW vw_DriverLiveQueue
AS 
SELECT d.Driver_ID AS [ID],h.First_name + ' ' +  h.Last_name AS [��������], O.End_Ride AS [����� ���������� ������], t.Class_car AS [�����],
CASE 
        WHEN reg.Name IS NULL THEN (SELECT Name FROM Region WHERE Region_ID = dwl.Region_ID)
        ELSE reg.Name 
    END AS [������� �����]
FROM DriverWorkLog dwl
JOIN Driver d
ON (d.Driver_ID = dwl.Driver_ID)
JOIN Human h
ON (d.Human_ID = h.Human_ID)
LEFT JOIN [Order] o --���������� ���, � ���� ���� ������ � ������� � ���, � ���� ��� ����.
ON (dwl.Driver_ID = o.Driver_ID)
LEFT JOIN Address ad --��������� � ���������� ��� �����, � ������� ����������� �������� ����� ��������� �������
ON ad.Address_ID = o.Address_distanation_ID
LEFT JOIN Region reg
ON reg.Region_ID = ad.Region_ID
JOIN Car c
ON c.Car_ID = d.Car_ID
JOIN Tariff t
ON t.Tariff_ID = c.Tariff_ID
--���������� ���, � ������� ���� ���� ������ ������� ������, ���� ������ ���� ������� ������.
WHERE SYSDATETIME() BETWEEN dwl.Start_date AND dwl.End_date
AND (o.OrderStatus_ID != 4 OR o.OrderStatus_ID IS NULL)
����� ��� ���������� ��� �� ��, ������������ ��
AND (
    o.End_Ride IS NULL OR
    o.End_Ride = (
        SELECT MAX(o2.End_Ride)
        FROM [Order] o2
        WHERE o2.Driver_ID = dwl.Driver_ID
    )
)
--������ ��� ������ � �������������.
SELECT * FROM vw_DriverLiveQueue WHERE [�����]='������-�����' AND [������� �����]='���������';

--������ ���������, ������� ������ ������ ������� �� ����������� ����� ���������� �������. ����� ��� ���������� ������� ������ � �����.
CREATE PROCEDURE UpdateOrderStatus
AS
BEGIN
    UPDATE [Order]
    SET OrderStatus_ID = 2
    WHERE end_ride < GETDATE() AND OrderStatus_ID = 4;
END

CREATE VIEW vw_dispatcherOrderStatistics AS
SELECT
    d.Dispatcher_ID AS [ID],
    MIN(h.First_name + ' ' + h.Last_name) AS [���������],
    SUM(CASE WHEN os.Status_Name = '�������' THEN 1 ELSE 0 END) AS [���������� ������],
    SUM(CASE WHEN os.Status_Name = '��������' THEN 1 ELSE 0 END) AS [����������� ������],
    SUM(CASE WHEN os.Status_Name = '�����������' THEN 1 ELSE 0 END) AS [� ����������]
FROM
    Dispatcher d
LEFT JOIN
    [Order] o ON d.Dispatcher_ID = o.Dispatcher_ID
LEFT JOIN
    OrderStatus os ON o.OrderStatus_ID = os.OrderStatus_ID
LEFT JOIN
    Human h ON h.Human_ID = d.Human_ID
GROUP BY
    d.Dispatcher_ID;