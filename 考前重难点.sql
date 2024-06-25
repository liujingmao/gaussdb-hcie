-- 总结重难点
create or replace function fun_cal_point(id1 int,coursename varchar(30)) returns float as
$$
declare point float;
begin 
	case when coursename = 'math' then
	 select (
		case when math <=59 then 0
			 when math <=69 then 0.1
			 when math <=79 then 0.2
			 when math <=89 then 0.3
			 when math <=100 then 0.4        
	 else 0 end ) into point from stu where id = id1;
		when coursename = 'art' then	 
	 select (
		case when art <=59 then 0
			 when art <=69 then 0.1
			 when art <=79 then 0.2
			 when art <=89 then 0.3
			 when art <=100 then 0.4       
	 else 0 end ) into point from stu where id = id1; 
	 when coursename = 'phy' then	 
	 select (
		case when phy <=59 then 0
			 when phy <=69 then 0.1
			 when phy <=79 then 0.2
			 when phy <=89 then 0.3
			 when phy <=100 then 0.4
	         else 0 end ) into point from stu where id = id1;
	 else raise notice '请输入正确的科目';
	 end case;
	 return point;
end;
$$language plpgsql;



select id,(fun_cal_point(id,'math')+fun_cal_point(id,'art')+fun_cal_point(id,'phy')) as g from stu;