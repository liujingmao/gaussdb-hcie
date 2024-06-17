### 高斯IE第八套

#### 1. SQL应用1

##### 请基于以下代码创建表及插入数据，并完成以下要求

```sql
-- create table
drop table if exists student;
drop table if exists class;
create table student(sno int,sname varchar(20),score int,month int,cno int);
-- score表示当月月考总分，月考总分为NULL,说明当月缺考
create table class(cno int,cname varchar(20));

-- insert data
insert into class values(1,'class1'),(2,'class2');

insert into student values(1,'Lee',610,1,1),(2,'Jerry',510,1,1),(5,'Lee',410,1,1),(3,'Tom',400,1,2),(4,'Jack',300,1,2),(6,'Jacy',NULL,1,2),(1,'Lee',410,2,1),(2,'Jerry',510,2,1),(5,'Lee',210,2,1),(3,'Tom',600,2,2),(4,'Jack',300,2,2),(6,'Jacy',510,2,2),(1,'Lee',410,3,1),(2,'Jerry',510,3,1),(5,'Lee',NULL,3,1),(3,'Tom',NULL,3,2),(4,'Jack',300,3,2),(6,'Jacy',410,3,2);
```

##### (1) 输出每月月考部分都比学号为5的同学分数高的所有学生信息

```sql
select 
	* 
from 
	student 
where 
	month =1 
and 
	score > (select score from student where sno = 5 and month = 1) 
union all 
	( select 
     	* 
     from 
    	 student 
     where month =2 
     and 
     	score > (select score from student where sno = 5 and month = 2));
```

##### (2) 输出每次月考缺考的学生信息，要求打印姓名、班级编号和缺考次数

```sql
```



##### (3) 输出每次月考和tom同时缺考的所有学生信息，要求打印学号、姓名和月考部分

##### (4) 输出全校月考中位数分数

##### (5) 统计每个班月考的最高分数，要求打印班级名称，考试时间和月考次数

#### 2. SQL应用2

##### 同上表

##### (1) 输出class1班级中比班级class2班级每月月考最低分还低的学生信息，要求打印学号、姓名和月考部分。

##### (2) 打印月考总分平均最高的学生信息，输出 学号，姓名和月考总分平均分

##### (3) 输出每个学生月考平均分和最高月考平均分学生之间的分数差距，打印学号、姓名、月考平均分和差距分数。

#### 3. SQL应用3

##### 基于以下学生成绩表，完成以下实验要求

```sql
-- 创建表
create table stu(
	id int,
    math int,
    art int,
    phy int,
    music int
);
-- 导入数据
insert into stu values(1,60,33,66,86);
insert into stu values(2,61,53,86,75);
insert into stu values(3,70,63,66,53);
insert into stu values(4,90,63,76,65);
insert into stu values(5,59,69,79,95);
insert into stu values(6,63,73,66,36);
insert into stu values(7,61,53,88,75);
insert into stu values(8,74,63,64,53);
insert into stu values(9,40,83,78,35);
insert into stu values(10,59,49,89,65);
```

##### (1) 求math,phy总成绩以及art,music的总成绩

```sql
-- 考生作答
select id,(math+phy) as sum_mp,(art+music) as sum_am from stu;
 id | sum_mp | sum_am
----+--------+--------
  1 |    126 |    119
  2 |    147 |    128
  3 |    136 |    116
  4 |    166 |    128
  5 |    138 |    164
  6 |    129 |    109
  7 |    149 |    128
  8 |    138 |    116
  9 |    118 |    118
 10 |    148 |    114
```

##### (2) 计算学生总成绩，并基于总成绩排序

``` sql
-- 考生作答
select id,sum(math+art+phy+music) as g from stu group by id order by g desc;
 id |  g
----+-----
  5 | 302
  4 | 294
  7 | 277
  2 | 275
 10 | 262
  8 | 254
  3 | 252
  1 | 245
  6 | 238
  9 | 236
(10 rows)
```

##### (3) art和music总分排名前5名的总成绩加5分，查询最终的所有学生总成绩

```sql
-- 考生作答
select id,(math+art+phy+music+5) from stu where id in (select id from (select id,(art+music) as am from stu order by am desc limit 5));
```

#### 4. SQL应用4

##### 基于以下学生成绩表，完成以下实验要求

```sql
-- create table
create table scopes(student_id int,chinese int,math int,english int,music int);
-- load data
insert into scopes values(1,90,88,100,88);
insert into scopes values(2,88,88,100,99);
insert into scopes values(3,87,89,98,89);
insert into scopes values(4,91,88,76,99);
insert into scopes values(5,92,88,78,98);
insert into scopes values(6,93,88,76,87);
```

##### (1) 计算每个学生chinese和math总分，以及english和music总分。要求一条SQL语句实现，不能使用临时表

