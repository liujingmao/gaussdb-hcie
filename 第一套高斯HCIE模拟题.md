### 高斯IE第一套

#### 1. 数据库对象管理及SQL应用

##### 当前有两张表，分别是学生表和班级表，请基于这两张表完成以下实验要求。

```sql
-- create table
create table student(sno int,sname varchar(50),score int,cno int);
create table classes(cno int,cname varchar(50));

-- import datas 
insert into student values(123,'a',456,1);
insert into student values(124,'b',546,1);
insert into student values(125,'c',548,1);
insert into student values(126,'d',569,1);
insert into student values(127,'e',540,1);
insert into student values(128,'f',536,2);
insert into student values(129,'g',512,2);
insert into student values(130,'h',546,2);
insert into student values(131,'i',508,2);
insert into student values(132,'j',456,2);

insert into classes values(1, '1 班');
insert into classes values(2, '2 班');
```

##### (1) 查询学号为130的学生的名字、总成绩以及所在班级

```sql
-- 考生作答
select 
	s.sname,
	s.score,
	c.cname 
from 
	student s,
	classes c 
where 
	s.cno = c.cno 
and 
	sno = 130;
```

##### (2) 查看每个班级(cno)月考总分(score)前三名，其中要求分数相同的人具有相同的编号(且排名不中断)

```sql
-- 考生作答
select 
	* 
from 
	(select 
     	*, 
     	dense_rank() over (partition by cno order by score desc) as rk 
     from 
     	student) 
 where rk <=3;
```

#### 2. 常用系统表查询 

##### (1) 表创建

##### 请按照要求创建表p_table(a int,b int,c int,d int)表，指定以b字段作为分区键，按10以下，10-20，20-30，30-40分，以a字段作为分布键的列存在(云主机到位后练习)

```sql
-- 考生作答
-- 考试时分布式建表
create table p_table(a int,b int,c int,d int) with (ORIENTATION=column)
distribute by hash(a)
partition by range(b) (
	partition p1 values less than(10),
	partition p2 values less than(20),
	partition p3 values less than(30),
    partition p4 values less than(40)
);
-- 练习单节点建表
create table p_table(a int,b int,c int,d int) partition by range(b);

-- 主备版本
create table p_table(a int,b int,c int,d int) with (ORIENTATION=column)
partition by range(b) (
	partition p1 values less than(10),
	partition p2 values less than(20),
	partition p3 values less than(30),
    partition p4 values less than(40)
);
```

##### (2) 查询表(p_table)的模式名和表名

```sql
-- 考生作答
-- 方法1，比较长的SQL
select 
	c.relname,
	n.nspname 
from 
	pg_class c 
join
	pg_namespace n
on
	c.relnamespace = n.oid
where
	c.relname = 'p_table';

-- 方法2，简单容易让人理解
select 
	tablename,
	schemaname 
from 
	pg_tables 
where 
	tablename = 'p_table';
	
tablename | schemaname
-----------+------------
 p_table   | public
(1 row)
```

##### (3) 查询表的所在节点nodeoids信息(云主机到位后，再练习哦)

```sql
-- 考生作答
select 
	t1.relname,
	t2.nodeoids 
from 
	pg_class t1,
	pgxc_class t2,
	pg_namespace t3 
where 
	t1.oid = t2.pcrelid 
and 
	t1.relnamespace = t3.oid 
and 
	t1.relname = 'p_table'
and 
	t3.nspname = 'public';
-- 有些无法理解 
```

##### (4) 查询表所在的节点实例信息

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
	cast(t2.nodeoids as varchar(20)) = cast(t4.oid as varchar(20)) -- 两种表达方法
and
	t1.relname = 'p_table'
and 
	t3.nspname = 'public';
	
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
	cast(t2.nodeoids::varchar(20)) = cast(t4.oid::varchar(20)) -- 两种表达方法
and
	t1.relname = 'p_table'
and 
	t3.nspname = 'public';
