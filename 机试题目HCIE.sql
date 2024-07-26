--1通用SQL查询
--两张表：
create table student(sno int ,sname varchar,score int ,cno int );
create table class(cno int ,cname varchar );
insert into student values(123, 'a', 456, 1);
insert into student values(124, 'b', 546, 1);
insert into student values(125, 'c', 548, 1);
insert into student values(126, 'd', 569, 1);
insert into student values(127, 'e', 540, 1);
insert into student values(128, 'f', 536, 2);
insert into student values(129, 'g', 512, 2);
insert into student values(130, 'h', 546, 2);
insert into student values(131, 'i', 508, 2);
insert into student values(132, 'j', 456, 2);
insert into class values(1, 'class1'),(2, 'class2');
--（1）简单查询，查询学号为130的学生的名字、总成绩以及所在班级
openGauss=> select s.*,b.cname from student s,class b where sno=130 and s.cno=b.cno;
 sno | sname | score | cno | cname  
-----+-------+-------+-----+--------
 130 | h     |   546 |   2 | class2
(1 row)
--（2）查看每个班级(cno)月考总分(score)前三名，其中要求分数相同的人具有相同的编号
openGauss=> select * from (select s.sno,s.sname,s.cno,dense_rank() over(partition by s.cno order by s.score desc) as ranking,c.cname from student s join class c on s.cno=c.cno) where ranking<=3;
 sno | sname | cno | ranking | cname  
-----+-------+-----+---------+--------
 126 | d     |   1 |       1 | class1
 125 | c     |   1 |       2 | class1
 124 | b     |   1 |       3 | class1
 130 | h     |   2 |       1 | class2
 128 | f     |   2 |       2 | class2
 129 | g     |   2 |       3 | class2
(6 rows)
--------------------------------------------------------------------------------------
--（1）如何查询表的模式名和表名
oracle=> select schemaname,tablename from pg_tables where tablename='student';
 schemaname | tablename 
------------+-----------
 jack       | student
(1 row)
--（2）表查询表的所在节点 nodeoids 信息 pgxc_class
postgres=# select nodeoids from pgxc_class p join pg_class c on p.pcrelid=c.oid where c.relname='student';
  nodeoids   
-------------
 16676 16683
(1 row)
--（3）查询表所在的节点实例信息 pgxc_node(需要分布式集群场景才能查到)
postgres=# select nodeoids from pgxc_class p join pg_class c on p.pcrelid=c.oid where c.relname='student';
  nodeoids   
-------------
 16676 16683
(1 row)

postgres=# select * from pgxc_node where oid in (16676,16683);
 node_name | node_type | node_port | node_host | node_port1 | node_host1 | hostis_primary | nodeis_primary | nodeis_preferred |   node_id   | sctp_port | control_port | sctp_port1 | control_port1 | nodeis_central 
-----------+-----------+-----------+-----------+------------+------------+----------------+----------------+------------------+-------------+-----------+--------------+------------+---------------+----------------
 dn_6001   | D         |     25330 | 10.0.0.71 |      25330 | 10.0.0.71  | t              | f              | f                |  1663988763 |     25334 |        25335 |          0 |             0 | f
 dn_6002   | D         |     25332 | 10.0.0.71 |      25332 | 10.0.0.71  | t              | f              | f                | -1870446040 |     25336 |        25337 |          0 |             0 | f
(2 rows)

--------------------------------------------------------------------------------------
--（1）创建用户
oracle=> create user abc identified by 'Gauss2023';
CREATE ROLE
--（2）用户赋权
oracle=> grant select,update on jack.student to abc;
GRANT
--（3）字段权限赋予
oracle=> grant select,update(sno,sname),delete on jack.student to abc;
GRANT
--（4）字段权限回收
oracle=> revoke select,update(sno,sname),delete on jack.student from abc;
REVOKE
--（5）创建角色并赋予审计管理
oracle=> create role abc with auditadmin identified by 'Gauss2023';
CREATE ROLE
--（6）将角色授予给用户
oracle=> grant abc to jack;
GRANT ROLE
--（7）创建用户并且设置有效期
oracle=> create user abc identified by 'Gauss2023' valid begin '2023-12-15 15:00:00' valid until '2222-12-15 15:00:00';
CREATE ROLE
--------------------------------------------------------------------------------------
--4 行级别访问控制
CREATE TABLE all_data(id int, role varchar(100), data varchar(100));
CREATE USER alice PASSWORD 'Huawei12#$%';
CREATE USER bob PASSWORD 'Huawei12#$%';
CREATE USER peter PASSWORD 'Huawei12#$%';
insert into all_data values(1,'alice','abc'),(2,'bob','def'),(3,'peter','xyz');
--打开行访问控制策略开关
oracle=> alter table all_data enable row level security;
ALTER TABLE
--创建行访问控制策略，当前用户只能查看用户自身的数据
oracle=> create row level security policy rlsp_alldata on all_data using(role=current_user);
CREATE ROW LEVEL SECURITY POLICY
--切换至用户alice，执行SQL"SELECT * FROM public.all_data"
oracle=> grant select on jack.all_data to alice,bob,peter;
GRANT
oracle=> grant usage on SCHEMA jack to alice,bob,peter;
GRANT
oracle=> \c - alice
Password for user alice: 
Non-SSL connection (SSL connection is recommended when requiring high-security)
You are now connected to database "oracle" as user "alice".
oracle=> select * from jack.all_data;
 id | role  | data 
----+-------+------
  1 | alice | abc
(1 row)
--删除策略
oracle=> drop row level security policy rlsp_alldata on all_data;
DROP ROW LEVEL SECURITY POLICY
--关闭行级访问策略
oracle=> alter table all_data disable row level security;
ALTER TABLE
--5 触发器
create table stu(sid int,name varchar);
create table course(cid int,name varchar);
create table selective(sid int,cid int,score int);
insert into stu values(1,'a'),(2,'b'),(3,'c');
insert into course values(1,'yuwen'),(2,'math'),(3,'english');
insert into selective values(1,1,100),(1,2,99),(1,3,98),(2,1,97),(2,2,88),(2,3,93),(3,1,91),(3,2,98),(3,3,92);
--（1）创建一个视图，把某一学生的成绩求和 
oracle=> create or replace view sum_score as select sid,sum(score) from selective group by sid;
CREATE VIEW
oracle=> select * from sum_score order by 1;
 sid | sum 
-----+-----
   1 | 297
   2 | 278
   3 | 281
(3 rows)
--（2）创建一个触发器，删除 teacher 表中某一教师数据时，同步删除org表中数据
create table teacher(id int,name varchar);
insert into teacher values (1,'a'),(2,'b');
create table org as select * from teacher;
--创建触发器函数：
create or replace function func_tri_teacher()
returns trigger
as $$
begin
  delete from org
   where id = old.id;
  return old;
end; $$ language plpgsql;
--创建触发器：
CREATE TRIGGER tri_teacher after DELETE ON teacher FOR EACH ROW execute PROCEDURE func_tri_teacher();
--验证触发器：
oracle=> select * from teacher;
 id | name 
----+------
  1 | a
  2 | b
(2 rows)

oracle=> select * from org;
 id | name 
----+------
  1 | a
  2 | b
(2 rows)

oracle=> delete from teacher where id=1;
DELETE 1
oracle=> select * from teacher ;
 id | name 
----+------
  2 | b
(1 row)

oracle=> select * from org;
 id | name 
----+------
  2 | b
(1 row)
--6 游标
create table sjh_cursor (a int,b int,c int);
insert into sjh_cursor values(1,2,3);
insert into sjh_cursor values(4,5,6);
--创建游标，使用游标从表里查询并输出2字段
create or replace procedure pro_sjh()
as
declare
  cursor c1 is select a, b
                 from sjh_cursor;
  var1 int;
  var2 int;
begin
  open c1; loop
    fetch c1 into var1,var2;
    exit when c1%notfound;
    raise notice 'sjh_cursor表a列数据为：%，b列数据为：%',var1,var2;
  end loop;
  close c1;
end;
/