```sql
-- 考生作答
select (chinese+math) as cm,(english+music) as en from scopes;
 cm  | en
-----+-----
 178 | 188
 176 | 199
 176 | 187
 179 | 175
 180 | 176
 181 | 163
```

##### (2) 目前有一张权重表(各科有不同的权重，目前权重策略有2个),请算出每个学生结合权重的成绩总和。要求一条SQL语句实现，不能使用临时表。每个学生都对应权限成绩。

+ 权限表结构如下

  ```sql
  create table weight(weight_id int,chinese decimal(10,2),math decimal(10,2),english decimal(10,2), music decimal(10,2));
  
  insert into weight values(1,0.3,0.2,0.2,0.3);
  insert into weight values(2,0.2,0.1,0.3,0.4);
  ```

  ##### 最终效果如下：

  | 序号 | student_id | weight_id | weight_sum |
  | ---- | ---------- | --------- | ---------- |
  | 1    | 1          | 1         | 87.7       |
  | 2    | 1          | 2         | 67.7       |
  | 3    | 2          | 1         | 78.8       |
  | 4    | 2          | 2         | 88.7       |

  ```sql
  -- 考生作答
   select s.student_id,w.weight_id,(w.chinese*s.chinese+w.math*s.math+w.english*s.english+w.music*s.music) as weight_sum from scopes s,weight w;
   student_id | weight_id | weight_sum
  ------------+-----------+------------
            1 |         1 |      91.00
            1 |         2 |      92.00
            2 |         1 |      93.70
            2 |         2 |      96.00
            3 |         1 |      90.20
            3 |         2 |      91.30
            4 |         1 |      89.80
            4 |         2 |      89.40
            5 |         1 |      90.20
            5 |         2 |      89.80
            6 |         1 |      86.80
            6 |         2 |      85.00
  ```

##### (3) 结合上面的结果，将一个学生对应的两个权重成绩，合到一行。要求一条SQL语句实现，不能使用临时表

**最终效果如下：**

| 序号 | student_id | weight_sum1 | weight_sum2 |
| ---- | ---------- | ----------- | ----------- |
| 1    | 1          | 87.7        | 67.7        |
| 2    | 2          | 78.8        | 66.7        |

```sql
-- 考生作答

select * from (select s.student_id,w.weight_id,(w.chinese*s.chinese+w.math*s.math+w.english*s.english+w.music*s.music) as weight_sum from scopes s,weight w) where weight_id=1;
 student_id | weight_id | weight_sum
------------+-----------+------------
          1 |         1 |      91.00
          2 |         1 |      93.70
          3 |         1 |      90.20
          4 |         1 |      89.80
          5 |         1 |      90.20
          6 |         1 |      86.80
         

moniti8=# select * from (select s.student_id,w.weight_id,(w.chinese*s.chinese+w.math*s.math+w.english*s.english+w.music*s.music) as weight_sum from scopes s,weight w) where weight_id=2;
 student_id | weight_id | weight_sum
------------+-----------+------------
          1 |         2 |      92.00
          2 |         2 |      96.00
          3 |         2 |      91.30
          4 |         2 |      89.40
          5 |         2 |      89.80
          6 |         2 |      85.00
(6 rows)

-- Ans
 select t1.student_id,t1.weight_sum as weight_sum1,t2.weight_sum as weight_sum2 from (select * from (select s.student_id,w.weight_id,(w.chinese*s.chinese+w.math*s.math+w.english*s.english+w.music*s.music) as weight_sum from scopes s,weight w) where weight_id=1) t1 left join (select * from (select s.student_id,w.weight_id,(w.chinese*s.chinese+w.math*s.math+w.english*s.english+w.music*s.music) as weight_sum from scopes s,weight w) where weight_id=2) t2 on t1.student_id = t2.student_id;
(6 rows)

select t1.student_id,t1.weight_sum as weight_sum1,t2.weight_sum as weight_sum2 from (select * from (select s.student_id,w.weight_id,(w.chinese*s.chinese+w.math*s.math+w.english*s.english+w.music*s.music) as weight_sum from scopes s,weight w) where weight_id=1) t1 left join (select * from (select s.student_id,w.weight_id,(w.chinese*s.chinese+w.math*s.math+w.english*s.english+w.music*s.music) as weight_sum from scopes s,weight w) where weight_id=2) t2 on t1.student_id = t2.student_id;
 student_id | weight_sum1 | weight_sum2
------------+-------------+-------------
          1 |       91.00 |       92.00
          2 |       93.70 |       96.00
          3 |       90.20 |       91.30
          4 |       89.80 |       89.40
          5 |       90.20 |       89.80
          6 |       86.80 |       85.00
(6 rows)

moniti8=#

```

