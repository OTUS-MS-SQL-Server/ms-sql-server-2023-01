---1 Создание базы данных по умолчанию
CREATE DATABASE test1_new;
GO



---2 с указанием файлов
CREATE DATABASE [test2]
ON  PRIMARY 
( NAME = test2, FILENAME = N'C:\1-DDL\test2.mdf' , 
	SIZE = 8MB , 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 65536KB )
 LOG ON 
( NAME = test2_log, FILENAME = N'C:\1-DDL\test2_log.ldf' , 
	SIZE = 8MB , 
	MAXSIZE = 10GB , 
	FILEGROWTH = 65536KB )
GO

---- удаление базы данных
drop database test2;

-- или

USE master; 
GO 
IF DB_ID (N'test2') IS NOT NULL 
	DROP DATABASE test2; 
GO 


---3 с файловыми группами
CREATE DATABASE [test2]
 ON  PRIMARY 
	( NAME = test2, FILENAME = N'C:\1-DDL\test2.mdf' , 
		SIZE = 8MB , 
		MAXSIZE = 50Mb, 
		FILEGROWTH = 10MB ),
	( NAME = test2_2, FILENAME = N'C:\1-DDL\test2_2.mdf' , 
		SIZE = 8MB , 
		MAXSIZE = 50Mb, 
		FILEGROWTH = 10% ),

	--Тут в идеале должен быть другой диск
	FILEGROUP test2_gr2
	( NAME = test2_f1, FILENAME = N'C:\2-DDL\test2_f1.ndf',
          SIZE = 10MB,
          MAXSIZE = 50MB,
          FILEGROWTH = 10%),
	
	( NAME = test2_f2,
	  FILENAME = N'C:\2-DDL\test2_f2.ndf',
          SIZE = 10MB,
          MAXSIZE = 50MB,
          FILEGROWTH = 10%)

 LOG ON 
	( NAME = test2_log, FILENAME = N'C:\1-DDL\test2_log.ldf' , 
		SIZE = 8MB , 
		MAXSIZE = 10GB , 
		FILEGROWTH = 65536KB ),
	( NAME = test2_log_f, FILENAME = N'C:\2-DDL\test2_log_f.ldf' , 
		SIZE = 10MB , 
		MAXSIZE = 50GB , 
		FILEGROWTH = 10Mb )
GO

-- 4 Редактирование БД
--добавление 3-го файла данных в файловую группу 2
use test2;

ALTER DATABASE [test2] 
ADD FILE 
( 
    NAME = N'test2_f3', 
    FILENAME = N'C:\2-DDL\test2_f3.ndf', 
    MAXSIZE = 100MB 
) 
TO FILEGROUP [test2_gr2] 
GO  

-- изменение имени БД
USE master; 
GO 
ALTER DATABASE test1_new 
Modify Name = test1 ; 
GO

--- добавление файловой группы, файла данных и журнала в новую группу  
ALTER DATABASE test1 
ADD FILEGROUP test1_FG2; 
GO 

ALTER DATABASE test1 
ADD FILE  
( 
    NAME = N'test1_f1', 
    FILENAME = N'C:\0-DDL\test1_f1.ndf', 
    SIZE = 5MB, 
    MAXSIZE = 100MB,
	FILEGROWTH = 5MB 
)
 TO FILEGROUP test1_FG2; 
GO 

ALTER DATABASE test1 
ADD LOG FILE  
( 
    NAME = N'test1_log_f1', 
    FILENAME = N'C:\2-DDL\test1_log_f1.ldf', 
    SIZE = 5MB, 
    MAXSIZE = 100MB,
	FILEGROWTH = 5MB 
); 
GO 

---изменение размера 
ALTER DATABASE test1  
MODIFY FILE 
    (NAME = N'test1_f1', 
    SIZE = 50MB);
GO  

drop database test1;

create database test1;

USE master; 
GO 
IF DB_ID (N'test1') IS NOT NULL 
	DROP DATABASE test1; 

----5 Создание таблиц
use test2;
GO

CREATE TABLE student(
	id 	int not null identity(1, 1)  primary key,
	fio	varchar(50) ,
	d_r	date 
)

EXEC sp_help student;