oracle=> call pro_sjh();
NOTICE:  sjh_cursor表a列数据为：1，b列数据为：2
NOTICE:  sjh_cursor表a列数据为：4，b列数据为：5
 pro_sjh 
---------
 
(1 row)

--7 性能调优 
--tablea(a int,b int,c int)
create TABLE tablea(a int,b int,c int);
insert into tablea values(generate_series(1,100000),generate_series(1,100000),generate_series(1,100000));
--（1）分别创建索引，并使下列简单查询走索引：
--explain select * from tablea where a=1 and b=2;
--explain select * from tablea where b=1 and c=2;
oracle=> create TABLE tablea(a int,b int,c int);
CREATE TABLE
oracle=> insert into tablea values(generate_series(1,100000),generate_series(1,100000),generate_series(1,100000));
INSERT 0 100000
oracle=> create index idx_ab on tablea(a,b);
CREATE INDEX
oracle=> create index idx_bc on tablea(b,c);
CREATE INDEX
oracle=> analyze tablea ;
ANALYZE
oracle=> explain select * from tablea where a=1 and b=2;
                              QUERY PLAN                              
----------------------------------------------------------------------
 Index Scan using idx_bc on tablea  (cost=0.00..8.27 rows=1 width=12)
   Index Cond: (b = 2)
   Filter: (a = 1)
(3 rows)

oracle=> explain select * from tablea where b=1 and c=2;
                              QUERY PLAN                              
----------------------------------------------------------------------
 [Bypass]
 Index Scan using idx_bc on tablea  (cost=0.00..8.27 rows=1 width=12)
   Index Cond: ((b = 1) AND (c = 2))
(3 rows)
--（2）如何使 sql 不使用索引(写出三种方式)
第一：set cpu_index_tuple_cost = 100000;
oracle=> set cpu_index_tuple_cost=100000;
SET
oracle=> explain select * from tablea where a=1 and b=2;
                        QUERY PLAN                        
----------------------------------------------------------
 Seq Scan on tablea  (cost=0.00..2041.00 rows=1 width=12)
   Filter: ((a = 1) AND (b = 2))
(2 rows)
第二：ALTER INDEX INDEX_NAME UNUSABLE;
oracle=> set cpu_index_tuple_cost=0.005;
SET
oracle=> ALTER INDEX idx_ab unusable;
ALTER INDEX
oracle=> explain select * from tablea where a=1 and b=2;
                              QUERY PLAN                              
----------------------------------------------------------------------
 Index Scan using idx_bc on tablea  (cost=0.00..8.27 rows=1 width=12)
   Index Cond: (b = 2)
   Filter: (a = 1)
(3 rows)
oracle=> ALTER INDEX idx_bc unusable;
ALTER INDEX
oracle=> explain select * from tablea where a=1 and b=2;
                        QUERY PLAN                        
----------------------------------------------------------
 Seq Scan on tablea  (cost=0.00..2041.00 rows=1 width=12)
   Filter: ((a = 1) AND (b = 2))
(2 rows)
第三：SELECT /*+tablescan()*/
oracle=> explain select /*+tablescan(tablea)*/ * from tablea where a=1 and b=2;
                        QUERY PLAN                        
----------------------------------------------------------
 Seq Scan on tablea  (cost=0.00..2041.00 rows=1 width=12)
   Filter: ((a = 1) AND (b = 2))
(2 rows)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--1 通用SQL查询
create  table stu(id int ,math int ,art int ,phy int);
insert into stu values (1,60,33,66);
insert into stu values (2,61,53,86);
insert into stu values (3,70,63,66);
insert into stu values (4,90,63,76);
insert into stu values (5,59,69,79);
--1)查看每门成绩是否大于每门平均成绩；
oracle=> select id,case when math>avg(math) over() then '大于' else '小于等于' end as 'is_math_bigger?',case when art>avg(art) over() then '大于' else '小于等于' end as 'is_art_bigger?',case when phy>avg(phy) over() then '大于' else '小于等于' end as 'is_phy_bigger?' from stu;
 id | is_math_bigger? | is_art_bigger? | is_phy_bigger? 
----+-----------------+----------------+----------------
  1 | 小于等于        | 小于等于       | 小于等于
  2 | 小于等于        | 小于等于       | 大于
  3 | 大于            | 大于           | 小于等于
  4 | 大于            | 大于           | 大于
  5 | 小于等于        | 大于           | 大于
(5 rows)
--2)编写函数，获取成绩绩点，0~59给0，60~69给0.1，70~79给0.2，80~89给0.3，90~100给0.4
CREATE or REPLACE FUNCTION get_score_point(vscore INT)
RETURNS TEXT
as $$
DECLARE
BEGIN
  RETURN (
  CASE
    WHEN vscore <= 59 THEN
      '0'
    WHEN vscore <= 69 THEN
      '0.1'
    WHEN vscore <= 79 THEN
      '0.2'
    WHEN vscore <= 89 THEN
      '0.3'
    ELSE
      '0.4'
  END);
END; $$ LANGUAGE PLPGSQL;
--3)id含'3'的同学，求总的绩点，返回绩点最大的ID和总绩点
oracle=> insert into stu values (1234,99,90,99);
INSERT 0 1
oracle=> select * from stu;
  id  | math | art | phy 
------+------+-----+-----
    1 |   60 |  33 |  66
    2 |   61 |  53 |  86
    3 |   70 |  63 |  66
    4 |   90 |  63 |  76
    5 |   59 |  69 |  79
 1234 |   99 |  90 |  99
(6 rows)
oracle=> select id,get_score_point(math)+get_score_point(art)+get_score_point(phy) as sum_point from stu where id like '%3%' order by 2 desc limit 1;
  id  | sum_point 
------+-----------
 1234 |       1.2
(1 row)
--4)按照总绩点排名输出
oracle=> select id,get_score_point(math)+get_score_point(art)+get_score_point(phy) as sum_point from stu order by 2 desc;
  id  | sum_point 
------+-----------
 1234 |       1.2
    4 |       0.7
    2 |       0.4
    3 |       0.4
    5 |       0.3
    1 |       0.2
(6 rows)
--5)编写add_mask(id1,id2)函数，当id1是当前查询用户时，显示正常ID，如果不是则显示为id2.
CREATE OR REPLACE FUNCTION add_mask(id1 TEXT, id2 TEXT)
RETURNS TEXT
AS $$
DECLARE
  id3 text;
BEGIN
  SELECT USER INTO id3;
  IF id1 = id3 THEN
    RETURN 'current USER is '||id3;
  ELSE
    RETURN 'CURRENT USER IS '||id2;
  END IF;
END; $$ LANGUAGE PLPGSQL;
--------------------------------------------------------------------------------------
--2 用户权限管理
--1）创建用户user1；
oracle=> create user user1 identified by 'Gauss2023';
CREATE ROLE
--2）查看用户user1和数据库的相关权限，题目提示用pg_database和pg_roles,要求显示数据库名、用户名、数据库的权限(一定要背下来，原题，而且不要去格式美化)
SELECT a.datname, b.rolname, string_agg(a.priv_t, ',')
  from (SELECT datname, (aclexplode(COALESCE(datacl, acldefault('d' :: "char", datdba)))).grantee as grantee, (aclexplode(COALESCE(datacl, acldefault('d' :: "char", datdba)))).privilege_type as priv_t
          FROM "pg_database"
         WHERE datname not like '%template%' ) a,
       "pg_roles" b
 WHERE (a.grantee = 0 or a.grantee = b.oid)
   AND b.rolname = 'user1'
 GROUP BY a.datname, b.rolname;
--3）把表table1的select和alter权限赋给user1；
oracle=> create table table1(id int);
CREATE TABLE
oracle=> grant select,alter on table1 to user1;
GRANT
--4）查询table1的owner，要求显示表名和owner；
oracle=> select a.relname,b.usename as owner from pg_class a join pg_user b on a.relowner=b.usesysid and a.relname='table1';
 relname | owner 
---------+-------
 table1  | jack