```

#### 3. 用户及权限管理

##### 当前有一张表sjh_test(a int,b int), 和角色jsh112,请给予当前环境完成以下用户及权限相关管理操作

```sql
-- create table
create table sjh_test(a int,b int,c int);
-- create role 
create role sjh112 password 'Huawei12#$%';
```

##### (1) 创建用户sjh111

```sql
-- 考生作答
create user sjh111 password 'Huawei12#$%';
```

##### (2) 将表sjh_test表的读取，删除权限给sjh111用户

```sql
-- 考生作答
-- 普通用户只有public模式的权限，需要将当前schema使用权限赋予给用户
grant usage on schema public to sjh111;
-- 赋权
grant select,delete on sjh_test to sjh111;
```

##### (3) 为用户sjh111权限在sjh_test表的a,b列上的查询、添加和更新权限

```sql
-- 考生作答
grant select(a,b),insert(a,b),update(a,b) on sjh_test to sjh111;
```

##### (4) 将用户sjh111权限在sjh_test表的a列上的查询、添加和更新权限回收

```sql
-- 考生作答
revoke select(a),insert(a),update(a) on sjh_test from sjh111;
```

##### (5) 创建jsh_audit角色,该角色拥有审计权限 (with auditadmin加上会使角色有审计权限)

```sql
-- 考生作答
create role jsh_audit with audtiadmin password 'XXXXXXX'; -- 必须加上密码，否则报错
```

##### (6) 将sjh112角色权限授予给用户sjh111,并允许sjh111继承权限可以再次授予其他角色或用户(with admin option)

```sql
-- 考生作答
grant sjh112 to sjh111 with admin option;
```

##### (7) 创建用户sjh113,设置使用有效期 "2023-01-28" 到 "2026-01-01"

```sql
-- 考生作答
create user sjh113 password 'xxxxxxx' valid begin '2023-01-28' valid until '2026-01-01';
```

#### 4. 行级访问控制 

##### 当前 有all_data表，字段信息如下 ，请给予表实现行级别访问控制

```sql
 -- create table 
 create table all_data(
 	 role varchar(50),
 	 name varchar(50),
 	 age int
 );
 -- insert into data
 insert into all_data values('root','zhangsan',18),('sjh111','lisi',43),('sjh113','wangwu',35);
```

##### (1) 打开all_data表的行访问控制策略开关

```sql
-- 考生作答
alter table all_data enable row level security;
```

##### (2) 为表all_data创建行访问控制策略，当前用户只能查看用户自身的数据

```sql
-- 考生作答
create row level security policy rls ON all_data using(role = CURRENT_USER);
```

##### (3) 为表all_data删除行访问控制策略

```sql
-- 考生作答
drop row level security policy rls ON all_data;
```

##### (4) 给表all_data 关闭行级访问策略

```sql
-- 考生作答
alter table all_data disable row level security;
```

#### 5. 触发器

```sql
-- 三张表
-- 学生信息表
CREATE TABLE STUDENT(
	sno integer,
    sname varchar(50),
	ssex varchar(5),
    sage integer
);

-- 课程表
CREATE TABLE COURSE(
	cno integer,
    cname varchar(50),
	credit integer
);

-- 选课表
CREATE TABLE ELECTIVE(
	sno integer,
    cno integer,
	grade integer
);

-- 插入数据
insert into student values(1,'a','M',12),(2,'b','M',11),(3,'c','F',12);

insert into course values(10,'chinese',100),(20,'math',200);

insert into elective values(1,10,90),(1,20,88),(2,10,92),(2,20,100),(3,10,76),(3,20,90);
```

##### (1) 创建SELECT_SD，查看学生成绩信息，查看学生姓名，课程名称，课程成绩

```sql
-- 考生作答
create view 
	SELECT_SD 
as 
	select 
		sname,
		cname,
		grade
	from 
		student s,
		course c,
		electve e 
	where 
		e.sno = s.sno 
	and 
		e.cno = c.cno;
```

##### (2) 编写函数FUNC_SUM,根据传递的学生的学生编号或者姓名返回某个学生的分数总和

```sql
-- 考生作答
create or replace function FUNC_SUM(stuid int) returns integer as 
$$
declare result integer;
begin
	select sum(grade) into result from elective where sno = stuid;
	return result;
