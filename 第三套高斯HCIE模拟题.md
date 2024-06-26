### 高斯IE第三套模拟题

#### 1. 数据库对象管理及SQL应用1

##### 基于以下学生成绩表，完成以下实验要求

```sql
-- 创建表
create table su(
	id int primary key not null, 
    firstname varchar(50) not null,
    familyname varchar(50) not null,
    shorterform varchar(50) not null,
    mark char(1) not null,
    score int not null
) distribute by replication;
-- 导入数据
insert into su values(1,'secebbie','peter','peter','S',86),
(2,'tom','jerry','tom','H',63),
(3,'amanda','lee','lee','H',67),
(4,'homas','brooke','homan','H',67),
(5,'elizabeth','katharine','elizabeth','H',67);
```

##### (1) 请查询姓名和姓氏，以姓名.姓氏的格式输出，要求首字母大写，姓名和姓氏之间使用"."拼接。

```sql
-- 考生作答
select 
	initcap(firstname||'.'||familyname) 
from 
	su;
select 
	initcap(concat(firstname,'.',familyname)) 
from 
	su;
```

##### (2) 插入一条新数据(2,'tom','jerry','tom','H',63),当出现主键冲突时，将主键修改为'F'

```sql
-- 考生作答
insert into su values(2,'tom','jerry','tom','H',63) on duplicate key update mark = 'F';
```

##### (3) 查询表，检查姓名是否是sec开头，展示姓名，判断结果result

```sql
-- 考生作答
select 
	firstname,
	(case when firstname like 'sec%' then 'T' else 'F' end) as result 
from 
	su;
```

##### (4) 查询表中所有列的数据，按照成绩进行排序，并显示名次(position),名次为连续的。要求展示所有字段，名字段position

```sql
-- 考生作答
select 
	*,
	dense_rank() over (order by score) as position 
from 
	su;
```

#### 2.  数据库对象管理及SQL应用2

#### 基于以下学生成绩事实表和维度表，完成以下实验要求

```sql
-- 创建表
create table student(
	student_id int,
    math int,
    phy int,
    art int,
    m2 int
);
-- 创建表
create table weight(
    weight_no int,
    math numeric,
    phy numeric,
    art numeric,
    m2 numeric
);

-- 插入数据
insert into student values(1,80,70,87,90);
insert into student values(2,80,70,87,90);
insert into student values(3,81,80,69,96);
insert into student values(4,89,86,89,93);
insert into student values(5,84,87,97,90);
insert into student values(6,89,79,88,91);
insert into student values(7,83,78,84,92);
insert into student values(8,84,79,89,93);
insert into student values(9,85,76,87,91);
insert into student values(10,90,90,84,93);

insert into weight values(1,0.4,0.3,0.2,0.1);
insert into weight values(2,0.1,0.2,0.3,0.4);
```

##### (1) 求math、phy 总成绩以及art m2的总成绩

```sql
-- 考生作答
select 
	student_id,
	(math+phy) as sum_m_p,
	(art+m2) as sum_a_m2 
from 
	student; 
```

##### (2) 根据维度表，按照两种加权算法计算出每个学生的加权成绩，展示student_id,weight_sum,单个学生加权成绩可以<u>*两行输出*</u> 

```sql
-- 考生作答
select 
	student_id,
	(s.math*w.math+s.phy*w.phy+s.art*w.art+s.m2*w.m2) as weight_sum 
from 
	student s,
	weight w;
```

##### (3) 根据维度表，按照两种加权算法计算出每个学生的加权成绩，展示包含student_id,weight_sum1,weight_sum2单个学生加权成绩要求*<u>一行输出</u>* 

```sql
-- 考生作答
select 
	w1.student_id,w1_sum,w2_sum 
from 
	(select 
     	s.student_id,
     	(s.math*w.math+s.phy*w.phy+s.art*w.art+s.m2*w.m2) as w1_sum 
     from 
     	student s,
     	weight w 
     where 
     	w.weight_no = 1) w1 
join 
	(select 
     	s.student_id,
     	(s.math*w.math+s.phy*w.phy+s.art*w.art+s.m2*w.m2) as w1_sum 
     from 
     	student s,
     	weight w 
     where 
     	w.weight_no = 2) w2 
on 
	w1.student_id = w2.student_id; 
```