(1 row)
--5）查询user1的表权限，要求显示表名、schema名、用户名、相关表权限；
openGauss=> select table_name,table_schema,grantee,string_agg(privilege_type,',') as privilege_type from information_schema.table_privileges where grantee='user1' group by table_name,table_schema,grantee;
 table_name | table_schema | grantee | privilege_type 
------------+--------------+---------+----------------
 table1     | jack         | user1   | SELECT,ALTER
(1 row)
--6）查询对表table1有操作权限的用户，要求显示2列：用户名、操作权限。
openGauss=> select grantee,string_agg(privilege_type,',') as privilege_type from information_schema.table_privileges where table_name='table1' group by grantee;
 grantee |                     privilege_type                      
---------+---------------------------------------------------------
 jack    | INSERT,SELECT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER
 user1   | SELECT,ALTER
(2 rows)
--3 数据库连接
--1）show max_connection;
oracle=> show max_connections;
 max_connections 
-----------------
 1000
(1 row)
--2）创建数据库带最大连接数，使用sql查出数据库的名字和最大连接；
oracle=> create database tmpdb with connection limit 1000;
CREATE DATABASE
oracle=> select datname,datconnlimit from pg_database where datname='tmpdb';
 datname | datconnlimit 
---------+--------------
 tmpdb   |         1000
(1 row)
--3）创建用户带最大连接数，使用sql查出用户的名字和最大连接；
oracle=> create user tmpuser identified by 'Gauss2023' connection limit 1000;
CREATE ROLE
oracle=> select rolname,rolconnlimit from pg_roles where rolname='tmpuser';
 rolname | rolconnlimit 
---------+--------------
 tmpuser |         1000
--4）修改数据库的最大连接数；
oracle=> create database tmpdb with connection limit 1000;
CREATE DATABASE
oracle=> alter database tmpdb connection limit 2000;
ALTER DATABASE
oracle=> select datname,datconnlimit from pg_database where datname='tmpdb';
 datname | datconnlimit 
---------+--------------
 tmpdb   |         2000
(1 row)

oracle=> drop database tmpdb;
DROP DATABASE
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--4 动态数据脱敏
--创建dev_mask和bob_mask用户。
CREATE USER dev_mask PASSWORD 'dev@1234';
CREATE USER bob_mask PASSWORD 'bob@1234';
--创建一个表tb_for_masking
CREATE TABLE tb_for_masking(col1 text, col2 text, col3 text);
--创建资源标签标记敏感列col1
oracle=> create resource label rl_col1 add column(tb_for_masking.col1);
CREATE RESOURCE LABEL
--创建资源标签标记敏感列col2
oracle=> create resource label rl_col2 add column(tb_for_masking.col2);
CREATE RESOURCE LABEL
--对访问敏感列col1的操作创建脱敏策略
oracle=> create masking policy mp_col1 creditcardmasking on label(rl_col1);
CREATE MASKING POLICY
--为脱敏策略maskpol1添加描述
oracle=> alter masking policy mp_col1 comments '这是col1的脱敏策略';
ALTER MASKING POLICY
--修改脱敏策略maskpol1，新增一项脱敏方式
oracle=> alter masking policy mp_col1 add fullemailmasking on label(rl_col1);
ALTER MASKING POLICY
--修改脱敏策略maskpol1，移除一项脱敏方式
oracle=> alter masking policy mp_col1 remove fullemailmasking on label(rl_col1);
ALTER MASKING POLICY
--修改脱敏策略maskpol1，修改一项脱敏方式
oracle=> alter masking policy mp_col1 modify maskall on label(rl_col1);
ALTER MASKING POLICY
--修改脱敏策略maskpol1使之仅对用户dev_mask和bob_mask,客户端工具为psql和gsql，IP地址为'10.20.30.40', '127.0.0.0/24'场景生效。
oracle=> alter masking policy mp_col1 modify (filter on roles ('dev_mask','bob_mask'),app(psql,gsql),ip('10.20.30.40', '127.0.0.0/24'));
ALTER MASKING POLICY
--修改脱敏策略maskpol1，使之对所有用户场景生效
oracle=> alter masking policy mp_col1 drop filter;
ALTER MASKING POLICY
--禁用脱敏策略maskpol1
oracle=> alter masking policy mp_col1 disable;
ALTER MASKING POLICY
oracle=> select * from gs_masking_policy;
 polname |    polcomments     |         modifydate         | polenabled 
---------+--------------------+----------------------------+------------
 mp_col1 | 这是col1的脱敏策略 | 2023-12-18 15:09:08.142365 | f
(1 row)

oracle=> select * from gs_policy_label;
 labelname | labeltype | fqdnnamespace | fqdnid | relcolumn | fqdntype 
-----------+-----------+---------------+--------+-----------+----------
 rl_tbl    | resource  |         20900 |  23209 |           | table
 rl_col1   | resource  |         20900 |  23787 | col1      | column
 rl_col2   | resource  |         20900 |  23787 | col2      | column
(3 rows)
oracle=> drop masking policy mp_col1;
DROP MASKING POLICY
oracle=> drop resource label rl_tbl,rl_col1,rl_col2;
DROP RESOURCE LABEL


create table student (id int,vdate timestamp);
--1)编写存储过程，输入个数，生成student，id从100000开始，starttime是当前时间；
CREATE OR REPLACE PROCEDURE ins_student(num int)
AS
DECLARE
  id    int := 100000;
  var   int;
  count int;
BEGIN
  FOR var IN 1.. num LOOP
    INSERT INTO "student"
    VALUES
      (id, now());
    id := id+1;
  END LOOP;
  SELECT count(*) INTO count
    from student;
  raise info '已插入%行，目前student表共有%行',num,count;
END;
/
--2）调用存储过程，生成90000个；
oracle=> call ins_student(90000);
INFO:  已插入90000行，目前student表共有90000行
 ins_student 
-------------
 
(1 row)
--3）查看生成了多少个。
oracle=> select count(*) from student;
 count 
-------
 90000
(1 row)



--su(id,first_name,family_name,sexmark,grade) id是主键
create table su(id int primary key,first_name varchar,family_name varchar,sexmark varchar,grade int);
insert into su values(1,'alice','bob','A',99),(2,'cid','data','B',88),(3,'opengauss','mpp','C',90),(4,'second','nice','D',83),(5,'tmpsec','good','E',96);
--(1)family_name跟first_name用'.'拼接，要求首字母大写
oracle=> select id,initcap(family_name||'.'||first_name),sexmark,grade from su;
 id |    initcap    | sexmark | grade 
----+---------------+---------+-------
  1 | Bob.Alice     | A       |    99
  2 | Data.Cid      | B       |    88
  3 | Mpp.Opengauss | C       |    90
  4 | Nice.Second   | D       |    83
  5 | Good.Tmpsec   | E       |    96
(5 rows)
--(2)firstname里面以'sec'开头的，给出判断结果
oracle=> select id,first_name,case when first_name like 'sec%' then 'T' else 'F' end as 'begin_with_sec?',family_name,sexmark,grade from jack.su;
 id | first_name | begin_with_sec? | family_name | sexmark | grade 
----+------------+-----------------+-------------+---------+-------
  1 | alice      | F               | bob         | A       |    99
  2 | cid        | F               | data        | B       |    88
  3 | opengauss  | F               | mpp         | C       |    90
  4 | second     | T               | nice        | D       |    83
  5 | tmpsec     | F               | good        | E       |    96
(5 rows)
--(3)根据grade做排序，生成连续的排序值，其中要求分数相同的人具有相同的编号，显示包含ID、first_name、family_name
oracle=> select id,first_name,family_name,grade,dense_rank() over(partition by 1 order by grade desc) from jack.su;
 id | first_name | family_name | grade | dense_rank 
----+------------+-------------+-------+------------
  1 | alice      | bob         |    99 |          1
  5 | tmpsec     | good        |    96 |          2
  3 | opengauss  | mpp         |    90 |          3
  2 | cid        | data        |    88 |          4
  4 | second     | nice        |    83 |          5