insert into student values	('Иванов', '10/03/2000'), 
							('Петров', '20/04/2001'),
							('Сидоров', '15/10/1999');

---6 создание моментального снимка базы

CREATE DATABASE test2_copy1 ON
( NAME = test2 , FILENAME = 'C:\0-DDL\test2_copy1.ss' ),
( NAME = test2_2, FILENAME = 'C:\0-DDL\test2_copy2.ss' ),
( NAME = test2_f1, FILENAME = 'C:\0-DDL\test2_copy_f1.ss' ),	
( NAME = test2_f2, FILENAME = 'C:\0-DDL\test2_copy_f2.ss' ),
( NAME = test2_f3, FILENAME = 'C:\0-DDL\test2_copy_f3.ss' )
AS SNAPSHOT OF test2;
GO

use test2_copy1;
select * from student;

insert into student values	('Иванов 2', '10/03/2000'); 

use master;
drop database test2_copy1;

------ 7 Создание новой схемы
use test2;

create schema sch_2; 

--- создание таблицы в новой схеме и другой группе
CREATE TABLE sch_2.student(
	id 	int not null identity(1, 1)  primary key,
	fio	varchar(50) ,
	d_r	date 
) on test2_gr2;


-- 8 Создание таблицы с разреженным столбцом
CREATE TABLE Tablesparse (
	id	int PRIMARY KEY,
	field1 varchar(50) SPARSE NULL 
) ;

---9 Создание синонима

CREATE SYNONYM db_test1 FOR test1.dbo.table1;

CREATE SYNONYM db_test2 FOR test2.sch_2.student;

use test2;
select * from db_test1;

select * from db_test2;

create database test1;

use test1;
CREATE TABLE table1(
	id 	int not null identity(1, 1)  primary key,
	fio	varchar(50)
)
GO


--- 10 Редактирование таблиц
-----
use test2;

CREATE TABLE kurs(
	id 			int not null identity(1, 1)  primary key,		
	name_k 		varchar(100) ,
	autor 		varchar(50)  ,
	price 		money 
);


CREATE TABLE vebinar (
	id 	int not null identity(1, 1)  primary key,
	id_s 		int not null ,
	id_k 		int not null ,
	name_v  	varchar(100) ,
	fio_v		varchar (50) ,
	date_v		datetime,
	d_z			int  
)

-- установление связи
ALTER TABLE vebinar  ADD  CONSTRAINT FK_v_st FOREIGN KEY(id_s)
REFERENCES student (id)
ON UPDATE CASCADE
ON DELETE CASCADE


ALTER TABLE vebinar  ADD  CONSTRAINT FK_v_k FOREIGN KEY(id_k)
REFERENCES kurs (id)


--------- Значение по умолчанию
--при добавлении новой записи в поле “Домашнее задание” по умолчанию заносится 0
ALTER TABLE vebinar ADD  CONSTRAINT v_dz DEFAULT (0) FOR d_z;

---- Ограничение по возрасту - зачислять можно только студентов c 18 лет 
ALTER TABLE student 
	ADD CONSTRAINT constr_dr 
		CHECK (datediff(yy, d_r, getdate()) >=18);

--Активация и деактивация ограничений
insert into student values	('Сидоров', '10/03/2010'); 

ALTER TABLE student NOCHECK CONSTRAINT constr_dr;

insert into student values	('Сидоров', '10/03/2010'); 

ALTER TABLE student CHECK CONSTRAINT constr_dr;

--- удаление ограничения
ALTER TABLE student  DROP CONSTRAINT constr_dr;


---11 создание последовательности
CREATE SEQUENCE example_seq
  AS int
  START WITH 1
  INCREMENT BY 1
  MINVALUE 0
  MAXVALUE 3
  CYCLE;

select next value for example_seq;

drop sequence example_seq;

CREATE SEQUENCE table_seq
  START WITH 1
  INCREMENT BY 1;
  
create table customer(
id int primary key,
fio varchar(50));

insert into customer values (
NEXT VALUE FOR table_seq, 'Иван2');

select * from customer 

create table customer_2(
id int primary key CONSTRAINT id_sec DEFAULT (NEXT VALUE FOR table_seq) ,
fio varchar(50));

