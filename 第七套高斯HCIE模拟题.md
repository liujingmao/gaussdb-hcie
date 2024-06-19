### 高斯IE第七套

####　1. 数据库对象管理及SQL应用1

##### 学生表（成绩表里有空值）

| 学生编号   | 成绩  | 月份  |
| :--------- | ----- | ----- |
| student_id | score | month |
| 1          | 56    | 1     |
| 2          | 68    | 1     |
| 3          |       | 1     |
| 4          | 67    | 1     |
| 5          |       | 1     |
| 6          | 53    | 1     |
| 1          | 56    | 2     |
| 2          | 68    | 2     |
| 3          |       | 2     |
| 4          | 67    | 2     |
| 5          | 99    | 2     |
| 6          |       | 2     |



```sql
-- 创建表 
create table student(id int,score int,month int);
-- 导入数据 
insert into student values(1,56,1),(2,68,1),(3,NULL,1),(4,67,1),(5,NULL,1),(6,53,1),(1,56,2),(2,68,2),(3,NULL,2),(4,67,2),(5,99,2),(6,NULL,2);
```

##### (1) 查询月考平均成绩比编号5的大的学生信息

```sql
-- 考生作答
-- 因为null值不计算，产生将null修改为0

hcie7=# select id,round(avg(nvl(score,0)),2) as a from student group by id having a > (select round(avg(nvl(score,0)),2) as a from student where id = 5);
 id |   a
----+-------
  1 | 56.00
  4 | 67.00
  2 | 68.00
(3 rows) 
  -- ans
  
select id,round((avg(nvl(score,0))),2) as avgscore from student group by id having avgscore > (select round((avg(nvl(score,0))),2) from student where id = 5);
 id | avgscore
----+----------
  1 |    56.00
  4 |    67.00
  2 |    68.00

```

##### (2) 查询每次月考成绩大于平均成绩的学生

``` sql
-- 考生作答

-- 窗口
方法一
select * from (select *,round((avg(nvl(score,0)) over (partition by month)),2) as avgscore from student) where score > avgscore;
 id | score | month | avgscore
----+-------+-------+----------
  6 |    53 |     1 |    40.67
  2 |    68 |     1 |    40.67
  4 |    67 |     1 |    40.67
  1 |    56 |     1 |    40.67
  1 |    56 |     2 |    48.33
  2 |    68 |     2 |    48.33
  4 |    67 |     2 |    48.33
  5 |    99 |     2 |    48.33
   
-- 方法二

select t1.*,avgscore from student as t1 join (select month,round(avg(nvl(score,0)),2) as avgscore from student group by month) t2 on t1.month=t2.month where score>avgscore;

id | score | month | avgscore
----+-------+-------+----------
  1 |    56 |     1 |    40.67
  2 |    68 |     1 |    40.67
  4 |    67 |     1 |    40.67
  6 |    53 |     1 |    40.67
  1 |    56 |     2 |    48.33
  2 |    68 |     2 |    48.33
  4 |    67 |     2 |    48.33
  5 |    99 |     2 |    48.33

```

##### (3) 查询每次平均成绩差值