(5 rows)
--(4)merge into ,根据ID判断，如果存在id=1则把sexmask字段改成'F',如果不存在插入下列数据:(2,'XX','XX','XX',98)
oracle=> select * from su order by 1;
 id | first_name | family_name | sexmark | grade 
----+------------+-------------+---------+-------
  1 | alice      | bob         | A       |    99
  2 | cid        | data        | B       |    88
  3 | opengauss  | mpp         | C       |    90
  4 | second     | nice        | D       |    83
  5 | tmpsec     | good        | E       |    96
(5 rows)

oracle=> delete from su where id=2;
DELETE 1
oracle=> merge into su using (select 2 id) b on (su.id=b.id) when matched then update set sexmark='F' when not matched then insert values (2,'XX','XX','XX',98);
MERGE 1
oracle=> select * from su order by 1;
 id | first_name | family_name | sexmark | grade 
----+------------+-------------+---------+-------
  1 | alice      | bob         | A       |    99
  2 | XX         | XX          | XX      |    98
  3 | opengauss  | mpp         | C       |    90
  4 | second     | nice        | D       |    83
  5 | tmpsec     | good        | E       |    96
(5 rows)

oracle=> merge into su using (select 2 id) b on (su.id=b.id) when matched then update set sexmark='F' when not matched then insert values (2,'XX','XX','XX',98);
MERGE 1
oracle=> select * from su order by 1;
 id | first_name | family_name | sexmark | grade 
----+------------+-------------+---------+-------
  1 | alice      | bob         | A       |    99
  2 | XX         | XX          | F       |    98
  3 | opengauss  | mpp         | C       |    90
  4 | second     | nice        | D       |    83
  5 | tmpsec     | good        | E       |    96
(5 rows)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
create table student(student_id int,math int,phy int,art int,m2 int);
create table weight(weight_no int ,math numeric(3,1),phy numeric(3,1),art numeric(3,1),m2 numeric(3,1));
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
--(1)求math、phy总成绩以及art、m2的总成绩：
openGauss=> select student_id,math+phy as sum_math_phy,art+m2 as sum_art_m2 from student ;
 student_id | sum_math_phy | sum_art_m2 
------------+--------------+------------
          1 |          150 |        177
          2 |          150 |        177
          3 |          161 |        165
          4 |          175 |        182
          5 |          171 |        187
          6 |          168 |        179
          7 |          161 |        176
          8 |          163 |        182
          9 |          161 |        178
         10 |          180 |        177
(10 rows)
--(2)根据维度表，按照两种加权算法计算出每个学生的加权成绩，展示包含student_id,weight_sum，单个学生加权成绩可以两行输出
oracle=> select a.student_id,a.math*b.math+a.phy*b.phy+a.art*b.art+a.m2*b.m2 as sum_point_score from student a,weight b;
 student_id | sum_point_score 
------------+-----------------
          1 |            79.4
          1 |            84.1
          2 |            79.4
          2 |            84.1
          3 |            79.8
          3 |            83.2
          4 |            88.5
          4 |            90.0
          5 |            88.1
          5 |            90.9
          6 |            86.0
          6 |            87.5
          7 |            82.6
          7 |            85.9
          8 |            84.4
          8 |            88.1
          9 |            83.3
          9 |            86.2
         10 |            89.1
         10 |            89.4
(20 rows)
--(3)根据维度表，按照两种加权算法计算出每个学生的加权成绩，展示包含student_id,weight_sum，单个学生加权成绩要求一行输出
--输出列名结果如下：
 student_id | weight1_sum | weight2_sum

oracle=> select a.student_id,a.math*b.math+a.phy*b.phy+a.art*b.art+a.m2*b.m2 as weight1_sum,a.math*c.math+a.phy*c.phy+a.art*c.art+a.m2*c.m2 as weight2_sum from student a,(select * from weight where weight_no=1) b,(select * from weight where weight_no=2) c;
 student_id | weight1_sum | weight2_sum 
------------+-------------+-------------
          1 |        79.4 |        84.1
          2 |        79.4 |        84.1
          3 |        79.8 |        83.2
          4 |        88.5 |        90.0
          5 |        88.1 |        90.9
          6 |        86.0 |        87.5
          7 |        82.6 |        85.9
          8 |        84.4 |        88.1
          9 |        83.3 |        86.2
         10 |        89.1 |        89.4
(10 rows)
--(4)对两种加权总成绩按排序。要求输出格式student_id,weight1_sum、rank1、weight2_sum、rank2，
--RANK1和RANK2分别按weight1_sum，weight2_sum倒序，整体结果按student_id进行正序排序
select student_id, weight1_sum, dense_rank() over(partition by 1 order by weight1_sum desc) as rank1, weight2_sum, dense_rank() over(partition by 1 order by weight2_sum desc) as rank2
  from (select s.student_id, w1.weight1_sum, w2.weight2_sum
          from student s
          join (select s.student_id, s.math * w.math + s.phy * w.phy + s.art * w.art + s.m2 * w.m2 as weight1_sum
          from student s, weight w
         where w.weight_no = 1 ) w1 on s.student_id = w1.student_id
          join (select s.student_id, s.math * w.math + s.phy * w.phy + s.art * w.art + s.m2 * w.m2 as weight2_sum
          from student s, weight w
         where w.weight_no = 2 ) w2 on s.student_id = w2.student_id )
 order by 1;
 
 student_id | weight1_sum | rank1 | weight2_sum | rank2 
------------+-------------+-------+-------------+-------
          1 |        79.4 |     9 |        84.1 |     8
          2 |        79.4 |     9 |        84.1 |     8
          3 |        79.8 |     8 |        83.2 |     9
          4 |        88.5 |     2 |        90.0 |     2
          5 |        88.1 |     3 |        90.9 |     1
          6 |        86.0 |     4 |        87.5 |     5
          7 |        82.6 |     7 |        85.9 |     7
          8 |        84.4 |     5 |        88.1 |     4
          9 |        83.3 |     6 |        86.2 |     6
         10 |        89.1 |     1 |        89.4 |     3
(10 rows)

--3 账本数据库
--创建防篡改模式ledgernsp。
oracle=> create schema ledgernsp with blockchain;
CREATE SCHEMA
--创建防篡改用户表ledgernsp.usertable。
oracle=> create table ledgernsp.usertable(id int,name varchar);
CREATE TABLE
--校验指定防篡改用户表的表级数据hash值与其对应历史表hash一致性。
oracle=> select pg_catalog.ledger_hist_check('ledgernsp','usertable');
 ledger_hist_check 
-------------------
 t
(1 row)
--校验指定防篡改用户表对应的历史表hash与全局历史表对应的relhash一致性。
oracle=> select pg_catalog.ledger_gchain_check('ledgernsp','usertable');
 ledger_gchain_check 
---------------------
 t
(1 row)
--4 安全审计
--(1)用SQL查看是否打开
oracle=> select name,setting from pg_settings where name='audit_enabled';
     name      | setting 
---------------+---------
 audit_enabled | on
(1 row)
--(2)用SQL查看日志存储最大空间
oracle=> select name,setting from pg_settings where name='audit_space_limit';
       name        | setting 
-------------------+---------
 audit_space_limit | 1048576
(1 row)
--(3)查看过去一天所有产生审计日志的总数。要用now()
oracle=> select * from pg_query_audit(now()-interval '1day',now());
--(4)查过去一天user1这个用户登录postgres数据库，要用now()
oracle=> select * from pg_query_audit(now()-interval '1day',now()) where username='user1';
--(5)删除指定时间段的审计日志。
oracle=> select * from pg_delete_audit('2023-12-01','2023-12-20');
 pg_delete_audit 
-----------------
 
(1 row)
--(6)删除数据库DB2；级联删除用户user1。
oracle=> drop database mysql;
DROP DATABASE
oracle=> drop user user1 cascade;
DROP ROLE

