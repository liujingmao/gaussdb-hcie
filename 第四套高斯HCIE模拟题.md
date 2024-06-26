### 高斯IE第四套

#### 1. 数据库连接

##### (1) 查看全局最大连接数

```sql
-- 考生作答
show max_connections;
```

##### (2) 创建用户并指定最大连接数，指定最大连接数为20000

```sql
-- 考生作答
create user testuser password 'Test@123' connectioin limit 20000;
```

##### (3) 查看用户的连接数，展示用户、最大连接数

```sql
-- 考生作答
select rolname,rolconnlimit from pg_roles where rolname = 'testuser';
```

##### (4) 修改用户最大连接数，将最大连接数修改为10000

```sql
-- 考生作答
alter user testuser connectioin limit 10000;
```

##### (5) 创建数据库指定最大连接数，指定最大连接数为100000，并使用SQL查看展示数据库及最大连接数

```sql
-- 考生作答
-- 1. create database
create database testdb connection limit 100000;
-- 2. select 
select * from pg_database where database = 'testdb';
```

##### (6) 创建数据库指定最大连接数，查看数据库最大连接数，展示数据库名称和最大连接数

```sql
-- 考生作答
select database,datconnlimit from pg_database where database = 'testdb';
```

##### (7) 修改数据库的最大连接数，将最大连接数修改为200000

```sql
-- 考生作答
alter database testdb connection limit 200000;
```

#### 2. 安全审计

##### (1) 创建用户user1,密码'test@123'

```sql
-- 考生作答
create user user1 password 'test@123';
```

##### (2) 给用户授予查看审计权限，同时可以创建审计策略

```sql
-- 考生作答
alter user with auditadmin,sysadmin
```

##### (3) 切换到user1,创建审计策略adt1,对数据库执行create操作

```sql
-- 考生作答
\c - user1
create audit policy adt1 privilege create;
```

##### (4) 创建审计策略adt2,数据库执行select操作创建审计策略

```sql
-- 考生作答
create audit policy adt2 access select;
```

##### (5) 修改审计策略adt1,对地址为'10.20.30.40'进行审计

```sql
-- 考生作答
alter audit policy adt1 modify(filter on ip('10.20.30.40'));
```

##### (6) 创建表tb1,字段自定义

```sql
-- 考生作答
create table tb1(id int,name varchar(32));
```

##### (7) 创建审计策略adt3,仅审计记录用户root,在执行针对表tb1资源的select,insert,delete操作数据库创建审计策略(这个是难点)

```sql
-- 考生作答
create resource label audit_label_adt3 add table(tb1);
create audit policy adt3 access select,insert,delete on label(audit_label_adt3) fileter on roles(root); 
```

##### (8) 关闭adt1审计策略

```sql
-- 考生作答
alter audit policy adt1 disable
```

##### (9) 删除以上创建的审计策略，级联删除用户user1

```sql
-- 考生作答
-- 1. 删除策略
drop audit policy adt1,adt2,adt3;
-- 2. 删除资源标签
drop resource label audit_label_adt3
-- 3. 级联删除用户
drop user testuser cascade
```

#### 3. 存储过程

##### 基于以下学生成绩表，完成以下实验

```sql
-- create table 
create table student(
	student_id int not null,
    math int not null,
    physical int not null,
    art int not null,
    music int not null);
    
-- insert data
insert into student values(1001,56,84,65,35),(1001,63,46,82,46),(1001,85,65,32,85);
insert into student values(1002,81,86,95,72),(1002,65,46,96,45),(1002,76,54,85,68);
insert into student values(1003,69,85,76,76),(1003,78,68,31,57),(1003,46,95,94,65);
insert into student values(1004,76,95,76,62),(1004,63,96,45,96),(1004,16,58,34,69);
insert into student values(1005,96,63,52,75),(1005,95,86,42,85),(1005,96,45,78,65);
insert into student values(1006,85,68,26,76),(1006,95,76,85,45),(1006,86,95,54,68);
insert into student values(1007,76,58,95,49),(1007,85,65,45,88),(1007,46,85,75,35);
insert into student values(1008,76,85,96,45),(1008,66,22,33,88),(1008,89,89,56,85);
insert into student values(1009,56,78,96,59),(1009,75,86,95,75),(1009,89,65,45,25);
insert into student values(1010,76,85,95,45),(1010,76,95,85,36),(1010,76,82,96,35);
insert into student values(1011,88,99,77,66),(1011,56,85,69,85),(1011,76,85,69,85);
```

