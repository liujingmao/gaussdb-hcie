### 第一套练习题目

#### 1. 创建表和导入数据

```sql
-- create table and load data
--
-- openGauss database dump
--

SET statement_timeout = 0;
SET xmloption = content;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: course; Type: TABLE; Schema: public; Owner: omm; Tablespace:
--

CREATE TABLE course (
	cid character varying(10),
	cname character varying(10),
	teid character varying(10)
)
WITH (orientation=row, compression=no);


ALTER TABLE public.course OWNER TO omm;

--
-- Name: score; Type: TABLE; Schema: public; Owner: omm; Tablespace:
--

CREATE TABLE score (
	sid character varying(10),
	cid character varying(10),
	score numeric(18,1)
)
WITH (orientation=row, compression=no);

ALTER TABLE public.score OWNER TO omm;

--
-- Name: student; Type: TABLE; Schema: public; Owner: omm; Tablespace:
--

CREATE TABLE student (
	sid character varying(10),
	sname character varying(10),
	sbirthday timestamp(0) without time zone,
	ssex character varying(10)
)
WITH (orientation=row, compression=no);


ALTER TABLE public.student OWNER TO omm;

--
-- Name: teacher; Type: TABLE; Schema: public; Owner: omm; Tablespace:
--

CREATE TABLE teacher (
	teid character varying(10),
	tname character varying(10)
)
WITH (orientation=row, compression=no);


ALTER TABLE public.teacher OWNER TO omm;

--
-- Data for Name: course; Type: TABLE DATA; Schema: public; Owner: omm
--

COPY course (cid, cname, teid) FROM stdin;
01	Chinese	02
02	Math	01
03	English	03
\.
;


--
-- Data for Name: score; Type: TABLE DATA; Schema: public; Owner: omm
--

COPY score (sid, cid, score) FROM stdin;
01	01	80.0
01	02	90.0
01	03	99.0
02	01	70.0
02	02	60.0
02	03	80.0
03	01	80.0
03	02	80.0
03	03	80.0
04	01	50.0
04	02	30.0
04	03	20.0
05	01	76.0
05	02	87.0
06	01	31.0
06	03	34.0
07	02	89.0
07	03	98.0
\.
;

--
-- Data for Name: student; Type: TABLE DATA; Schema: public; Owner: omm
--


COPY student (sid, sname, sbirthday, ssex) FROM stdin;
01	Bobby	1990-01-01 00:00:00	Male
02	Jeff	1990-12-21 00:00:00	Male
03	Kenny	1990-12-20 00:00:00	Male
04	Andy	1990-12-06 00:00:00	Male
05	Elaine	1991-12-01 00:00:00	Female
06	Megan	1992-01-01 00:00:00	Female
07	Gina	1989-01-01 00:00:00	Female
09	Eva	2017-12-20 00:00:00	Female
10	Fiona	2017-12-25 00:00:00	Female
11	Lucy	2012-06-06 00:00:00	Female
12	Susan	2013-06-13 00:00:00	Female
13	Jessica	2014-06-01 00:00:00	Female
\.
;

--
-- Data for Name: teacher; Type: TABLE DATA; Schema: public; Owner: omm
--

COPY teacher (teid, tname) FROM stdin;
01	Mr.Smith
02	Mr.Lee
03	Miss.Grace
\.
;

--
-- Name: public; Type: ACL; Schema: -; Owner: omm
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM omm;
GRANT CREATE,USAGE ON SCHEMA public TO omm;
GRANT USAGE ON SCHEMA public TO PUBLIC;


--
-- openGauss database dump complete
--

```

##### (1) 查询student表中Kenny的信息。

```sql
mydb=# 
select 
	* 
from 
	student 
where 
	sname = 'Kenny';
 sid | sname |      sbirthday      | ssex 
-----+-------+---------------------+------
 03  | Kenny | 1990-12-20 00:00:00 | Male
(1 row)
```

##### (2) 查看student表中学生的数量。

```sql
mydb=# 
select 
	count(1) 
from 
	student;
 count 
-------
    12
(1 row)
```

##### (3) 查看student表中男生和女生分别人数是多少。

```sql
mydb=# 
select 
	ssex,count(ssex) 
from 
	student 
group by 
	ssex 
order by 
	count;
  ssex  | count 
--------+-------
 Male   |     4
 Female |     8
(2 rows)
```