--7 性能优化
--test（id、kemu、classID、grade）,里面8万条数据
CREATE TABLE test(id int,kemu VARCHAR,classid int,grade int);
INSERT INTO test VALUES(generate_series(1,80000),concat('kemu',cast(ceil(random()*10) as integer)),ceil(random()*10),ceil(random()*100));
INSERT INTO test VALUES(generate_series(800001,800010),concat('kemu',cast(ceil(random()*10) as integer)),10,generate_series(101,110));
--1、查10班级里面kemu1最低分是多少，要保障走索引
oracle=> create index idx_kemu_grade on test(kemu,grade);
CREATE INDEX
oracle=> analyze test;
ANALYZE
oracle=> explain select min(grade) from test where kemu='kemu1' and classid=10;
                                          QUERY PLAN                                          
----------------------------------------------------------------------------------------------
 Result  (cost=2.97..2.98 rows=1 width=0)
   InitPlan 1 (returns $0)
     ->  Limit  (cost=0.00..2.97 rows=1 width=4)
           ->  Index Scan using idx_kemu_grade on test  (cost=0.00..2353.47 rows=792 width=4)
                 Index Cond: (((kemu)::text = 'kemu1'::text) AND (grade IS NOT NULL))
                 Filter: (classid = 10)
(6 rows)
oracle=> select min(grade) from test where kemu='kemu1' and classid=10;
 min 
-----
   1
(1 row)
--2、10班级同一科目成绩比9班级最高分高的同学(本题只做逻辑参考，非原题，原题记不住了)
oracle=> select a.*,b.kemu as B_kemu,b.grade as B_grade from test a,(select kemu,max(grade) as grade from test where classid=9 group by kemu) b where a.kemu=b.kemu and a.grade>b.grade order by 1;
   id   | kemu  | classid | grade | B_kemu | B_grade 
--------+-------+---------+-------+--------+---------
 800001 | kemu8 |      10 |   101 | kemu8  |     100
 800002 | kemu9 |      10 |   102 | kemu9  |     100
 800003 | kemu4 |      10 |   103 | kemu4  |     100
 800004 | kemu4 |      10 |   104 | kemu4  |     100
 800005 | kemu4 |      10 |   105 | kemu4  |     100
 800006 | kemu6 |      10 |   106 | kemu6  |     100
 800007 | kemu3 |      10 |   107 | kemu3  |     100
 800008 | kemu8 |      10 |   108 | kemu8  |     100
 800009 | kemu7 |      10 |   109 | kemu7  |     100
 800010 | kemu6 |      10 |   110 | kemu6  |     100
(10 rows)

--1 存储过程：
oracle=> create table student (sid int,math int,art int,phy int,music int);
CREATE TABLE
oracle=> insert into student values (1,88,66,81,91),(2,33,44,55,66),(3,22,33,45,43);
INSERT 0 3
--（1）输入学号，返回对应的总成绩
oracle=> CREATE OR REPLACE PROCEDURE get_sum_score(vid int)
oracle-> AS
oracle$> DECLARE
oracle$>   vscore INT;
oracle$> BEGIN
oracle$>   SELECT math + art + phy + music INTO vscore
oracle$>     FROM "student"
oracle$>    WHERE sid = vid;
oracle$>   raise info 'sid为%的学生的总成绩为%',vid,vscore;
oracle$> END;
oracle$> /
CREATE PROCEDURE

oracle=> call get_sum_score(1);
INFO:  sid为1的学生的总成绩为326
 get_sum_score 
---------------
 
(1 row)
--（2）对于学生每科成绩，0-59，绩点0，60-69，绩点0.1， 70-79，绩点0.2，80-89，绩点0.3, 90-100，绩点0.4，给出学号和科目，返回对应的绩点(本题只做逻辑参考，非原题，原题记不住了)
oracle=> CREATE OR REPLACE PROCEDURE get_sid_point(id int)
oracle-> AS
oracle$> DECLARE
oracle$>   math_score  DECIMAL(3, 1);
oracle$>   art_score   DECIMAL(3, 1);
oracle$>   phy_score   DECIMAL(3, 1);
oracle$>   music_score DECIMAL(3, 1);
oracle$>   vid         int;
oracle$> BEGIN
oracle$>   SELECT sid,
oracle$>          CASE
oracle$>            WHEN math <= 60 THEN
oracle$>              0
oracle$>            WHEN math < 70 THEN
oracle$>              0.1
oracle$>            WHEN math < 80 THEN
oracle$>              0.2
oracle$>            WHEN math < 90 THEN
oracle$>              0.3
oracle$>            WHEN math <= 100 THEN
oracle$>              0.4
oracle$>          END as math_score,
oracle$>          CASE
oracle$>            WHEN art <= 60 THEN
oracle$>              0
oracle$>            WHEN art < 70 THEN
oracle$>              0.1
oracle$>            WHEN art < 80 THEN
oracle$>              0.2
oracle$>            WHEN art < 90 THEN
oracle$>              0.3
oracle$>            WHEN art <= 100 THEN
oracle$>              0.4
oracle$>          END as art_score,
oracle$>          CASE
oracle$>            WHEN phy <= 60 THEN
oracle$>              0
oracle$>            WHEN phy < 70 THEN
oracle$>              0.1
oracle$>            WHEN phy < 80 THEN
oracle$>              0.2
oracle$>            WHEN phy < 90 THEN
oracle$>              0.3
oracle$>            WHEN phy <= 100 THEN
oracle$>              0.4
oracle$>          END as phy_score,
oracle$>          CASE
oracle$>            WHEN music <= 60 THEN
oracle$>              0
oracle$>            WHEN music < 70 THEN
oracle$>              0.1
oracle$>            WHEN music < 80 THEN
oracle$>              0.2
oracle$>            WHEN music < 90 THEN
oracle$>              0.3
oracle$>            WHEN music <= 100 THEN
oracle$>              0.4
oracle$>          END as music_score INTO vid,
oracle$>          math_score,
oracle$>          art_score,
oracle$>          phy_score,
oracle$>          music_score
oracle$>     FROM "student"
oracle$>    WHERE sid = id;
oracle$>   raise info 'sid为%的学生的绩点为math->%,art->%,phy->%,music->%',vid,math_score,art_score,phy_score,music_score;
oracle$> END;
oracle$> /
CREATE PROCEDURE
oracle=> call get_sid_point(1);
INFO:  sid为1的学生的绩点为math->0.3,art->0.1,phy->0.3,music->0.4
 get_sid_point 
---------------
 
(1 row)

===================================================================================================================================================
--2 性能调优：(本题只做逻辑参考，非原题，原题记不住了，考试中的大概率没有这么复杂)
oracle=> create table student (sid int primary key,name varchar,classid int);
NOTICE:  CREATE TABLE / PRIMARY KEY will create implicit index "student_pkey" for table "student"
CREATE TABLE
oracle=> insert into student values (1,'a',202201),(2,'b',202201),(3,'c',202201),(4,'d',202202),(5,'e',202202),(6,'f',202202),(7,'g',202203),(8,'h',202203),(9,'i',202203);
INSERT 0 9
oracle=> create table score1 (sid int,kemu varchar,score int,foreign key(sid) references student(sid));
CREATE TABLE
oracle=> create table score2 (sid int,kemu varchar,score int,foreign key(sid) references student(sid));
CREATE TABLE
oracle=> insert into score1 values (1,'语文',99),(1,'数学',98),(1,'英语',97),(2,'语文',97),(2,'数学',91),(2,'英语',92),(3,'语文',91),(3,'数学',93),(3,'英语',88),(4,'语文',93),(4,'数学',92),(4,'英语',92),(5,'语文',94),(5,'数学',90),(5,'英语',79),(6,'语文',89),(6,'数学',90),(6,'英语',77),(7,'语文',83),(6,'数学',96),(6,'英语',78),(7,'语文',33),(7,'数学',77),(7,'英语',77),(8,'语文',88),(8,'数学',88),(8,'英语',88),(9,'语文',99),(9,' 数学',98),(9,'英语',96);
INSERT 0 30
oracle=> insert into score2 values (1,'语文',99),(1,'数学',94),(1,'英语',100),(2,'语文',100),(2,'数学',91),(2,'英语',92),(3,'语文',91),(3,'数学',93),(3,'英语',92),(4,'语文',93),(4,'数学',92),(4,'英语',92),(5,'语文',94),(5,'数学',94),(5,'英语',79),(6,'语文',89),(6,'数学',94),(6,'英语',68),(7,'语文',83),(6,'数学',96),(6,'英语',78),(7,'语文',33),(7,'数学',68),(7,'英语',68),(8,'语文',92),(8,'数学',92),(8,'英语',92),(9,'语文',99),(9,'数学',94),(9,'英语',96);
INSERT 0 30
--1，三个表，student和score1, score2表，查202201班级和202202班级所有人语文成绩前5的记录，第一个查询要使用union, 第二个查询是对第一个的优化
 --QUERY 1
