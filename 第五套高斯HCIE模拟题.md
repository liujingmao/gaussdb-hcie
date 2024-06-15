#### 高斯IE第五套

##### 1. 数据库对象管理及SQL语法1

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

##### (2)

##### (3)

##### (4)

##### (5) 按第栋求出每栋楼所需要的营养值 





##### 2. 数据库对象管理及SQL语法2

##### (1) 创建user2用户，user2用户需要具备创建数据库的权限 

##### (2) 查询用户的连接数上限



##### 3. 数据库连接

##### 4. 安全审计

##### 5. 存储过程

##### 6. 触发器

##### 7. 性能调优

