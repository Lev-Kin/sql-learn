/*
Лабораторная работа. Теория баз данных.

1. Создайте базу данных Step_Lab1
*/
CREATE DATABASE Step_Lab1
go

USE Step_Lab1
go

/* 
2. Создайте четыре таблицы в базе данных. 
*/
CREATE TABLE sale(
	id int IDENTITY(1,1) primary key  NOT NULL,
	postnumber nchar(6),
	detnumber nchar(6),
	prodnumber nchar(6),
	qamount int
)
go

CREATE TABLE post(
	postnumber nchar(6) primary key  NOT NULL,
	sname nchar(20),
	rating int,
	city nchar(20),
)
go

CREATE TABLE det(
	detnumber nchar(6) primary key  NOT NULL,
	name nchar(20),
	color nchar(20),
	weight int,
	city nchar(20)
)
go

CREATE TABLE prod(
	prodnumber nchar(6) primary key  NOT NULL,
	name nchar(20),
	city nchar(20)
)
go

select * from post
select * from det
select * from prod
select * from sale
go

/* 
3. Выполните модификацию структуры таблицы sale, добавив поле с датой поставки.
Убедиться в успешности выполненных действий.
При необходимости исправить ошибки.
*/
alter table sale add
datepost datetime NULL
go
sp_help sale
go

/* 
4. Запишите и выполните совокупность запросов для занесения
вышеприведенных данных в созданные таблицы
*/

-- sale (spj)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S1','P1','J1',200)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S1','P1','J4',700)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S2','P3','J1',400)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S2','P3','J2',200)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S2','P3','J3',200)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S2','P3','J4',500)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S2','P3','J5',600)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S2','P3','J6',400)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S2','P3','J7',800)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S2','P5','J2',100)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S3','P3','J1',200)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S3','P4','J2',500)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S4','P6','J3',300)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S4','P6','J7',300)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S5','P2','J2',200)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S5','P2','J4',100)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S5','P5','J5',500)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S5','P5','J7',100)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S5','P6','J2',200)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S5','P1','J4',100)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S5','P3','J4',200)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S5','P4','J4',800)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S5','P5','J4',400)
insert into sale (postnumber, detnumber, prodnumber, qamount) values('S5','P6','J4',500)
-----
-- post (s)
insert into post (postnumber, sname, rating, city) values('S1','Cмит' ,20,'Лондон')
insert into post (postnumber, sname, rating, city) values('S2','Джонс',10,'Париж')
insert into post (postnumber, sname, rating, city) values('S3','Блейк',30,'Париж')
insert into post (postnumber, sname, rating, city) values('S4','Кларк',20,'Лондон')
insert into post (postnumber, sname, rating, city) values('S5','Адамс',30,'Афины')
-----
-- det (p)
insert into det (detnumber, name, color, weight, city) values('P1','Гайка','Красный',12,'Лондон')
insert into det (detnumber, name, color, weight, city) values('P2','Болт','Зеленый',17,'Париж')
insert into det (detnumber, name, color, weight, city) values('P3','Винт','Голубой',17,'Рим')
insert into det (detnumber, name, color, weight, city) values('P4','Винт','Красный',14,'Лондон')
insert into det (detnumber, name, color, weight, city) values('P5','Кулачок','Голубой',12,'Париж')
insert into det (detnumber, name, color, weight, city) values('P6','Блюм','Красный',19,'Лондон')
-----
-- prod (j)
insert into prod (prodnumber, name, city) values('J1','Жесткий диск','Париж')
insert into prod (prodnumber, name, city) values('J2','Перфоратор','Рим')
insert into prod (prodnumber, name, city) values('J3','Считыватель','Афины')
insert into prod (prodnumber, name, city) values('J4','Принтер','Афины')
insert into prod (prodnumber, name, city) values('J5','Флоппи-диск','Лондон')
insert into prod (prodnumber, name, city) values('J6','Терминал','Осло')
insert into prod (prodnumber, name, city) values('J7','Лента','Лондон')
----

/* 
5. Проверить результат заполнения таблиц,
написав и выполнив простейший запрос
select * from имя_таблицы
При наличии ошибок выполнить корректировку,
исправив либо удалив ошибочные строки таблиц
*/

