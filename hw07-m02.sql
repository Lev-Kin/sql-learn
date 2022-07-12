/*
-- Домашка 4 --
--drop view въю_время_сотрудников
CREATE VIEW въю_время_сотрудников AS
SELECT dbo.sf_getOnlyDate(з.Дата_Время) Дата, с.id, с.Группа, с.Должность,
SUM(dbo.sf_getMinutes(з.Время_разговора)) Время_звонков
FROM Звонки з
LEFT JOIN Сотрудники с ON с.id=з.Сотрудник
WHERE з.Сотрудник IS NOT NULL
GROUP BY dbo.sf_getOnlyDate(з.Дата_Время), с.id, с.Группа, с.Должность
GO
 
--drop view въю_время_супера
CREATE VIEW въю_время_супера AS 
SELECT вс.Дата, г.Супервайзер id, с.Должность,с.Группа,
avg(вс.Время_звонков)Время_звонков
FROM въю_время_сотрудников вс
LEFT JOIN Группы г ON г.id=вс.Группа
LEFT JOIN Сотрудники с ON с.id=г.Супервайзер
GROUP BY вс.Дата, г.Супервайзер, с.Должность,с.Группа
GO
 
--drop view въю_время_начальника
CREATE VIEW въю_время_начальника AS 
SELECT вр.Дата,с.id,с.Должность,с.Группа,
avg(вр.Время_звонков)Время_звонков
FROM въю_время_супера вр
LEFT JOIN Сотрудники с ON с.Должность=1
GROUP BY  вр.Дата,с.Должность,с.id, с.Группа
GO
 
--=== Ведомость ===--
--drop view въю_зарплата_сотрудников
CREATE VIEW въю_зарплата_сотрудников AS 
SELECT r.Дата, r.id id_Сотрудника, с.Фамилия Фамилия, д.Имя Должность, r.Время_звонков Время_разговора, dbo.sf_getPrice(r.Должность,r.Дата) Цена,
round(r.Время_звонков*dbo.sf_getPrice(r.Должность,r.Дата),2) Сумма_Зарплаты, r.Группа Группа
FROM
(
	SELECT Дата,id,Должность,Группа,Время_звонков
	FROM въю_время_сотрудников
 
	UNION ALL
 
	SELECT Дата,id,Должность,Группа,Время_звонков
	FROM въю_время_супера
 
	UNION ALL
 
	SELECT Дата,id,Должность,Группа,Время_звонков
	FROM въю_время_начальника
)r
LEFT JOIN Сотрудники с ON с.id=r.id AND r.id IS NOT NULL
LEFT JOIN Должности д ON д.id=r.Должность
LEFT JOIN Группы г ON г.id=r.Группа
WHERE  r.id IS NOT NULL
GO
 
--id Сотрудника, Фамилию, Должность, Время разговора, Цену минуты, Сумму начисленной зарплаты для каждой цены тарифа.
SELECT id_Сотрудника, Фамилия, Должность, Время_разговора, Цена, Сумма_Зарплаты
FROM въю_зарплата_сотрудников
GO
 
12. Самостоятельно напишите хранимую процедуру с названием ОборотнаяВедомость.
Выборка процедуры должна содержать информацию о сумме начисленной зарплаты по сотрудникам за указанный период (включая даты начала и конца),
сумму, начисленную до указанного периода и после периода.
Параметры процедуры: 
@ДатаНачала datetime, --Дата начала периода выборки
@ДатаОкончания datetime, --Дата окончания периода выборки
@ИмяГруппы varchar(30) = '%' –Группа. Если не указана, выбирать все.
 
Пример вызова exec ОбороTнаяВедомость :) '10.12.2014', '11.12.2014', 'Группа-2'
*/
 
--drop PROCEDURE ОборотнаяВедомость
--exec ОборотнаяВедомость '10.12.2014','11.12.2014','2'
 
SELECT * FROM въю_зарплата_сотрудников
SELECT * FROM Группы
 
GO
CREATE PROCEDURE ОборотнаяВедомость
@ДатаНачала datetime, 
@ДатаОкончания datetime,
@ИмяГруппы VARCHAR(30) = '%'
AS
SELECT зс.id_Сотрудника, зс.Фамилия, зс.Группа, 0 НачисленоДоНачалаПериода,isnull(SUM(зс.Сумма_Зарплаты),0) НачисленоЗаПериод, 0 НачисленоПослеПериода
INTO #temp
FROM въю_зарплата_сотрудников зс
WHERE 
зс.Дата
BETWEEN @ДатаНачала AND @ДатаОкончания AND зс.Группа LIKE @ИмяГруппы					
GROUP BY зс.id_Сотрудника, зс.Фамилия, зс.Группа
INSERT INTO #temp
SELECT зс.id_Сотрудника, зс.Фамилия, зс.Группа, isnull(SUM(зс.Сумма_Зарплаты),0),0,0
FROM въю_зарплата_сотрудников зс
WHERE
зс.Дата < @ДатаНачала AND зс.Группа LIKE @ИмяГруппы					
GROUP BY зс.id_Сотрудника, зс.Фамилия, зс.Группа
INSERT INTO #temp
SELECT зс.id_Сотрудника, зс.Фамилия, зс.Группа, 0, 0, isnull(SUM(зс.Сумма_Зарплаты),0)
FROM въю_зарплата_сотрудников зс
WHERE 
зс.Дата > @ДатаОкончания AND зс.Группа LIKE @ИмяГруппы						
GROUP BY зс.id_Сотрудника, зс.Фамилия, зс.Группа
SELECT t.id_Сотрудника, t.Фамилия, t.Группа,
SUM(t.НачисленоДоНачалаПериода) НачисленоДоНачалаПериода,
SUM(t.НачисленоЗаПериод) НачисленоЗаПериод,
SUM(t.НачисленоПослеПериода) НачисленоПослеПериода
 FROM #temp t 
 GROUP BY t.id_Сотрудника, t.Фамилия, t.Группа
 ORDER BY 1


