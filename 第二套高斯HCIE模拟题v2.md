

### 第二套模拟题

#### 1. 数据库对象管理及SQL应用

##### 基于以下学生成绩表，完成以下实验要求

```sql
--- 创建表
create table stu(id int,math int, art int,phy int);
--- 导入数据
insert into stu values(1,60,33,66),(2,61,53,86),(3,70,63,66),(4,90,63,76),(5,59,69,79);
```

##### (1) 查看每门成绩是否大于每门平均成绩

````sql
--考生作答
select *,	
	case when math <=avg(math) over() then '不大于' else '大于' end as is_math_bigger, 
	case when art <=avg(art) over() then '不大于' else '大于' end as is_art_bigger,
	case when phy <=avg(phy) over() then '不大于' else '大于' end as is_phy_bigger
from stu;

moniti2-# from stu;
 id | math | art | phy | is_math_bigger | is_art_bigger | is_phy_bigger
----+------+-----+-----+----------------+---------------+---------------
  1 |   60 |  33 |  66 | 不大于         | 不大于        | 不大于
  2 |   61 |  53 |  86 | 不大于         | 不大于        | 大于
  3 |   70 |  63 |  66 | 大于           | 大于          | 不大于
  4 |   90 |  63 |  76 | 大于           | 大于          | 大于
  5 |   59 |  69 |  79 | 不大于         | 大于          | 大于
(5 rows)
```
```sql
窗口函数，正常来说所有的聚合函数都是在分组之后计算的对吧，比如常见的count，sum，avg这些，但是openGauss的分组有些问题，就是要单独查询的字段都必须是分组键，这个over的作用相当于是局部的分组，over里面有两个可配置的参数over(partition by c1 order by c1 desc) partition就等价于groupby，orderby就是排序，在聚合函数后面加over表示你的聚合计算是根据后面over指定的分组方式和排序方式得到结果

正常计算每个学生的总成绩就是select sid,sum(score) from score group by sid，如果要查询学生姓名那就得是select sid,sname,sum(score) from score group by sid,sname

用over的话就是对于大查询来说没有做分组select sid,sname,sum(score) over(partition by sid) from score
```

##### (2) 编写函数获取成绩绩点，输入学生id和科目名称，输出对应的绩点值 0~59 给0；60~69给0.1;70~79给0.2; 80~89给0.3; 90~100给0.4

```sql
--考生作答
create or replace function get_gd_by_score(inputscore int) returns float as
$$
declare gd float;
begin
select (case when inputscore <=59 then 0 when inputscore <=69 then 0.1 when inputscore <=79 then 0.2 when inputscore <=89 then 0.3 when inputscore <=100 then 0.4 else -1 end) into gd;
return gd;
end;
$$ language plpgsql;

-- 总结高斯数据库编写函数的结构及case when 结构
-- case when结构以case开头，以end终止
create or replace function -- 1. 创建函数开头的固定写法 
get_gd_by_score(inputscore int) -- 2. 声明函数名及传入的参数和参数类型 
returns float -- 3. 声音返回值的数据类型 
as -- 4. 固定写法
$$ -- 5.1 这个神奇的$$符号，开始要一对$$，终止也要一对$$,两对$$将SQL业务逻辑包含其中
declare gd float; -- 6
begin -- 7.1 固定写法
select (case when inputscore <=59 then 0 when inputscore <=69 then 0.1 when inputscore <=79 then 0.2 when inputscore <=89 then 0.3 when inputscore <=100 then 0.4 else -1 end) into gd; -- 8. sql 业务逻辑
return gd; -- 9. 返回值
end; -- 7.2 固定写法
$$ language plpgsql; -- 5.2 这个神奇的$$符号，开始要一对$$，终止也要一对$$,两对$$将SQL业务逻辑包含其中
```

```sql
--考生作答
create or replace function fun_cal_point(id1 int,coursename varchar(30)) returns float as
$$
declare point float;
begin
   	case when coursename='math' then select (get_gd_by_score(math)) into point from stu where id=id1;
	when coursename='art' then select (get_gd_by_score(art)) into point from stu where id=id1;
	when coursename='phy' then select (get_gd_by_score(phy)) into point from stu where id=id1;