##### (4) 对两种加权总成绩进行排序。要求输出格式student_id,weight1_sum,rank1,weight2_sum,rank2

```sql
-- 考生作答
select 
	t3.student_id,
	t3.weight_sum1,
	t3.rank1,
	t4.weight_sum2,
	t4.rank2 
from 
	(select t1.student_id,(t1.math*t2.math+t1.phy*t2.phy+t1.art*t2.art+t1.m2*t2.m2) as weight_sum1,dense_rank() over(partition by 1 order by weight_sum1 desc) as rank1 from student t1,weight t2 where weight_no=1) t3 
join
	(select t1.student_id,(t1.math*t2.math+t1.phy*t2.phy+t1.art*t2.art+t1.m2*t2.m2) as weight_sum2,dense_rank() over(partition by 1 order by weight_sum2 desc) as rank2 from student t1,weight t2 where weight_no=2) t4 
on 
	t3.student_id = t4.student_id;

select 
	t3.student_id,
	weight_sum1,
	dense_rank() over (partition by 1 order by weight_sum1 desc) as rank1,
	weight_sum2,
	dense_rank() over(partition by 1 order by weight_sum2 desc) as rank2 
from 
	(select t1.student_id,(t1.math*t2.math+t1.phy*t2.phy+t1.art*t2.art+t1.m2*t2.m2) as weight_sum1 from student t1,weight t2 where weight_no=1) t3 
join 
	(select t1.student_id,(t1.math*t2.math+t1.phy*t2.phy+t1.art*t2.art+t1.m2*t2.m2) as weight_sum2 from student t1,weight t2 where weight_no=2) t4 
on 
	t3.student_id = t4.student_id;
```



#### 3. 账本数据库

##### (1) 创建防篡改模式(schema)ledgernsp

```sql
-- 考生作答
create schema ledgernsp with blockchain;
```

##### (2) 创建防篡改用户表usertable(在ledgernsp这个schema下面创建)

```sql
-- 考生作答
create ledgernsp.usertable(id int,name text);
```

##### (3) 核验指定防篡改用户表的表级数据hash值与其对应历史表hash一致性

```sql
-- 考生作答
select ledger_hist_check('ledgernsp','usertable'); -- 这东西就只有记住了没有技巧可言
```

##### (4) 检验指定防篡改用户表对应的历史表hash与全局表对应的relhash一致性

```sql
-- 考生作答
select ledger_gchain_check('ledgernsp','usertable'); -- 这东西就只有记住了没有技巧可言
```

#### 4. 安全审计

##### (1) 用SQL查看审计是否打开

```sql
-- 考生作答
-- 方法1
show audit_enabled;
-- 方法2 
select 
	name,
	setting 
from 
	pg_settings 
where 
	name = 'audit_enabled';
```

##### (2)  用SQL查看日志存储的最大空间

```sql
-- 考生作答
-- 方法1
show audit_space_limit;
-- 方法2 基于gs_settings 系统视图查看
select 
	name,
	setting 
from 
	pg_settings 
where 
	name = 'audit_space_limit';
```

##### (3) 查看过去一天所有产生审计日志的总数，当前时间要求使用now()

```sql
-- 考生作答
select count(*) from pg_query_audit(now()-1,now());
```

##### (4) 查过去一天user1这个用户登录postgres数据库，当前时间要求使用now()

```sql
-- 考生作答
select 
	* 
from 
	pg_query_audit(now()-1,now()) 
where 
	type = 'login_success' 
and 
	username = 'user1' 
and 
	database = 'postgres';
```

##### (5)  删除't1'和't2'时间段的审计记录

```sql
-- 考生作答
select pg_delete_audit('t1','t2');
```

##### (6) 删除数据库DB2,级联删除用户user1

```sql
-- 考生作答
drop database DB2;
-- 级联删用户
drop user user1 cascade;
```

#### 5. 存储过程

##### 基于以下信息表，完成以下实验要求

```sql
-- 创建表
create table aps_students(
	logid serial,
    starttime timestamp(0) not null,
    primary key (logid)
);
```

##### (1) 编写存储过程，生成记录，传入学生个数，学生logid从100000开始，starttime为当前时间