select *
  FROM (SELECT a.sid, a.name, a.classid, b.kemu, b.score
          FROM "student" a
          JOIN "score1" b ON a.sid = b.sid
         WHERE a.classid in(202201, 202202)
           and b.kemu = '语文'
         order by b.score desc
         limit 5 )
UNION ALL
select *
  FROM (SELECT a.sid, a.name, a.classid, b.kemu, b.score
          FROM "student" a
          JOIN "score2" b ON a.sid = b.sid
         WHERE a.classid in(202201, 202202)
           and b.kemu = '语文'
         order by b.score desc
         limit 5 )
 order by score desc
 LIMIT 5;
 --QUERY 2
WITH CombinedScores AS
         (SELECT a.sid, a.name, a.classid, b.score
            FROM "student" a
            JOIN score1 b ON a.sid = b.sid
           WHERE classid IN('202201', '202202')
             and b.kemu = '语文' UNION ALL
             SELECT a.sid, a.name, a.classid, b.score
                  FROM "student" a
                  JOIN score2 b ON a.sid = b.sid
                 WHERE classid IN('202201', '202202')
                   and b.kemu = '语文')
SELECT sid, name, score
  FROM CombinedScores
 ORDER BY score DESC
 LIMIT 5;

--2，找202201和202202年级相同的科目，202201的成绩在score2中不存在的成绩，每一个查询要求使用not in, 第二个查询是对第一个的优化
select t202201.*
  from (SELECT a.sid, a.name, a.classid, b.kemu, b.score
          FROM "student" a
          JOIN "score1" b ON a.sid = b.sid
                         AND a.classid = 202201
        UNION ALL
        SELECT a.sid, a.name, a.classid, b.kemu, b.score
          FROM "student" a
          JOIN "score2" b ON a.sid = b.sid
                         AND a.classid = 202201) t202201,(SELECT a.sid, a.name, a.classid, b.kemu, b.score
                                            FROM "student" a
                                            JOIN "score1" b ON a.sid = b.sid
                                                           AND a.classid = 202202
                                          UNION ALL
                                          SELECT a.sid, a.name, a.classid, b.kemu, b.score
                                            FROM "student" a
                                            JOIN "score2" b ON a.sid = b.sid
                                                           AND a.classid = 202202) t202202 where t202201.kemu = t202202.kemu AND t202201.score NOT IN(SELECT score
                                                                    from score2
                                                                   where score2.kemu = t202201.kemu);

--3，查询班级202201语文成绩最高的学生，要求先创建索引，并且能保证一定会使用索引
oracle=> create index idx_sid_classid on student(sid,classid);
CREATE INDEX
oracle=> create index idx_kemu on score1(kemu);
CREATE INDEX
oracle=> create index idx_kemu2 on score2(kemu);
CREATE INDEX


EXPLAIN ANALYSE
SELECT max(score)
  FROM (SELECT max(score) AS score
          FROM "score1" c
         WHERE sid IN(SELECT sid
                        FROM "student" s
                       WHERE s.sid = c.sid
                         and s.classid = 202201
                         AND c.kemu = '语文')
        UNION ALL
        SELECT max(score) AS score
          FROM "score2" c
         WHERE sid IN(SELECT sid
                        FROM "student" s
                       WHERE s.sid = c.sid
                         and s.classid = 202201
                         AND c.kemu = '语文'));
                                                                           QUERY PLAN                                                           
                 
------------------------------------------------------------------------------------------------------------------------------------------------
 Aggregate  (cost=251.20..251.21 rows=1 width=8) (actual time=0.106..0.106 rows=1 loops=1)
   ->  Append  (cost=125.58..251.19 rows=2 width=4) (actual time=0.069..0.103 rows=2 loops=1)
         ->  Aggregate  (cost=125.58..125.59 rows=1 width=8) (actual time=0.068..0.068 rows=1 loops=1)
               ->  Seq Scan on score1 c  (cost=0.00..125.54 rows=15 width=4) (actual time=0.036..0.063 rows=3 loops=1)
                     Filter: (SubPlan 5)
                     Rows Removed by Filter: 27
                     SubPlan 5
                       ->  Result  (cost=0.00..8.27 rows=1 width=4) (actual time=0.039..0.039 rows=3 loops=30)
                             One-Time Filter: ((c.kemu)::text = '语文'::text)
                             ->  Index Only Scan using idx_sid_classid on student s  (cost=0.00..8.27 rows=1 width=4) (actual time=0.022..0.022 rows=3 loops=10)
                                   Index Cond: ((sid = c.sid) AND (classid = 202201))
                                   Heap Fetches: 3
         ->  Aggregate  (cost=125.58..125.59 rows=1 width=8) (actual time=0.032..0.032 rows=1 loops=1)
               ->  Seq Scan on score2 c  (cost=0.00..125.54 rows=15 width=4) (actual time=0.007..0.032 rows=3 loops=1)
                     Filter: (SubPlan 6)
                     Rows Removed by Filter: 27
                     SubPlan 6
                       ->  Result  (cost=0.00..8.27 rows=1 width=4) (actual time=0.014..0.014 rows=3 loops=30)
                             One-Time Filter: ((c.kemu)::text = '语文'::text)
                             ->  Index Only Scan using idx_sid_classid on student s  (cost=0.00..8.27 rows=1 width=4) (actual time=0.009..0.009 rows=3 loops=10)
                                   Index Cond: ((sid = c.sid) AND (classid = 202201))
                                   Heap Fetches: 3
 Total runtime: 0.338 ms
(23 rows)

--4，查询202201班级的学生的成绩比202202班级的学生最高成绩还要大的学生信息，给出的查询是使用的<（小于号），要求进行改写。
SELECT t01.kemu, t01.score as t01_score, t02.score as t02_score
  FROM (SELECT kemu, score
          FROM "student" a
          JOIN "score1" b ON a.sid = b.sid
                         AND a.classid = 202201 ) t01
  JOIN (SELECT DISTINCT kemu, score
          FROM (SELECT b.kemu, max(b.score) AS score
                  FROM "student" a
                  JOIN "score1" b ON a.sid = b.sid
                                 AND a.classid = 202202
                 GROUP BY b.kemu
                UNION ALL
                SELECT b.kemu, max(b.score) AS score
                  FROM "student" a
                  JOIN "score2" b ON a.sid = b.sid
                                 AND a.classid = 202202
                 GROUP BY b.kemu)) t02 ON t02.score < t01.score AND t01.kemu = t02.kemu;
 kemu | t01_score | t02_score 
------+-----------+-----------
 语文 |        99 |        94
 数学 |        98 |        96
 英语 |        97 |        92
 语文 |        97 |        94
(4 rows)
===================================================================================================================================================


/*3 数据库连接
1，使用sql查询全局最大连接数
2，创建用户，指定连接数
3，查询用户的连接数
4，修改用户的连接数
5，创建数据库，指定连接数
6，查询数据库的连接数
7，修改数据库的连接数

4 数据库和用户管理
1）通过sql查询数据库最大连接数
2）创建用户user1指定最大连接数，指定连接数为3
3）修改用户user1最大连接数为10
4）通过sql查询该用户最大连接数
5）创建数据库并指定最大连接数为10
6）修改最大连接数为20
7）通过sql查询该用户最大连接数
*/