else raise notice 'please input right course name;';
end case;
return point;
end;
$$ language plpgsql;
```

```sql
总结高斯数据库编写函数的结构

create or replace function --1. 固定写法

fun_cal_point(id1 int,coursename varchar(30)) --2. 函数名及传递的参数名及参数名的数据类型

returns float --3. 申明返回值的数据类型

as --4. as 也是固定写法，后面接一对'$$',其中函数的业务逻辑写在这一对$$里面
$$
declare point float; --5. 声明或者定义返回值及数据类型，后面接begin end结构
begin --6. begin 正式开始
   	case when coursename='math' then select (get_gd_by_score(math)) into point from stu where id=id1;
	when coursename='art' then select (get_gd_by_score(art)) into point from stu where id=id1;
	when coursename='phy' then select (get_gd_by_score(phy)) into point from stu where id=id1;
else raise notice 'please input right course name;';
end case;
return point;
end; --
$$ language plpgsql;
```

##### (3) id含有'3'的同学，求总的绩点，返回绩点最大的ID和总绩点

```sql
moniti2=# 
select id,(fun_cal_point(id,'math')+fun_cal_point(id,'art')+fun_cal_point(id,'phy')) as gd from stu where id like '%3%';
 id | gd
----+----
  3 | .4
(1 row)
```

##### (4) 求总绩点，返回绩点最大的ID和总绩点

```sql
select 
	id,
	(fun_cal_point(id,'math')+fun_cal_point(id,'art')+fun_cal_point(id,'phy')) as gd 
from 
	stu 
order by gd desc limit 1;
 id | gd
----+----
  4 | .7
(1 row)
```

##### (5) 按照总绩点排名输出

```sql
moniti2=# 
select 
	id,
	(fun_cal_point(id,'math')+fun_cal_point(id,'art')+fun_cal_point(id,'phy')) as gd 
from 
	stu 
order by gd desc;
 id | gd
----+----
  4 | .7
  2 | .4
  3 | .4
  5 | .3
  1 | .2
(5 rows)
```

##### (6) 编写add_mask(id1,id2)函数，当id1是当前查询用户时，显示正常id,如果不是则显示为id2

```sql
create or replace FUNCTION add_mask(id1 varchar(200),id2 varchar(200)) returns varchar(200) as 
$$
begin
	if id1 = current_user then
		return id1;
	else
		return id2;
	end if;
end;
$$ language plpgsql;
```

#### 2. 用户权限管理

##### (1) 创建用户user1

```sql
--考生作答
create user user1 password 'xxxxxx';
```

##### (2) 查看用户user1和数据库相关权限，要求显示数据库表、用户名、数据库的权限

```sql
--考生作答
select
	datname,
	(aclexplode(datacl)).grantee as g,
	(aclexplode(datacl)).privilege_type as p 
from 
	pg_database
where 
	datname 
not like 'template%';

-- 结果：
moniti2=# select
moniti2-# datname,
moniti2-# (aclexplode(datacl)).grantee as g,
moniti2-# (aclexplode(datacl)).privilege_type as p
moniti2-# from pg_database
moniti2-# where datname not like 'template%';
 datname | g | p
---------+---+---
(0 rows)

moniti2=#
```

##### (3) 把表table1的select和alter权限赋给user1

```sql
--考生作答
grant select,alter on talbe1 to user1;
```

##### (4) 查询table1的owner,要求显示表名和owner

```sql
--考生作答
select 
	tablename,
	tableowner 
from 
	pg_tables 
where 
	tablename = 'table1';
```

##### (5) 查询user1的表权限，要求显示表名、schema表、用户名、相关权限

```sql
--考生作答
select 
	grantee,
	table_name,
	table_schema,
	privilage_type 