```sql
-- 考生作答
select t1.*,avgscore,t1.score-avgscore as diff from student as t1 join (select month,round(avg(nvl(score,0)),2) as avgscore from student group by month) t2 on t1.month=t2.month;

select t1.id,nvl(t1.score,0),t1.month,avgscore,nvl(t1.score,0)-avgscore as diff from student as t1 join (select month,round(avg(nvl(score,0)),2) as avgscore from student group by month) t2 on t1.month=t2.month;
 id | nvl | month | avgscore |  diff
----+-----+-------+----------+--------
  1 |  56 |     1 |    40.67 |  15.33
  2 |  68 |     1 |    40.67 |  27.33
  4 |  67 |     1 |    40.67 |  26.33
  6 |  53 |     1 |    40.67 |  12.33
  1 |  56 |     2 |    48.33 |   7.67
  2 |  68 |     2 |    48.33 |  19.67
  4 |  67 |     2 |    48.33 |  18.67
  5 |  99 |     2 |    48.33 |  50.67
  3 |   0 |     1 |    40.67 | -40.67
  5 |   0 |     1 |    40.67 | -40.67
  3 |   0 |     2 |    48.33 | -48.33
  6 |   0 |     2 |    48.33 | -48.33

 select t1.id,nvl(t1.score,0),t1.month,avgscore,nvl(t1.score,0)-avgscore as diff from student as t1 join (select month,round(avg(nvl(score,0)),2) as avgscore from student group by month) t2 on t1.month=t2.month order by id;
 id | nvl | month | avgscore |  diff
----+-----+-------+----------+--------
  1 |  56 |     1 |    40.67 |  15.33
  1 |  56 |     2 |    48.33 |   7.67
  2 |  68 |     1 |    40.67 |  27.33
  2 |  68 |     2 |    48.33 |  19.67
  3 |   0 |     1 |    40.67 | -40.67
  3 |   0 |     2 |    48.33 | -48.33
  4 |  67 |     2 |    48.33 |  18.67
  4 |  67 |     1 |    40.67 |  26.33
  5 |  99 |     2 |    48.33 |  50.67
  5 |   0 |     1 |    40.67 | -40.67
  6 |  53 |     1 |    40.67 |  12.33
  6 |   0 |     2 |    48.33 | -48.33


```

#### 2. 数据库对象管理及SQL应用2

##### 当前有一张订单表lineitem,具体字段如下

```sql
-- 字段说明--
L_ORDERKEY BIGINT NOT NULL
L_PARTKEY BIGINT NOT NULL
L_SUPPKEY BIGINT NOT NULL
L_LINENUMBER BIGINT NOT NULL
L_QUANTITY float8 NOT NULL
L_EXTENDEPPRICE float8 NOT NULL
L_DISCOUNT float8 NOT NULL
L_TAX float8 NOT NULL
L_RETURNFLAG CHAR(1) NOT NULL
L_LINESTATUS CHAR(1) NOT NULL
L_SHIPDATE DATE NOT NULL
L_COMMITDATE DATA NOT NULL
L_ARRIVALDATE DATA NOT NULL
L_ORDERSTRATEGY CHAR(32) NOT NULL
L_TRANSPORTROUTE CHAR(32) NOT NULL
L_COMMENT VARCHAR(64) NOT NULL
```

##### (1) 创建分区表，根据上述字段信息创建分区表，按L_SHIPDATE分区，按年分1993，1994，1995，1996，1997，1998，1999分区名称分别是L_SHIPDATE_1 第二个分区是L_SHIPDATE_2,以此类推，使用L_ORDERKEY进行哈希分布，建表完成执行上述数据导入代码，进行数据导入

```sql
-- 考生作答
-- 创建分布式分区表的格式要学会
create table (c1,c2...cn) 
distribute by hash(cn) 
partition by range(c2)
(
	partition partitionname1 values less than (),




);-- 去主机到了，要记得练习

-- create tabel 

-- create table 
create table lineitem(L_ORDERKEY BIGINT NOT NULL,
L_PARTKEY BIGINT NOT NULL,
L_SUPPKEY BIGINT NOT NULL,
L_LINENUMBER BIGINT NOT NULL,
L_QUANTITY float8 NOT NULL,
L_EXTENDEPPRICE float8 NOT NULL,
L_DISCOUNT float8 NOT NULL,
L_TAX float8 NOT NULL,
L_RETURNFLAG CHAR(1) NOT NULL,
L_LINESTATUS CHAR(1) NOT NULL,
L_SHIPDATE DATE NOT NULL,
L_COMMITDATE DATE NOT NULL,
L_ARRIVALDATE DATE NOT NULL,
L_ORDERSTRATEGY CHAR(32) NOT NULL,
L_TRANSPORTROUTE CHAR(32) NOT NULL,
L_COMMENT VARCHAR(64) NOT NULL) 
distribute by hash(L_ORDERKEY) 
partition by range(L_SHIPDATE)(
	partitioin L_SHIPDATE_1 values less than('1993-01-01'),
    partitioin L_SHIPDATE_2 values less than('1994-01-01'),
    partitioin L_SHIPDATE_3 values less than('1995-01-01-01-01'),
    partitioin L_SHIPDATE_4 values less than('1996-01-01'),
    partitioin L_SHIPDATE_5 values less than('1997-01-01'),
    partitioin L_SHIPDATE_6 values less than('1998-01-01'),
    partitioin L_SHIPDATE_7 values less than('1999-01-01'));--云数据库在练
```

