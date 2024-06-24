### 高斯IE第五套

#### 1. 数据库对象管理及SQL语法1

##### 	由于疫情管控，某小区进行封锁，收集了RESIDENTS居民表数据，包含姓名、年龄、性别、楼栋信息

```sql
-- 创建表
create table residents(
    name varchar(200),
    age int,
    sex char(1),
    buiding int
);
-- 导入数据 
insert into residents values('a',0,'m',02);
insert into residents values('b',24,'m',03);
insert into residents values('c',25,'f',05);
insert into residents values('d',26,'f',09);
insert into residents values('e',27,'f',10);
insert into residents values('f',28,'m',07);
insert into residents values('g',0,'f',06);
insert into residents values('h',30,'m',12);
insert into residents values('I',31,'f',13);
insert into residents values('k',52,'f',13);
insert into residents values('L',53,'m',12);
insert into residents values('m',34,'m',12);
insert into residents values('n',15,'f',13);
insert into residents values('o',17,'f',03);
insert into residents values('p',0,'f',04);
insert into residents values('q',66,'m',02);
insert into residents values('r',39,'m',01);
insert into residents values('s',40,'m',02);
```

#####  (1) 为了方便按楼栋给婴儿送纸尿裤，查出每栋楼age<1的数量，最后显示楼栋信息和对应的数量 

```sql
-- 考生作答
select 
	buiding,
	count(age) 
from 
	(select 
     	buiding,
     	age 
     from 
     	residents 
    where 
     	age < 1) 
 group  by 
 	buiding;
 buiding | count
---------+-------
       6 |     1
       4 |     1
       2 |     1
(3 rows)
```

##### (2) 由于每栋楼各个年龄段的人都有，故按age年龄分组[0-18),[18-35),[35-55),[55-+oo)形成age_group字段，每组命名group1,group2,group3,group4

```sql
-- 考生作答
select 
	*, 
	(case when age < 18 then 'group1' 
     	  when age <35 then 'group2' 
     	  when age < 55 then 'group3' 
     	  else 'group4' end) as age_group 
from 
	residents;
```

##### (3) age_group 按每组人数排序，查询出age_group、人数，最大年龄，最小年龄，平均年龄(平均年龄向下取整)

```sql
-- 考生作答
hcie5=# 
select 
	age_group,
	count(age) "人数",
	max(age) "最大年龄",
	min(age) "最小年龄",
	floor(avg(age)) "平均年龄" 
from
	(select 
     	age, 
     	(case when age < 18 then 'group1' 
              when age <35 then 'group2' 
              when age < 55 then 'group3' 
         	  else 'group4' end) as age_group 
      from residents) t 
 group by 
 	age_group 
 order by 
 	"人数" 
 desc;
 age_group | 人数 | 最大年龄 | 最小年龄 | 平均年龄
-----------+------+----------+----------+----------
 group2    |    8 |       34 |       24 |       28
 group1    |    5 |       17 |        0 |        6
 group3    |    4 |       53 |       39 |       46
 group4    |    1 |       66 |       66 |       66
(4 rows)

hcie5=#
```

##### (4) 由于需要每天送食物，增加如下年龄段所需要实物营养表，需要统计出该小区每天总营养值 

```sql
create table nutrition(age_group varchar(20),nutrition_value int);
insert into nutrition values('group1',5),('group2',7),('group3',6),('group4',5);
```

```sql
-- 

select sum(t2.nutrition_value*t1.n) from (select t.age_group,count(age) as n from(select age, (case when age < 18 then 'group1' when age <35 then 'group2' when age < 55 then 'group3' else 'group4' end) as age_group from residents) t group by age_group) t1,
nutrition t2 where t1.age_group = t2.age_group;

hcie5=# select sum(t2.nutrition_value*t1.n) from (select t.age_group,count(age) as n from(select age, (case when age < 18 then 'group1' when age <35 then 'group2' when age < 55 then 'group3' else 'group4' end) as age_group from residents) t group by age_group) t1,
hcie5-# nutrition t2 where t1.age_group = t2.age_group;
 sum
-----
 110
(1 row)

-- 老师给的答案
select sum(nutrition_value) from(select buiding, (case when age < 18 then 'group1' when age <35 then 'group2' when age < 55 then 'group3' else 'group4' end) as age_group from residents) t1,nutrition t2 where t1.age_group = t2.age_group;
-- 结果
hcie5=# select sum(nutrition_value) from(select buiding, (case when age < 18 then 'group1' when age <35 then 'group2' when age < 55 then 'group3' else 'group4' end) as age_group from residents) t1,nutrition t2 where t1.age_group = t2.age_group;
 sum
-----
 110
(1 row)

hcie5=#
```