from 
	information_schema.table_privileges 
where 
	grantee = 'user1'
```



##### (6) 查询对表table1有操作权限的用户，要求显示2列：用户名、操作权限

```sql
--考生作答
select 
	grantee as user,
	privilege_type 
from 
	information_schema.table_privileges 
where 
	table_name = 'table1';
```

#### 3. 数据库连接

##### (1) 查看全局最大连接数

```sql
--考生作答
show max_connections
```

##### (2) 创建数库最大连接数，指定最大连接数为100000，并使用SQL查看展示数据库名称，最大连接数

```sql
--考生作答
-- 创建数据库 connection limit 指定最大连接数
create database test_db connection limit 100000;
-- 查看数据库最大连接数
select datname,datconnlimit from pg_database where datname = 'test_db';
```

##### (3) 创建用户并指定最大连接数，指定最大连接数为20000，并使用SQL查看展示用户名称和最大连接数

```sql
--考生作答
-- 创建用户，connection limit 指定最大连接数
create user sjh_max password 'xxxxxx' connection limit 20000;
-- 对已经存在的用户设置也可以设置最大连接数的指定
alter user sjh_max connection limit 20000;
-- 查看用户名、最大连接数
select rolname,rolconnlimit from pg_roles where rolname = 'sjh_max';
```

##### (4) 修改数据库的最大连接数，将最大连接数修改为200000

```sql
--考生作答
alter database test_db connection limit 200000;
```

#### 4. 动态数据脱敏

##### (1) 创建dev_mask 和 bob_mask用户

```sql
--考生作答
create user dev_mask password 'Cmb@2024';
create user bob_mask password 'Cmb@2024';
```

##### (2) 创建表tb_for_masking ,字段信息包含(col1 text,col2 text,col3 text)

```sql
--考生作答
create table tb_for_masking(col1 text,col2 text,col3 text);
```

##### (3) 为col1列设置脱敏策略，使用maskall函数对col1列进行数据脱敏

```sql
--考生作答
--使用资源标签标记col1列
create resource label mask_lb1 add column(tb_for_masking.col1);
-- 为 col1列制定脱敏策略
create masking policy maskpol1 maskall on label(mask_lb1);
```

##### (4) 为maskpol1 脱敏策略添加描述信息 "masking policy for tb_for_masking.col1"

```sql
--考生作答
alter masking policy maskpol1 COMMENTS 'masking policy for tb_for_masking.col1';
```

##### (5) 为maskpol1脱敏策略在原基础上新增加以col2列做随机脱敏，脱敏函数使用randommasking

```sql
--考生作答
--使用资源标签标记col1列
create resource label mask_lb2 add column(tb_for_masking.col2);
-- 为 col2列制定脱敏策略
alter masking policy maskpol1  add randommasking on label(mask_lb2);
```

##### (6) 修改maskpol1 移除在col2列上的randommasking脱敏方式

```
--考生作答
-- 为 col2列删除脱敏策略
alter masking policy maskpol1  remove randommasking on label(mask_lb2);
```

##### (7) 修改maskpol1这个脱敏方式，将在col1列的maskall脱敏方式修改为randommasking脱敏

```sql
--考生作答
-- 为 col1列修改脱敏策略为randommasking
alter masking policy maskpol1  modify randommasking on label(mask_lb1);
```

##### (8) 修改脱敏策略maskpol1使之仅对用户dev_mask和bob_mask,客户端工具为psql和gsql,IP地址为'10.20.30.40','127.0.0.0/24'场景生效

```sql
--考生作答
alter masking policy maskpol1 MODIFY(FILTER ON ROLES(dev_mask,bob_mask),APP(psql,gsql),IP('10.20.30.40','127.0.0.0/24'))
```

##### (9) 修改脱敏策略maskpol1,使之对所有用户场景生效

```sql
--考生作答
alter masking policy maskpol1 drop filter;
```

##### (10) 禁用脱敏策略

```sql
--考生作答
alter masking policy maskpol1 disable;
```

#### 5. 触发器

##### (1) 创建视图SELECT_SD,查看学生成绩信息，查看学生姓名，课程名称，课程成绩

```sql
create view 
	SELECT_SD as 
		select 
			sname,
			cname,
			grade 
		from 
			student,
			course c,
			elective e 
		where 
			e.sno =s.sno 
		and 
			e.cno = c.cno;
