/*
Контрольная работа. Теория баз данных.

Задание 1
Написать запрос, выводящий фамилии сотрудников, уволенных в декабре 2014 года
*/
select с.Фамилия
from Сотрудники с
where с.Дата_увольнения>=CONVERT(date,'2014-12-01') and с.Дата_увольнения<=CONVERT(date,'2014-12-31')

/*
Задание 2
Написать запрос, выводящий имена сотрудников, имеющих тезок. Вывести поля Имя, КоличествоТезок.
*/
select Имя, count(Имя)
from Сотрудники
group by Имя
having COUNT(1)>1

/*
Задание 3
Написать запрос, 
выводящий фамилии сотрудников, время ответа на звонок и фамилию супервайзера группы, где работают эти сотрудники.
В выборку должны попадать только сотрудники у которых были звонки с временем ответа более 8 минут.
Выборку отсортировать по убыванию времени ответа.
*/
select с.Фамилия, з.Время_ответа, сс.Фамилия Супервайзер
from Сотрудники с, Звонки з, Группы г, Сотрудники сс
where с.id=з.Сотрудник and сс.id=г.Супервайзер and dbo.sf_getMinutes(з.Время_ответа)>8 and г.id=с.Группа
order by з.Время_ответа desc

/*
Задание 4
Написать запрос,
выводящий для перечня сотрудников следующие поля:
id Сотрудника, Фамилию, номер и название линии, на которой у этого сотрудника наименьшее
суммарное время разговоров и это наибольшее наименьшее время линии.
*/
--drop view вВремяСотрудников
--go
create view minВремяСотрудников as 
select с.id, с.Фамилия, з.Линия, min(dbo.sf_getMinutes(з.Время_разговора)) min_Время_звонков_на_линии
from Звонки з
left join Сотрудники с on с.id=з.Сотрудник
WHERE з.Сотрудник IS NOT NULL
group by  с.id, с.Фамилия, з.Линия

SELECT мвс.id, мвс.Фамилия, мвс.Линия, min(мвс.min_Время_звонков_на_линии) Мин_Время 
FROM minВремяСотрудников мвс
GROUP BY   мвс.id,  мвс.Фамилия, мвс.Линия
ORDER BY Линия DESC 


/*
Задание 5
Написать блок кода, используя курсор,
для получения на указанную дату строки со списком (через запятую)
работающих сотрудников (Фамилия Имя), у которых эта дата - день рождения.
Пример оформления:
Declare @Дата datetime = '18.03.2015'

BEGIN
  declare @Список varchar(8000)
-- скрипт
  print @Список
END
*/
declare @Дата datetime = '18.03.2015'
declare @Список varchar(8000)=' '
declare @Имя varchar(800)
declare @Фамилия varchar(800)
DECLARE КурсорДата CURSOR FOR 

select с.Фамилия, с.Имя
from Сотрудники с
where
format(CONVERT(date,с.Дата_рождения),'MM.dd') = format(CONVERT(date, @Дата),'MM.dd')
open КурсорДата
FETCH NEXT FROM КурсорДата INTO @Фамилия, @Имя
WHILE @@FETCH_STATUS=0
BEGIN
  SET @Список = @Список+ ' '+ @Фамилия+' '+@Имя+','
  FETCH NEXT FROM КурсорДата
  INTO @Фамилия,@Имя
END
 print @Список
 CLOSE КурсорДата
DEALLOCATE КурсорДата