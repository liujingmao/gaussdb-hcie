1. 将staffs.csv、department.csv、patient.csv数据导入到对应的数据表中。

   ```sql
   myhcie2=# \dt
                              List of relations
    Schema |    Name    | Type  | Owner |             Storage
   --------+------------+-------+-------+----------------------------------
    public | department | table | omm   | {orientation=row,compression=no}
    public | patient    | table | omm   | {orientation=row,compression=no}
    public | staffs     | table | omm   | {orientation=row,compression=no}
   (3 rows)
   
   myhcie2=# \d staffs;
                Table "public.staffs"
      Column   |         Type          | Modifiers
   ------------+-----------------------+-----------
    s_id       | integer               |
    s_name     | character varying(32) |
    s_idcard   | character varying(50) |
    s_gender   | character(8)          |
    s_phone    | character varying(32) |
    s_d_id     | integer               |
    s_position | character varying(32) |
   
   myhcie2=# \d patient;
                     Table "public.patient"
       Column    |              Type              | Modifiers
   --------------+--------------------------------+-----------
    p_id         | character varying(32)          |
    p_name       | character varying(16)          |
    p_idcard     | character varying(32)          |
    p_phone      | character varying(16)          |
    p_kin        | character varying(16)          |
    p_kin_phone  | character varying(16)          |
    p_s_id       | character varying(16)          |
    p_m_id       | character varying(16)          |
    p_start_time | timestamp(0) without time zone |
    p_until_time | timestamp(0) without time zone |
    p_remark     | character varying(64)          |
   
   myhcie2=# \d department;
               Table "public.department"
      Column   |          Type           | Modifiers
   ------------+-------------------------+-----------
    d_id       | integer                 |
    d_name     | character varying(32)   |
    d_s_id     | character varying(16)   |
    d_descript | character varying(1024) |
   
   myhcie2=# select * from staffs;
    s_id | s_name |      s_idcard      | s_gender |   s_phone   | s_d_id | s_position
   ------+--------+--------------------+----------+-------------+--------+------------
    1001 | liyi   | 452132197403151541 | men      | 15121451623 |      1 | doctor
    1002 | lier   | 452132197512231542 | men      | 15221451623 |      1 | nurse
    1003 | lisan  | 452132197302251543 | woman    | 15321451623 |      2 | doctor
    1004 | lisi   | 452132198703031544 | men      | 15421451623 |      2 | nurse
    1005 | liwu   | 452132198611051545 | men      | 15521451623 |      3 | doctor
    1006 | liliu  | 452132199804051546 | woman    | 15621451623 |      3 | doctor
    1007 | liqi   | 452132200105051547 | men      | 15721451623 |      3 | nurse
    1008 | liba   | 452132199903051548 | woman    | 15821451623 |      2 | doctor
    1009 | lijiu  | 452132200005041549 | woman    | 15921451623 |      1 | nurse
    1010 | lishi  | 452132197608191540 | men      | 15021451623 |      1 | doctor
   (10 rows)
   
   myhcie2=# select * from patient;
        p_id     |  p_name  |      p_idcard      |   p_phone   |  p_kin  | p_kin_phone | p_s_id | p_m_id |    p_start_time     |    p_until_time     |
      p_remark
   --------------+----------+--------------------+-------------+---------+-------------+--------+--------+---------------------+---------------------+-------
   ----------------------
    202001020001 | zhangyi  | 532154199803215231 | 15325421650 | wangyi  | 15312542540 | 1001   | 1002   | 2020-01-02 00:00:00 | 2020-03-04 00:00:00 | Penici
   llin allergy
    202010020001 | zhanger  | 532154199711305232 | 15325421651 | wanger  | 15312542541 | 1003   | 1004   | 2020-10-02 00:00:00 | 2021-03-04 00:00:00 | No all
   ergy
    202110020001 | zhangsan | 532154195410315232 | 15325421652 | wangsan | 15312542542 | 1005   | 1007   | 2021-10-02 00:00:00 | 2021-03-04 00:00:00 | Antibi
   otic drug allergy
    202103020001 | zhangsi  | 532154202212125232 | 15325421653 | wangsi  | 15312542543 | 1005   | 1007   | 2021-03-02 00:00:00 | 2021-03-04 00:00:00 | No all
   ergy
    202210020001 | zhangwu  | 532154200403045232 | 15325421654 | wangwu  | 15312542544 | 1010   | 1002   | 2022-10-02 00:00:00 |                     | Allerg
   ies to sedative drugs
    202301020001 | zhangliu | 532154199905205232 | 15325421655 | wangliu | 15312542545 | 1010   | 1009   | 2023-01-02 00:00:00 |                     | No all
   ergy
   (6 rows)
   
   myhcie2=# select * from department;
    d_id |      d_name      | d_s_id |
               d_descript
   ------+------------------+--------+-----------------------------------------------------------------------------------------------------------------------
   ---------------------------------------------------------------------------------------------------------------------------------------------------------
       1 | Orthopedics      | 1001   | Orthopedics mainly refers to the correction or prevention of skeletal deformities in children; Refers to a clinical de
   partment that treats any bone or joint disease
       2 | Neurosurgery     | 1003   | Study the human nervous system such as the brain spinal cord and peripheral nervous system as well as the related subs
   idiary organs such as skull cerebrovascular and other structural injuries inflammation tumors deformities and other diseases
       3 | Gastroenterology | 1005   | A clinical tertiary discipline that focuses on diseases such as the esophagus stomach small intestine large intestine
   liver gallbladder and pancreas. There are various types of digestive diseases with a wide range of medical knowledge and complex and precise operations.
   (3 rows)
   ```