##### (2) 查看表的schema名称，展示表名和schema名称

```sql
-- 考生作答
select 
	tablename,
	schemaname 
from 
	pg_tables 
where 
	tablename = 'lineitem';
```

##### (3) 查看表分布节点的oid,展示表名，nodeoids

```sql
-- 考生作答
select t1.relname,
	   t3.nodeoids 
from 
	pg_class t1,
	pg_namespace t2,
	pgxc_class t3 
where 
	t1.oid = t3.pcrelid 
and 
	t1.relnamespace = t2.oid 
and 
	relname = 'lineitem' 
and 
	nspname = 'public';

-- 涉及三个系统表 pg_class pg_namespace pgxc_class
-- 关联条件两个  pg_class.oid = pgxc_class.pcrelid 
			   pg_class.relnamespace = pg_namespace.oid
			   
-- 两个过滤条件  
```

##### (4) 查看表所在实例的信息

```sql
-- 考生作答
select 
	t4.* 
from 
	pg_class t1,
	pgxc_class t2,
	pg_namespace t3,
	pgxc_node t4
where
	t1.oid = t2.pcrelid
and
	t1.relnamespace = t3.oid 
and 
	cast(t2.nodeoids as varchar(20)) = cast(t4.oid as varchar(20)) 
and
	t1.relname = 'lineitem'
and 
	t3.nspname = 'public';
```

#### 3. 数据库连接

##### (1) 创建用户user2用户，user2用户需要具备创建数据库的权限

```  sql
-- 考生作答--
hcie7=# create user user2 createdb password 'Huawei@123';
CREATE ROLE
```

##### (2) 查询用户的连接数上限

```sql
-- 考生作答
hcie7=# select rolname,rolconnlimit from pg_roles where rolname = 'user2';
 rolname | rolconnlimit
---------+--------------
 user2   |           -1
```

##### (3) 设置user2用户连接数为100

```sql
-- 考生作答
hcie7=# alter user user2 connection limit 100;
ALTER ROLE
hcie7=#
```

##### (4) 查询postgres 数据库连接上限；显示库，上限数量

```sql
-- 考生作答
hcie7=# select datname,datconnlimit from pg_database where datname = 'postgres';
 datname  | datconnlimit
----------+--------------
 postgres |           -1
```

##### (5) 查询postgres数据库中用户已经使用的会话数量

```sql
-- 考生作答，这个会话数量，之前没有遇到过
hcie7=# select count(datname) from pg_stat_activity where datname = 'postgres';
 count
-------
     7
```

##### (6) 查询所有用户已经使用的会话连接数

```sql
-- 考生作答，这个会话数量，之前没有遇到过,
```

##### (7) 查询库最大连接数???

```sql
-- 考生作答，这个会话数量，之前没有遇到过
hcie7=# show max_connections;
 max_connections
-----------------
 1000
(1 row)
```

##### (8) 查询会话状态，显示datid,pid,state??

```sql
-- 考生作答，这个会话数量，之前没有遇到过
hcie7=# select datid,pid,state from pg_stat_activity;
 datid |       pid       | state
-------+-----------------+--------
 57414 | 140289995831040 | active
 15707 | 140290849437440 | active
 15707 | 140290822240000 | idle
 15707 | 140290897737472 | idle
 15707 | 140290872571648 | active
 15707 | 140290926487296 | idle
 15707 | 140290962732800 | idle
 15707 | 140291013076736 | active
```

#### 4. 行级别访问控制 

##### (1) 创建user3用户，密码'test@123'

```sql
-- 考生作答
hcie7=# create user user3 password 'test@123';
CREATE ROLE
```

##### (2) 当前有一张表t_test(id,name); 有2万以上的数据，请授权只允许user3能够访问id=3的数据

```sql
-- 考生作答
-- 根据题目意思，先给user3select权限，再打开行级策略
grant select on t_test to user3;
alter table t_test enable row level security;
create row level security policy lsp_for_user3 on t_test to user3 using(id=3);
-- 设置完成行级访问策略，记得验证，验证时会发现权限不够，报错
```

