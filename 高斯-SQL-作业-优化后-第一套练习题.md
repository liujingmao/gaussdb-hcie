```sql
1.查询student表中Kenny的信息。
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
2.查看student表中学生的数量。
mydb=# 
select 
	count(1) 
from 
	student;
 count 
-------
    12
(1 row)
3.查看student表中男生和女生分别人数是多少。
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
4.查询student表中2012年出生的学生信息。提示：可使用to_char()函数，转换student表中的sbirthday成为字符类型。
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

5.查看student表中姓名为“Megan”的学号sid和总成绩。
mydb=# 
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
6.查看考试总分数大于190分的同学姓名和总分数，并且按照总分数由高到低降序排列。
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
7.查询课程为Math且高于87分的学生姓名和分数
mydb=# 
select 
	t1.sname,
	t2.score 
from 
	(select 
     	sid,
     	cid,
     	score 
    from 
     	(select 
         	sid,
         	cid,
         	score 
         from 
         	score  
         where 
         	cid 
         in 
         	(select cid from course where cname = 'Math')) t where t.score > 87) t2 left join student t1 on t2.sid = t1.sid;
 sname | score 
-------+-------
 Bobby |  90.0
 Gina  |  89.0
(2 rows)

老师给的参考：
select 
	s1.sname,
	s2.score as ts
from 
	student s1,
	score s2,
	course c1 
where 
	s1.sid = s2.sid 
	and s2.cid = c1.cid -- 关联条件
and 
	c1.cname = 'Math' 
and 
	s2.score > 87; -- 多想想字段与要查询结果之间的结构
```