2. 查看“zhangsan”病患的家属信息（家属姓名、家属联系方式）。

   ```sql
   myhcie2=# select p_kin,p_kin_phone from patient where p_name = 'zhangsan';
     p_kin  | p_kin_phone
   ---------+-------------
    wangsan | 15312542542
   (1 row)
   ```

3. 请查看当前在就医病人是否有过敏史，如果有请查看具体过敏信息。

   ```sql
   select p.p_remark,d.d_descript from patient p,department d where d.d_s_id = d.d_s_id and p.p_remark != 'No allergy';                                     
   p_remark           |
          d_descript
   -----------------------------+----------------------------------------------------------------------------------------------------------------------------
   ----------------------------------------------------------------------------------------------------------------------------------------------------
    Penicillin allergy          | Orthopedics mainly refers to the correction or prevention of skeletal deformities in children; Refers to a clinical departm
   ent that treats any bone or joint disease
    Antibiotic drug allergy     | Orthopedics mainly refers to the correction or prevention of skeletal deformities in children; Refers to a clinical departm
   ent that treats any bone or joint disease
    Allergies to sedative drugs | Orthopedics mainly refers to the correction or prevention of skeletal deformities in children; Refers to a clinical departm
   ent that treats any bone or joint disease
    Penicillin allergy          | Study the human nervous system such as the brain spinal cord and peripheral nervous system as well as the related subsidiar
   y organs such as skull cerebrovascular and other structural injuries inflammation tumors deformities and other diseases
    Antibiotic drug allergy     | Study the human nervous system such as the brain spinal cord and peripheral nervous system as well as the related subsidiar
   y organs such as skull cerebrovascular and other structural injuries inflammation tumors deformities and other diseases
    Allergies to sedative drugs | Study the human nervous system such as the brain spinal cord and peripheral nervous system as well as the related subsidiar
   y organs such as skull cerebrovascular and other structural injuries inflammation tumors deformities and other diseases
    Penicillin allergy          | A clinical tertiary discipline that focuses on diseases such as the esophagus stomach small intestine large intestine liver
    gallbladder and pancreas. There are various types of digestive diseases with a wide range of medical knowledge and complex and precise operations.
    Antibiotic drug allergy     | A clinical tertiary discipline that focuses on diseases such as the esophagus stomach small intestine large intestine liver
    gallbladder and pancreas. There are various types of digestive diseases with a wide range of medical knowledge and complex and precise operations.
    Allergies to sedative drugs | A clinical tertiary discipline that focuses on diseases such as the esophagus stomach small intestine large intestine liver
    gallbladder and pancreas. There are various types of digestive diseases with a wide range of medical knowledge and complex and precise operations.
   (9 rows)
   ```
   
4. 查看由“lisi”负责监管的所有病人信息。

   ```sql
    select * from patient p,staffs s where p.p_m_id = s.s_id and s.s_name='lisi';
        p_id     | p_name  |      p_idcard      |   p_phone   | p_kin  | p_kin_phone
   | p_s_id | p_m_id |    p_start_time     |    p_until_time     |  p_remark  | s_id
   | s_name |      s_idcard      | s_gender |   s_phone   | s_d_id | s_position
   --------------+---------+--------------------+-------------+--------+-------------
   +--------+--------+---------------------+---------------------+------------+------
   +--------+--------------------+----------+-------------+--------+------------
    202010020001 | zhanger | 532154199711305232 | 15325421651 | wanger | 15312542541
   | 1003   | 1004   | 2020-10-02 00:00:00 | 2021-03-04 00:00:00 | No allergy | 1004
   | lisi   | 452132198703031544 | men      | 15421451623 |      2 | nurse
   (1 row)
   ```

