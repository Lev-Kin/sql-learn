/*
Домашнее задание. Модуль 1
Курс: «Теория баз данных»

При помощи скриптов сгенерируйте базу данных step_l1
Создайте таблицу для ведения справочника единиц измерения состоящую из полей rootid, name
Добавьте эту таблицу в диаграмму.
Пришлите скриншот.
Создайте в таблице WareCards индекс по полю Name
Сгенерируйте и пришлите скрипт таблицы с индексами.
Наполните таблицы данными (10-15 операция, 2-3 кассы, 10-15 товаров, 3-4 группы)

*/

CREATE DATABASE step_l1
USE step_l1
 
-- Создаем таблицы Вещевые карты и Операции наличных и заполняем
CREATE TABLE WareCards(
  ID INT NOT NULL,
  Name nvarchar(50) NOT NULL, --
  Dim nvarchar(50), --
  Price money,
  Grup nvarchar(50), --
  Remark nvarchar(50),
  CONSTRAINT PK_WareCards PRIMARY KEY(ID),
)
 
INSERT WareCards(ID,Grup,Dim,Name) VALUES
(10001,N'Мучное изделие',N'г',N'Хлеб - Бородинский'),
(10002,N'Мучное изделие',N'г',N'Хлеб - Нарачанский'),
(10003,N'Мучное изделие',N'г',N'Хлеб - Купаловский'),
(10004,N'Мучное изделие',N'г',N'Хлеб - Ржаной край'),
(10005,N'Молочные продукты',N'мл',N'Молоко - Бабушкина крынка'),
(10006,N'Молочные продукты',N'мл',N'Молоко - Славянские традиции'),
(10007,N'Молочные продукты',N'мл',N'Молоко - Минская марка'),
(10008,N'Молочные продукты',N'г',N'Сыр - Голланндский Премиум'),
(10009,N'Молочные продукты',N'г',N'Сыр - Сметанковый'),
(10010,N'Молочные продукты',N'кг',N'Сыр - Белая Русь'),
(10011,N'Хоз. товары',N'шт',N'Гупки - Dompi'),
(10012,N'Хоз. товары',N'шт',N'Швабра - для полов'),
(10013,N'Хоз. товары',N'шт',N'Швабра - для окон'),
(10014,N'Сад и огород',N'шт',N'Шампур металический'),
(10015,N'Сад и огород',N'шт',N'Липкая лента от мух')
 
CREATE TABLE CashOperats(
  ID INT NOT NULL,
  QAmount REAL,
  Amount money,
  ADate datetime NOT NULL CONSTRAINT DF_CashOperats_ADate DEFAULT SYSDATETIME(),
  CashBox nvarchar(50),
CONSTRAINT PK_CashOperats PRIMARY KEY (ID),
)
 
INSERT CashOperats(ID,QAmount,Amount,CashBox) VALUES
(10001,100,10,N'Экспресс касса'),
(10002,250,15,N'Общая касса'),
(10003,320,15,N'Самообслуживания касса'),
(10004,180,16,N'Экспресс касса'),
(10005,180,18,N'Экспресс касса'),
(10006,200,20,N'Общая касса'),
(10007,300,11,N'Самообслуживания касса'),
(10008,400,5,N'Экспресс касса'),
(10009,50,6,N'Экспресс касса'),
(10010,2,8,N'Экспресс касса'),
(10011,4,2,N'Общая касса'),
(10012,3,3,N'Общая касса'),
(10013,6,4,N'Самообслуживания касса'),
(10014,3,8,N'Самообслуживания касса'),
(10015,2,10,N'Общая касса')
 
-- Группа товаров
CREATE TABLE WareGroups(
  ID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_WareGroups PRIMARY KEY,
  Name nvarchar(50) NOT NULL
)
 
-- Ящики наличных (кассы)
CREATE TABLE CashBoxes(
  ID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_CashBoxes PRIMARY KEY,
  Name nvarchar(50) NOT NULL
)
 
-- Размерность товаров
CREATE TABLE Dimensionalities(
  ID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Dimensionalities PRIMARY KEY,
  Name nvarchar(50) NOT NULL
)
 
-- Заполняем справочники (группа товаров, ящики наличных, размерность товаров)
INSERT WareGroups(Name)
SELECT DISTINCT Grup
FROM WareCards
WHERE Grup IS NOT NULL -- отбрасываем записи у которых позиция не указана
 
INSERT CashBoxes(Name)
SELECT DISTINCT CashBox
FROM CashOperats
WHERE CashBox IS NOT NULL
 
INSERT Dimensionalities(Name)
SELECT DISTINCT Dim
FROM WareCards
WHERE Dim IS NOT NULL
-----------------------------------------------------------
ALTER TABLE WareCards ADD DimID INT, GroupID INT
ALTER TABLE CashOperats ADD CashBoxID INT
-----------------------------------------------------------
ALTER TABLE WareCards ADD CONSTRAINT FK_WareCards_DimID
FOREIGN KEY(DimID) REFERENCES Dimensionalities(ID)
 