end;
$$language plpgsql
```

##### (3) 创建触发器DELETE_ELE,在STUDENT表上绑定触发器DELETE_ELE，在删除表中某个学生时，将ELECTIVE表中该学生的选课记录一并删除

```sql
-- 考生作答
-- 删除elective表记录的函数
create or replace function func_delete_ele() returns trigger as 
$$
begin
	delete from elective where sno = old.sno;
	return old;
end;
$$language plpgsql

-- 绑定到student表的触发器
create trigger delete_ele before delete on student for each row execute procedure func_delete_ele();
```

```sql
-- 总结一下触发器的结构和根据要求梳理运行流程
-- 删除elective表记录的函数
create or replace function 
func_delete_ele() 
returns trigger 
as 
$$
begin
	delete from elective where sno = old.sno;
	return old;
end;
$$language plpgsql

-- 绑定到student表的触发器
create trigger delete_ele before delete on student for each row execute procedure func_delete_ele();

-- 参考学习：https://blog.csdn.net/GaussDB/article/details/134659930
```

#### 6. 游标

##### 以下为表创建SQL语句，该题目没有数据 

```sql
create table TEACHER(
	ID INTEGER NOT NULL,
    NAME VARCHAR(50) NOT NULL,
	DEPTNO INTEGER NOT NULL,
    SALARY FLOAT NOT NULL,
    TITLE VARCHAR(100) NOT NULL --职称：讲师、副教授、教授
)

create table DEPARTMENT(
	ID INTEGER NOT NULL,
    NAME VARCHAR(50) NOT NULL);
   
create table TEACHER(
	ID INTEGER NOT NULL,
    NAME VARCHAR(50) NOT NULL,
	DEPTNO INTEGER NOT NULL,
    SALARY FLOAT NOT NULL,
    TITLE VARCHAR(100) NOT NULL
);

create table DEPARTMENT(
	ID INTEGER NOT NULL,
    NAME VARCHAR(50) NOT NULL);
    
insert into TEACHER values(1,'Zhangsan',20,50000.00,'教授'),
(2,'XiaoMing',20,20000.00,'讲师'),
(3,'lisi',30,20000.00,'副教授'),
(4,'XiaoMing',30,20000.00,'副教授');

insert into TEACHER values(5,'Zhangwukun',40,50000.00,'教授'),
(6,'WuSong',20,21000.00,'讲师'),
(7,'liuSan',50,20500.00,'副教授'),
(8,'Sehu',30,26000.00,'副教授');

insert into TEACHER values(9,'yiyuqian',40,1.00,'教授'),
(10,'liangyuanqian',20,2.00,'讲师'),
(11,'sanyuan',50,3.00,'副教授'),
(12,'siyuanqian',30,4.00,'副教授');

insert into TEACHER values(13,'liuwan',40,60000.00,'教授'),
(14,'qiwan',20,70000.00,'讲师'),
(15,'bawan',50,80000.00,'副教授'),
(16,'jiuwan',40,90000.00,'副教授');

insert into DEPARTMENT values(20,'机电工程学院'),(30,'计算机学院');
insert into DEPARTMENT values(40,'自动化学院'),(50,'管理学院');
```

##### (1) 创建存储过程pro_curs_1,使用游标打印各部门总人数，按照人数降序排序，打印格式如下 ：部门名称1---人数部门名称2---人数打印操作可以使用DBE_OUTPUTPRINT_LINE(outputstr)接口

```sql
-- 考生作答
create or replace procedure pro_curs_1()
as
declare cursor cur1 is select d.name as dn,count(*) as pc from teacher t,department d where t.deptno=d.id group by d.name order by pc desc;
begin
	for i in cur1 loop
		DBE_OUTPUTPRINT_LINE(concat(i.dn,'---',i.pc::varchar));-- 分布式条件才能使用该函数
	end loop;
end;
call pro_curs_1()

create or replace procedure pro_curs_1()
as
declare cursor cur1 is
select d.name as dn,count(*) as pc from teacher t,department d
where t.deptno = d.id group by d.name order by pc desc;
begin
for i in cur1 loop
raise notice '%-%',i.dn,i.pc;   -- 单节点集群暂时用这个方法解决这个问题
end loop;
end;
moniti1$# /
CREATE PROCEDURE
moniti1=# call  pro_curs_1();
NOTICE:  计算机学院-2
NOTICE:  机电工程学院-2
 pro_curs_1