##### (1) 对math和phsycal排名前10的学生，art加5分，求所有学生总成绩

```sql
-- 考生作答
(select 
 	student_id,
 	sum(math+physical+art+5+music) as score 
 from
 	student 
 group by 
 	student_id 
 order by 
 	score desc 
 limit 10) 
union all 
(select
 	student_id,
 	sum(math+physical+art+music) as score 
 from 
 	student
 group by
 	student_id
 order by
 	score 
 desc 
 offset 10);
```

##### (2) 获取art和music排名前10，同时math和physical在art和music前10名的学生信息

```sql
-- 考生作答
select 
	s1.*,
	s2.mpscore
from 
	(select 
     	student_id,
     	sum(art+music) as amscore 
     from 
     	student 
     group by 
     	student_id 
     order by 
     	amscore 
     desc limit 10) s1
join
	(select
    	student_id,
    	sum(math+physical) as mpscore 
     from 
     	student 
     group by 
     	student_id 
     order by 
     	mpscore 
     desc limit 10) s2
on 
	s1.student_id = s2.student_id;
```

##### (3) 编写存储过程，输入学生id返回总成绩

```sql
-- 考生作答
create or replace procedure pro_total_score(id_score inout int)
as 
begin
	select sum(math+physical+art+music) into id_score from student where student_id = id_score;
end;
/
```

##### (4) 编写存储过程，输入学号和科目名称，返回对应的平均成绩

```sql
-- 考生作答
-- 答案一
create or replace procedure pro_avg_score(id inout int,coursename varchar(20))
as
begin
	case when coursename='math' then select avg(math) into id from student where student_id = id;
	when coursename='physical' then select avg(physical) into id from student where student_id = id;
	when coursename='art' then select avg(art) into id from student where student_id = id;
	when coursename='music' then select avg(music) into id from student where student_id = id;
	end case;
end;
/

-- 答案二
-- 考生作答
create or replace procedure pro_avg_score(id int,coursename varchar(20),avgscore out float)
as
begin
	case when coursename='math' then select avg(math) into avgscore from student where student_id = id;
	when coursename='physical' then select avg(physical) into avgscore from student where student_id = id;
	when coursename='art' then select avg(art) into avgscore from student where student_id = id;
	when coursename='music' then select avg(music) into avgscore from student where student_id = id;
	end case;
end;
/
```

##### (5)  编写存储过程，输入学生id和科目名称，输出对应的绩点值,从0-59 给0分; 60-69给0.1分; 70-79给0.2分; 80-89给0.3分; 90-100给0.4分。

```sql
-- 考生作答 注意题目要求，写函数与写存储过程是不一样的
create or replace procedure 
pro_cal_point(id1 int,coursename varchar(30),point out float) as 
begin
	case when coursename = 'math' then
		select (
            case when math <=59 then 0
            when math <=69 then 0.1
            when math <=79 then 0.2
            when math <=89 then 0.3
            when math <=99 then 0.4
       else 0 end) into point from student where student_id =id1 limit 1;
       when coursename = 'physical' then
		select (
            case when physical <=59 then 0
            when physical <=69 then 0.1
            when physical <=79 then 0.2
            when physical <=89 then 0.3
            when physical <=99 then 0.4
       else 0 end) into point from student where student_id =id1 limit 1;
       when coursename = 'art' then
		select (
            case when art <=59 then 0
            when art <=69 then 0.1
            when art <=79 then 0.2
            when art <=89 then 0.3
            when art <=99 then 0.4
       else 0 end) into point from student where student_id =id1 limit 1;
       when coursename = 'music' then
		select (
            case when music <=59 then 0
            when music <=69 then 0.1
            when music <=79 then 0.2
            when music <=89 then 0.3
            when music <=99 then 0.4
       else 0 end) into point from student where student_id =id1 limit 1;
   else raise notice 'please input right course name;';
   end case; 
end;
/
```

#### 4. 性能优化

##### 有三个表，分别是学生信息表student和202201班级成绩表score1,202202班级成绩表score2

```sql
-- create table 

create table score1(
	id int,
    chinese int,
    math int
);

create table score2(
	id int,
    chinese int,
    math int
);

-- insert datas

insert into score1 values(1,78,88),(2,88,98),(3,90,100);

insert into score1 values(4,100,100);

insert into score2 values(10,68,98),(11,58,78),(12,98,99);
```



##### (1) 查看202201班级和202202班级所有人语文成绩前10的记录，第一个查询使用union

```sql
-- 考生作答
(select * from score1 order by chinese limit 2)
union
(select * from score2 order by chinese limit 2);
```

