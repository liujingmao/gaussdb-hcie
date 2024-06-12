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