##### (3) 修改赋权能看id=1或者2的数据

```sql
-- 考生作答
alter row level security policy lsp_for_user3 on t_test using(id = 1 or id = 2);
```

##### (4) 当前有一张用户表t_user(id,age),请创建两名用户u1和u2,密码均为'test@123'

```sql
-- 考生作答
create user u1 password 'test@123';
create user u2 password 'test@123';
```

##### (5) 设置行级别访问控制，u1,u2设置只能查看自己的用户信息

```sql
-- 考生作答
-- 1. 赋权
grant select on t_user to u1;
grant select on t_user to u2;
-- 2. 打开行级访问策略控制
alter table t_user enable row level security;

create row level security policy lsp_for_u1 on t_user to u1 using(id=current_user);

create row level security policy lsp_for_u2 on t_user to u2 using(id=current_user);

```

##### (6) 加一个级别访问控制让u1只能看自己且年龄30以下的数据

```sql
-- 考生作答

create row level security policy lsp_for_u11 on t_user to u1 using(id=current_user and age < 30);
```

##### (7) 删除上述配置的所有行级访问控制策略

```sql
-- 考生作答
drop row level security policy lsp_for_u11 on t_user;
drop row level security policy lsp_for_u1 on t_user;
drop row level security policy lsp_for_u2 on t_user;
```

##### (8) 关闭表的行控制开关，并且级联删除用户

```sql
-- 考生作答
alter table t_user disable row level security;
alter table t_test disable row level security;

drop user u1 cascade;
drop user u2 cascade;
drop user user3 cascade;
```

#### 5. 存储过程

| 编号   | 成绩 | 课程 |
| ------ | ---- | ---- |
| '1001' | 86   | 'c1' |
| '1002' | 95   | 'c2' |

```sql
-- create table 
create table scoretable(
	sno varchar(8),
    score int,
    course varchar(8)
);

insert into scoretable values('1001',86,'c1'),('1002',95,'c2');

create table score(
	sno varchar(20),
    score int,
    course varchar(20)
);
```

##### (1) 要求输入c1返回该课程的成绩信息(课程和id本身带有单引号)

```sql
-- 考生作答
create or replace procedure get_score_by_course(c in varchar(8),s out int) as 
begin 
	select score into s from scoretable where course = c;
end;
/

call get_score_by_course('c1',null);

-- 结果：
hcie7=# create or replace procedure get_score_by_course(c in varchar(8),s out int) as
hcie7$# begin
hcie7$# select score into s from scoretable where course = c;
hcie7$# end;
hcie7$# /
CREATE PROCEDURE
hcie7=# call get_score_by_course('c1',null);
 s
----
 86
(1 row)

hcie7=# call get_score_by_course('c2',null);
 s
----
 95
(1 row)

-- 老师提供的答案

create or replace procedure get_score_by_cid(cid_score inout varchar(20)) as
begin
	cid_score = concat('''',cid_score,'''');
	select score into cid_score from score where cid = cid_score;
end;
/
call get_score_by_cid('c1');
```

#### 6. 触发器

##### 本题根据教授详情表和部门表完成相应触发器创建使用

```sql
-- 创建表
create table teacher(
	id integer primary key,
    name varchar(50) not null,
	deptnd integer not null,
	title varchar(50) not null
);
create table department (
	id integer primary key,
    name varchar(50) not null,
	number_of_senior integer default 0);
	
根据以下表信息创建Tri_update_D 触发器，如果修改Number_of_senior字段时提示"不能随便修改部门教授职称人数"，如果已经有了Tri_update_D触发器，则删除后再重新创建
	insert into teacher values(1,'tom',1,'associate professor'),(2,'bill',1,'professor'),(11,'eiston',3,'associate professor');
 insert into department values(1,'physical',0),(2,'mathmetrics',0),(3,'chemistry',0);
```

##### (1) 创建Tri_update_D 触发器，如果修改Number_of_senior字段时提示"不能随便修改部门教授职称人数"，如果已经有了Tri_update_D触发器，则删除后再重新创建