##### (4) 查询student表中2012年出生的学生信息。提示：可使用to_char()函数，转换student表中的sbirthday成为字符类型。

```sql
mydb=# 
select 	
	sid,
	sname,
	to_char(sbirthday),
	ssex 
from 
	student 
where 
	to_char 
like '2012%';

 sid | sname |       to_char       |  ssex  
-----+-------+---------------------+--------
 11  | Lucy  | 2012-06-06 00:00:00 | Female
 
 老师给的参考答案
select 
	sid,
	sname,
	to_char(sbirthday),
	ssex
from 
    student 
where 
    to_char(sbirthday,'yyyy')='2012'; -- to_char()函数的使用
    -- 第一个参数是某个字段 ，
    -- 第二个参数是字段的pattern
    -- 第三个是"="后面接的题目中
myhcie=# 
select 
		sid,
		sname,
		to_char(sbirthday),
		ssex 
from 
		student 
where 
		to_char(sbirthday,'yyyy')='2012';
		
select sid,sname,to_char(sbirthday) from student where to_char(sbirthday,'yyyy')='2012';
			
 sid | sname |       to_char       |  ssex
-----+-------+---------------------+--------
 11  | Lucy  | 2012-06-06 00:00:00 | Female
(1 row)
```

##### (5) 查看student表中姓名为“Megan”的学号sid和总成绩。

```sql
mydb=# 
-- 方法1. 子查询 
select 
	sid,
	sum(score) 
from 
	score  
where 
	sid 
in 
	(select sid from student where sname='Megan') -- 字查询过滤会影响性能吗？
group by 
	sid;
 sid | sum  
-----+------
 06  | 65.0
(1 row)
方法2 join on
select 
	t1.sid,
	sum(t1.score) 
from 
	score t1 
join 
	(select * from student where sname = 'Megan') t2 
on 
	t1.sid = t2.sid 
group by 
	t1.sid;
 sid | sum
-----+------
 06  | 65.0
 
 方法3  
select 
	t1.sid,
	sum(t1.score) 
from
	score t1,
	student t2 
where 
	t1.sid = t2.sid 
and 
	t2.sname = 'Megan'
group by 
	t1.sid ;
 sid | sum
-----+------
 06  | 65.0
```

##### (6) 查看考试总分数大于190分的同学姓名和总分数，并且按照总分数由高到低降序排列

```sql
mydb=# 
select 
	t3.sname,
	t4.s1 
from 
	student t3
right join 
	(select 
     		t.sid,
     		t.s as s1 
     from 
     		(select sid,sum(score) as s  from score  group by sid order by s desc) t where s1 > 190) t4
on t3.sid = t4.sid order by s1 desc;
 sname |  s1   
-------+-------
 Bobby | 269.0
 Kenny | 240.0
 Jeff  | 210.0
(3 rows)

老师给的参考
select 
	s1.sname,   -- 需要查询的字段1
	sum(s2.score) as ts -- 需要查询的结果 as 搞一个别名
from 
	student s1,  -- 表1
	score s2 	 -- 表2
where 
	s1.sid = s2.sid  -- 两个表的连接条件
group by 
	s1.sname  -- 分组
having ts > 190  -- 相当于过滤筛选条件
order by ts desc; -- 排序

myhcie=# select s1.sname,sum(s2.score) as ts from student s1,score s2 where s1.sid = s2.sid group by s1.sname having ts > 190 order by ts desc;
 sname |  ts
-------+-------
 Bobby | 269.0
 Kenny | 240.0
 Jeff  | 210.0
 
select 
 	t1.sname,
 	sum(score) as ts 
 from 
 	student t1,
 	score t2,course t3 
 where 
 	t1.sid = t2.sid 
 and 
 	t2.cid = t3.cid 
 group by 
 	t1.sname 
 having ts > 190 
 order by ts desc;
 sname |  ts
-------+-------
 Bobby | 269.0
 Kenny | 240.0
 Jeff  | 210.0
```

##### (7) 查询课程为Math且高于87分的学生姓名和分数

```sql
select
	t1.sname,
	t2.score 
from 
	student t1,
	score t2,
	course t3 
where 
	t1.sid = t2.sid 
and 
	t2.cid = t3.cid 
and 
	t3.cname = 'Math' 
and t2.score > 87;
 sname | score
-------+-------
 Bobby |  90.0
 Gina  |  89.0
```