------------
```

##### (2) 创建存储过程pro_curs_2,使用游标读取薪水按降序排序的前三位老师和后三位老师的信息，分别获取ID，姓名，部门名称，薪水和职称，请按以下格式打印ID-姓名-部门名称-薪水-职称

```sql
-- 考生作答
create or replace procedure pro_curs_2()
as 
declare cursor cur1 is 
select
	t.id,
	t.name,
	d.name,
	t.salary,
	t.title
from
	((select * from teacher order by salary desc limit 3) 
     	union all
     (select * from teacher order by salary limit 3)) t 
     	join department d on t.deptno = d.id;
begin
	for i in cur1 loop
		DBE_OUTPUTPRINT_LINE(concat(i.id::varchar,'-',i.sname,'-',i.dname,'-',i.salary::varchar,'-',i.title));
	end loop;
end;

create or replace procedure pro_curs_2()
as 
declare cursor cur1 is 
select
	t.id as tid,
	t.name as tname,
	d.name as dname,
	t.salary,
	t.title
from
	((select * from teacher order by salary desc limit 3) 
     	union all
     (select * from teacher order by salary limit 3)) t 
     	join department d on t.deptno = d.id;
begin
	for i in cur1 loop
		raise notice '%-%-%-%-%',i.tid,i.tname,i.dname,i.salary,i.title; -- %参数点位符号
	end loop;
end;
/
```

```sql
-- 总结存储过程与游标的用法
-- 创建存储过程pro_curs_2,使用游标读取薪水按降序排序的前三位老师和后三位老师的信息，分别获取ID，姓名，部门名称，薪水和职称，请按以下格式打印ID-姓名-部门名称-薪水-职称
create or replace procedure -- 1. 创建存储过程的固定
pro_curs_2() -- 2. 根据题目给的要求声明存储过程名称
as -- 3. AS作为连词，固定写法
declare cursor cur1 -- 4. 声明并创建游标，declare cursor 是声明游标的固定词汇，cur1是游标名称，可以随意自己定义
is -- 4. is作为连词，固定写法,后面接的是sql逻辑，可以理解成is后面内容结果放在游标cur1中，cur1是对象，该对象放在是后面查询的结果,后面select ... from 出来的结果放在cur1对象中
select
	t.id as tid,
	t.name as tname,
	d.name as dname,
	t.salary,
	t.title
from
	((select * from teacher order by salary desc limit 3) 
     	union all
     (select * from teacher order by salary limit 3)) t 
join 
	department d 
on 
	t.deptno = d.id;
-- 5. 对标注里面的结果进行打印，使用raise notice,该业务逻辑使用begin 和 end包裹
begin
	for i in cur1 loop -- 6. 对cur1中的结果进行便利 后面接loop关键字
		raise notice '%-%-%-%-%',i.tid,i.tname,i.dname,i.salary,i.title; -- 7. %是动态参数的占位符号
	end loop; -- 8. 后面接个end loop为固定搭配结构
end;
/
```

#### 7. 数据库优化

##### 通常的SQL优化会通过参数调优的方式进行调整，例如如下参数

```
set enable_fast_query_shipping = off;
set enable_stream_operator = on;
```

##### 请根据以下表完成数据库优化

```sql
-- create table
create table tb_user(
    stu_no INT,
    stu_name VARCHAR(32),
	age INT,
    hobby_type INT
);

-- insert data
insert into 
	tb_user select id,'xiaoing'||(random()*60+10)::int,
	(random()*60+10)::int,
	(random()*5+1)::int 
from 
	(select generate_series(1,100000)id) tb_user;
```

##### (1) 收集tb_user的统计信息

```sql
-- 考生作答
analyze tb_user;
```

##### (2) 为下面两个查询语句创建索引，让执行计划和索引最合理

```sql
SQL1: explain analyze select * from tb_user where age=29 and stu_name = 'xiaoming';
SQL2: explain analyze select * from tb_user where stu_no = 100 and age = 29;
```

```sql
-- 考生作答
SQL1:
select gs_index_advise('select * from tb_user where age=29 and stu_name = "xiaoming"');
create index index_name1 on tb_user(age,stu_name);
                       