```sql
-- 考生作答
create or replace function notice() returns trigger as 
$$
begin
	raise notice '不能随便修改部门教授职称人数';
	return null;
end;
$$language plpgsql;

DROP TRIGGER IF EXISTS Tri_update_D ON department;
create trigger Tri_update_D after update on department for each row execute procedure notice();

hcie2=# update department set number_of_senior = 1;
NOTICE:  不能随便修改部门教授职称人数
NOTICE:  不能随便修改部门教授职称人数
NOTICE:  不能随便修改部门教授职称人数


create trigger Tri_update_D before update of number_of_senior on department for each row execute procedure notice(); -- 对于each row，

hcie2=# update department set number_of_senior = 1;
NOTICE:  不能随便修改部门教授职称人数
NOTICE:  不能随便修改部门教授职称人数
NOTICE:  不能随便修改部门教授职称人数


create trigger Tri_update_D before update of number_of_senior on department for each statement execute procedure notice();

hcie2=# update department set number_of_senior = 1;
NOTICE:  不能随便修改部门教授职称人数
UPDATE 3
hcie2=# update department set number_of_senior = 10;
NOTICE:  不能随便修改部门教授职称人数

-- 结果

hcie7=# create or replace function notice() returns trigger as
hcie7-# $$
hcie7$# begin
hcie7$# raise notice '不能随便修改部门教授职称人数';
hcie7$# end;
hcie7$# $$language plpgsql;
CREATE FUNCTION
hcie7=# DROP TRIGGER IF EXISTS Tri_update_D ON department;
DROP TRIGGER
hcie7=# create trigger Tri_update_D after update on department for each row execute procedure notice();
CREATE TRIGGER
hcie7=# update department set number_of_senior = 1;
NOTICE:  不能随便修改部门教授职称人数
ERROR:  control reached end of trigger procedure without RETURN
CONTEXT:  PL/pgSQL function notice()
hcie7=#
```

##### (2) 禁止触发器，修改department表中id=1的number_of_senior=10,并查出表中的数据 

```sql
-- 考生作答
alter table department disable trigger Tri_update_D;
hcie2=# update department set number_of_senior = 0;
UPDATE 3
hcie2=# update department set number_of_senior = 10 where id =1;
UPDATE 1
hcie2=# select * from department;
 id |    name     | number_of_senior 
----+-------------+------------------
  1 | physical    |               10
  2 | mathmetrics |                0
  3 | chemistry   |                0

```

##### (3) 启动触发器，修改department表中id=1的number_of_senior=20

```sql
-- 考生作答
hcie2=# alter table department enable trigger Tri_update_D;
ALTER TABLE
hcie2=# update department set number_of_senior = 20 where id =1;
NOTICE:  不能随便修改部门教授职称人数
UPDATE 1
hcie2=# 

```

#### 7. 性能优化

##### 当前有三个表，分别是学生信息表student(id,name,sex,class) 和 202201班级成绩表score1(id,course,score),202202班级成绩表score2结构与score1相同

```sql
create table student2(
	id int,
    name varchar(12),
    sex char(2),
    class varchar(8));

create table score1(
	id int,
    course varchar(8),
    score int
);

create table score2(
	id int,
    course varchar(8),
    score int
);

-- import data

insert into student2 values(1,'a','F','202201');
insert into student2 values(2,'b','F','202202');
insert into student2 values(3,'c','M','202201');
insert into student2 values(4,'d','F','202202');
insert into student2 values(5,'e','M','202201');
insert into student2 values(6,'f','M','202202');
insert into student2 values(7,'g','M','202201');
insert into student2 values(8,'h','F','202201');

insert into score1 values(1,'yuwen',88),(1,'math',98);
insert into score1 values(3,'yuwen',86),(3,'math',88);
insert into score1 values(5,'yuwen',56),(5,'math',76);
insert into score1 values(7,'yuwen',89),(7,'math',46);
insert into score1 values(8,'yuwen',79),(8,'math',86);


insert into score2 values(2,'yuwen',76),(2,'math',90);
insert into score2 values(4,'yuwen',75),(4,'math',100);
insert into score2 values(6,'yuwen',85),(6,'math',99);

```



##### (1) 用union查询输出student所有列，score1和score2的course,grade列，按照id升序，成绩降序

