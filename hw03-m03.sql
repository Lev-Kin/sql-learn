-- Домашнее задание. Модуль 3
-- Курс: «Теория баз данных»

--14. Сделать выборку содержащую:
--id линии, id сотрудника, чаще других отвечавших на звонки линии, количество звонков этого сотрудника на этой линии.
--Создадим таблицу для всех отвеченных звонков
CREATE TABLE Ответ_на_звонки
(
	id  INT  NOT NULL,
	id_Сотрудника INT NOT NULL,
	Фамилия VARCHAR(30) NOT NULL,
	Отвеченые_Звонки INT NOT NULL,
)
GO
 
--Внесем данные по всем отвеченным звонкам
INSERT INTO Ответ_на_звонки (id,id_Сотрудника, Фамилия, Отвеченые_Звонки)
SELECT л.id, с.id, с.Фамилия, COUNT(з.Сотрудник) Отвеченые_Звонки
FROM Линии л, Сотрудники с, Сотрудники_Линии сл, Звонки з
WHERE с.id=сл.Сотрудник AND с.id=з.Сотрудник AND л.id=сл.Линия AND л.id=з.Линия
GROUP BY л.id, с.id, с.Фамилия
ORDER BY Отвеченые_Звонки DESC 
GO
 
--Выборка из отвеченных звонков максимальное на линии
SELECT онз.id_Сотрудника, онз.Фамилия, MAX(онз.Отвеченые_Звонки) Макс_Ответов 
FROM Ответ_на_звонки онз
GROUP BY  онз.id_Сотрудника, онз.Фамилия
ORDER BY Макс_Ответов DESC 
GO

--15.Сделать выборку содержащую:
--Название должности, Среднее время ответа, Среднее время Разговора, Среднее время удержания.
--CONVERT( type [ (length) ], expression [ , style ] )
--SELECT AVG(aggregate_expression)FROM tables [WHERE conditions];
SELECT д.Имя,
CONVERT(TIME, CONVERT(datetime, AVG(CONVERT(FLOAT, (CONVERT (datetime,з.Время_ответа   ))))))Среднее_Время_Ответа,
CONVERT(TIME, CONVERT(datetime, AVG(CONVERT(FLOAT, (CONVERT (datetime,з.Время_разговора))))))Среднее_Время_Разговора,
CONVERT(TIME, CONVERT(datetime, AVG(CONVERT(FLOAT, (CONVERT (datetime,з.Время_удержания))))))Среднее_Время_Удержания
FROM Должности д,Звонки з
WHERE д.id=з.Сотрудник
GROUP BY д.Имя
ORDER BY д.Имя
GO

