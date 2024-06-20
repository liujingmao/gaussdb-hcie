### 高斯IE第九套

#### 1. 数据库对象管理及SQL应用

##### 当前有一张表test,请基于该表完成以下操作

```sql
drop table if exists test;
create table test(
	id int primary key,
    name varchar(50),a
    age int) distribute by hash(name);
    
 drop table if exists test;
create table test(
	id int primary key,
    name varchar(50),a
    age int);
 
-- import data
insert into test values(),(),(),(),();
```

##### (1) 请为name字段上创建索引

##### (2) 请查看数据在各个节点的分布情况，显示表名、节点名、数据量

##### (3) 删除主键索引

##### (4) 重建主键索引

##### (5) 对age列添加检查约束，要求只能写入大于18的值

##### (6)对name列添加非空约束

#### 2. 安全审计

##### (1) 请创建一个具有创建审计管理员用户hcie_audit

##### (2) 切换用户查看guc参数审计总开关是否开户

##### (3) 查看用户hcie_audit成功登录postgres的记录

##### (4) 统计一天内的审计数量要求用now()

##### (5) 删除指定时间的审计记录(如删除过去10min内的)

#### 3. 用户权限管理

##### 当前有一张表sjh_test(a int,b int)和角色sjh112，请给予当前环境完成以下用户及权限相关管理操作。

```sql
-- create table
create table sjh_test(a int,b int);
-- create role
create rolw sjh112 password 'Huawei@123';
```

##### (1) 创建用户sjh111

##### (2) 将表sjh_test的读取和删除权限授予给sjh111用户

##### (3) 为用户sjh111授权在sjh_test表的a,b列的查询、添加和更新权限

##### (4) 回收用户sjh111在sjh_test表的a,b列的查询、添加和更新权限

##### (5) 查看用户sjh111和数据库的相关权限，要求显示数据库名、用户名、数据库的权限

##### (6) 查询sjh_test的owner,要求显示表名和owner

##### (7) 查看sjh111的表权限，要求显示表名、schema名、用户名、相关表权限

##### (8) 查询对表sjh_test有操作权限的用户，要求显示：用户名、操作权限 

##### (9) 创建user3用户，密码'test@123'

##### (10) 当前有一张表t_test(id,name),有2w的数据，请授权只允许user3能看id=1的数据

##### (11)修改赋权能看id =1 或 id =2 的数据

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

insert into course values('c1','chinese'),('c2','math');
insert into score values('001',86,'c1'),('002',95,'c2');
```

##### (1) 编写存储过程，输入课程c1获取平均成绩、数据编号和课程名称，根据平均成绩获取成绩绩点：0-59给0分，60-69给0.1,70-79给0.2,80-89给0.3,90-100给0.4

```sql
-- 作答区
```

#### 5. 数据库优化

根据教师表teacher(老师编号，教师名),课程表course(课程名，任课老师编号、课程编号)，班级表class(班级名称、班级编号、学年)，分数表score(课程编号、分数、学生学号、班级编号)

##### 请根据以下表完成数据库优化

```sql
-- create table 
create table teacher(tno int,tname varchar(50));
create table course(courseno int,courname varchar(50),tno int);
create table class(cno varchar(50),cname varchar(50),xuenian varchar(50));
create table score(cno int,score int,stuno int,courseno int);
```

##### (1) 查询2020学年，语文平均成绩大于80的班级，打印班级名称及平均成绩，要求where条件里有两个非相关子查询 

##### (2) 优化上一步的语句，将where条件中的非相关的子查询改为from后边的范围表

##### (3) 优化上一步的语句，将from后面的子查询优化为父表的关联查询 