##### (5) 按第栋求出每栋楼所需要的营养值 

```sql
select t1.buiding,sum(nutrition_value) from (select buiding, (case when age < 18 then 'group1' when age <35 then 'group2' when age < 55 then 'group3' else 'group4' end) as age_group from residents) t1,nutrition t2 where t2.age_group=t1.age_group group by t1.buiding;
 
 -- 老师给的答案
  
select buiding,sum(nutrition_value) from (select buiding, (case when age < 18 then 'group1' when age <35 then 'group2' when age < 55 then 'group3' else 'group4' end) as age_group from residents) t1,nutrition t2 where t2.age_group=t1.age_group group by buiding;

-- 结果 
hcie5=#  select t1.buiding,sum(nutrition_value) from (select buiding, (case when age < 18 then 'group1' when age <35 then 'group2' when age < 55 then 'group3' else 'group4' end) as age_group from residents) t1,nutrition t2 where t2.age_group=t1.age_group group by t1.buiding;
 buiding | sum
---------+-----
       1 |   6
       4 |   5
       3 |  12
       5 |   7
      13 |  18
      12 |  20
       9 |   7
       6 |   5
      10 |   7
       7 |   7
       2 |  16
(11 rows)

hcie5=# select buiding,sum(nutrition_value) from (select buiding, (case when age < 18 then 'group1' when age <35 then 'group2' when age < 55 then 'group3' else 'group4' end) as age_group from residents) t1,nutrition t2 where t2.age_group=t1.age_group group by buiding;
 buiding | sum
---------+-----
       1 |   6
       4 |   5
       3 |  12
       5 |   7
      13 |  18
      12 |  20
       9 |   7
       6 |   5
      10 |   7
       7 |   7
       2 |  16
(11 rows)

-- 考生作答
select t2.age_group,sum(t2.nutrition_value*t1.n) from (select t.age_group,count(age) as n from(select age, (case when age < 18 then 'group1' when age <35 then 'group2' when age < 55 then 'group3' else 'group4' end) as age_group from residents) t group by age_group) t1,nutrition t2 where t1.age_group = t2.age_group group by t2.age_group order by sum desc;
-- 结果
hcie5=# select t2.age_group,sum(t2.nutrition_value*t1.n) from (select t.age_group,count(age) as n from(select age, (case when age < 18 then 'group1' when age <35 then 'group2' when age < 55 then 'group3' else 'group4' end) as age_group from residents) t group by age_group) t1,nutrition t2 where t1.age_group = t2.age_group group by t2.age_group order by sum desc;
 age_group | sum
-----------+-----
 group2    |  56
 group1    |  25
 group3    |  24
 group4    |   5
(4 rows)
```

##### 2. 数据库对象管理及SQL语法2

##### 当前有一张订单表lineitem,具体字段如下

```sql
-- 字段说明
L_ORDERKEY BIGINT NOT NULL  -- 订单key
L_PARTKEY BIGINT NOT NULL -- 配件key
L_SUPPKEY BIGINT NOT NULL -- 供应商key
L_LINENUMBER BIGINT NOT NULL -- 流水号
L_QUANTITY float8 NOT NULL -- 数量
L_EXTENDEPPRICE float8 NOT NULL -- 出厂价
L_DISCOUNT float8 NOT NULL -- 折扣
L_TAX float8 NOT NULL -- 税点
L_RETURNFLAG CHAR(1) NOT NULL -- 原反标志
L_LINESTATUS CHAR(1) NOT NULL -- 明细
L_SHIPDATE DATE NOT NULL -- 发货日期
L_COMMITDATE DATA NOT NULL -- 预计到达日期
L_ARRIVALDATE DATA NOT NULL -- 到达日期
L_ORDERSTRATEGY CHAR(32) NOT NULL  -- 订单处理策略
L_TRANSPORTROUTE CHAR(32) NOT NULL -- 运输路径
L_COMMENT VARCHAR(64) NOT NULL -- 备注
```

##### 数据导入

```sql
insert into lineitem values();
```