5. 查看属于“Gastroenterology”科室的病人有哪些。

   ```sql
   myhcie2=# select * from patient p,department d where p.p_s_id=d.d_s_id and d.d_name = 'Gastroenterology';
        p_id     |  p_name  |      p_idcard      |   p_phone   |  p_kin  | p_kin_phone | p_s_id | p_m_id |    p_start_time     |
     p_until_time     |        p_remark         | d_id |      d_name      | d_s_id |
                                                                                        d_descript
   
   --------------+----------+--------------------+-------------+---------+-------------+--------+--------+---------------------+--
   -------------------+-------------------------+------+------------------+--------+----------------------------------------------
   -------------------------------------------------------------------------------------------------------------------------------
   ---------------------------------------------------------------------------------------------------
    202110020001 | zhangsan | 532154195410315232 | 15325421652 | wangsan | 15312542542 | 1005   | 1007   | 2021-10-02 00:00:00 | 2
   021-03-04 00:00:00 | Antibiotic drug allergy |    3 | Gastroenterology | 1005   | A clinical tertiary discipline that focuses o
   n diseases such as the esophagus stomach small intestine large intestine liver gallbladder and pancreas. There are various type
   s of digestive diseases with a wide range of medical knowledge and complex and precise operations.
    202103020001 | zhangsi  | 532154202212125232 | 15325421653 | wangsi  | 15312542543 | 1005   | 1007   | 2021-03-02 00:00:00 | 2
   021-03-04 00:00:00 | No allergy              |    3 | Gastroenterology | 1005   | A clinical tertiary discipline that focuses o
   n diseases such as the esophagus stomach small intestine large intestine liver gallbladder and pancreas. There are various type
   s of digestive diseases with a wide range of medical knowledge and complex and precise operations.
   (2 rows)
   
   老师给的答案：
   myhcie2=# 
   
   select 
   	p.* 
   from 
   	patient p,department d 
   where 
   	p.p_s_id=d.d_s_id 
   and 
   	d.d_name = 'Gastroenterology';
        p_id     |  p_name  |      p_idcard      |   p_phone   |  p_kin  | p_kin_phone | p_s_id | p_m_id |    p_start_time     |    p_until_time     |
    p_remark
   --------------+----------+--------------------+-------------+---------+-------------+--------+--------+---------------------+---------------------+-------
   ------------------
    202110020001 | zhangsan | 532154195410315232 | 15325421652 | wangsan | 15312542542 | 1005   | 1007   | 2021-10-02 00:00:00 | 2021-03-04 00:00:00 | Antibi
   otic drug allergy
    202103020001 | zhangsi  | 532154202212125232 | 15325421653 | wangsi  | 15312542543 | 1005   | 1007   | 2021-03-02 00:00:00 | 2021-03-04 00:00:00 | No all
   ergy
   (2 rows)
   ```

6. 查看各病人及对应的主治医师与监管护士姓名。

   ```sql
   myhcie2=# 
   
   select 
   	t1.p_name,t1.dn,t2.nn 
   		from 
   			(select 
                	p.p_name,s.s_name as dn from patient p,staffs s where s.s_id = p.p_s_id) t1 
                left join 
                	(select p.p_name,s.s_name as nn from patient p,staffs s where s.s_id = p.p_m_id) t2 
                	on t1.p_name = t2.p_name;
     p_name  |  dn   |  nn
   ----------+-------+-------
    zhangyi  | liyi  | lier
    zhanger  | lisan | lisi
    zhangsi  | liwu  | liqi
    zhangsan | liwu  | liqi
    zhangliu | lishi | lijiu
    zhangwu  | lishi | lier
    
    老师给的参考答案
    
    select 
    	p_name,s1.s_name dn,s2.s_name nn
    from 
    	patient p, staffs s1,staffs s2 
    where 
    	p.p_s_id=s1.s_id 
    and 
    	p.p_m_id=s2.s_id;
     p_name  |  dn   |  nn
   ----------+-------+-------
    zhangwu  | lishi | lier
    zhangyi  | liyi  | lier
    zhanger  | lisan | lisi
    zhangsan | liwu  | liqi
    zhangsi  | liwu  | liqi
    zhangliu | lishi | lijiu
   
   ```

   

