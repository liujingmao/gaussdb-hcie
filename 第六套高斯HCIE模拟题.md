#### 高斯IE第六套

##### 1. 数据库对象管理及SQL语法1

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
);

 insert into su values(1,'secebbie','peter','peter','S',86),
 (2,'tom','jerry','tom','H',63),
 (3,'amanda','lee','lee','H',67),
 (4,'homas','brooke','homas','H',67),
 (5,'elizeberth','katharine','elizabeth','H',67);
```

##### (1) 请查询姓名和姓氏，并以姓名和格式输出，要求首字母大写，姓名和姓氏之间使用'.'拼接

```sql
-- 
```

##### (2)插入一条数据(),当出现主键冲突时，将mark修改为'F'

```sql
--
```

##### (3) 查询表，检查姓名是否sec开关，展示姓名，判断结果为result.

```sql
-- 
```

##### (4) 查询表中所有列的数据，按照成绩进行排序，并显示名次(position),名次为连接的。要求展示所有字段，名字字段position

```sql
-- 
```

##### 2. 数据库对象管理及SQL语法2

##### 当前有一张订单表lineitem字段说明

```sql
--
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

##### (1) 创建分区表，根据上述字段信息表创建分区表，按L_SHIPDATE分区，按年分1993，1994，1995，1996，1997，1998，1999，分区名字分别是L_SHIPDATE_1,L_SHIPDATE_2,以此类推，使用L_ORDERKEY进行哈希分布，建表完成执行上方数据导入代码，进行数据导入

```sql
-- 
```

##### (2) 查询表的schema名称，展示表名，schema名称

```sql
-- 
```

##### (3) 查看表分布节点的oid,展示表名，nodeoids

```sql
-- 
```

##### (4)  查看表所在的实例的信息

```sql
-- 
```

##### 3. 用户及权限管理

##### (1) 使用两个查询语句，查看'postgres'数据库的最大连接数和已使用连接数

```sql
-- 
```

##### (2) 创建用户user_test,并指定该用户具有创建数据库和创建角色的权限 

```sql
-- 
```

##### (3) 创建表table_test,此表包含一个名为col_test的列，为用户user_test授权在table_test表的col_test列上的查询、更新权限

```sql
-- 
```

##### (4) 收回用户user_test在table_test列的更新权限

```sql
-- 
```

##### (5) 创建角色role_test,此角色拥有审计权限

```sql
-- 
```

##### (6) 将角色role_test的权限授权给用户user_test,并允许用户将此权限再授权给其他用户或者角色 

```sql
-- 
```

##### (7) 用户user_test账号被盗，请手动锁定此账号

```sql

```

##### (8) 级联删除用户user_test,并重新创建，将账号设置为在2023年国庆期间有效

```sql
-- 
```

##### 4. 行级访问控制

##### 基于以下SQL还原表和数据

```sql
-- 创建表
create table bank_card(
	b_number NCHAR(40) PRIMARY KEY,
    b_type NCHAR(20),
	b_c_id int not null
);
-- 创建用户
insert into bank_card values('00000000001','信用卡',1);
insert into bank_card values('00000000002','信用卡',3);
insert into bank_card values('00000000003','信用卡',5);
insert into bank_card values('00000000004','信用卡',7);
insert into bank_card values('00000000005','储蓄卡',9);
insert into bank_card values('00000000006','储蓄卡',1);
```

##### (1) 创建用户crecar_mger,savcard_mger,密码均为'Test@123'

```sql
-- 
```

##### (2) 给上题中创建的两个用户授予bank_card表的读取权限

```sql
-- 
```

##### (3) 打开bank_card表的行级访问控制开关

```sql
-- 
```

##### (4) 创建行级访问控制策略bank_card_rls,要求crecard_mger用户只能查看信用卡信息，sacard_mger用户只能查看储蓄卡信息。

```sql
-- 
```

##### (5) 切换到crecard_mger用户查看bank_card表的内容

```sql
-- 
```

##### (6) 使用root用户删除行级控制策略bank_card_rls,并关闭表的行级访问控制开关

```sql
-- 
```

##### 5. 触发器

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
```

#####  (1) 创建SELECT_SD，查看学生成绩信息，查看学生姓名，课程名称，课程成绩

```sql
-- 
```

#####  (2) 编写函数FUNC_SUM,根据传递的学生的学生编号或者姓名返回某个学生的分类总和

```sql
-- 
```

#####  (3) 创建触发器DELETE_ELE,在STUDENT表上绑定触发器DELETE_ELE，在删除表中某个学生时，将ELECTIVE表中该学生的选课记录一并删除

```sql
-- 
```

##### 6. 游标

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

#####  (1) 创建存储过程pro_curs_1,使用游标打印各部门总人数，按照人数降序排序，打印格式如下 ：部门名称1---人数部门名称2---人数打印操作可以使用DBE_OUTPUTPRINT_LINE(outputstr)接口

```sql
-- 
```



#####  (2) 创建存储过程pro_curs_2,使用游标读取薪水按降序排序的前三位老师和后三位老师的信息，分别获取ID，姓名，部门名称，薪水和职称，请按以下格式打印ID-姓名-部门名称-薪水-职称

```sql
--
```

##### 7. 性能调优

##### 通常的SQL优化会通过参数调优的方式进行调整，例如如下参数

```sql
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

##### (2) 为下面两个查询语句创建索引，让执行计划和索引最合理

```sql
SQL1: explain analyze select * from tb_user where age=29 and stu_name = 'xiaoming';
SQL2: explain analyze select * from tb_user where stu_no = 100 and age = 29;
```

```sql
-- 作答区
```

##### (3) 在上题的基础上，用3种不同的方式使如下SQL不走索引

```sql
explain analyze select * from tb_user where stu_no = 100 and age =29;
```

```sql
-- 作答区
```

##### 8. 论述题

##### (1) 权限管理模型RBAC和ABAC区别

##### (2) 数据库数据加密方式有哪些，至少3种