##### (1) 创建分区表，根据上述字段信息创建分区表，按L_SHIPDATE分区，按年份1993，1994，1995，1996，1997，1998，1999，分区名称分别是L_SHIPDATE_1,第二个分区名L_SHIPDATE_2，以此类推，使用L_ORDERBYKEY进行哈希分布，建表完成执行上方数据导入代码，进行数据导入。

```sql
-- 作答区
create table lineitem (
L_ORDERKEY BIGINT NOT NULL,  -- 订单key
L_PARTKEY BIGINT NOT NULL, -- 配件key
L_SUPPKEY BIGINT NOT NULL, -- 供应商key
L_LINENUMBER BIGINT NOT NULL, -- 流水号
L_QUANTITY float8 NOT NULL, -- 数量
L_EXTENDEPPRICE float8 NOT NULL, -- 出厂价
L_DISCOUNT float8 NOT NULL, -- 折扣
L_TAX float8 NOT NULL, -- 税点
L_RETURNFLAG CHAR(1) NOT NULL, -- 原反标志
L_LINESTATUS CHAR(1) NOT NULL, -- 明细
L_SHIPDATE DATE NOT NULL, -- 发货日期
L_COMMITDATE DATA NOT NULL, -- 预计到达日期
L_ARRIVALDATE DATA NOT NULL, -- 到达日期
L_ORDERSTRATEGY CHAR(32) NOT NULL,  -- 订单处理策略
L_TRANSPORTROUTE CHAR(32) NOT NULL, -- 运输路径
L_COMMENT VARCHAR(64) NOT NULL, -- 备注
) distribute by hash(L_ORDERBYKEY)
partition by range(L_SHIPDATE)(
partition L_SHIPDATE_1 values less than ('1993-01-01'),
partition L_SHIPDATE_2 values less than ('1994-01-01'),
partition L_SHIPDATE_3 values less than ('1995-01-01'),
partition L_SHIPDATE_4 values less than ('1996-01-01'),
partition L_SHIPDATE_5 values less than ('1997-01-01'),
partition L_SHIPDATE_6 values less than ('1998-01-01'),
partition L_SHIPDATE_7 values less than ('1999-01-01'));
```

##### (2) 查询表的schema名称，展示表名，schema名称

```sql
-- 作答区
select tablename,schemaname from pg_tables where tablename = 'lineitem';
```

##### (3) 查看表分布节点的oid, 展示表名，nodeoids

```sql
-- 作答区
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
	t1.relnamespace  = t3.oid 
and 
	t1.relname = 'lineitem' 
and 
	t3.nspname = 'public';
	-- 
	
select 
	t1.relname,
	t2.nodeoids,
    t1.relnamespace
from 
	pg_class t1,
	pgxc_class t2,
	pg_namespace t3 
where 
	t1.oid = t2.pcrelid 
and 
	t1.relnamespace  = t3.oid 
and 
	t1.relname = 'lineitem' 
and 
	t3.nspname = 'public';
```

##### (4) 查看表所在实例的信息

```sql
-- 作答区
select 
	t4.* 
from 
	pg_class t1,
	pg_namespace t2,
	pgxc_class t3,
	pgxc_node t4 
where 
	t1.oid = t3.pcrelid 
and 
	t1.relnamespace = t2.oid 
and 
	t3.nodeoids::varchar = t4.oid::varchar 
and 
	t1.relname = 'lineitem' 
and 
	t2.nspname = 'public';

select t4.* from pg_class t1,pg_namespace t2,pgxc_class t3,pgxc_node t4 
where t1.oid = t3.pcrelid and t1.relnamespace = t2.oid 
and t3.nodeoids::varchar = t4.oid::varchar
and t1.relname = '' and t2.nspname = '';
```

##### 3. 数据库连接

##### (1) 创建user2用户，user2用户需要具备创建数据库的权限 

```sql
-- 考生作答
create user user2 createdb password 'Huawei@123';
```

##### (2) 查询用户的连接数上限

```sql
-- 考生作答
select rolname,rolconnlimit from pg_roles where rolname = 'user2';
 rolname | rolconnlimit
---------+--------------
 user2   |           -1
```

##### (3) 设置user2用户连接数100

```sql
-- 考生作答
hcie5=# alter user user2 connection limit 100;
ALTER ROLE
hcie5=# select rolname,rolconnlimit from pg_roles where rolname = 'user2';
 rolname | rolconnlimit
---------+--------------
 user2   |          100
```