##### (4)按照两个权重成绩之和的大小，进行从大到小排序，且生成排序序号，要求生成连续排序序号，相同的值有相同的序号。一条SQL语句实现，不能使用临时表。

**最终效果如下**

| student_id | weight_sum1 | weight_rank | weight_sum2 | weight_rank |
| ---------- | ----------- | ----------- | ----------- | ----------- |
| 1          | 87.7        | 1           | 67.7        | 1           |
| 2          | 78.8        | 2           | 66.7        | 2           |

```sql
-- 考生作答
```

#### 5. 性能优化1

##### 当前有一张表create table test(student_id,int,class_id int,kemu varchar2(20),score int); 有8w条数据

```sql
-- 插入数据
```

##### (1) 查202202班级同一科目成绩比202201班级最高分的同学，根据以下SQL优化重写。

```sql
-- 原SQL: 
select * from test where score > (select max(score) from test where class_id) and class_id = '202202';
```

#### 6. 性能优化2

##### 当前有三个表，分别是学生信息表student(sid,sname,sno)和202201班级成绩表score1(sid,course,score),202202班级成绩表score2(同score1)

#####  (1) 查202201班级和202202班级所有人语言成绩前10的记录，第一个查询要用union

```sql
-- 考生作答
```

##### (2) 对以下SQL语句进行优化

```sql
-- 考生作答
```

##### (3) 查看两个班级相同的科目，202201班级在202202中不存在的成绩，要求使用not in

```sql
-- 考生作答
```

##### (4) 对以上SQL语句进行优化

```sql
-- 考生作答
```

##### (5) 查询班级202201语文成绩最高的学生，要求先创建索引，并且能保证一定会使用索引 

```sql
-- 考生作答
```

##### (6) 查询202201班级的学生的成绩比202202班级的学生最高成绩还要大的学生信息，对以下给出的SQL进行改写

```sql
SQL: 
select 
	stu.sid,
	stu.sname,
	sum(score) sumscore 
from 
	student stu,
	score1 s1 
where
	stu.sid = s1.sid
group by
	stu.sid,
	stu.sname
having sumscore > (select 
                   		max(score) 
                   from (select 
                         	sum() score 
                         from 
                         	score2 
                         group by sid));
```

```sql
-- 考生作答
```

#### 7.  性能优化3

##### 基于学生表(sno,sname,cno),班级表(cno,cname),课程表(courid,courname),成绩表(sno,courid,score)完成关键查询

```sql
-- create table 
create table student(sno varchar(20),sname varchar(50),cno int);
create table class(cno int,cname varchar(50));
create table course(courid int,courname varchar(50));
create table score(sno varchar(20),courid int,score int);

-- insert data
insert into student values('1001','张三',1),('1002','李四',1),('1003','王五',2),('1004','赵六',2);
insert into class values(1,'1 班'),(2,'2 班');
insert into course values(1,'语文'),(2,'数学'),(3,'英语'),(4,'物理');

insert into score values('1001',1,84),('1001',1,64),('1001',2,86),('1001',2,94);
insert into score values('1001',3,84),('1001',3,56),('1001',4,48),('1001',4,84);
insert into score values('1002',1,83),('1002',1,85),('1002',2,46),('1002',2,74);
insert into score values('1002',3,65),('1002',3,76),('1002',4,56),('1002',4,98);
insert into score values('1003',1,86),('1003',1,74),('1003',2,88),('1003',2,54);
insert into score values('1003',3,86),('1003',3,76),('1003',4,67),('1003',4,76);
insert into score values('1004',1,100),('1004',1,100),('1004',2,87),('1004',2,86);
insert into score values('1004',3,69),('1004',3,67),('1004',4,84),('1004',4,92);
```



##### (1) 语文平均成绩大于80的所有成绩，输出班级名，学号(或班级号)，平均成绩，要求使用两where非相关的子查询 

```sql
-- 考生作答

-- create table student(sno varchar(20),sname varchar(50),cno int);
-- create table class(cno int,cname varchar(50));
-- create table course(courid int,courname varchar(50));
-- create table score(sno varchar(20),courid int,score int);
```

##### (2) 在上一题基础上，使用from查询优化

```sql
-- 考生作答
```

##### (3) 在上一题目基础上，使用父查询(消除子查询)

```sql
-- 考生作答
```

#### 8. 存储过程

##### 当前有一张表stu(sno,math,art,physical,cno)

```sql
create table stuv3(sno varchar(30),math float,art float,physical float,cno int);
insert into stuv3 values('1001',56,85,72,1),('1002',66,75,82,1),('1003',87,76,88,2);
```

##### (1) 查看学生每门成绩与每门平均成绩的差值