--5 SQL开发
--student(student_id,math,pysical,art,music)
create table student(student_id int,math int,phy int,art int,music int);
insert into student values (1,88,66,81,91),(2,33,44,55,66),(3,22,33,45,43),(4,99,88,80,79),(5,99,98,97,99),(6,90,98,97,90);
--1）编写存储过程，输入学生id返回总成绩
oracle=> create or replace procedure pro_sumscore(id int) as
oracle$> declare
oracle$> vstudent_id int;
oracle$> sumscore int;
oracle$> begin
oracle$> select student_id,math+phy+art+music into vstudent_id,sumscore from student where student_id=id;
oracle$> raise info 'student_id为%的学生的总成绩为%',id,sumscore;
oracle$> end;
oracle$> /
CREATE PROCEDURE
oracle=> call pro_sumscore(1);
INFO:  student_id为1的学生的总成绩为326
 pro_sumscore 
--------------
 
(1 row)
--2）对学习math和pysical排名前二的学生，art加5分，求所有学生总成绩
UPDATE "student"
   SET art = art + 5
 WHERE student_id in(SELECT student_id
                       FROM "student"
                      ORDER BY math + phy DESC
                      LIMIT 2);

SELECT student_id, math + phy + art + music AS sum_score
  from "student";

SELECT *
  FROM "student"
 ORDER BY 1;
--3）art和music排名前二，同时math和pysical在前二名的学生信息
oracle=> SELECT *
oracle->   FROM student
oracle->  WHERE student_id IN(SELECT student_id
oracle(>                        FROM student
oracle(>                       ORDER BY math + phy DESC
oracle(>                       LIMIT 2)
oracle->    AND student_id IN(SELECT student_id
oracle(>                        FROM student
oracle(>                       ORDER BY art + music DESC
oracle(>                       LIMIT 2);
 student_id | math | phy | art | music 
------------+------+-----+-----+-------
          5 |   99 |  98 |  97 |    99
          6 |   90 |  98 |  97 |    90
(2 rows)
--触发器
--department表和teacher表
CREATE TABLE department (
     did integer,
     teid integer,
     level integer
 )
 WITH (orientation=row, compression=no);
CREATE TABLE teacher (
     teid integer,
     name character varying
 )
 WITH (orientation=row, compression=no);
insert into teacher values (101,'a'),(102,'b'),(103,'c');
insert into department values (1,101,1),(2,102,2),(3,103,3);
--1，写一个触发器，当试图从表department中更改字段教师级别的时候，提示：部门表的教师级别不允许更改
CREATE OR REPLACE FUNCTION func_tri_change()
RETURNS TRIGGER
AS $$
BEGIN
  IF NEW.LEVEL != OLD.LEVEL THEN
    RAISE EXCEPTION '部门表的教师级别不允许更改';
  END IF;
  RETURN NEW;
END; $$ LANGUAGE PLPGSQL;
CREATE TRIGGER tri_change BEFORE UPDATE OF LEVEL ON "department" FOR EACH ROW EXECUTE PROCEDURE func_tri_change();
--验证触发器：
openGauss=> UPDATE department SET LEVEL=2 WHERE did=1;
ERROR:  部门表的教师级别不允许更改
--2，让触发器失效，再尝试更改教师级别
oracle=> alter table department disable trigger tri_change;
ALTER TABLE
oracle=> UPDATE department SET LEVEL=2 WHERE did=1;
UPDATE 1
--3，重新让触发器生效，再尝试更改教师级别
oracle=> alter table department enable trigger tri_change;
ALTER TABLE
openGauss=> UPDATE department SET LEVEL=2 WHERE did=1;
ERROR:  部门表的教师级别不允许更改

--6 安全审计
--1)创建用户user1,密码'test@123'
oracle=> create user user1 identified by 'test@123';
CREATE ROLE
--2)给用户授予查看审计权限，同时可以创建审计策略
--auditadmin可以查看审计策略
oracle=> alter user user1 auditadmin;
ALTER ROLE
--poladmin可以创建审计策略
oracle=> alter user user1 poladmin;
ALTER ROLE
--3)切换至user1,创建审计策略adt1,对数据库执行create操作创建
oracle=> create audit policy adt1 privileges create;
CREATE AUDIT POLICY
--4)创建审计策略adt2,数据库执行select操作创建审计策略
oracle=> create audit policy adt2 access select;
CREATE AUDIT POLICY
--5)修改adt1,对IP地址为'10.20.30.40'进行审计
oracle=> alter audit policy adt1 modify (filter on ip ('10.20.30.40'));
ALTER AUDIT POLICY
--6)创建表tb1
oracle=> create table tb1(id int);
CREATE TABLE
--7)创建审计策略adt3,仅审计计记录用户root,在执行针对表tb1资源进行的select、insert、delete操作数据库创建审计策略
openGauss=> create resource label rl_tb1 add table(tb1);
CREATE RESOURCE LABEL
oracle=> create audit policy adt3 access select on label(rl_tb1),insert on label(rl_tb1),delete filter on roles(root);
ERROR:  role: [root] is invalid
oracle=> create audit policy adt3 access select on label(rl_tb1),insert on label(rl_tb1),delete filter on roles(omm);
CREATE AUDIT POLICY
--8)关闭adt1审计策略
oracle=> alter audit policy adt1 disable;
ALTER AUDIT POLICY
--9)删除以上创建的审计策略，级联删除用户user1
oracle=> drop audit policy adt1,adt2,adt3;
DROP AUDIT POLICY
oracle=> drop user user1 cascade;
DROP ROLE
--5、用SQL查找employ表中的所有数据,如果工资大于9000，则下调百分之10;如果小于5000 则增加百分之10
create  table employ 
(emp_no int primary key, 
 ename   varchar2(18),
 salary  int,
 deptno  int,
 jointime date );

insert into employ
values
  (1, 'a', 10000, 1, now()),
  (2, 'b', 3000, 2, now());
  
SELECT emp_no,
       ename,
       CASE
         WHEN salary > 9000 THEN
           salary * 0.9
         WHEN salary < 5000 THEN
           salary * 1.1
         ELSE
           salary
       END AS adjusted_salary,
       deptno,
       jointime
  FROM employ;


--权限访问控制: 给用户u1赋权只允许访问all_data表id=1的数据，修改上面的权限改为只允许u1访问all_data表id=1和id=2的数据(据说有人碰到类似这样的题了，行级访问控制，比产品文档的例题稍微复杂一点).
openGauss=> select * from all_data ;
 id | role  |    data    
----+-------+------------
  1 | alice | alice data
  2 | bob   | bob data
  3 | peter | peter data
(3 rows)

openGauss=> alter table all_data enable row level security;
ALTER TABLE
openGauss=> create row level security policy rlsp_role on all_data using(case when current_user='u1' then id=1 end);
CREATE ROW LEVEL SECURITY POLICY
openGauss=> \c - u1
Password for user u1: 
Non-SSL connection (SSL connection is recommended when requiring high-security)
You are now connected to database "postgres" as user "u1".
openGauss=> select * from jack.all_data ;
 id | role  |    data    
----+-------+------------
  1 | alice | alice data
(1 row)

openGauss=> \c - jack
Password for user jack: 
Non-SSL connection (SSL connection is recommended when requiring high-security)
You are now connected to database "postgres" as user "jack".
openGauss=> alter row level security policy rlsp_role on all_data using(case when current_user='u1' then id=1 or id=2 end);
ALTER ROW LEVEL SECURITY POLICY
openGauss=> \c - u1
Password for user u1: 
Non-SSL connection (SSL connection is recommended when requiring high-security)
You are now connected to database "postgres" as user "u1".
openGauss=> select * from jack.all_data ;
 id | role  |    data    
----+-------+------------
  1 | alice | alice data
  2 | bob   | bob data
(2 rows)


--20231228实战没做出来的题：
--以下只是题目逻辑，非原题：
openGauss=> create table stu(id varchar,name varchar);
CREATE TABLE
openGauss=> insert into stu values ('0001','name1'),('0002','name2'),('0003','name3'),('0004','name4');
INSERT 0 4
openGauss=> select * from stu ;
  id  | name  
------+-------
 0001 | name1
 0002 | name2
 0003 | name3
 0004 | name4
