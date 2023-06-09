--
-- PostgreSQL database dump
--

-- Dumped from database version 10.16
-- Dumped by pg_dump version 10.16

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- Name: company; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA company;


ALTER SCHEMA company OWNER TO postgres;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: adminpack; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION adminpack; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';


--
-- Name: d_update(); Type: FUNCTION; Schema: company; Owner: postgres
--

CREATE FUNCTION company.d_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

    if(SELECT SUM(t.truancies) FROM company.department AS d, (SELECT truancies, department_id FROM company.information) AS t

                    WHERE d.department_id=t.department_id AND d.departmentname=new.departmentname) > 0

        then

        new.total_truancies = (SELECT SUM(t.truancies) FROM company.department AS d, (SELECT truancies, department_id FROM company.information) AS t

                    WHERE d.department_id=t.department_id AND d.departmentname=new.departmentname);

    end if;

    return new;

END;

$$;


ALTER FUNCTION company.d_update() OWNER TO postgres;

--
-- Name: delete_data_cell_email(text, text); Type: FUNCTION; Schema: company; Owner: postgres
--

CREATE FUNCTION company.delete_data_cell_email(cell text, e text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    info_id1 int;
    stime_id1 int;
    wterm_id1 int;
    e_id1 int;
BEGIN
    info_id1 = (SELECT info_id FROM company.information WHERE cellnumber=cell AND email=e);
    stime_id1 = (SELECT stime_id FROM company.information WHERE cellnumber=cell AND email=e);
    wterm_id1 = (SELECT wterm_id FROM company.shift_time
    WHERE stime_id=((SELECT stime_id FROM company.information WHERE cellnumber=cell AND email=e)));
    e_id1 = (SELECT e_id FROM company.information WHERE cellnumber=cell AND email=e);

    DELETE FROM company.information WHERE info_id=info_id1;
    DELETE FROM company.employee WHERE e_id=e_id1;
    DELETE FROM company.shift_time WHERE stime_id=stime_id1;
    DELETE FROM company.working_term WHERE wterm_id = wterm_id1;
    
END
$$;


ALTER FUNCTION company.delete_data_cell_email(cell text, e text) OWNER TO postgres;

--
-- Name: delete_data_wid(integer, integer, integer); Type: FUNCTION; Schema: company; Owner: postgres
--

CREATE FUNCTION company.delete_data_wid(wt_id integer, st_id integer, eid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN

    DELETE FROM company.working_term WHERE wterm_id = wt_id;

    DELETE FROM company.shift_time WHERE stime_id=st_id;

    DELETE FROM company.information WHERE stime_id=st_id;

    DELETE FROM company.employee WHERE e_id=eid;

END

$$;


ALTER FUNCTION company.delete_data_wid(wt_id integer, st_id integer, eid integer) OWNER TO postgres;

--
-- Name: delete_data_wid(integer, integer, integer, integer); Type: FUNCTION; Schema: company; Owner: postgres
--

CREATE FUNCTION company.delete_data_wid(i_id integer, eid integer, st_id integer, wt_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN

    DELETE FROM company.information WHERE info_id=i_id;

    DELETE FROM company.employee WHERE e_id=eid;

    DELETE FROM company.shift_time WHERE stime_id=st_id;

    DELETE FROM company.working_term WHERE wterm_id = wt_id;

END

$$;


ALTER FUNCTION company.delete_data_wid(i_id integer, eid integer, st_id integer, wt_id integer) OWNER TO postgres;

--
-- Name: delete_department_name_post(text, text); Type: FUNCTION; Schema: company; Owner: postgres
--

CREATE FUNCTION company.delete_department_name_post(dname text, pname text) RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN

    DELETE FROM company.department WHERE department_id=(SELECT department_id

    FROM company.department WHERE departmentname=dname AND postname=pname);

END

$$;


ALTER FUNCTION company.delete_department_name_post(dname text, pname text) OWNER TO postgres;

--
-- Name: delete_department_wid(integer); Type: FUNCTION; Schema: company; Owner: postgres
--

CREATE FUNCTION company.delete_department_wid(d_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN

    DELETE FROM company.department WHERE department_id=d_id;

END

$$;


ALTER FUNCTION company.delete_department_wid(d_id integer) OWNER TO postgres;

--
-- Name: getenumb(integer); Type: FUNCTION; Schema: company; Owner: postgres
--

CREATE FUNCTION company.getenumb(eid integer) RETURNS TABLE(name text, surname text, cell character varying, t integer)
    LANGUAGE plpgsql
    AS $$

BEGIN

    RETURN query SELECT employee.name, employee.surname, cellnumber, truancies

        FROM company.employee, company.information, company.shift_time

        WHERE employee.e_id=eid AND information.e_id=eid AND information.stime_id=shift_time.stime_id;

END

$$;


ALTER FUNCTION company.getenumb(eid integer) OWNER TO postgres;

--
-- Name: info_check(); Type: FUNCTION; Schema: company; Owner: postgres
--

CREATE FUNCTION company.info_check() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

    if(SELECT (SELECT appeared FROM company.working_term WHERE wterm_id=(SELECT wterm_id FROM company.shift_time WHERE stime_id=new.stime_id))) = false

        then

        new.truancies = new.truancies + 1;

    end if;

    return new;

END;

$$;


ALTER FUNCTION company.info_check() OWNER TO postgres;

--
-- Name: info_delete(); Type: FUNCTION; Schema: company; Owner: postgres
--

CREATE FUNCTION company.info_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

    if (SELECT old.truancies) > 0 THEN

        UPDATE company.department SET total_truancies = total_truancies - (SELECT old.truancies)

        WHERE department_id=old.department_id;

    end if;

    return new;

END;

$$;


ALTER FUNCTION company.info_delete() OWNER TO postgres;

--
-- Name: insert_data(text, text, integer, text, text, timestamp without time zone, timestamp without time zone, integer); Type: FUNCTION; Schema: company; Owner: postgres
--

CREATE FUNCTION company.insert_data(n text, s text, d_id integer, em text, cell text, atm timestamp without time zone, ltm timestamp without time zone, st integer) RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN

    INSERT INTO company.employee(e_id, name, surname)  VALUES ((SELECT (SELECT MAX(e_id) FROM company.employee) + 1), n, s);

    INSERT INTO company.working_term(wterm_id, arrivaltime, leavingtime) VALUES ((SELECT (SELECT MAX(wterm_id) FROM company.working_term) + 1), atm, ltm);

    INSERT INTO company.shift_time(stime_id, shifttime, wterm_id) VALUES ((SELECT (SELECT MAX(wterm_id) FROM company.shift_time) + 1), st, (SELECT MAX(wterm_id) FROM company.working_term));

    INSERT INTO company.information(info_id, department_id, email, cellnumber, e_id, stime_id) VALUES ((SELECT (SELECT MAX(info_id) FROM company.information) + 1), d_id, em, cell, (SELECT MAX(e_id) FROM company.employee), (SELECT MAX(shift_time.stime_id) FROM company.shift_time));

END

$$;


ALTER FUNCTION company.insert_data(n text, s text, d_id integer, em text, cell text, atm timestamp without time zone, ltm timestamp without time zone, st integer) OWNER TO postgres;

--
-- Name: insert_department(text, text, text); Type: FUNCTION; Schema: company; Owner: postgres
--

CREATE FUNCTION company.insert_department(departmentn text, sname text, pname text) RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN

    INSERT INTO company.department(department_id, departmentname, supervisorname, postname) 

    VALUES ((SELECT (SELECT MAX(department_id) FROM company.department) + 1), departmentn, sname, pname);

END

$$;


ALTER FUNCTION company.insert_department(departmentn text, sname text, pname text) OWNER TO postgres;

--
-- Name: return_department_id(text, text); Type: FUNCTION; Schema: company; Owner: postgres
--

CREATE FUNCTION company.return_department_id(dname text, pname text) RETURNS integer
    LANGUAGE plpgsql
    AS $$

DECLARE

    d_id int;

BEGIN

    d_id = (SELECT department_id FROM company.department WHERE departmentname=dname AND postname=pname);

    RETURN d_id;

END

$$;


ALTER FUNCTION company.return_department_id(dname text, pname text) OWNER TO postgres;

--
-- Name: t_amount(); Type: FUNCTION; Schema: company; Owner: postgres
--

CREATE FUNCTION company.t_amount() RETURNS real
    LANGUAGE plpgsql
    AS $$

DECLARE

    avgs REAL;

BEGIN

    avgs = (SELECT AVG(truancies) FROM company.information);

    RETURN avgs;

END

$$;


ALTER FUNCTION company.t_amount() OWNER TO postgres;

--
-- Name: t_update(text); Type: FUNCTION; Schema: company; Owner: postgres
--

CREATE FUNCTION company.t_update(dname text) RETURNS integer
    LANGUAGE plpgsql
    AS $$

DECLARE

    crs_my CURSOR FOR SELECT DISTINCT d.departmentname, t.truancies FROM company.department AS d, (SELECT truancies, department_id FROM company.information) AS t

                    WHERE d.department_id=t.department_id AND d.departmentname=dname;

    _i_id int;

    _dname text;

    tr int;

    sum int;

BEGIN

    OPEN crs_my;

    LOOP

        FETCH crs_my INTO _dname, tr;

        IF NOT FOUND THEN EXIT;

        end if;

        sum=tr;

        UPDATE company.department SET total_truancies=sum WHERE departmentname=_dname;

    end loop;

    CLOSE crs_my;

    RETURN sum;

END

$$;


ALTER FUNCTION company.t_update(dname text) OWNER TO postgres;

--
-- Name: truancy_check(integer); Type: FUNCTION; Schema: company; Owner: postgres
--

CREATE FUNCTION company.truancy_check(eid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN

    UPDATE company.information SET truancies=truancies + 1 WHERE e_id=eid;

    IF (eid != ALL(SELECT employee.e_id FROM company.employee)) THEN

        RAISE EXCEPTION using

            errcode='mismatch',

            message='your id isnt correct',

            hint='id is incorrect';

        ROLLBACK;

    end if;

    IF (SELECT appeared FROM company.working_term

    WHERE wterm_id=(SELECT wterm_id FROM company.shift_time

    WHERE stime_id=(SELECT stime_id FROM company.information WHERE e_id=eid))) = true THEN

        RAISE EXCEPTION using

            errcode='mismatch',

            message='The employee appeared',

            hint='The employee appeared';

        ROLLBACK;

    end if;

EXCEPTION WHEN others THEN

        RAISE NOTICE 'SQLSTATE: %', SQLSTATE;

        RAISE;

END

$$;


ALTER FUNCTION company.truancy_check(eid integer) OWNER TO postgres;

--
-- Name: update_department(integer, text, text, text); Type: FUNCTION; Schema: company; Owner: postgres
--

CREATE FUNCTION company.update_department(d_id integer, dname text, sname text, pname text) RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN

    UPDATE company.department SET departmentname=dname, supervisorname=sname, postname=pname WHERE department_id=d_id;

END

$$;


ALTER FUNCTION company.update_department(d_id integer, dname text, sname text, pname text) OWNER TO postgres;

--
-- Name: update_emp(); Type: FUNCTION; Schema: company; Owner: postgres
--

CREATE FUNCTION company.update_emp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

    IF new.name <> old.name THEN

        UPDATE company.employee SET name = new.name

        WHERE name = old.name AND surname = old.surname;

    end if;

    IF new.surname <> old.surname THEN

        UPDATE company.employee SET surname = new.surname

        WHERE name = old.name AND surname = old.surname;

    end if;

    IF new.cellnumber <> old.cellnumber THEN

        UPDATE company.information SET cellnumber = new.cellnumber

        WHERE cellnumber = old.cellnumber AND email = old.email;

    end if;

    IF new.email <> old.email THEN

        UPDATE company.information SET email = new.email

        WHERE cellnumber = old.cellnumber AND email = old.email;

    end if;

    RETURN new;

END;

$$;


ALTER FUNCTION company.update_emp() OWNER TO postgres;

--
-- Name: update_employee(integer, text, text); Type: FUNCTION; Schema: company; Owner: postgres
--

CREATE FUNCTION company.update_employee(eid integer, n text, s text) RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN

    UPDATE company.employee SET name=n, surname=s WHERE e_id=eid;

END

$$;


ALTER FUNCTION company.update_employee(eid integer, n text, s text) OWNER TO postgres;

--
-- Name: update_information(integer, text, text, integer); Type: FUNCTION; Schema: company; Owner: postgres
--

CREATE FUNCTION company.update_information(i_id integer, em text, cell text, tr integer) RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN

    UPDATE company.information SET email=em, cellnumber=cell, truancies=tr WHERE info_id=i_id;

END

$$;


ALTER FUNCTION company.update_information(i_id integer, em text, cell text, tr integer) OWNER TO postgres;

--
-- Name: update_stime(integer, integer); Type: FUNCTION; Schema: company; Owner: postgres
--

CREATE FUNCTION company.update_stime(st_id integer, st integer) RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN

    UPDATE company.shift_time SET shifttime=st WHERE stime_id=st_id;

END

$$;


ALTER FUNCTION company.update_stime(st_id integer, st integer) OWNER TO postgres;

--
-- Name: update_wterm(integer, timestamp without time zone, timestamp without time zone, boolean); Type: FUNCTION; Schema: company; Owner: postgres
--

CREATE FUNCTION company.update_wterm(wt_id integer, atm timestamp without time zone, ltm timestamp without time zone, apprd boolean) RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN

    UPDATE company.working_term SET arrivaltime=atm, leavingtime=ltm, appeared=apprd WHERE wterm_id=wt_id;

END

$$;


ALTER FUNCTION company.update_wterm(wt_id integer, atm timestamp without time zone, ltm timestamp without time zone, apprd boolean) OWNER TO postgres;

--
-- Name: updtnumber(integer, text); Type: FUNCTION; Schema: company; Owner: postgres
--

CREATE FUNCTION company.updtnumber(eid integer, cnum text) RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN

    UPDATE company.information SET cellnumber = cnum WHERE cellnumber = (SELECT cell FROM GetENumb(eid));

END;

$$;


ALTER FUNCTION company.updtnumber(eid integer, cnum text) OWNER TO postgres;

--
-- Name: view_insert(); Type: FUNCTION; Schema: company; Owner: postgres
--

CREATE FUNCTION company.view_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

    PERFORM insert_data(new.name, new.surname, (SELECT department_id FROM company.department

    WHERE departmentname=new.departmentname AND postname=new.postname), new.email, new.cellnumber, new.arrivaltime, new.leavingtime, new.shifttime);

    return new;

END;

$$;


ALTER FUNCTION company.view_insert() OWNER TO postgres;

--
-- Name: info_check(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.info_check() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

    if(SELECT (SELECT appeared FROM company.working_term WHERE wterm_id=(SELECT wterm_id FROM company.shift_time WHERE stime_id=i.stime_id))

    FROM (SELECT stime_id FROM company.information) AS i) = true then

        new.truancies = new.truancies + 1;



    end if;

    return new;

END;

$$;


ALTER FUNCTION public.info_check() OWNER TO postgres;

--
-- Name: info_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.info_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

    if (SELECT truancies FROM company.information WHERE department_id=old.department_id) > 0 THEN

        UPDATE company.department SET total_truancies = total_truancies - (SELECT truancies FROM company.information WHERE department_id=old.department_id)

        WHERE department_id=old.department_id;

    end if;

    return new;

END;

$$;


ALTER FUNCTION public.info_delete() OWNER TO postgres;

--
-- Name: update_emp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_emp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

    IF new.name <> old.name THEN

        UPDATE company.employee SET name = new.name

        WHERE name = old.name AND surname = old.surname;

    end if;

    IF new.surname <> old.surname THEN

        UPDATE company.employee SET surname = new.surname

        WHERE name = old.name AND surname = old.surname;

    end if;

    IF new.cellnumber <> old.cellnumber THEN

        UPDATE company.information SET cellnumber = new.cellnumber

        WHERE cellnumber = old.cellnumber AND email = old.email;

    end if;

    IF new.email <> old.email THEN

        UPDATE company.information SET email = new.email

        WHERE cellnumber = old.cellnumber AND email = old.email;

    end if;

END;

$$;


ALTER FUNCTION public.update_emp() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: working_term; Type: TABLE; Schema: company; Owner: postgres
--

CREATE TABLE company.working_term (
    wterm_id integer NOT NULL,
    arrivaltime timestamp without time zone NOT NULL,
    leavingtime timestamp without time zone NOT NULL,
    appeared boolean DEFAULT true
);


ALTER TABLE company.working_term OWNER TO postgres;

--
-- Name: Working term_wterm_id_seq; Type: SEQUENCE; Schema: company; Owner: postgres
--

CREATE SEQUENCE company."Working term_wterm_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE company."Working term_wterm_id_seq" OWNER TO postgres;

--
-- Name: Working term_wterm_id_seq; Type: SEQUENCE OWNED BY; Schema: company; Owner: postgres
--

ALTER SEQUENCE company."Working term_wterm_id_seq" OWNED BY company.working_term.wterm_id;


--
-- Name: department; Type: TABLE; Schema: company; Owner: postgres
--

CREATE TABLE company.department (
    department_id integer NOT NULL,
    departmentname text,
    supervisorname text,
    postname text,
    total_truancies integer DEFAULT 0
);


ALTER TABLE company.department OWNER TO postgres;

--
-- Name: department_department_id_seq; Type: SEQUENCE; Schema: company; Owner: postgres
--

CREATE SEQUENCE company.department_department_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE company.department_department_id_seq OWNER TO postgres;

--
-- Name: department_department_id_seq; Type: SEQUENCE OWNED BY; Schema: company; Owner: postgres
--

ALTER SEQUENCE company.department_department_id_seq OWNED BY company.department.department_id;


--
-- Name: employee; Type: TABLE; Schema: company; Owner: postgres
--

CREATE TABLE company.employee (
    e_id integer NOT NULL,
    name text NOT NULL,
    surname text NOT NULL
);


ALTER TABLE company.employee OWNER TO postgres;

--
-- Name: information; Type: TABLE; Schema: company; Owner: postgres
--

CREATE TABLE company.information (
    info_id integer NOT NULL,
    department_id integer NOT NULL,
    email text,
    cellnumber character varying(12) NOT NULL,
    e_id integer,
    stime_id integer,
    truancies integer DEFAULT 0
);


ALTER TABLE company.information OWNER TO postgres;

--
-- Name: e_info; Type: VIEW; Schema: company; Owner: postgres
--

CREATE VIEW company.e_info AS
 SELECT e.name,
    e.surname,
    i.cellnumber,
    i.email
   FROM (company.employee e
     LEFT JOIN company.information i ON ((e.e_id = i.e_id)));


ALTER TABLE company.e_info OWNER TO postgres;

--
-- Name: employee_e_id_seq; Type: SEQUENCE; Schema: company; Owner: postgres
--

CREATE SEQUENCE company.employee_e_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE company.employee_e_id_seq OWNER TO postgres;

--
-- Name: employee_e_id_seq; Type: SEQUENCE OWNED BY; Schema: company; Owner: postgres
--

ALTER SEQUENCE company.employee_e_id_seq OWNED BY company.employee.e_id;


--
-- Name: information_department_id_seq; Type: SEQUENCE; Schema: company; Owner: postgres
--

CREATE SEQUENCE company.information_department_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE company.information_department_id_seq OWNER TO postgres;

--
-- Name: information_department_id_seq; Type: SEQUENCE OWNED BY; Schema: company; Owner: postgres
--

ALTER SEQUENCE company.information_department_id_seq OWNED BY company.information.department_id;


--
-- Name: information_e_id_seq; Type: SEQUENCE; Schema: company; Owner: postgres
--

CREATE SEQUENCE company.information_e_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE company.information_e_id_seq OWNER TO postgres;

--
-- Name: information_e_id_seq; Type: SEQUENCE OWNED BY; Schema: company; Owner: postgres
--

ALTER SEQUENCE company.information_e_id_seq OWNED BY company.information.e_id;


--
-- Name: information_info_id_seq; Type: SEQUENCE; Schema: company; Owner: postgres
--

CREATE SEQUENCE company.information_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE company.information_info_id_seq OWNER TO postgres;

--
-- Name: information_info_id_seq; Type: SEQUENCE OWNED BY; Schema: company; Owner: postgres
--

ALTER SEQUENCE company.information_info_id_seq OWNED BY company.information.info_id;


--
-- Name: information_stime_id_seq; Type: SEQUENCE; Schema: company; Owner: postgres
--

CREATE SEQUENCE company.information_stime_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE company.information_stime_id_seq OWNER TO postgres;

--
-- Name: information_stime_id_seq; Type: SEQUENCE OWNED BY; Schema: company; Owner: postgres
--

ALTER SEQUENCE company.information_stime_id_seq OWNED BY company.information.stime_id;


--
-- Name: shift_time; Type: TABLE; Schema: company; Owner: postgres
--

CREATE TABLE company.shift_time (
    stime_id integer NOT NULL,
    shifttime integer NOT NULL,
    wterm_id integer
);


ALTER TABLE company.shift_time OWNER TO postgres;

--
-- Name: shift_time_stime_id_seq; Type: SEQUENCE; Schema: company; Owner: postgres
--

CREATE SEQUENCE company.shift_time_stime_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE company.shift_time_stime_id_seq OWNER TO postgres;

--
-- Name: shift_time_stime_id_seq; Type: SEQUENCE OWNED BY; Schema: company; Owner: postgres
--

ALTER SEQUENCE company.shift_time_stime_id_seq OWNED BY company.shift_time.stime_id;


--
-- Name: shift_time_wterm_id_seq; Type: SEQUENCE; Schema: company; Owner: postgres
--

CREATE SEQUENCE company.shift_time_wterm_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE company.shift_time_wterm_id_seq OWNER TO postgres;

--
-- Name: shift_time_wterm_id_seq; Type: SEQUENCE OWNED BY; Schema: company; Owner: postgres
--

ALTER SEQUENCE company.shift_time_wterm_id_seq OWNED BY company.shift_time.wterm_id;


--
-- Name: view1; Type: VIEW; Schema: company; Owner: postgres
--

CREATE VIEW company.view1 AS
 SELECT e.name,
    e.surname,
    i.cellnumber,
    i.email,
    d.departmentname,
    d.postname,
    w.arrivaltime,
    w.leavingtime,
    s.shifttime
   FROM ((((company.employee e
     LEFT JOIN company.information i ON ((e.e_id = i.e_id)))
     LEFT JOIN company.department d ON ((i.department_id = d.department_id)))
     LEFT JOIN company.shift_time s ON ((i.stime_id = s.stime_id)))
     LEFT JOIN company.working_term w ON ((s.wterm_id = w.wterm_id)));


ALTER TABLE company.view1 OWNER TO postgres;

--
-- Name: department; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.department (
    department_id integer NOT NULL,
    departmentname text NOT NULL,
    supervisorname text NOT NULL,
    postname text NOT NULL
);


ALTER TABLE public.department OWNER TO postgres;

--
-- Name: department_department_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.department_department_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.department_department_id_seq OWNER TO postgres;

--
-- Name: department_department_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.department_department_id_seq OWNED BY public.department.department_id;


--
-- Name: e_info; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.e_info AS
 SELECT e.name,
    e.surname,
    i.cellnumber,
    i.email
   FROM (company.employee e
     LEFT JOIN company.information i ON ((e.e_id = i.e_id)));


ALTER TABLE public.e_info OWNER TO postgres;

--
-- Name: employee; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee (
    e_id integer NOT NULL,
    name text NOT NULL,
    surname text NOT NULL
);


ALTER TABLE public.employee OWNER TO postgres;

--
-- Name: employee_e_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employee_e_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employee_e_id_seq OWNER TO postgres;

--
-- Name: employee_e_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employee_e_id_seq OWNED BY public.employee.e_id;


--
-- Name: information; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.information (
    info_id integer NOT NULL,
    department_id integer NOT NULL,
    email text,
    cellnumber text NOT NULL,
    e_id integer NOT NULL,
    stime_id integer NOT NULL
);


ALTER TABLE public.information OWNER TO postgres;

--
-- Name: information_department_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.information_department_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.information_department_id_seq OWNER TO postgres;

--
-- Name: information_department_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.information_department_id_seq OWNED BY public.information.department_id;


--
-- Name: information_e_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.information_e_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.information_e_id_seq OWNER TO postgres;

--
-- Name: information_e_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.information_e_id_seq OWNED BY public.information.e_id;


--
-- Name: information_info_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.information_info_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.information_info_id_seq OWNER TO postgres;

--
-- Name: information_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.information_info_id_seq OWNED BY public.information.info_id;


--
-- Name: information_stime_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.information_stime_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.information_stime_id_seq OWNER TO postgres;

--
-- Name: information_stime_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.information_stime_id_seq OWNED BY public.information.stime_id;


--
-- Name: shift_time; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shift_time (
    stime_id integer NOT NULL,
    shifttime integer NOT NULL,
    wterm_id integer NOT NULL
);


ALTER TABLE public.shift_time OWNER TO postgres;

--
-- Name: shift_time_stime_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shift_time_stime_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shift_time_stime_id_seq OWNER TO postgres;

--
-- Name: shift_time_stime_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shift_time_stime_id_seq OWNED BY public.shift_time.stime_id;


--
-- Name: shift_time_wterm_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shift_time_wterm_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shift_time_wterm_id_seq OWNER TO postgres;

--
-- Name: shift_time_wterm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shift_time_wterm_id_seq OWNED BY public.shift_time.wterm_id;


--
-- Name: working_term; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.working_term (
    wterm_id integer NOT NULL,
    arrivaltime timestamp without time zone NOT NULL,
    leavingtime timestamp without time zone NOT NULL
);


ALTER TABLE public.working_term OWNER TO postgres;

--
-- Name: working_term_wterm_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.working_term_wterm_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.working_term_wterm_id_seq OWNER TO postgres;

--
-- Name: working_term_wterm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.working_term_wterm_id_seq OWNED BY public.working_term.wterm_id;


--
-- Name: department department_id; Type: DEFAULT; Schema: company; Owner: postgres
--

ALTER TABLE ONLY company.department ALTER COLUMN department_id SET DEFAULT nextval('company.department_department_id_seq'::regclass);


--
-- Name: employee e_id; Type: DEFAULT; Schema: company; Owner: postgres
--

ALTER TABLE ONLY company.employee ALTER COLUMN e_id SET DEFAULT nextval('company.employee_e_id_seq'::regclass);


--
-- Name: information info_id; Type: DEFAULT; Schema: company; Owner: postgres
--

ALTER TABLE ONLY company.information ALTER COLUMN info_id SET DEFAULT nextval('company.information_info_id_seq'::regclass);


--
-- Name: information department_id; Type: DEFAULT; Schema: company; Owner: postgres
--

ALTER TABLE ONLY company.information ALTER COLUMN department_id SET DEFAULT nextval('company.information_department_id_seq'::regclass);


--
-- Name: information e_id; Type: DEFAULT; Schema: company; Owner: postgres
--

ALTER TABLE ONLY company.information ALTER COLUMN e_id SET DEFAULT nextval('company.information_e_id_seq'::regclass);


--
-- Name: information stime_id; Type: DEFAULT; Schema: company; Owner: postgres
--

ALTER TABLE ONLY company.information ALTER COLUMN stime_id SET DEFAULT nextval('company.information_stime_id_seq'::regclass);


--
-- Name: shift_time stime_id; Type: DEFAULT; Schema: company; Owner: postgres
--

ALTER TABLE ONLY company.shift_time ALTER COLUMN stime_id SET DEFAULT nextval('company.shift_time_stime_id_seq'::regclass);


--
-- Name: shift_time wterm_id; Type: DEFAULT; Schema: company; Owner: postgres
--

ALTER TABLE ONLY company.shift_time ALTER COLUMN wterm_id SET DEFAULT nextval('company.shift_time_wterm_id_seq'::regclass);


--
-- Name: working_term wterm_id; Type: DEFAULT; Schema: company; Owner: postgres
--

ALTER TABLE ONLY company.working_term ALTER COLUMN wterm_id SET DEFAULT nextval('company."Working term_wterm_id_seq"'::regclass);


--
-- Name: department department_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department ALTER COLUMN department_id SET DEFAULT nextval('public.department_department_id_seq'::regclass);


--
-- Name: employee e_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee ALTER COLUMN e_id SET DEFAULT nextval('public.employee_e_id_seq'::regclass);


--
-- Name: information info_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.information ALTER COLUMN info_id SET DEFAULT nextval('public.information_info_id_seq'::regclass);


--
-- Name: information department_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.information ALTER COLUMN department_id SET DEFAULT nextval('public.information_department_id_seq'::regclass);


--
-- Name: information e_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.information ALTER COLUMN e_id SET DEFAULT nextval('public.information_e_id_seq'::regclass);


--
-- Name: information stime_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.information ALTER COLUMN stime_id SET DEFAULT nextval('public.information_stime_id_seq'::regclass);


--
-- Name: shift_time stime_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shift_time ALTER COLUMN stime_id SET DEFAULT nextval('public.shift_time_stime_id_seq'::regclass);


--
-- Name: shift_time wterm_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shift_time ALTER COLUMN wterm_id SET DEFAULT nextval('public.shift_time_wterm_id_seq'::regclass);


--
-- Name: working_term wterm_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.working_term ALTER COLUMN wterm_id SET DEFAULT nextval('public.working_term_wterm_id_seq'::regclass);


--
-- Data for Name: department; Type: TABLE DATA; Schema: company; Owner: postgres
--

COPY company.department (department_id, departmentname, supervisorname, postname, total_truancies) FROM stdin;
7	hqc	╨б╤В╨░╨╜╨╕╤Б╨╗╨░╨▓ ╨в╤А╨╕╨╜╨╛╨╢╨╡╨╜╨║╨╛	╨Ъ╤Г╤А╨░╤В╨╛╤А	0
6	a4tech	╨Ъ╨╕╤А╨╕╨╗╨╗ ╨Ы╤Л╤Б╤М╨║╨╛	╨Э╨░╨▒╨╗╤О╨┤╨░╤В╨╡╨╗╤М ╨╛╤В╨┤╨╡╨╗╨░	1
5	NTech	╨Т╨░╨╗╨╡╤А╨╕╨╣ ╨Ц╨╝╤Л╤И╨╡╨╜╨║╨╛	╨Ю╤Е╤А╨░╨╜╨╜╨╕╨║	2
2	BTMC	╨Ь╨╕╤Е╨░╨╕╨╗ ╨Ю╨╗╨╡╨│╨╛╨▓╨╕╤З	╨Э╨░╨▒╨╗╤О╨┤╨░╤В╨╡╨╗╤М ╨╛╤В╨┤╨╡╨╗╨░	3
1	BTMC	╨Ь╨╕╤Е╨░╨╕╨╗ ╨Ю╨╗╨╡╨│╨╛╨▓╨╕╤З	╨С╤Г╤Е╨│╨░╨╗╤В╨╡╤А	3
3	4scheme	╨Ь╨░╨╣╨║ ╨Т╨░╨╖╨╛╨▓╤Б╨║╨╕	╨У╨╗╨░╨▓╨░ ╨╛╤В╨┤╨╡╨╗╨░	2
4	4scheme	╨Ь╨░╨╣╨║ ╨Т╨░╨╖╨╛╨▓╤Б╨║╨╕	╨Э╨░╤З╨░╨╗╤М╨╜╨╕╨║	1
0	NTech	╨Т╨░╨╗╨╡╤А╨╕╨╣ ╨Ц╨╝╤Л╤И╨╡╨╜╨║╨╛	╨а╨░╨╖╤А╨░╨▒╨╛╤В╤З╨╕╨║	1
11	DDF	╨б╨╡╤А╨│╨╡╨╣ ╨Ю╤А╨╗╨╛╨▓	╨б╨╗╨╡╤Б╨░╤А╤М	0
8	BHQ	╨Ш╨│╨╛╤А╤М ╨Ъ╨╛╨╝╨░╤А╨╛╨▓	╨У╨╗╨░╨▓╨░ ╨╛╤В╨┤╨╡╨╗╨░	0
9	FFD	╨Р╨╗╨╡╨║╤Б╨░╨╜╨┤╤А ╨б╨░╤А╨░╨╜╤Б╨║╨╕╨╣	Chief Operating Officer	0
\.


--
-- Data for Name: employee; Type: TABLE DATA; Schema: company; Owner: postgres
--

COPY company.employee (e_id, name, surname) FROM stdin;
11	╨Р╨╜╤В╨╛╨╜	╨Я╨╡╤З╨╡╨╜╨╛╨▓
2	╨Р╨╗╨╡╨║╤Б╨╡╨╣	╨и╨┐╨░╨║
3	╨Ш╨▓╨░╨╜	╨Ю╤В╤А╤П╨┤╨╛╨▓
4	╨Р╨╗╨╡╨║╤Б╨░╨╜╨┤╤А	╨и╨╗╤П╨┐╨╕╨║
5	╨Ш╨╗╤М╤П	╨Х╨╗╨╕╨╜
6	╨Э╨╕╨║╨╕╤В╨░	╨Ъ╨╛╤В╨╛╨▓
7	╨Т╨░╨╗╨╡╤А╨╕╨╣	╨Ъ╤А╨╛╤В╨╛╨▓
8	╨Ц╨╡╨╜╤П	╨Т╨╛╨╗╨╡╨▓
0	╨а╨░╨╝╨╖╨░╨╜	╨Ф╨╛╨╜
10	╨Ш╨▓╨░╨╜	╨С╨░╤И╨║╨╡╤А╨╛╨▓
\.


--
-- Data for Name: information; Type: TABLE DATA; Schema: company; Owner: postgres
--

COPY company.information (info_id, department_id, email, cellnumber, e_id, stime_id, truancies) FROM stdin;
4	3	cmonbroooo@gmail.com	+79106324535	3	2	0
10	7	howdfucc@mail.ru	+79106485515	10	10	0
2	2	coolguy12322@mail.ru	+79026338521	2	2	3
3	5	haixxxx@gmail.com	+79026542321	5	4	1
5	3	xxandr2322@gmail.com	+79046554521	4	3	2
11	3	shrekmegakek35@gmail.com	+79023441312	11	11	0
7	7	simpledimple@rumbler.ru	+79106512222	7	7	0
6	6	sad222dd@mail.ru	+79046522321	6	6	2
8	3	kto33ddd@mail.ru	+79103212443	8	8	0
0	1	ramzan1980cool@mail.ru	+79046648522	0	0	0
\.


--
-- Data for Name: shift_time; Type: TABLE DATA; Schema: company; Owner: postgres
--

COPY company.shift_time (stime_id, shifttime, wterm_id) FROM stdin;
0	8	2
2	8	0
3	9	3
4	8	4
5	7	5
6	7	6
7	8	7
8	8	8
10	6	10
11	8	11
\.


--
-- Data for Name: working_term; Type: TABLE DATA; Schema: company; Owner: postgres
--

COPY company.working_term (wterm_id, arrivaltime, leavingtime, appeared) FROM stdin;
0	2012-01-04 15:00:00	2012-01-04 23:00:00	t
3	2012-04-04 08:00:00	2012-01-04 16:00:00	t
4	2012-04-04 08:00:00	2012-01-04 15:00:00	t
2	2012-05-04 12:00:00	2012-05-04 20:00:00	f
5	2012-06-21 08:00:00	2012-06-21 15:00:00	t
6	2012-06-21 08:00:00	2012-06-21 15:00:00	f
7	2012-07-21 18:00:00	2012-06-21 02:00:00	t
8	2012-07-18 18:00:00	2012-06-22 03:00:00	t
10	2013-05-21 18:00:00	2013-05-22 00:00:00	t
11	2012-07-18 18:00:00	2012-06-21 02:00:00	t
\.


--
-- Data for Name: department; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.department (department_id, departmentname, supervisorname, postname) FROM stdin;
1	aaa	bbb	dddd
\.


--
-- Data for Name: employee; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employee (e_id, name, surname) FROM stdin;
\.


--
-- Data for Name: information; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.information (info_id, department_id, email, cellnumber, e_id, stime_id) FROM stdin;
\.


--
-- Data for Name: shift_time; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shift_time (stime_id, shifttime, wterm_id) FROM stdin;
\.


--
-- Data for Name: working_term; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.working_term (wterm_id, arrivaltime, leavingtime) FROM stdin;
\.


--
-- Name: Working term_wterm_id_seq; Type: SEQUENCE SET; Schema: company; Owner: postgres
--

SELECT pg_catalog.setval('company."Working term_wterm_id_seq"', 7, true);


--
-- Name: department_department_id_seq; Type: SEQUENCE SET; Schema: company; Owner: postgres
--

SELECT pg_catalog.setval('company.department_department_id_seq', 7, true);


--
-- Name: employee_e_id_seq; Type: SEQUENCE SET; Schema: company; Owner: postgres
--

SELECT pg_catalog.setval('company.employee_e_id_seq', 7, true);


--
-- Name: information_department_id_seq; Type: SEQUENCE SET; Schema: company; Owner: postgres
--

SELECT pg_catalog.setval('company.information_department_id_seq', 1, false);


--
-- Name: information_e_id_seq; Type: SEQUENCE SET; Schema: company; Owner: postgres
--

SELECT pg_catalog.setval('company.information_e_id_seq', 20, true);


--
-- Name: information_info_id_seq; Type: SEQUENCE SET; Schema: company; Owner: postgres
--

SELECT pg_catalog.setval('company.information_info_id_seq', 16, true);


--
-- Name: information_stime_id_seq; Type: SEQUENCE SET; Schema: company; Owner: postgres
--

SELECT pg_catalog.setval('company.information_stime_id_seq', 21, true);


--
-- Name: shift_time_stime_id_seq; Type: SEQUENCE SET; Schema: company; Owner: postgres
--

SELECT pg_catalog.setval('company.shift_time_stime_id_seq', 11, true);


--
-- Name: shift_time_wterm_id_seq; Type: SEQUENCE SET; Schema: company; Owner: postgres
--

SELECT pg_catalog.setval('company.shift_time_wterm_id_seq', 9, true);


--
-- Name: department_department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.department_department_id_seq', 1, true);


--
-- Name: employee_e_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employee_e_id_seq', 1, false);


--
-- Name: information_department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.information_department_id_seq', 1, false);


--
-- Name: information_e_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.information_e_id_seq', 1, false);


--
-- Name: information_info_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.information_info_id_seq', 1, false);


--
-- Name: information_stime_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.information_stime_id_seq', 1, false);


--
-- Name: shift_time_stime_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shift_time_stime_id_seq', 1, false);


--
-- Name: shift_time_wterm_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shift_time_wterm_id_seq', 1, false);


--
-- Name: working_term_wterm_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.working_term_wterm_id_seq', 1, false);


--
-- Name: working_term Working term_pk; Type: CONSTRAINT; Schema: company; Owner: postgres
--

ALTER TABLE ONLY company.working_term
    ADD CONSTRAINT "Working term_pk" PRIMARY KEY (wterm_id);


--
-- Name: department department_pk; Type: CONSTRAINT; Schema: company; Owner: postgres
--

ALTER TABLE ONLY company.department
    ADD CONSTRAINT department_pk PRIMARY KEY (department_id);


--
-- Name: employee employee_pk; Type: CONSTRAINT; Schema: company; Owner: postgres
--

ALTER TABLE ONLY company.employee
    ADD CONSTRAINT employee_pk PRIMARY KEY (e_id);


--
-- Name: information information_pk; Type: CONSTRAINT; Schema: company; Owner: postgres
--

ALTER TABLE ONLY company.information
    ADD CONSTRAINT information_pk PRIMARY KEY (info_id);


--
-- Name: shift_time shift_time_pk; Type: CONSTRAINT; Schema: company; Owner: postgres
--

ALTER TABLE ONLY company.shift_time
    ADD CONSTRAINT shift_time_pk PRIMARY KEY (stime_id);


--
-- Name: department department_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_pk PRIMARY KEY (department_id);


--
-- Name: employee employee_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pk PRIMARY KEY (e_id);


--
-- Name: information information_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.information
    ADD CONSTRAINT information_pk PRIMARY KEY (info_id);


--
-- Name: shift_time shift_time_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shift_time
    ADD CONSTRAINT shift_time_pk PRIMARY KEY (stime_id);


--
-- Name: working_term working_term_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.working_term
    ADD CONSTRAINT working_term_pk PRIMARY KEY (wterm_id);


--
-- Name: idx_cell; Type: INDEX; Schema: company; Owner: postgres
--

CREATE INDEX idx_cell ON company.information USING btree (cellnumber);


--
-- Name: idx_name; Type: INDEX; Schema: company; Owner: postgres
--

CREATE INDEX idx_name ON company.employee USING btree (name);


--
-- Name: idx_stime; Type: INDEX; Schema: company; Owner: postgres
--

CREATE INDEX idx_stime ON company.shift_time USING btree (shifttime);


--
-- Name: idx_surname; Type: INDEX; Schema: company; Owner: postgres
--

CREATE INDEX idx_surname ON company.employee USING btree (surname);


--
-- Name: department_department_id_uindex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX department_department_id_uindex ON public.department USING btree (department_id);


--
-- Name: employee_e_id_uindex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX employee_e_id_uindex ON public.employee USING btree (e_id);


--
-- Name: information_info_id_uindex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX information_info_id_uindex ON public.information USING btree (info_id);


--
-- Name: shift_time_stime_id_uindex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX shift_time_stime_id_uindex ON public.shift_time USING btree (stime_id);


--
-- Name: shift_time_wterm_id_uindex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX shift_time_wterm_id_uindex ON public.shift_time USING btree (wterm_id);


--
-- Name: working_term_wterm_id_uindex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX working_term_wterm_id_uindex ON public.working_term USING btree (wterm_id);


--
-- Name: information acheck; Type: TRIGGER; Schema: company; Owner: postgres
--

CREATE TRIGGER acheck BEFORE INSERT ON company.information FOR EACH ROW EXECUTE PROCEDURE company.info_check();


--
-- Name: information info_del; Type: TRIGGER; Schema: company; Owner: postgres
--

CREATE TRIGGER info_del AFTER DELETE ON company.information FOR EACH ROW EXECUTE PROCEDURE company.info_delete();


--
-- Name: department tcheck; Type: TRIGGER; Schema: company; Owner: postgres
--

CREATE TRIGGER tcheck AFTER UPDATE ON company.department FOR EACH ROW EXECUTE PROCEDURE company.d_update();


--
-- Name: e_info update_employee; Type: TRIGGER; Schema: company; Owner: postgres
--

CREATE TRIGGER update_employee INSTEAD OF UPDATE ON company.e_info FOR EACH ROW EXECUTE PROCEDURE company.update_emp();


--
-- Name: view1 viewtrigger; Type: TRIGGER; Schema: company; Owner: postgres
--

CREATE TRIGGER viewtrigger INSTEAD OF INSERT ON company.view1 FOR EACH ROW EXECUTE PROCEDURE company.view_insert();


--
-- Name: information information_department_department_id_fk; Type: FK CONSTRAINT; Schema: company; Owner: postgres
--

ALTER TABLE ONLY company.information
    ADD CONSTRAINT information_department_department_id_fk FOREIGN KEY (department_id) REFERENCES company.department(department_id);


--
-- Name: information information_employee_e_id_fk; Type: FK CONSTRAINT; Schema: company; Owner: postgres
--

ALTER TABLE ONLY company.information
    ADD CONSTRAINT information_employee_e_id_fk FOREIGN KEY (e_id) REFERENCES company.employee(e_id);


--
-- Name: information information_shift_time_stime_id_fk; Type: FK CONSTRAINT; Schema: company; Owner: postgres
--

ALTER TABLE ONLY company.information
    ADD CONSTRAINT information_shift_time_stime_id_fk FOREIGN KEY (stime_id) REFERENCES company.shift_time(stime_id);


--
-- Name: shift_time wterm_id; Type: FK CONSTRAINT; Schema: company; Owner: postgres
--

ALTER TABLE ONLY company.shift_time
    ADD CONSTRAINT wterm_id FOREIGN KEY (stime_id) REFERENCES company.working_term(wterm_id);


--
-- Name: information information_department_department_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.information
    ADD CONSTRAINT information_department_department_id_fk FOREIGN KEY (department_id) REFERENCES company.department(department_id);


--
-- Name: information information_employee_e_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.information
    ADD CONSTRAINT information_employee_e_id_fk FOREIGN KEY (e_id) REFERENCES company.employee(e_id);


--
-- Name: information information_shift_time_stime_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.information
    ADD CONSTRAINT information_shift_time_stime_id_fk FOREIGN KEY (stime_id) REFERENCES company.shift_time(stime_id);


--
-- Name: shift_time shift_time_working_term_wterm_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shift_time
    ADD CONSTRAINT shift_time_working_term_wterm_id_fk FOREIGN KEY (wterm_id) REFERENCES company.working_term(wterm_id);


--
-- Name: SCHEMA company; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA company TO test;
GRANT USAGE ON SCHEMA company TO companyuser;


--
-- Name: TABLE working_term; Type: ACL; Schema: company; Owner: postgres
--

GRANT ALL ON TABLE company.working_term TO companyadmin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE company.working_term TO companyuser;


--
-- Name: TABLE department; Type: ACL; Schema: company; Owner: postgres
--

GRANT ALL ON TABLE company.department TO companyadmin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE company.department TO companyuser;


--
-- Name: TABLE employee; Type: ACL; Schema: company; Owner: postgres
--

GRANT ALL ON TABLE company.employee TO companyadmin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE company.employee TO companyuser;


--
-- Name: TABLE information; Type: ACL; Schema: company; Owner: postgres
--

GRANT ALL ON TABLE company.information TO companyadmin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE company.information TO companyuser;


--
-- Name: TABLE shift_time; Type: ACL; Schema: company; Owner: postgres
--

GRANT ALL ON TABLE company.shift_time TO companyadmin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE company.shift_time TO companyuser;


--
-- PostgreSQL database dump complete
--