```sql
-- 考生作答
select t1.sno,(t1.math-t2.m) as diff_math_avgm,(t1.art-t2.a) as diff_art_avga,(t1.physical-t2.p) as diff_phy_avgp from stuv3 t1,(select avg(math) as m,avg(art) as a,avg(physical) as p from stuv3) t2;
```

##### (2) 编写存储过程，输入学生id和科目名称输出对应的绩点值，0-59 给0，60-69给0.1,70-79给0.2, 80-89给0.3,90-100给0.4

```sql
-- 考生作答
create or replace procedure get_grade_by_score(inputscore inout float) as
begin
	select (case when inputscore <=59 then 0 when inputscore <=69 then 0.1 when inputscore <=79 then 0.2 when inputscore <=89 then 0.3 when inputscore <=100 then 0.4 else -1 end) into inputscore;
end;
/

create or replace procedure fun_cal_point(id1 in varchar(20),coursename varchar(30),grade out float) as
begin
   	case when coursename='math' then select (get_grade_by_score(math)) into grade from stuv3 where sno=id1;
	when coursename='art' then select (get_grade_by_score(art)) into grade from stuv3 where sno=id1;
	when coursename='physical' then select (get_grade_by_score(physical)) into grade from stuv3 where sno=id1;
else raise notice 'please input right course name;';
end case;
end;
/
```

##### (3) 编写存储过程，根据学号，班级，获取学生的总分

```sql
-- 考生作答
create or replace procedure get_total_score_by_no_cno(id1 in varchar(20),cno1 in int,sum_score out int) as 
begin
	select (math+art+physical) into sum_score from stuv3 where sno = id1 and cno = cno1;
end;
/
-- create table stuv3(sno varchar(30),math float,art float,physical float,cno int);
```

#### 9. 触发器1

##### 本题根据以下表完成相应触发器创建使用

```sql
-- creat table
create table tab1(sname text,deptno int,salary float,title text);
create table dept(id int,dept_name text);
create table logger(sname text,dept_name text,log_date date);

-- import datas

insert into tab1 values('a',1,1000.00,'teacher'),('b',2,2000,'professor');
insert into dept values(1,'M'),(2,'C');
insert into logger('a','M',202304),('b','C',202202)
```

##### 创建触发器，要求在tab1表插入一行数据时，自动往logger表中插入一条记录，记录sname和部门名称，并用当天的日期来标记该行数的生成时间

##### (1) 创建触发器函数T_INS_TR

```sql
-- 考生作答
CREATE OR REPLACE FUNCTION T_INS_TR() RETURNS TRIGGER AS 
$$  
BEGIN  
    INSERT INTO logger(sname, dept_name, log_date) SELECT (NEW.sname,d.dept_name,sysdate) FROM dept d WHERE d.id = NEW.deptno;  
    RETURN NEW;  
END;  
$$
 LANGUAGE plpgsql;  
```

##### (2) 创建触发器T_INS_TR

```sql
-- 考生作答
CREATE TRIGGER T_INS_TR AFTER INSERT ON tab1 FOR EACH ROW EXECUTE procedure T_INS_TR();
```

##### (3) 禁用表tab1上的所有触发器

```sql
-- 考生作答

ALTER TRIGGER T_INS_TR ON tab1 DISABLE;

```

##### (4) 删除触发器T_INS_TR

```sql
-- 考生作答
DROP TRIGGER T_INS_TR
```



#### 10. 触发器2

##### 根据以下表完成相应触发器创建使用

```sql
-- create table 
create table stuv2(
	sid integer,
    sname character varying(20)
) with (orientation = row,commpression = no) distribute by hash(sid) to group group_version1;

create table selecttive(
	sid integer,
	course_name character varying(20)
) with (orientation = row,compression = no) distribute by hash(sid) to group group_version1;

-- 单节点db创建表
create table stuv2(
	sid integer,
    sname character varying(20)
);

create table selecttive(
	sid integer,
	course_name character varying(20)
);

-- 数据插入

insert into stuv2 values(1,'tom');
insert into stuv2 values(2,'marry');
insert into stuv2 values(3,'lzy');

insert into selecttive values(1,'数学');
insert into selecttive values(2,'语文');
insert into selecttive values(3,'英语');
```

##### 创建触发器，删除stu某一条数据，同时删除selecttive上的相关数据

##### (1) 创建触发器函数DELETE_STIVE

```sql
-- 考生作答
create or replace function DELETE_STIVE() returns trigger as 
$$
begin
	delete from selecttive where sid = old.sid;
	return old;
end;
$$language plpgsql;
```

##### (2) 创建触发器DELTE_SELECT_TRIGGER

```sql
-- 考生作答
create trigger DELTE_SELECT_TRIGGER before delete on stuv2 for each row execute procedure DELETE_STIVE();
```







