### 高斯IE第九套

#### 1. 数据库对象管理及SQL应用

##### 当前有一张表test,请基于该表完成以下操作

```sql
drop table if exists test;
create table test(
	id int primary key,
    name varchar(50),a
    age int) distribute by hash(name); -- 单节点db去年distribute by hash();
    
drop table if exists test;
create table test(
	id int primary key,
    name varchar(50),
    age int);
 
-- import data
insert into test values(1,'zhangsan',45),
(3,'wangwu',22),(2,'lisi',56),(4,'zhaoliu',23),(5,'tom',45),
(6,'bob',25),
(7,'jack',26),
(8,'marry',27),(9,'mali',30);
```

##### (1) 请为name字段上创建索引

```sql
hcie9=# create index index_name on test(name);
CREATE INDEX
```

##### (2) 请查看数据在各个节点的分布情况，显示表名、节点名、数据量

```sql
-- 云主机上练习
select tablename,nodename,dnsize from table_distribution();
hcie9=# select tablename,nodename,dnsize from table_distribution();
ERROR:  unsupported view in single node mode.
-- 注意考试时的where 后面根据具体schemas和table传值查询
```

##### (3) 删除主键索引

```sql
-- 1. 查看约束名称
select 
	* 
from 
	pg_constraint t1,
	pg_class t2 
where 
	t1.conrelid = t2.oid
and 
	t2.relname = 'test';
	
-- 结果 
select conname from pg_constraint t1,pg_class t2 where t1.conrelid = t2.oid and t2.relname = 'test';
  conname
-----------
 test_pkey
(1 row)
	
-- 2. 删除主键索引，即删除主键约束
alter table test drop constraint test_pkey;

-- 结果 
hcie9=# 
select conname from pg_constraint t1,pg_class t2 where t1.conrelid = t2.oid and t2.relname = 'test';
 conname
---------
(0 rows)
```

##### (4) 重建主键索引(操作流程要熟悉)

```sql
-- 如果主键已经删除不存在了，重新创建
alter table test add constraint test_pkey primary key(id);

-- 重建整张表的索引
reindex table test;

-- 重建指定索引
alter index test_pkey rebuild;
reindex index test_pkey;
```

##### (5) 对age列添加检查约束，要求只能写入大于18的值

```sql
alter table add constraint test_age check(age>18);
```

##### (6)对name列添加非空约束

```sql
alter table test modify name not null;
```

#### 2. 安全审计

##### (1) 请创建一个具有创建审计管理员用户hcie_audit

```sql
-- 作答区
create user hcie_audit auditadmin poladmin password 'Huawei@123';
```

##### (2) 切换用户查看guc参数审计总开关是否开户

```sql
-- 作答区
show audit_enabled;

-- 或者是

 select name,setting from pg_settings where name like 'audit_ena%'
;
     name      | setting
---------------+---------
 audit_enabled | on

```

##### (3) 查看用户hcie_audit成功登录postgres的记录

```sql
select
	* 
from 
	pg_query_audit(now()- interval '1 hour',now()) 
where 
	username = 'hcie_audit' 
and 
	database = 'postgres'
and 
	type = 'login_success' 
and 
	result = 'ok';
```

##### (4) 统计一天内的审计数量要求用now()

```sql
select count(*) from pg_query_audit(now()-1,now());
```

##### (5) 删除指定时间的审计记录(如删除过去10min内的)

```sql
select pg_delete_audit(now() - interval '10 min',now()); -- select 直接加该函数
```

#### 3. 用户权限管理

##### 当前有一张表sjh_test(a int,b int)和角色sjh112，请给予当前环境完成以下用户及权限相关管理操作。

```sql
-- create table
create table sjh_test(a int,b int);
-- create role
create role sjh112 password 'Huawei@123';
```

##### (1) 创建用户sjh111

```sql
-- 作答区
create user sjh111 password 'Huawei@123';
```

##### (2) 将表sjh_test的读取和删除权限授予给sjh111用户

```sql
+ -- 普通用户只有public模式的权限，需要将当前schema使用权限授予给用户
grant usage on schema root to sjh111;
-- 作答区
grant select,delete on sjh_test to sjh111;
```

##### (3) 为用户sjh111授权在sjh_test表的a,b列的查询、添加和更新权限

```sql
-- 作答区
grant select(a,b),insert(a,b),update(a,b) on sjh_test to sjh111;
```

##### (4) 回收用户sjh111在sjh_test表的a列的查询、添加和更新权限

```sql
-- 作答区
revoke select(a),insert(a),update(a) on sjh_test from sjh111;
```

##### (5) 查看用户sjh111和数据库的相关权限，要求显示数据库名、用户名、数据库的权限(知识盲区)

```sql
-- 作答区
select 
	t1.*,
	rolname 
from 
	(select datname,(aclexplode(datacl)).grantee,(aclexplode(datacl)).privilege_type from pg_database) t1,
	pg_roles 
where 
	grantee = pg_roles.oid 
and 
	rolname = 'sjh111' 
and datname not like 'tempplate%';

```

##### (6) 查询sjh_test的owner,要求显示表名和owner

```sql
-- 作答区--pg_tables
select schemaname,tablename,tableowner from pg_tables where tablename = 'sjh_test'
;
 schemaname | tablename | tableowner
------------+-----------+------------
 public     | sjh_test  | omm
(1 row)
```

##### (7) 查看sjh111的表权限，要求显示表名、schema名、用户名、相关表权限(知识盲区)