```sql
-- 考生作答
create or replace procedure create_student_info(num int) as
begin
	for id in 100000..(100000+num-1) loop
		insert into aps_students values(id,now()); -- now() 使用sysdate也是ok的
	end loop;
end;
```

##### (2) 用上一操作初始化90000学生

```sql
-- 考生作答
call create_student_info(90000); -- 调用存储过程来初始化90000个学生
```

##### (3) 查出aps_student表中初始化学生的个数 

```sql
-- 考生作答
select count(*) from app_student;
```

#### 6. 触发器

##### 当前有两张表，一张是学生表student(id,name), 和分数表score(id,math,XX,xx), 

##### (1) 创建触发器，删除学生表中记录时，同步删除score中学生的记录

```sql
-- 考生作答
-- 创建触发器函数
create or replace function tri_delete_func() returns trigger as
$$
begin
	delete from score where id = old.id;
	return old;
end;
$$language plpgsql
-- 创建触发器
create trigger delete_trigger before delete on student for each row execute procedure tri_delete_func();
```

#### 7. 性能优化

##### 当前有一张表test(id,kemu,classid,grade)，该表有8万条数据

##### (1) 查202202班级里面语文化最低分，要保障走索引 

```sql
-- 考生作答
-- 1.收集统计表信息
analyze test;
-- 2.获取索引推荐
select * from gs_index_advise('select min(grade) from test where kemu = "yuwen" and classid="202202"');
-- 3.创建索引
create index index_kemu test(kemu);
create index index_classid test(classid);
-- 4.查202202班级里面语文化最低分
select min(grade) from test where kumu = "yuwen" and classid = "202202";
```

##### (2) 查202202班级同一科目成绩比202201班级最高分高的同学，根据以下SQL优化重写

**原生SQL**

```sql
select 
	* 
from 
	test t1
where 
	t1.classid='202202' 
and 
	grade < (select
             	min(grade) 
            from 
             	test t2 
             where 
             	t2.classid = '202201');
```

**优化后的SQL**

```sql
-- 考生作答
select 
	* 
from 
	test t1 
join 
	(select min(grade) as min_grade from test t2 where classid = 202201) t3 
on 
	t1.grade < t3.min_grade 
where 
	t1.classid = 202202;
-- Note: 原SQL中存在子查询，每扫描一次t1表，会遍历子查询结果，性能较差，改成join方式，消除子查询，查询时间从198ms缩短到85ms,性能得到提升。
```

#### 8. 论述

##### (1) 使用存储过程的优点，至少写4点

+ ###### 存储过程极大地提高**SQL**语言的**灵活性**，可以完成**复杂的运算**

+ ###### 可以保障数据的**安全性**和**完整性**

+ ###### **极大地改善SQL语句的性能**，在运行存储过程之前，数据库已经对其语法和句法分析，并给出优化执行方案。这种已经编译好的过程极大地改善了SQL的执行性能

+ ###### **可以降低网络的通信量**，客户端通过调用存储过程只需要存储过程名和传入相关参数即可，与传输SQL相比自然数据量少很多

##### (2) 存储过程和函数的区别

+ ###### **含义不同(概念不同)**

  + ###### **存储过程**: 是SQL语句和可控制流程语句的**预编译集合**

  + ###### **函数**:是有一个或者多个SQL语句组成的**子程序** 

+ ###### **使用条件不同**

  + ###### **存储过程**： 可以在单个存储过程中执行一系列SQL语句。而且可以从自己的存储过程内引入其他存储过程，这可以简化一系列复杂的语句；

  + ###### **函数**：自定义函数有着诸多限制，有许多语句不能使用，例如**临时表**

+ ###### **执行方式不同**

  + ###### **存储过程**：可以返回参数，如记录集，存储过程声明时不需要返回类型

  + ###### **函数**：只能返回值或者是表对象，声明时需要描述**(声明)返回类型**，且函数中必须包含一个有效的**return**语句。

##### (3) 存储过程和匿名块的区别,写2个

+ ###### **存储过程** 是经过预编译并存储在数据库的，可以重复使用的可控制流程语句的集合；而匿名块是未存储在数据库中，从应用程序缓存区擦除后，除非应用重新输入代码，否则无法重启执行；

+ ###### **匿名块** 不需要命名，存储过程必须申明名字

  