insert into customer_2(fio) values ('Петр2');



----12 Создание индекса
create index idx_fio on student (fio);


ALTER TABLE sch_2.student 
	ADD e_mail varchar(50) constraint e_mail_un unique;


--- 13 system versioned tables
use WideWorldImporters

SELECT ValidFrom, ValidTo, *
FROM Sales.Customers
WHERE CustomerName like 'J%'
ORDER BY CustomerID

SELECT ValidFrom, ValidTo, *
 FROM Sales.Customers FOR System_Time AS OF '20130101'
-- FROM Sales.Customers FOR System_Time BETWEEN '20121201' AND '20130101'
-- FROM Sales.Customers FOR System_Time FROM '20121201' TO '20130101'
-- FROM Sales.Customers FOR System_Time CONTAINED IN ('20130501' ,'20190212')
WHERE CustomerName like 'J%'	
ORDER BY CustomerID

SELECT ValidFrom, ValidTo, c.*
FROM Sales.Customers FOR System_Time ALL c
WHERE CustomerName like 'J%'	
ORDER BY c.CustomerID, c.ValidFrom

---
use test2;

--- с анонимной таблицей архива
CREATE TABLE Course
(
    ID INT NOT NULL PRIMARY KEY CLUSTERED
  , CourseName VARCHAR(50) NOT NULL
  , StartTime DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL
  , EndTime DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL
  , PERIOD FOR SYSTEM_TIME (StartTime, EndTime)
)
WITH (SYSTEM_VERSIONING = ON);

insert into Course(ID, CourseName) values (1, 'БД')
update Course set CourseName = 'DataBase';
delete from Course 
select * from Course FOR System_Time ALL;

--- с таблицей архива по умолчанию 
CREATE TABLE Course2
(
    ID INT NOT NULL PRIMARY KEY CLUSTERED
  , CourseName VARCHAR(50) NOT NULL
  , StartTime DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL
  , EndTime DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL
  , PERIOD FOR SYSTEM_TIME (StartTime, EndTime)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = sch_2.CourseHistory));


ALTER TABLE Course2 SET (SYSTEM_VERSIONING = OFF);

drop table Course2;
drop table sch_2.CourseHistory;


-----14 Графовые таблицы
CREATE TABLE Person (ID INTEGER PRIMARY KEY, Name VARCHAR(100), Age INT) AS NODE;
CREATE TABLE friends (StartDate date) AS EDGE;

select * from Person;

insert into Person(ID, Name, Age) 
values  (1, 'Ваня', 18),
		(2, 'Оля', 17),
		(3, 'Саша', 20);

select * from friends;

insert into friends
values  ((SELECT $node_id FROM Person WHERE ID = 1), 
			(SELECT $node_id FROM Person WHERE ID = 2), '20/01/2021'),
		((SELECT $node_id FROM Person WHERE ID = 1), 
			(SELECT $node_id FROM Person WHERE ID = 1), '20/01/2021'),
		((SELECT $node_id FROM Person WHERE ID = 1), 
			(SELECT $node_id FROM Person WHERE ID = 3), '15/02/2021'),
		((SELECT $node_id FROM Person WHERE ID = 2), 
			(SELECT $node_id FROM Person WHERE ID = 3), '04/02/2021'),
		((SELECT $node_id FROM Person WHERE ID = 3), 
			(SELECT $node_id FROM Person WHERE ID = 1), '16/02/2021');


SELECT Person2.Name 
FROM Person Person1, friends, Person Person2
WHERE MATCH(Person1-(friends)->Person2)
AND Person1.Name = 'Ваня';

--- 15 удаление 
use test2;

drop table if exists sch_2.student ;
select * from student 
delete from student;
insert into student values	('Сидоров', '10/03/2000'); 

truncate table student;
alter table vebinar drop constraint fk_v_st;

insert into student values	('Сидоров', '10/03/2000'); 

truncate table customer;
insert into customer values	(NEXT VALUE FOR table_seq, 'Сидоров'); 
select * from customer
-----
truncate table Course

USE master; 
GO 

IF DB_ID (N'test2') IS NOT NULL 
	DROP DATABASE test2; 
GO 