(4 rows)
在opengauss中写一个函数，第一个值是要选择的id，第二个值是其他id要被替换成的值。比如当id=0001要查表时，其他id被替换成****，name列不变
  id  | name  
------+-------
 0001 | name1
 **** | name2
 **** | name3
 **** | name4

比如当id=0002要查表时，显示如下
  id  | name  
------+-------
 **** | name1
 0002 | name2
 **** | name3
 **** | name4
 
 
openGauss=> CREATE OR REPLACE FUNCTION mask_id(var1 text, var2 text)
openGauss-> returns setof stu
openGauss-> as $$
openGauss$> DECLARE
openGauss$>   r stu % ROWTYPE;
openGauss$> BEGIN
openGauss$>   FOR r IN select case
openGauss$>                     when id = var1 then
openGauss$>                       id
openGauss$>                     else
openGauss$>                       '****'
openGauss$>                   end as id,
openGauss$>                   name
openGauss$>              from stu LOOP
openGauss$>     RETURN next r;
openGauss$>   end LOOP;
openGauss$>   RETURN;
openGauss$> end; $$ LANGUAGE plpgsql;
CREATE FUNCTION
openGauss=> call mask_id('0001','****');
  id  | name  
------+-------
 0001 | name1
 **** | name2
 **** | name3
 **** | name4
(4 rows)

openGauss=> call mask_id('0002','****');
  id  | name  
------+-------
 **** | name1
 0002 | name2
 **** | name3
 **** | name4
(4 rows)


/*
论述题：(不必一字不差背下来，但是该答的点要对)

使用存储过程的优点包括：（考试让写4个）

1. **提高性能**：存储过程在数据库服务器上进行编译和优化，可以减少网络通信开销，提高执行速度。
2. **重用性**：存储过程可以在多个应用程序中被调用，提高代码复用性，减少开发工作量。
3. **安全性**：存储过程可以对数据进行权限控制，只允许授权用户执行特定操作，提高数据安全性。
4. **简化复杂操作**：存储过程可以封装复杂的业务逻辑，简化应用程序的开发过程。
5. **减少数据传输**：存储过程可以返回结果集，减少了数据传输的量，提高了系统性能。
6. **良好的封装性**：在进行相对复杂的数据库操作时，原本需要使用一条一条的 SQL 语句，可能要连接多次数据库才能完成的操作，现在变成了一次存储过程，只需要连接一次即可。
7. **减少网络通信开销**：由于存储过程在数据库服务器上执行，因此可以减少客户端和服务器之间的网络通信开销。
8. **提高开发效率**：存储过程可以封装复杂的业务逻辑，使得开发人员可以专注于应用程序的开发，而不是数据库的操作。


存储过程和函数的区别如下：(考试让写3个)

1. **定义**：存储过程是SQL语句和可控制流程语句的预编译集合，以一个名称存储并作为一个单元处理。函数则是由一个或多个SQL语句组成的子程序，可用于封装代码以便重新使用。
2. **参数**：存储过程可以返回参数，如记录集，函数只能返回值或者表对象。存储过程的参数有in,out,inout三种，存储过程声明时不需要返回类型。而函数参数只有in，函数需要描述返回类型，且函数中必须包含一个有效的return语句。
3. **使用条件**：存储过程可以在单个存储过程中执行一系列SQL语句，而且可以从自己的存储过程内引用其他存储过程，这可以简化一系列复杂语句。而函数有许多限制，如不能使用临时表，只能使用表变量等。
4. **执行方式**：存储过程可以返回参数，如记录集，函数只能返回值或者表对象。
5. **功能**：存储过程可以用于执行一组修改全局数据库状态的操作。而函数则不能用于此类操作。
6. **性能**：由于存储过程是预编译的，因此其执行速度通常比函数快。


存储过程和匿名块的区别如下：(考试让写2个)
1. **定义**：存储过程是命名的SQL语句集合，可重复使用，不需声明变量。匿名块则是未命名的代码块，每次执行时都需要重新编写或粘贴。
2. **使用方式**：存储过程可以通过调用其名称来执行，无需每次都重新编写SQL语句。而匿名块则需要每次执行时重新编写或粘贴。
3. **重复使用性**：存储过程可以重复使用，减少代码的重复编写。而匿名块则无法重复使用。
4. **代码组织结构**：存储过程可以组织成模块化的结构，使得代码更加清晰和易于维护。而匿名块则没有这样的组织结构。


1、全量备份、差分备份和增量备份区别
全量备份是对数据库当前所有数据的整体备份，备份集一般较大，恢复时间较长。
差分备份是基于上一次全量备份之后的差异数据的备份，备份集一般比全量小，恢复时候要先恢复全量再恢复差异部分。
增量备份基于的是上一次增量，所以恢复时可能要恢复全量+多次增量备份。

2、全量备份、差分备份、增量备份集大小关系
一般情况下是全量>差分>增量

3、数据可以恢复到指定时间点，使用什么技术实现，与物理文件备份相比，这种依赖哪个关键文件。
使用的是PITR技术，主要依赖的是WAL日志文件。


1，数据库事务什么？GaussDB(for opengauss)如何管理事务？
数据库事务是一组具有ACID特性的能访问数据库内部对象的可执行序列。
OpenGauss这样开启并结束事务
oracle=> start transaction isolation level serializable read write;
START TRANSACTION
oracle=> end;
COMMIT
oracle=> start transaction isolation level READ COMMITTED READ WRITE;
START TRANSACTION
oracle=> end;
COMMIT
oracle=> start transaction isolation level repeatable READ READ WRITE;
START TRANSACTION
oracle=> end;
COMMIT


2，GaussDB(for opengauss)支持哪些事务隔离级别，每种如何理解？
三种隔离级别，分别是
read commited 读已提交：就是A窗口可以读到B窗口已提交的数据，未提交的无法读到。
repeatable read 可重复读：就是A窗口无法读到B窗口已提交的数据，事务开始时会生成读视图贯穿整个事务。
SERIALIZABLE 可串行化：事务只能串行执行，降低数据库效率，一般不采用。


3，使用命令启动一个事务，并且设置事务类型为只读
oracle=> start transaction isolation level repeatable read read only;
START TRANSACTION
oracle=> end;
COMMIT


RBAC和ABAC是两种不同的权限管理模型，它们的主要区别体现在以下几个方面：

1. 权限授予方式：RBAC是基于角色进行权限授予，即根据角色赋予权限。而ABAC则是基于属性进行权限授予，即根据用户、环境或资源的属性来决定是否赋予权限。
2. 灵活性：RBAC的模型构建相对简单，对于中小型组织来说，维护角色和授权关系的工作量不大，反而定制各种策略相对麻烦。而ABAC则更加灵活，可以根据用户特征、对象特征、操作类型等属性确定访问权限，适用于大型组织。
3. 粒度：RBAC控制整个组织的广泛访问，而ABAC则采用细粒度方法。这意味着在考虑RBAC与ABAC时，RBAC控制整个组织的广泛访问，而ABAC则采用细粒度方法。

ACL：访问控制列表


RBAC：基于角色的访问控制，角色通常是指具有某些共同特征的一组人，例如：部门、地点、资历、级别、工作职责等。
在系统初始时Admin根据业务需要创建多个拥有不同权限组合的不同角色，当需要赋予某个用户权限的时候，把用户归到相应角色里即可赋予符合需要的权限。

ABAC：基于属性的访问控制，这包括用户属性、环境属性和资源属性。
用户属性：包括如用户的姓名、角色、组织、ID和安全许可等内容
环境属性：包括如访问时间、数据的位置和当前组织的威胁等级。
资源属性：包括如创建日期、资源所有者、文件名和数据敏感性。

两者区别：
RBAC与ABAC之间的主要区别在于方法授予访问权限的方式。 RBAC按照角色授予访问权限，ABAC可以根据用户特征，对象特征，操作类型等属性确定访问权限。

ACL：访问控制列表


数据库数据加密方式有哪些，至少3种
对称加密 AES
非对称加密 DES
透明加密 TDE
行级访问控制
数据脱敏
*/