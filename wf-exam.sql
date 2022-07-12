/*
Экзамен. Теория баз данных.
База данных для выполнения заданий: CallCenter

=== Задание 1 ===
Написать запрос, выводящий имена сотрудников, имеющих тезок и их количество.
Например:
Александр	2
Василий		3
*/
SELECT с.Имя Имя_сотрудника, COUNT(сс.id) Тёзка_количество
FROM Сотрудники с, Сотрудники сс
WHERE с.Имя = сс.Имя and с.id <> сс.id
GROUP BY с.Имя
--------------------------------------------------------------------------------


/*
=== Задание 2 ===
Написать запрос, выводящий фамилии сотрудников, 
время ответа на звонок и фамилию супервайзера группы,
где работают эти сотрудники.
В выборку должны попадать только сотрудники у которых были звонки
с временем ответа более 8 минут.
Выборку отсортировать по убыванию времени ответа.
*/
SELECT с.Фамилия Фамилия_сотрудника, з.Время_ответа, сс.Фамилия Фамилия_супервайзера
FROM Сотрудники с
	LEFT JOIN Звонки з ON з.Сотрудник = с.id
	LEFT JOIN Группы г ON с.Группа = г.id
	LEFT JOIN Сотрудники сс ON сс.id = г.Супервайзер
WHERE з.Время_ответа > '00:08:00'
ORDER BY з.Время_ответа DESC
--------------------------------------------------------------------------------


/*
=== Задание 3 ===
Сделать выборку содержащую:
Название группы, фамилию сотрудника этой группы с 
наибольшим суммарным временем разговора,
суммарное время в минутах этого сотрудника.
*/
--DROP TABLE #Temp
SELECT г.Имя Название_группы, с.Фамилия Фамилия_сотрудника,
ROUND(SUM(dbo.sf_getMinutes(з.Время_разговора)), 0) Время_разговора
INTO #Temp
FROM Группы г
	LEFT JOIN Сотрудники с ON с.Группа = г.id
	LEFT JOIN Звонки з ON з.Сотрудник = с.id
GROUP BY г.Имя, с.Фамилия

SELECT *
FROM #Temp
WHERE Время_разговора
IN (
	SELECT MAX(Время_разговора)
	FROM #Temp
	GROUP BY Название_группы
	)
--------------------------------------------------------------------------------


/*
=== Задание 4 ===
Написать хранимую процедуру «ОборотнаяВедомость», 
рассчитывающую по сотрудникам за указанный период сумму начисленной зарплаты,
суммы выплаченной зарплаты и сумму задолженности по зарплате 
(разница между начисленным и выплаченным).
Параметры процедуры:
ДатаНачалаПериода, ДатаОкончанияПериода
Выводимые столбцы: 
idСотрудника, Фамилия, Должность, Группа, СуммаНачисленоЗаПериод,
СуммаВыплаченоЗаПериод, СуммаЗадолженность.
Выборка должна быть отсортирована по idСотрудника, суммы округлены до копеек.

Для формирования таблицы выплат зарплаты, используйте запрос:
select Дата, КодСотрудника id, Зарплата 
into Выплаты
from вЗарплатаСотрудников
where Дата<'25/12/2014'

Где вЗарплатаСотрудников - представление, которое возвращает таблицу с
расчетам зарплаты всех сотрудников за все дни.
Представление содержит поля:
Дата, КодСотрудника, ФамилияСотрудника, Должность, Группа, ВремяЗвонков, Цена, СуммаЗП.
Зарплата специалиста считается за фактическое время.
Зарплата супервайзера от среднего времени звонков сотрудников его группы.
Зарплата начальника от среднего расчетного времени супервайзеров.
*/
--DROP VIEW въю_время_сотрудников
GO
CREATE VIEW въю_время_сотрудников
AS
SELECT dbo.sf_getOnlyDate(з.Дата_Время) Дата, с.id, с.Группа, с.Должность,
SUM(dbo.sf_getMinutes(з.Время_разговора)) Время_звонков
FROM Звонки з
	LEFT JOIN Сотрудники с ON с.id=з.Сотрудник
WHERE з.Сотрудник IS NOT NULL
GROUP BY dbo.sf_getOnlyDate(з.Дата_Время), с.id, с.Группа, с.Должность
GO
 
--DROP VIEW въю_время_супера
CREATE VIEW въю_время_супера
AS 
SELECT вс.Дата, г.Супервайзер id, с.Должность, с.Группа,
AVG(вс.Время_звонков)Время_звонков
FROM въю_время_сотрудников вс
	LEFT JOIN Группы г ON г.id=вс.Группа
	LEFT JOIN Сотрудники с ON с.id=г.Супервайзер
GROUP BY вс.Дата, г.Супервайзер, с.Должность,с.Группа
GO
 