##### (2) 对以上SQL语句进行优化

```sql
-- 考生作答
(select * from score1 order by chinese limit 2)
union all
(select * from score2 order by chinese limit 2);
```

##### (3) 查看两个班级的科目，202201班级在score2表中不存在的成绩，要求使用not in(需要确定score1,score2表具体字段有哪些科目，以及所谓相同科目是一个具体科目还是所有科目都要判断)

```sql
-- 考生作答
select chinese from score1  where chinese not in (select chinese from score2);
select math from score1  where math not in (select math from score2);
```

##### (4) 对以上SQL语句进行优化

```sql
-- 考生作答
-- not 修改为not exists 
(select chinese,math from score1) not exists in (select chinese,math from score2);
```

##### (5) 查询班级202201语文成绩最高的学生，要求先创建索引，并能够保证一定会使用索引 

```sql
-- 考生作答
create index chi_index on score1(chinese);
select max(chinese) from score1;
select max(chinese) from student;
```

##### (6)  查询202201班级的学生的成绩比202202班级的学生最高成绩还要大的学生信息，对以下给出的SQL进行改写

```sql
-- 原SQL??

select id,sum(chinese+math) as ts from score1 group by id having ts < (select sum(math+chinese) as maxscore2 from score2 group by id order by maxscore2 desc limit 1);

select 
	id,
	sum(chinese+math) as ts 
from 
	score1 
group by 
	id 
having 
	ts > (select 
          	sum(math+chinese) as maxscore2 
          from 
          	score2 
          group by 
          	id 
          order by 
          	maxscore2 desc limit 1);
```

```sql
-- 考生作答
-- 方法一 join
select 
	t1.id,
	t1.ts1 
from 
	(select id,sum(math+chinese) as ts1 from score1 group by id) t1 
join 
	(select 
     	max(ts2) ms 
     from 
     	(select sum(math+chinese) as ts2 from score2 group by id)) t2 
on 
	t1.ts1 > t2.ms;
-- 方法二 where 联立过滤
select 
	t1.id,
	t1.ts1 
from 
	(select id,sum(math+chinese) as ts1 from score1 group by id) t1,
	(select 
     	max(ts2) ms 
     from 
     	(select sum(math+chinese) as ts2 from score2 group by id)) t2 
where 
	t1.ts1 > t2.ms;
```

####  5. 论述

##### (1) 全量备份、差分备份和增量备份的区别

+ 全量备份：在备份全部数据时，全量备份需要的时间最长，因为需要备份的数据量大。但是，这种备份方式在恢复速度最快，只需要一个磁盘可恢复丢失的数据，此外，由于需要备份的数据量较大，全量备份可能会占用比较多的存储空间；
+ 差分备份：差分备份是备份自上一次完全备份之后有变化的数据。这种备份方式相较于全量备份，备份数据量少，因此 备份所需要的时间较少。同时，由于只需要对第一次全备份和最后一次差异备份进行恢复，所以恢复时间也相对较快。但是，差分备份的数据恢复过程相较于全量备份和增量备份较为复杂；
+ 增量备份：增量备份是备份上一次备份(包括完全备份、差异备份、增量备份)之后有变化的数据。这种备份方式最大的优点是没有重复的备份数据，因此备份的数据量并不大，备份所需要的时间很短。但是，增量备份的数据恢复比较麻烦，需要所有的增量备份数据才能进行恢复；
+ 三种备份所备份的数据量不一样，所需要的时间也不一样，全量备份不需要依赖于其他任意备份，差分备份和增量备份需要依赖于全量备份。

##### (2) 全量备份、差分备份和增量备份数据集大小关系

+ 全量备份的数据是最大的，是执行备份时刻的所有数据；
+ 差分备份的数据虽然没有全量大，但相比较增量更大，因为差分备份的是相较于上次全量备份有变更的数据；
+ 增量备份的数据集大小是有三种备份中最小的，因为增量备份只与上一次备份相比较，无论上一次备份是全量、差分还是增量都可以；

##### (3) 数据可以恢复到指定时间点，使用什么技术实现，与物理文件备份相比，这种依赖哪个关键文件

+ 将数据恢复到指定时间点需要基于PITR技术实现，主要需要依赖于全量备份文件、增量备份文件和WAL日志；
+ 恢复时先根据指定时间点找到最近上次全量备份进行恢复，然后逐个恢复这次全量后的增量备份，直到恢复到时间点前最后一次增量备份，从最后一次增量备份到时间点这段时间数据通过WAL日志进行恢复。



