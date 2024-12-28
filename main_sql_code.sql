--Запрос для заполнения checkBox водитель
SELECT d.Dispatcher_ID, (h.Last_name + ' ' + h.First_name) AS 'Name'
FROM Dispatcher d
JOIN Human h
ON (d.Human_ID = h.Human_ID);

--Запрос для checkBox клиент
SELECT Client_ID, Username
FROM Client;
--Запрос для checkBox Тариф
SELECT Tariff_ID, Class_car
FROM Tariff;
--Запрос для checkBox Адрес отправления
SELECT 
    Address_ID, 
    (Street + 
     CASE 
         WHEN Entertance_door IS NOT NULL THEN ', Подъезд ' + CAST(Entertance_door AS VARCHAR)
         ELSE ''
     END) AS Full_Address
FROM 
    Address

--Запрос для checkBox адрес назначения
SELECT 
    Address_ID, 
    (Street + 
     CASE 
         WHEN Entertance_door IS NOT NULL THEN ', Подъезд ' + CAST(Entertance_door AS VARCHAR)
         ELSE ''
     END) AS Full_Address
FROM 
    Address

--Запрос для получения данных checkBox статус заказа
SELECT *
FROM OrderStatus;


Отображение списка заказов(Создание представления)
CREATE VIEW vw_Orders AS
SELECT 
    o.Date_create AS [Дата], 
    c.Username AS [Клиент], 
    t.Class_car AS [Тариф], 
    o.Cost AS [Стоимость],
    (a.Street + 
     CASE 
         WHEN a.Entertance_door IS NOT NULL THEN ', Подъезд ' + CAST(a.Entertance_door AS VARCHAR)
         ELSE ''
     END) AS [Адрес отправки],
    (ad.Street + 
     CASE 
         WHEN ad.Entertance_door IS NOT NULL THEN ', Подъезд ' + CAST(ad.Entertance_door AS VARCHAR)
         ELSE ''
     END) AS [Адрес назначения],
    (h.First_name + ' ' + h.Last_name) AS [Водитель],
    os.Status_name AS [Статус]
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

--Вызов созданного представления
SELECT * FROM vw_Orders;

--Получаем информацию по тарифу. (Вместо эконом может быть другой)
SELECT *
FROM Tariff
WHERE Class_car='Эконом-класс';

--Получаем информацию о водителе
SELECT Driver_ID, (h.First_name + ' ' + h.Last_name) AS 'Fullname'
FROM Driver d
JOIN Human h
ON (d.Human_ID = h.Human_ID);

--Получаем район старта
SELECT *
FROM Region;

Получаем записи с Driver WorkLog(Создаём view)
CREATE VIEW vw_DriverWorkLog AS
SELECT
	dwk.Start_date AS [Старт],
	dwk.End_date AS [Завершение],
	(h.First_name + ' ' + h.Last_name) AS [Водитель],
	r.Name AS [Район старта]
FROM DriverWorkLog dwk
JOIN Driver d
ON (dwk.Driver_ID = d.Driver_ID)
JOIN Human h
ON (d.Human_ID = h.Human_ID)
JOIN Region r
ON (dwk.Region_ID = r.Region_ID)

SELECT * FROM vw_DriverWorkLog;


--Получаем представления для отображения списка водителей
CREATE VIEW vw_DriverList AS 
SELECT 
    (h.First_name + ' ' + h.Last_name) AS [Водитель],
    (d.Percent_Taxi_Rider) AS [Процент с поездки],
    (c.Car_brand) AS [Марка],
    (c.Government_number) AS [Гос.номера],
    (t.Class_car) AS [Тариф]
FROM 
    Driver d
JOIN 
    Human h ON h.Human_ID = d.Human_ID
JOIN 
    Car c ON c.Driver_ID = d.Driver_ID
JOIN 
    Tariff t ON c.Tariff_ID = t.Tariff_ID;
SELECT * FROM vw_DriverList;

Представление для живой очереди.Выводит все незанятых водителей. Т.е. те которые находятся на смене и не имеют заказов в выполнении.
CREATE VIEW vw_DriverLiveQueue
AS 
SELECT d.Driver_ID AS [ID],h.First_name + ' ' +  h.Last_name AS [Водитель], O.End_Ride AS [Время последнего заказа], t.Class_car AS [Тариф],
CASE 
        WHEN reg.Name IS NULL THEN (SELECT Name FROM Region WHERE Region_ID = dwl.Region_ID)
        ELSE reg.Name 
    END AS [Текущий Район]
FROM DriverWorkLog dwl
JOIN Driver d
ON (d.Driver_ID = dwl.Driver_ID)
JOIN Human h
ON (d.Human_ID = h.Human_ID)
LEFT JOIN [Order] o --Показываем тех, у кого нету записи в заказах и тех, у кого они есть.
ON (dwl.Driver_ID = o.Driver_ID)
LEFT JOIN Address ad --Соединяем и отображаем тот район, в котором остановился водитель после последней поездки
ON ad.Address_ID = o.Address_distanation_ID
LEFT JOIN Region reg
ON reg.Region_ID = ad.Region_ID
JOIN Car c
ON c.Car_ID = d.Car_ID
JOIN Tariff t
ON t.Tariff_ID = c.Tariff_ID
--Показываем тех, у которых либо нету заказа который принят, либо вообще нету статуса заказа.
WHERE SYSDATETIME() BETWEEN dwl.Start_date AND dwl.End_date
AND (o.OrderStatus_ID != 4 OR o.OrderStatus_ID IS NULL)
Здесь уже проверочка идёт на то, поездкиопять же
AND (
    o.End_Ride IS NULL OR
    o.End_Ride = (
        SELECT MAX(o2.End_Ride)
        FROM [Order] o2
        WHERE o2.Driver_ID = dwl.Driver_ID
    )
)
--Запрос для работы с представленим.
SELECT * FROM vw_DriverLiveQueue WHERE [Тариф]='Эконом-класс' AND [Текущий район]='Ленинский';

--Создаём процедуру, который меняет статус поездки на завершённый после завершения поездки. Нужна для обновления статуса заказа в форме.
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
    MIN(h.First_name + ' ' + h.Last_name) AS [Диспетчер],
    SUM(CASE WHEN os.Status_Name = 'Отклонён' THEN 1 ELSE 0 END) AS [Отклонённые заказы],
    SUM(CASE WHEN os.Status_Name = 'Завершён' THEN 1 ELSE 0 END) AS [Выполненные заказы],
    SUM(CASE WHEN os.Status_Name = 'Выполняется' THEN 1 ELSE 0 END) AS [В выполнении]
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