--DROP VIEW въю_время_начальника
CREATE VIEW въю_время_начальника
AS 
SELECT вр.Дата,с.id,с.Должность,с.Группа,
AVG(вр.Время_звонков)Время_звонков
FROM въю_время_супера вр
	LEFT JOIN Сотрудники с ON с.Должность=1
GROUP BY вр.Дата, с.Должность, с.id, с.Группа
GO
 
--=== Ведомость ===--
--DROP VIEW въю_зарплата_сотрудников
CREATE VIEW въю_зарплата_сотрудников
AS 
SELECT r.Дата, r.id КодСотрудника, с.Фамилия Фамилия, д.Имя Должность, r.Время_звонков Время_разговора, dbo.sf_getPrice(r.Должность, r.Дата) Цена,
ROUND(r.Время_звонков*dbo.sf_getPrice(r.Должность,r.Дата),2) Зарплата
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
WHERE r.id IS NOT NULL
GO

--Выплаты SELECT * FROM Выплаты
SELECT Дата, КодСотрудника id, Зарплата
INTO Выплаты
FROM въю_зарплата_сотрудников
WHERE Дата < '25/12/2014'
GO

--=== ОборотнаяВедомость ===--
--DROP PROCEDURE ОборотнаяВедомость
GO
CREATE PROCEDURE ОборотнаяВедомость
	@ДатаНачалаПериода datetime,
	@ДатаОкончанияПериода datetime
AS
	SELECT
	--с.id КодСотрудника, с.Фамилия ФамилияСотрудника, д.Имя Должность, г.Имя Группа,
	--isnull(sum(зс.Зарплата),0) СуммаНачисленоЗаПериод, isnull(sum(в.Зарплата),0) СуммаВыплаченоЗаПериод,
	--isnull(sum(зс.Зарплата),0)-isnull(sum(в.Зарплата),0) СуммаЗадолженность
	зс.Дата, с.id КодСотрудника, с.Фамилия ФамилияСотрудника, д.Имя Должность, г.Имя Группа, зс.Время_разговора ВремяЗвонков, зс.Цена, зс.Зарплата СуммаЗП
	FROM Сотрудники с
		LEFT JOIN Должности д ON д.id=с.Должность
		LEFT JOIN Группы г ON г.id=с.Группа
		LEFT JOIN въю_зарплата_сотрудников зс ON зс.КодСотрудника=с.id AND зс.Дата>=@ДатаНачалаПериода AND зс.Дата<=@ДатаОкончанияПериода 
		LEFT JOIN Выплаты в ON в.id=с.id AND зс.Дата=в.Дата AND в.Дата>=@ДатаНачалаПериода AND в.Дата<=@ДатаОкончанияПериода 
	WHERE  @ДатаНачалаПериода > ISNULL(Дата_найма,'01/01/1970') AND @ДатаНачалаПериода < ISNULL(Дата_увольнения,'01/01/3000')
	AND зс.Время_разговора IS NOT NULL
	GROUP BY зс.Дата, с.id, с.Фамилия, д.Имя ,г.Имя, зс.Цена, зс.Время_разговора, зс.Зарплата
	ORDER BY 2

--exec ОборотнаяВедомость '10.12.2014','10.12.2014'
--------------------------------------------------------------------------------


/*
=== Задание 5 ===
Написать скалярную функцию «СписокИменинников».
Функция, для указанной в параметре даты,
должна возвращать строку со списком (через запятую) работающих сотрудников,
у которых эта дата - день рождения.
Пример вызова функции:
select 'Список именинников: ' + dbo.СписокИменинников('18.03.2015')
*/
--DROP FUNCTION dbo.СписокИменинников
GO
CREATE FUNCTION dbo.СписокИменинников
(
	@Дата datetime 
) 
RETURNS varchar(8000)
AS 
BEGIN	
    DECLARE @Список		varchar(800) = ' '
	DECLARE @Фамилия	varchar(800)
	DECLARE @Имя		varchar(800)
 
	DECLARE Курсор_список CURSOR FOR 
	SELECT Фамилия, Имя
	FROM Сотрудники
	WHERE FORMAT(Дата_рождения, 'MMdd') = FORMAT(@Дата ,'MMdd')   
		and @Дата > ISNULL(Дата_найма,'01/01/1990')
		and @Дата < ISNULL(Дата_увольнения,'01/01/9999')
	ORDER BY 1
 
	OPEN Курсор_список
	FETCH NEXT FROM Курсор_список
	INTO @Фамилия, @Имя
		SET @Список = NULL
		WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @Список = ISNULL(@Список+', '+@Фамилия+' '+@Имя, @Фамилия+' '+@Имя)
				FETCH NEXT FROM Курсор_список
				INTO @Фамилия, @Имя
			END
				CLOSE Курсор_список
		 DEALLOCATE Курсор_список
	RETURN ISNULL (@Список,'')
END
GO

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


/*
select * from Сотрудники
order by 5
*/
