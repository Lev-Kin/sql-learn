/*
Домашнее задание. Модуль 2
Курс: «Теория баз данных»

37. Заполните справочник товаров warecards в базе данных step_l1 используя таблицу warecards2 из базы данных step_l2.
При этом проведите ремастеринг даннных. 
Записи, не попавшие в конечный справочник, сохраните в отдельной таблице wc_error.
Используемые запросы (скрипты) и порядок их выполнения сохраните в файле.
*/

SELECT *
INTO [step_l1].[dbo].[tempWarecards2]
FROM [step_l2].[dbo].[warecards2]
 
SELECT ID, NAME, DimID, Price ,GroupID, Remark
FROM WareCards
UNION ALL
SELECT ROOTID, NAME, DIMID, price, GROUPID, NULL AS Remark
FROM tempWarecards2
 
CREATE TABLE wc_error
(
    ROOTID NVARCHAR(20),
    WEIGHT FLOAT,
    postname NVARCHAR(20),
    PRODCOUNTRYID NVARCHAR(20),
);
 
SELECT ROOTID, WEIGHT, postname, PRODCOUNTRYID 
FROM [step_l2].[dbo].[warecards2]
UNION ALL
SELECT ROOTID, WEIGHT, postname, PRODCOUNTRYID 
FROM wc_error