SQL2:
select gs_index_advise('select * from tb_user where stu_no = 100 and age = 29');
create index index_name2 on tb_user(stu_no,age);
```

##### (3) 在上题的基础上，用3种不同的方式使如下SQL不走索引 

```sql
explain analyze select * from tb_user where stu_no = 100 and age =29;
```

```sql
-- 考生作答
-- 方法1. 通过hint干预优化不走索引
SQL1: 
explain anylyze 
select
	/* + tablescan(tb_user) */* 
from
	tb_user 
where 
	age = 29
and 
	stu_name = 'xiaoming';
SQL2:
explain anylyze 
select
	/* + tablescan */* 
from
	tb_user 
where 
	stu_no=100
and 
	age = 29;
-- 方法2.增大index开销
set cpu_index_tuple_cost = 100000
-- 方法3.直接禁用索引
alter index index_name1 unusable;
alter index index_name2 unusable;
```

#### 8. 论述

##### (1) 权限管理模型RBAC和ABAC区别

+ **RBAC**： 基于角色的访问控制，角色通常是指具有某类共同特征的一组人，例如：部门、地点、资历、级别、工作职责等。在系统初始时Admin根据业务需要创建多个拥有不同权限组合的角色，当需要赋予绑定某个用户权限的时候，把用户归到相应角色里即可赋予需要的权限 
+ **ABAC**：不同于常见的将用户通过某种方式关联到权限的方式，ABAC则是通过动态计算一个或者一组属性来判断是否满足某种条件来进行授权判断(可以编写简单的逻辑)。属性通常来说分为四类：用户属性，环境属性，操作属性和对象属性，所以理论上能够实现非常灵活的权限控制，几乎能够满足所有类型的需求。权限判断需要实时执行，规则过多会导致性能问题。
+ 两者区别：RBAC基于用户角色提供对资源或者信息的访问，而ABAC提供基于用户，环境或者资源属性的访问权限。

##### (2) 数据库数据加密方式有哪些，至少3种

+ 函数加密: 字段级别，通过调用函数，如**md5()**等函数对传入参数进行加密，业务感知加密，不支持密文条件安全，数据在会话中临时解密，数据库无法自动解密，防止高权限账号窃取数据；
+ 透明加密：表级别，数据在文件落盘时加密，对用户及上层使用**SQL**的应用不感知，对于需要加密的表创建时通过**TDE**参数指定加密算法，数据库无感知，内存明文处理，防止基于物理磁盘的数据窃取，**TDE**密钥管理分三层，分别是根密钥、主密钥和数据加密密钥；
+ 全密态：字段级，支持密态等值查询，数据库无法解密，防止运维、管理和高权账户等窃取隐私数据，在业务中仅在**DDL**层做了扩展，在**create table**或者**alter table**新增加列时可以将列设置为加密列，给需要加密的列绑定列加密密钥即可，**DML**操作于其他表一致，但需要以密态方式创建客户端连接才可以，如果是非密态模式，那么查询看到的数据是密文，未指定加密的列均明文处理，密钥管理分三层，分别是根密钥、主密钥和列加密密钥，密钥均存储于**GaussDB Client**中，减少攻击面。总之，函数加密，是用户把密钥给到数据库，数据库在执行过程中函数时做一个加密动作，在数据库里加密。透明加密是数据库自己找一个密钥，在磁盘落盘时做数据加密，是磁盘加密。全密态加密是客户找到密钥之后先把数据加密，再把数据交给数据库，全生命周期都是密文。
+ 客户端和服务端**SSL**通信加密：**SSL**加密支持对称加密、非对换加密、对称加密算法指的是加密和解密使用相同的密钥，特点是算法公开、加密和解密速度快，效率高；非对称加密算法包含两个密钥，公钥和私钥是一对，加密和解密使用不同的密码，特点是算法复杂度高、安全性更高、性能较对称加密差。
+ 常见的算法为**AES**、**DES**、**MD5**和**SM4**