ALTER TABLE WareCards ADD CONSTRAINT FK_WareCards_GroupID
FOREIGN KEY(GroupID) REFERENCES WareGroups(ID)
 
ALTER TABLE CashOperats ADD CONSTRAINT FK_CashOperats_CashBoxID
FOREIGN KEY(CashBoxID) REFERENCES CashBoxes(ID)
------------------------------------------------------------
 
SELECT * FROM WareCards
SELECT * FROM CashOperats
SELECT * FROM WareGroups
SELECT * FROM CashBoxes
SELECT * FROM Dimensionalities
 
-- делаем Апгрейт таблиц Вещевые карты и Операции наличных
UPDATE wc
SET
   DimID =(SELECT ID FROM Dimensionalities WHERE Name=wc.Dim),
 GroupID =(SELECT ID FROM WareGroups WHERE Name=wc.Grup)
FROM WareCards wc
 
UPDATE cb
SET
   CashBoxID =(SELECT ID FROM CashBoxes WHERE Name=cb.CashBox)
FROM CashOperats cb
 
---------------------------------------------------------------
 
SELECT * FROM WareCards
SELECT * FROM CashOperats
 
-- Удаляем лишние колонки
ALTER TABLE WareCards DROP COLUMN Dim,Grup
ALTER TABLE CashOperats DROP COLUMN CashBox
 
-- Проверка поиск (проверка)
SELECT wc.ID,g.Name Group_goods, wc.Name, d.Name Dimensional
FROM WareCards wc
LEFT JOIN WareGroups g ON g.ID=wc.GroupID
LEFT JOIN Dimensionalities d ON d.ID=wc.DimID
 
--------------------- Удаляем
DROP TABLE WareCards
DROP TABLE CashOperats
---------------------
 
-- Заново создаем и Делаем связи в таблице Вещевые карты
CREATE TABLE WareCards(
  ID INT NOT NULL,
  Name nvarchar(50),
  DimID INT,
  Price money,
  GroupID INT,
  Remark nvarchar(50),
CONSTRAINT PK_WareCards PRIMARY KEY (ID),
CONSTRAINT FK_WareCards_DimID FOREIGN KEY(DimID) REFERENCES Dimensionalities(ID),
CONSTRAINT FK_WareCards_GroupID FOREIGN KEY(GroupID) REFERENCES WareGroups(ID),
CONSTRAINT CK_WareCards_ID CHECK(ID BETWEEN 10000 AND 19999),
INDEX IDX_WareCards_Name(Name) -- индекс по полю Name
)
 
INSERT WareCards(ID,Name) VALUES
(10001,N'Хлеб - Бородинский'),
(10002,N'Хлеб - Нарочанский'),
(10003,N'Хлеб - Купаловский'),
(10004,N'Хлеб - Ржаной край'),
(10005,N'Молоко - Бабушкина крынка'),
(10006,N'Молоко - Славянские традиции'),
(10007,N'Молоко - Минская марка'),
(10008,N'Сыр - Голландский Премиум'),
(10009,N'Сыр - Сметанковый'),
(10010,N'Сыр - Белая Русь'),
(10011,N'Гупки - Dompi'),
(10012,N'Швабра - для полов'),
(10013,N'Швабра - для окон'),
(10014,N'Шампур металлический'),
(10015,N'Липкая лента от мух')
 
-- Заново создаем и Делаем связи в таблице Операции наличных
CREATE TABLE CashOperats(
  ID INT NOT NULL,
  WareCardID INT,
  QAmount REAL,
  Amount money,
  ADate datetime NOT NULL CONSTRAINT DF_CashOperats_ADate DEFAULT SYSDATETIME(),
  CashBoxID INT,
CONSTRAINT PK_CashOperats PRIMARY KEY (ID),
CONSTRAINT FK_CashOperats_WareCardID FOREIGN KEY(WareCardID) REFERENCES WareCards(ID),
CONSTRAINT FK_CashOperats_CashBoxID FOREIGN KEY(CashBoxID) REFERENCES CashBoxes(ID),
CONSTRAINT CK_CashOperats_ID CHECK(ID BETWEEN 10000 AND 19999),
)
 
INSERT CashOperats(ID,QAmount,Amount) VALUES
(10001,100,10),
(10002,250,15),
(10003,320,15),
(10004,180,16),
(10005,180,18),
(10006,200,20),
(10007,300,11),
(10008,400,5),
(10009,50,6),
(10010,2,8),
(10011,4,2),
(10012,3,3),
(10013,6,4),
(10014,3,8),
(10015,2,10)