##### (4) 查询postgres数据库连接上限，显示库和上限数据

```sql
-- 考生作答
select datname,datconnlimit from pg_database where datname = 'postgres';
 datname  | datconnlimit
----------+--------------
 postgres |           -1
(1 row)
```

##### (5) 查询postgres数据库中用户已经使用的会话数量

```sql
-- 已经使用的会话--之前不知道如何处理
select count(datname) from pg_stat_activity where datanme = 'postgres';
-- 结果
hcie5=# select count(datname) from pg_stat_activity where datname = 'postgres';
 count
-------
     7
(1 row)

-- 查询已经结束的会话数量
select count(datname) from pg_stat_activity where datname = 'postgres' and state = 'idle';
```

##### (6) 查询所有用户已经使用的会话连接数

```sql
-- 这个也不知。。。。
select count(datname) from pg_stat_activity;
```

##### (7) 查询库的最大连接数

```sql
-- 
hcie5=# show max_connections;
 max_connections
-----------------
 1000
(1 row)
```

##### (8) 查询会话状态，显示datid,pid和state

```sql
-- 
hcie5=# select datid,pid,state from pg_stat_activity;
 datid |       pid       | state
-------+-----------------+--------
 65618 | 140513148008192 | active
 15707 | 140514016884480 | idle
 15707 | 140514049914624 | active
 15707 | 140514106013440 | active
 15707 | 140514158442240 | idle
 15707 | 140514125412096 | idle
 15707 | 140514198243072 | idle
 15707 | 140514248587008 | active
```

#### 4. 安全审计

##### (1) 创建用户user3,密码是'test@123'

```sql
create user user3 password 'test@123';
-- 结果
hcie5=# create user user3 password 'test@123';
CREATE ROLE
```

##### (2) 给用户授予查看审计权限

```sql
-- 作答区
hcie5=# alter user user3 with auditadmin;
ALTER ROLE
```

##### (3) 登录postgres， 创建统一审计策略adt1,对所有数据库执行create审计操作

```sql
openGauss=# create audit policy adt1 privileges create;
CREATE AUDIT POLICY
```

##### (4) 登录postgres, 创建审计策略adt2,对所有数据库执行select审计操作

```sql
create audit policy adt2 access select;
CREATE AUDIT POLICY
```

##### (5) 创建postgres, 创建表tb1,创建审计策略adt3,仅审计记录用户root,在执行针对表tb1资源进行select,insert,delete操作数据库创建审计策略

```sql
-- 1. create table
create table tb1(c1 int);
-- 2. create resource label
create resource lable rls_adt3 add table(tb1);
-- 3. create audit polic
create audit policy adt3 access select on label(rls_adt3),insert on label(),delete on label() filter on roles(root);
```

##### (6) 为统一审计对象adt1,增加描述'audit policy for tb1'

```sql
openGauss=# alter audit policy adt1 comments 'audit policy for tb1'; -- 内容只能用单引号？
```

##### (7) 修改adt1，使之对地址IP地址为'10.20.30.40'的场景生效

```sql
alter audit policy adt1 modify (filter on ip('10.20.30.40'));
ALTER AUDIT POLICY
```

##### (8) 禁用统一审计策略adt1

```sql
alter audit policy adt1 disable;
```

##### (9)  删除审计策略adt1 adt2 adt3 和相应的资源标签，联级删除用户user3

```sql
openGauss=# drop audit policy adt1;
DROP AUDIT POLICY
openGauss=# drop audit policy adt2;
DROP AUDIT POLICY
openGauss=# drop audit policy adt3;
drop resource label rl_for_adt3;
DROP AUDIT POLICY
drop user user3 cascade;
```

#### 5. 存储过程

##### 基于以下表信息，完成以下实验要求

```sql
-- create table
CREATE TABLE APS_STUDENTS(
	LOGID SERIAL,
    STARTTIME TIMESTAMP(0) NOT NULL,
    PRIMARY KEY(LOGID)
);
```

##### (1) 编写存储过程，生成记录，传入学生个数，学生LOGID从1000000开始，starttime为当前时间

```sql
-- 考生作答
create or replace procedure generate_stu(num int) as
begin
	for i in 1000000 .. 1000000+num-1 loop
		insert into APS_STUDENTS values(i,sysdate);
	end loop;
end;
/
```

##### (2) 用上一操作初始化90000个学生