7. 分别统计各科室的医生与护士数量为多少

   ```sql
   老师给的答案
   
   select d_name,s_position,count(1) from staffs s,department d where s.s_d_id=d.d_id group by d_name,s_position;
   myhcie2=# 
   select 
   	d_name,s_position,count(1) 
   from 
   	staffs s,department d 
   where 
   	s.s_d_id=d.d_id 
   group by 
   	d_name,s_position;
         d_name      | s_position | count
   ------------------+------------+-------
    Gastroenterology | doctor     |     2
    Neurosurgery     | doctor     |     2
    Gastroenterology | nurse      |     1
    Orthopedics      | doctor     |     2
    Neurosurgery     | nurse      |     1
    Orthopedics      | nurse      |     2
   
   ```

   

8. 统计各护士监管病人数为多少（输出护工工号、姓名、监管病人数）。

   ```sql
   myhcie2=# 
   select 
   	s.s_id, t2.nn,t2.count 
   from 
   		(select 
            	t1.nn,count(t1.p_name) 
           		from (select 
                         	s.s_id,s.s_name as nn,p.p_name 
                         from 
                         	patient p,staffs s 
                         where 
                         	s.s_id = p.p_m_id) t1 
           			 group by t1.nn) t2,staffs s where s.s_name = t2.nn;
    s_id |  nn   | count
   ------+-------+-------
    1002 | lier  |     2
    1004 | lisi  |     1
    1007 | liqi  |     2
    1009 | lijiu |     1
   (4 rows)
   ```

9. 统计目前各科室的在就医病人数量（输出科室名称，在就医病人数量）。提示：在就医病人指出院时间为空或出院时间大于当前时间的病人

   ```sql
   select 
   	d.d_name as "科室名称", 
   	t1.pn as "病人数量" 
   from 
   	(select 
        	p_s_id as ps,
        	count(p_name) as pn 
        from 
        	patient 
        group by 
        	p_s_id) t1,department d 
   where d.d_s_id = t1.ps;
        科室名称     | 病人数量
   ------------------+----------
    Orthopedics      |        1
    Neurosurgery     |        1
    Gastroenterology |        2
   
   ```

10. 根据病人身份证信息计算病人年龄（7-14位数字就是出生日期）。

    ```sql
    myhcie2=# 
    select  
    	p_name,p_idcard,
    	(to_char(now(),'yyyy')::int - SUBSTR(p_idcard,7,4)::int) as age 
    from patient;                 
    p_name  |      p_idcard      | age
    ----------+--------------------+-----
     zhangyi  | 532154199803215231 |  26
     zhanger  | 532154199711305232 |  27
     zhangsan | 532154195410315232 |  70
     zhangsi  | 532154202212125232 |   2
     zhangwu  | 532154200403045232 |  20
     zhangliu | 532154199905205232 |  25
    (6 rows)
    
    我的答案只精确到年，没有精确到月的计算
    
    老师给的答案
    myhcie2=# 
    select 
    	p_name,p_idcard,
    	date_part('year',age(substr(p_idcard,7,8))) as age 
    from patient;
      p_name  |      p_idcard      | age
    ----------+--------------------+-----
     zhangyi  | 532154199803215231 |  26
     zhanger  | 532154199711305232 |  26
     zhangsan | 532154195410315232 |  69
     zhangsi  | 532154202212125232 |   1
     zhangwu  | 532154200403045232 |  20
     zhangliu | 532154199905205232 |  25
     
     这个计算年龄精确到月份，比较准确
    ```

11. 在年龄达到60岁及以上的病人的备注栏中备注“高龄老人”，年龄小于等于14岁的病人备注“儿童”。

```sql
myhcie2=# 
select 
	t1.p_name,
	t1.p_idcard,
	t1.age,
	(case when age >=60 then '高龄老人' when age <=14 then '儿童' end) as "p_remarkv2" 
from 
	(select 
     	p_name,
     	p_idcard,
     	(to_char(now(),'yyyy')::int - SUBSTR(p_idcard,7,4)::int) as age 
     from 
     	patient) t1;
  
  p_name  |      p_idcard      | age | p_remarkv2
----------+--------------------+-----+------------
 zhangyi  | 532154199803215231 |  26 |
 zhanger  | 532154199711305232 |  27 |
 zhangsan | 532154195410315232 |  70 | 高龄老人
 zhangsi  | 532154202212125232 |   2 | 儿童
 zhangwu  | 532154200403045232 |  20 |
 zhangliu | 532154199905205232 |  25 |
```

