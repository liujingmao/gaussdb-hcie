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
```

##### (2) 由于每栋楼各个年龄段的人都有，帮按age年龄分组[0-18),[18-35),[35-55),[55-+oo)形成age_group字段，每组命名group1,group2,group3,group4

##### (3) age_group 按每组人数排序，查询出age_group、人数，最大年龄，最小年龄，平均年龄(平均年龄向下取整)

##### (4) 由于需要每天送食物，增加如下年龄段所需要实物营养表，需要统计出该小区每天总营养值 

```sql
create table nutrition(age_group varchar(20),nutrition_value int);
insert into nutritioin values('group1',5),('group2',7),('group3',6),('group4',5);
```

##### (5) 按第栋求出每栋楼所需要的营养值 

##### 2. 数据库对象管理及SQL语法2

##### 3. 数据库连接

##### (1) 创建user2用户，user2用户需要具备创建数据库的权限 

##### (2) 查询用户的连接数上限

##### (3) 设置user2用户连接数100

##### (4) 查询postgres数据库连接上限，显示库和上限数据

##### (5) 查询postgres数据库中用户已经使用的会话数量

##### (6) 查询所有用户已经使用的会话连接数

##### (7) 查询库的最大连接数

##### (8) 查询会话状态，显示datid,pid和state

#### 4. 安全审计

##### (1) 创建用户user3,密码是'test@123'

##### (2) 给用户授予查看审计权限

##### (3) 登录postgres， 创建统一审计策略adt1,对所有数据库执行create审计操作

##### (4) 登录postgres, 创建审计策略adt2,对所有数据库执行select审计操作

##### (5) 创建postgres, 创建表tb1,创建审计策略adt3,仅审计记录用户root,在执行针对表tb1资源进行select,insert,delete操作数据库创建审计策略

##### (6) 为统一审计对象adt1,增加描述'audit policy for tb1'

##### (7) 修改adt1，使之对地址IP地址为'10.20.30.40'的场景生效

##### (8) 禁用统一审计策略adt1

##### (9)  删除审计策略adt1 adt2 adt3 和相应的资源标签，联级删除用户user3

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
```

##### (2) 用上一操作初始化90000个学生

```sql
-- 考生作答
```

##### (3) 查询出aps_student表中初始化学生个数

```sql
-- 考生作答
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
```

##### (2) 禁止触发器，修改DEPARTMENT表中ID=1的NUMBER_OF_SENIOR=10,并查出表中数据

```sql
-- 考生作答
```

##### (3) 启动触发器，修改DEPARTMENT表中ID=1的NUMBER_OF_SENIOR=20,并查出表中数据

```sql
-- 考生作答
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
```

##### (2) 为下面两个查询创建索引，让执行计划和索引最为合理

```sql
SQL1： explain analyze select * from tb_user where age = 29 and stu_name = 'xiaoming';

SQL1: explain analyze select * from tb_user where stu_no = 100 and age = 29;
```

```sql
-- 考生作答
```

##### (3) 在上题目的基础上，用3种不同方式使如下SQL不走索引

```sql
explain analyze select * from tb_user where stu_no =100 and age =29;
```

```sql
-- 考生作答
```