```sql
-- 考生作答
hcie5=# call generate_stu(90000);
 generate_stu
--------------
```

##### (3) 查询出aps_students表中初始化学生个数

```sql
-- 考生作答
hcie5=# select count(*) from aps_students;
 count
-------
 90000
(1 row)
```

#### 6. 触发器

本题根据教授详情表和部门表完成相应触发器创建使用

```sql
-- create table 
CREATE TABLE TEACHER(
	ID INTEGER PRIMARY KEY,
    NAME VARCHAR(50) NOT NULL,
    DEPID INTEGER NOT NULL,
    TETLE VARCHAR(50) NOT NULL
);

CREATE TABLE DEPARTMENT(
	ID INTEGER PRIMARY KEY,
    NAME VARCHAR(50) NOT NULL,
    NUMBER_OF_SENIOR INTEGER DEFAULT 0);
    
-- IMPORT DATA
insert into DEPARTMENT values(1,'physical',0),(2,'math',0),(3,'chem',0);

insert into teacher values(1,'tom',1,'associate professor'),(2,'bill',1,'professor'),(11,'eiston',3,'associate professor');
```

##### (1) 创建Tri_update_D 触发器，如果修改Number_of_senior字段时提示"不能随便修改部门教授职称人数"，如果已经有和Tri_update_D触发器，则删除后再重新删除

```sql
-- 考生作答
create or replace function notice() returns trigger as 
$$
begin
	raise notice '不能随便修改部门教授职称人数';
	return null;
end;
$$language plpgsql;

-- 下面是'for each row' 和 'for each statement'的区别结果对比

DROP TRIGGER IF EXISTS Tri_update_D ON department;
create trigger Tri_update_D after update on department for each row execute procedure notice();

hcie2=# update department set number_of_senior = 1;
NOTICE:  不能随便修改部门教授职称人数
NOTICE:  不能随便修改部门教授职称人数
NOTICE:  不能随便修改部门教授职称人数


create trigger Tri_update_D before update of number_of_senior on department for each row execute procedure notice();

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

##### (2) 禁止触发器，修改DEPARTMENT表中ID=1的NUMBER_OF_SENIOR=10,并查出表中数据

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

##### (3) 启动触发器，修改DEPARTMENT表中ID=1的NUMBER_OF_SENIOR=20,并查出表中数据

```sql
-- 考生作答
-- 当触发器存在时会将触发器删除
drop trigger if exists DEPARTMENT on DEPARTMENT;
-- drop trigger if exists trigger name on tablename;
-- drop trigger if exists triggername on tablename;
hcie2=# alter table department enable trigger Tri_update_D;
ALTER TABLE
hcie2=# update department set number_of_senior = 20 where id =1;
NOTICE:  不能随便修改部门教授职称人数
UPDATE 1
hcie2=# 
```

#### 7. 性能调优

##### 通常的SQL优化会通过参数调优的方式进行调整，例如如下参数

```sql
set enable_fast_query_shipping = off;
set enable_stream_operator = on;
```

##### 根据以下表完成数据库优化

```sql
-- create table
create table tb_user(
    stu_no int,
    stu_name varchar(32),
    age int,
    hobby_type int) distribute by hash(age);
-- insert into data
insert into tb_user select id, 
'xiaoming'||random()*60+10::int,
(random()*60+10)::int,
(random()*5+1)::int from (select generate_series(1,100000)) tb_user;
```

#####  (1) 收集tb_user的统计信息

```sql
-- 考生作答
analyze tb_user;
```

##### (2) 为下面两个查询创建索引，让执行计划和索引最为合理

```sql
SQL1： explain analyze select * from tb_user where age = 29 and stu_name = 'xiaoming';
SQL2:  explain analyze select * from tb_user where stu_no = 100 and age = 29;
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

##### (3) 在上题目的基础上，用3种不同方式使如下SQL不走索引

```sql
explain analyze select * from tb_user where stu_no =100 and age =29;
```

```sql
-- 作答区
-- 考生作答
-- 方法1. 通过hint干预优化不走索引
SQL1: 
explain analyze 
select
	/* + tablescan(tb_user) */tb_user.age,tb_user.stu_name 
from
	tb_user 
where 
	age = 29
and 
	stu_name = 'xiaoming';
SQL2:
explain analyze 
select
	/* + tablescan(tb_user) */ tb_user.stu_no,tb_user.age 
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