select * from post
select * from det
select * from prod
select * from sale
go

/* 
6. Подготовьте и выполните запросы:
Выдать общее количество деталей P1, поставляемых поставщиком S1
*/
select sum (qamount)
from sale
where postnumber = 'S1' and detnumber = 'P1' 
go

/* 
7. Получить общее число изделий,
для которых поставляет детали поставщик S1.
*/
select count (distinct qamount)
from det, sale
where postnumber='S1'
go

/* 
8.Получить полный список деталей для всех изделий,
изготавливаемых в Лондоне.
*/
select distinct sale.prodnumber
from sale, prod
where city='Лондон' and prod.prodnumber = sale.prodnumber

/* 
9. Получить номера деталей, поставляемых для всех изделий из Лондона.
*/
select distinct sale.detnumber
 from sale,det 
 where det.city='Лондон' and det.detnumber=sale.detnumber

/* 
10.	Получить список всех поставок,
в которых количество деталей находится в диапазоне от 300 до 750 включительно.
*/
select postnumber, prodnumber, qamount
from sale
where qamount between 300 and 750

/* 
11.	Выдать номера изделий, использующих по крайней мере одну деталь,
поставляемую поставщиком S1.
*/
select distinct prodnumber
from sale
where postnumber = 'S1'

/* 
12.	Выдать номера изделий, детали для которых поставляет каждый поставщик,
поставляющий какую-либо красную деталь.
*/
select distinct prodnumber 
from sale
where postnumber
in
(
	select distinct postnumber
	from sale
	where detnumber
	in
	(
		select detnumber 
		from det
		where color='Красный'
	)
)

/* 
13.	Для каждой поставляемой для некоторого изделия детали выдать ее номер,
номер изделия и соответствующее общее количество деталей.
*/
select detnumber, prodnumber, COUNT(*)
from sale
group by detnumber, prodnumber

/* 
14.	Получить цвета деталей, поставляемых поставщиком S1.
В следующих заданиях необходимо написать запросы для модификации данных таблиц.
Выполнять модификацию не нужно.
Для отладки используйте откат транзакций.
*/
select color
from det 
where detnumber
in
(
select distinct detnumber 
from sale 
where postnumber='S1'
)

/*
15. Увеличить на 10 рейтинг всех поставщиков, рейтинг которых в настоящее время меньше, чем рейтинг поставщика S4.
*/
update post
set rating += 10
from post
where rating < (
				select rating
				from post
				where postnumber='S4'
				)
/*
16. Удалить все изделия, для которых нет поставок деталей.
*/
 delete
 from prod
 where prodnumber
 not in
 (
 select prodnumber
 from sale
 ) 

/*
17. Построить таблицу post_j1 с упорядоченным списком номеров и фамилиями поставщиков, поставляющих детали для изделия с номером J1
*/
select postnumber,sname
into post_j1
from post
where postnumber
in
(
	select distinct postnumber
	from sale
	where detnumber
	in
	(
		select distinct detnumber 
		from sale
		where prodnumber='J1'
	)
)

/*
18. Вставить в таблицу post(поставщики) нового поставщика с номером S10 с фамилией Уайт из города Нью-Йорк с неизвестным рейтингом.
*/
insert into post(postnumber, sname, rating, city) values ('S10', 'Уайт', NULL, 'Нью-Йорк')

/*
19. Увеличить на 10 рейтинг тех поставщиков, объем поставки которых выше среднего.
*/
update post
set rating+=10
where postnumber
in
(
select distinct postnumber
from sale 
where qamount > 
				(
				select avg(res.r)
				from 
					(
					select postnumber, avg(qamount)r
					from sale 
					group by postnumber
					)res
				)
)

/*
 Ответы:
 6  - 900
 7  - 2
 8  - J5, J7
 9  - P1, P4, P6
 10 - 11 поставок
 11 - J1, J4
 12 - J1, J2, J3, J4, J5, J7
 13 - 21 запись
 14 - 1  запись
 15 - 1 строка затронута
 16 - 0 строк  затронута
 17 - 4 строки затронута
 18 - 1 строка затронута
 19 - 4 строки затронута
*/