```sql
-- 考生作答
(select 
 	t1.*,
 	t2.course,
 	t2.score 
from 
 	student2 t1 
join 
 	score1 t2 
on t1.id = t2.id) 
union 
(select 
 	t3.*,
 	t4.course,
 	t4.score 
 from 
 	student2 t3 
 join 
 	score2 t4 
 on 
 	t3.id = t4.id)
order by id,score desc;
```

##### (2) 对以上SQL语句进行优化

```sql
-- 考生作答
-- 考生作答
(select 
 	t1.*,
 	t2.course,
 	t2.score 
from 
 	student2 t1 
join 
 	score1 t2 
on t1.id = t2.id) 
union all --- 因为在不同的班级里，可以使用union all
(select 
 	t3.*,
 	t4.course,
 	t4.score 
 from 
 	student2 t3 
 join 
 	score2 t4 
 on 
 	t3.id = t4.id)
order by id score desc;
```

##### (3) 查看两个班级相同的科目，202201班在score1中不存在的成绩，要求使用not in

```sql
-- 考生作答
select 
	course,
	score 
from 
	score1 
where 
	score 
not in ( select 
        	score 
        from 
        	score2 
        where 
        	score2.course = score1.course);
```

##### (4) 对以上SQL进行优化

```sql
-- 考生作答
select 
	course,
	score 
from 
	score1 
where not exists 
	(select 
     	score 
    from 
     	score2 
    where 
     	score2.course = score1.course
     and 
     	score2.score = score1.score);
```

####　8. 论述

##### (1) 什么是数据库事务，介绍GaussDB数据库事务管理的实现

+ 事务是单个逻辑单元执行的一系列操作，这些操作作为一个整体一起向系统提交要么执行，要么不执行。事务是一个不可分割的工作逻辑单元，GaussDB支持事务的ACID特性(**原子性**(atomicity)，**一致性(consistancy)**,**隔离性(isolation)**,**持久性(duration)**)。
+ **GaussDB**基于**MVCC**(多版本并发控制)并结合两阶段锁的方式进行事务管理，其特点是**读写之间不阻塞**。**SELECT**是纯读操作，**UPDATE**和**DELETE**读写操作。在准备阶段就会把提交操作所需要的信息和资源全部写入磁盘，进行持久化，提交阶段根据之前准备好的提交信息和资源，故障或者执行失败发生在准备阶段和提交阶段之间时，事务的最终状态为回滚。
+ **GaussDB**基于**GTM**组件协助管理分布式事务，采用多版本并发控制**MVCC**机制。**GaussDB**提供了不同的**GTM**模式，**GTM-Lite**和**GTM-Free**。在**GTM-Lite**模式下，中心事务处理节点的压力得到减轻，事务处理流程进一步优化，**GTM**的性能和并发瓶颈得到缓解，可实现强一致性；在**GTM-Free**模式下，中心事务管理节点不再参与事务管理，消除了**GTM**单点瓶颈，可以达到更高的事务处理性能，但不支持强一致性，仅支持最终一致性。

##### (2) GaussDB数据库有哪些事务隔离级别，并说明含义

+ **READ COMMITED**: 读已提交隔离级别，事务只能讲到已提交的数据而不会读未提交的数据，这是默认值 。在读已提交模式里，每个新的命令都是从一个新的快照开始的，而这个快照包含所有到该时刻为止已经提交的事务，因此同一事务中后面的命令将看到任何已经提交的其它事务的结果(效果)。这里关心的问题是在单个命令里是否看到数据库里完全一致的视图。
+ **REPEATABLE READ**: 事务可以重复读隔离级别，事务只能讲到事务开始之前已经提交的数据，不能读取到未提交的数据 以及事务执行期间其它并发事务提交的修改(**但是，查询能够查到自身所在事物中先前更新的执行结果，即使先前更新尚未提交**)。可重复读事务中的查询看到的是事务开始时的快照，不是该事务内部当前查询开始时的快照，就是说，单个事务内部的**SELECT**命令总是查看到同样的数据，查看不到自身事务开始之后其他并发事务修改后提交的数据。

##### (3) 输出命令，启动事务，事务隔离级别为读已提交，只读模式

+ 启动事务:  **start transaction**

+ 设置隔离级别为只读模式

  **set local transaction isolation level read committed read only**

+ 结束事务

  **commit;**

  