```

##### (2) 编写函数FUNC_SUM,返回某个学生的分数总和

```sql
--考生作答
create or replace function FUNC_SUM(stuid int) returns integer as 
$$
declare result integer;
begin
	select sum(grade) into result from elective where sno = stuid;
	return result;
end;
$$language plpgsql;
```

##### (3) 创建触发器DELETE_ELE,在STUDENT表绑定触发器DELETE_ELE,在删除表中某个学生时，将ELECTIVE表中该学生的选课记录一并删除

```sql
--考生作答
-- 删除elective表记录的函数
create or replace function func_delete_ele() returns trigger as 
$$
begin	
	delete from elective where sno = old.sno;
	return old;
    -- 如果触发器触发时间为before,需要return old,将old记录返回给原事件，否则触发器执行完后原事件会执行失败；
end;
$$language plpgsql;

--绑定到student表的触发器
create trigger delete_ele before delete on student for each row execute procedure func_delete_ele() ;
```

#### 6. 存储过程

##### 基于以下信息表，完成以下实验要求

```sql
---创建表
create table student(id serial,starttime timestamp(0));
```

##### (1) 编写存储过程，生成记录，输入个数，生成student,id从10000开始，starttime是当前时间

```sql
--考生作答
create or replace procedure create_student_information(num int) 
as 
begin
	for id in 10000..10000+num-1 loop
		insert into student values(id,sysdate);
		end loop;
end;
/
```

##### (2) 调用存储过程，生成90000条记录

```sql
--考生作答
call create_student_information(90000)
```

##### (3) 查看表记录数

```sql
--考生作答
select count(*) from student;
```

#### 7. 数据库优化

##### 通常的SQL优化会通过参数调优的方式进行调整，例如如下参数

```sql
set enable_fast_query_shipping = off;
set enable_stream_operator = on;
```

##### 请根据以下表完成数据库优化

```sql
--create table 
create table tb_user(
	stu_no int,
    stu_name varchar(32),
    age int,
    hobby_type int
) distribute by hash(age);
-- 插入数据
insert into tb_user 
select 
	id,
	'xiaoming'||(random()*60+10)::int,
	(random()*60+10)::int,
	(random()*5+1)::int 
from 
	(select generate_series(1,100000) id) tb_user;
```

##### (1) 收集tb_user的统计信息

```sql
考生作答
analyze tb_user;
```

##### (2) 为以下两个查询语句创建索引，让执行计划和索引最合理

```sql
SQL1: explain analyze select * from tb_user where age = 29 adn stu_name = 'xiaoming';
SQL2: explain analyze select * from tb_user where stu_no = 100 and age = 29;
```

```sql
考生作答
-- SQL1: 	
	select gs_index_advise('select * from tb_user where age = 29 adn stu_name = "xiaoming");
	create index age_name on tb_user(stu_name,age);
-- SQL2:
    select gs_index_advise('select * from tb_user where stu_no = 100 and age = 29');
    create index age_no on tb_user(stu_no,age);
```

##### (3) 在上题操作的基础上，用3种不同方式使如下SQL不走索引

```sql
explain analyze select * from tb_user where stu_no = 100 and age = 29;
```

```sql
---考生作答(和第一套模拟题一样)
--1. 通过hint干预优化不走索引
--2. 调大index 开销
set cpu_index_tuple_cost = 1000000;
--3. 直接禁止用索引
alter index age_no,age_name unusable;
```

#### 8. 论述题

##### (1) 使用储存过程的优点

##### (2) 存储过程和函数的区别

##### (3) 存储过程和匿名块的区别





