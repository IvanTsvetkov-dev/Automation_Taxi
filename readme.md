# Automating the work of a city taxi dispatcher

### Database practice
*Technologies:* DBMS - SQL SERVER, Modeling - Oracle Data Modeler, Interface - Windows Form Application(C#)

*Task:* Develop information system, according requirements.
### Stages:
1. Analyze subject area  
2. Design database. 
3. Create user interface 
4. Chose DBMS and develop structure date.
5. Coding

### Task
Taxi drivers work on their own transport, giving the service a fixed percentage of the money earned on each trip. Cars are divided into classes (economy class, middle class, business class, elite class). Tariffs for trips are set centrally according to the formula: cost of delivery + kilometers of the way * cost per kilometer + waiting time * cost of waiting. The cost depends on the class of the car.

Regular customers receive a discount (a certain fixed percentage of the cost at the standard rate). The client is offered to become a "regular" after a certain number of trips from his address and / or called from his phone. He chooses a unique code name, which simplifies further communication with the dispatcher.

At any given time, one dispatcher provides taxi management. The dispatcher receives calls and assigns orders to drivers. He is responsible for important decisions that affect the taxi's profit, customer satisfaction, and driver satisfaction:

determine whether the caller is a regular or "regular" customer;
accept or refuse the order;
assign a car of the desired class or offer the client another;
select a car to carry out the order;
decide which district the driver should go to after completing the order.
The dispatcher's salary is a fixed salary + a certain percentage of the money earned (by the taxi service) during his shifts.

The live queue method is used to distribute orders among drivers: the first in line is selected from among the cars of the required class in the required district. Drivers' satisfaction with dispatchers depends on the "fairness" in the distribution of orders (equality of the average waiting time for an order by drivers, minimization of cases when a driver is forced to move from district to district empty (going out to orders or returning)).

*Post scriptum:* city will be chose Yaroslavl, him streets, areas.

Main task:

1. Register drivers, cars, the moments when drivers start work, the moments when work ends, etc.

2. Register the time of order receipt, customer phone number, address for car delivery, destination district, arrival time of the car at the departure address, the moment of the start of the trip, the moment of the end of the trip, the cost taken from the passenger, etc.

3. Promptly register the position (by district) of free and occupied cars, the position of drivers in the "live queue".

4. Display statistics on dispatchers

### Description entities
1. Human

2. Driver.
Each driver is a priori a human being and has his own car that he works on (according to the problem conditions). He also has a fixed percentage that he receives from each trip.

3. Client.
Each person can be a client who ordered a taxi. The client can be regular and have a corresponding discount (a certain fixed percentage of the cost at the standard rate). This entity has the following attributes
4. Dispatcher.
Each person can be a dispatcher who receives calls from clients and assigns orders to drivers. This entity has the following attributes
5. DriverWorkLog.
Each driver works a certain number of hours per day (shift). When coming to work, the dispatcher records the start time of the shift and the end time. The driver starts the shift in a certain area (that is, there can be several drivers in one area at the same time)

6. Car. Each driver works only on his own car. Each car has its own class (Rate), on which the cost of the trip depends. This entity has the following attributes

7. Tariff. Each trip has a certain tariff - economy, medium, business, elite. Tariffs for trips are set by the formula: cost of delivery + kilometers of the way * cost per kilometer + waiting time * waiting cost. This entity has the following attributes

8. Order.The client places an order. He tells the dispatcher by phone what tariff he wants to go at and specifies where from and where he needs to go. The cost of the trip is automatically calculated based on the distance from the departure point to the destination determined by the dispatcher, the time of car delivery, waiting time and the time of the trip itself are calculated. Automatically, based on this data, start_ride (trip start time) is recorded - the time of order placement + driver waiting time, end_ride (end time) - the time of order placement + driver waiting time + travel time. This will allow us to get approximately the time when we can add the driver to the live queue without calling the driver in advance. The driver is assigned and the order status becomes “in progress”. Or, if there is no suitable driver, then the driver, time and end of the trip, cost and waiting time are not filled in
the order. The status indicates rejected.

9. OrderStatus.Each order must have a status. As soon as the order is received by the dispatcher and he assigns a free driver, the order is in the “in progress” state, as soon as the driver has completed his order - it is “completed”. If there are no free drivers - the order is “rejected”

10. Address.When placing an order, the client specifies the destination address and the arrival address. Each address has a street and house number (This is included in Street). Also, each street belongs to a certain district

11. Region.Each city has certain districts with their own names. Each district has its own streets and addresses. When assigning a driver, the dispatcher selects the one closest to the pick-up point, that is, the one who is in the same district
### ERD

![Logical](https://github.com/user-attachments/assets/c23866c5-463e-4e11-966e-74f202f31158)  
### Relational Model  
![Relational](https://github.com/user-attachments/assets/859ff666-699c-4765-8721-de4738f80ed7)  

### Screenshoot User Interface  
![image](https://github.com/user-attachments/assets/152b208a-2716-441a-96cf-1d42d7ec7587)  
![image](https://github.com/user-attachments/assets/516c20fd-5a4e-4cac-9168-4765ff60839c)  
![image](https://github.com/user-attachments/assets/8708c9d0-8435-415e-a5a7-26900feb5068)
![image](https://github.com/user-attachments/assets/783dfc6d-c96b-407a-b35b-1159c6d51d88)
![image](https://github.com/user-attachments/assets/d19733d9-451d-4b00-a575-1ec25aa5feae)  

## Result
The main target of this database practice was design complex model and try implement it.

*Post scriptum:* The user interface was not the main target.