```sql
-- 作答区-- information_schema.table_privileges
hcie9=# select table_name,table_schema,grantee,privilege_type from information_schema.table_privileges where grantee = 'sjh111';
 table_name | table_schema | grantee | privilege_type
------------+--------------+---------+----------------
 sjh_test   | public       | sjh111  | SELECT
 sjh_test   | public       | sjh111  | DELETE
```

##### (8) 查询对表sjh_test有操作权限的用户，要求显示：用户名、操作权限(知识盲区)

```sql
-- 作答区 -- information_schema.table_privileges
 select grantee,privilege_type from information_schema.table_privileges where table_name = 'sjh_test';
 grantee | privilege_type
---------+----------------
 omm     | INSERT
 omm     | SELECT
 omm     | UPDATE
 omm     | DELETE
 omm     | TRUNCATE
 omm     | REFERENCES
 omm     | TRIGGER
 sjh111  | SELECT
 sjh111  | DELETE
```

##### (9) 创建user3用户，密码'test@123'

```sql
-- 作答区
create user user3 password 'test@123';
```

##### (10) 当前有一张表t_test(id,name),有2w的数据，请授权只允许user3只能看id=1的数据

```sql
-- 作答区
grant select on t_test to user3;
alter table t_test enable row level security;
create row level security policy rls on t_test to user3 using(id=1);
```

##### (11)修改赋权能看id =1 或 id =2 的数据

```sql
-- 作答区
alter row level security policy rls on t_test to user3 using(id = 1 or id =2)
```

#### 4. 存储过程

**成绩表**

| 编号 | 成绩 | 课程 |
| ---- | ---- | ---- |
| 001  | 86   | c1   |
| 002  | 95   | c2   |

**课程表**

| 课程编号 | 课程名称 |
| -------- | -------- |
| c1       | chinese  |
| c2       | math     |

```sql
-- create table & 导入数据
create table course(cid varchar(20),cname varchar(50));
create table score(id varchar(20),score int, cid varchar(20));

-- insert datas

insert into course values('c1','chinese'),('c2','math');
insert into score values('001',86,'c1'),('002',95,'c2');

insert into score values('003',88,'c1'),('003',90,'c2');

```

##### (1) 编写存储过程，输入课程c1获取平均成绩、数据编号和课程名称，根据平均成绩获取成绩绩点：0-59给0分，60-69给0.1,70-79给0.2,80-89给0.3,90-100给0.4

```sql
-- 作答区
-- 编写存储过程，输入课程c1获取平均成绩、数据编号和课程名称，根据平均成绩获取成绩绩点：0-59给0分，60-69给0.1,70-79给0.2,80-89给0.3,90-100给0.4

-- create table course(cid varchar(20),cname varchar(50));
-- create table score(id varchar(20),score int, cid varchar(20));

-- insert into course values('c1','chinese'),('c2','math');
-- insert into score values('001',86,'c1'),('002',95,'c2');

create or replace procedure get_avgscore_scoreid_cname(
    courseid in varchar(20),
    avgescore out float,
    sid out varchar(20),
    coursename out varchar(50),
    grade out float) as 
begin 
	select round(avg(score),2) into avgescore from score where cid = courseid;
	select id into sid from score where cid = courseid;
	select cname into coursename from course where cid = courseid;
	case when avgescore<60 then grade = 0; 
		when avgescore<70 then grade = 0.1;
		when avgescore<80 then grade = 0.2;
		when avgescore<90 then grade = 0.3;
		when avgescore<=100 then grade = 0.4;
	end case;
end;
/
```

#### 5. 数据库优化

根据教师表teacher(老师编号，教师名),课程表course(课程名，任课老师编号、课程编号)，班级表class(班级名称、班级编号、学年)，分数表score(课程编号、分数、学生学号、班级编号)

##### 请根据以下表完成数据库优化

```sql
-- create table 
create table teacher(
    tno int,
    tname varchar(50)
);
create table course(
    courseno int,
    courname varchar(50),
    tno int);
create table class(
    cno varchar(50),
    cname varchar(50),
    xuenian varchar(50));
create table score(
    cno int,
    score int,
    stuno int,
    courseno int
);

-- insert data

insert into teacher values(1,'a');

insert into course values(1,'语文',1);

insert into class values('100','class1','2020');

insert into score values(100,88,20,1);


```

##### (1) 查询2020学年，语文平均成绩大于80的班级，打印班级名称及平均成绩，要求where条件里有两个非相关子查询 

```sql
select 
	t1.cname,
	round(avg(nvl(t2.score,0)),2) as avgscore 
from 
	class t1 
join 
	score t2 
on 
	t1.cno = t2.cno 
where 
	t1.cno 
in 
	(select cno from class where xuenian = '2020') 
and 
	t2.courseno = (select courseno from course where courname = '语文')
group by 
	t1.cname having avgscore > 80;
```

##### (2) 优化上一步的语句，将where条件中的非相关的子查询改为from后边的范围表

```sql
select 
	t1.cname,round(avg(nvl(t2.score,0)),2) as avgscore 
from 
	score t2 
join 
	(select * from class where xuenian = '2020') t1 
on
	t1.cno = t2.cno 
join 
	(select * from course where courname = '语文') t3 
on 
	t3.courseno =  t2.courseno 
group by 
	t1.cname having avgscore > 80;
```

##### (3) 优化上一步的语句，将from后面的子查询优化为父表的关联查询 

```sql
select 
	t1.cname,
	round(avg(nvl(t2.score,0)),2) as avgscore 
from 
	class t1,
	score t2,
	course t3 
where 
	t1.cno = t2.cno 
and 
	t3.courseno =  t2.courseno
and 
	t1.xuenian = '2020' 
and 
	t3.courname = '语文' 
group by 
	t1.cname having avgscore > 80;
```







