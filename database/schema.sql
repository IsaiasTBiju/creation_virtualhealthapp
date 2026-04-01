--
-- PostgreSQL database dump
--
<<<<<<< HEAD
=======

<<<<<<< HEAD
=======
\restrict XdyEuzNrllcpMJw30LN4AcKbdl0f70QZxM1j2i0BOwP74uKEPKkQIlEG45gWfLd
>>>>>>> 4fba9e7a32a337633fe8e7bd08986a56ed06f786

>>>>>>> 140c8dbc1e6a2545ea4682a841393fbbcaae35ca
-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2026-02-17 11:19:57 +04

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 259 (class 1255 OID 16782)
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 230 (class 1259 OID 16486)
-- Name: activity_tracking; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activity_tracking (
    activity_id integer NOT NULL,
    user_id integer,
    date date NOT NULL,
    steps integer DEFAULT 0,
    calories_burned numeric(10,2) DEFAULT 0,
    distance_km numeric(10,2) DEFAULT 0,
    active_minutes integer DEFAULT 0,
    source character varying(50) DEFAULT 'manual'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.activity_tracking OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16485)
-- Name: activity_tracking_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.activity_tracking_activity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.activity_tracking_activity_id_seq OWNER TO postgres;

--
-- TOC entry 4092 (class 0 OID 0)
-- Dependencies: 229
-- Name: activity_tracking_activity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.activity_tracking_activity_id_seq OWNED BY public.activity_tracking.activity_id;


--
-- TOC entry 236 (class 1259 OID 16543)
-- Name: appointments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.appointments (
    appointment_id integer NOT NULL,
    user_id integer,
    healthcare_professional_id integer,
    appointment_date date NOT NULL,
    appointment_time time without time zone NOT NULL,
    appointment_type character varying(100),
    status character varying(30) DEFAULT 'scheduled'::character varying,
    notes text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT appointments_status_check CHECK (((status)::text = ANY (ARRAY[('scheduled'::character varying)::text, ('completed'::character varying)::text, ('cancelled'::character varying)::text])))
);


ALTER TABLE public.appointments OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 16542)
-- Name: appointments_appointment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.appointments_appointment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.appointments_appointment_id_seq OWNER TO postgres;

--
-- TOC entry 4093 (class 0 OID 0)
-- Dependencies: 235
-- Name: appointments_appointment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.appointments_appointment_id_seq OWNED BY public.appointments.appointment_id;


--
-- TOC entry 258 (class 1259 OID 16765)
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_logs (
    log_id integer NOT NULL,
    user_id integer,
    action character varying(100),
    table_name character varying(100),
    record_id integer,
    old_values jsonb,
    new_values jsonb,
    ip_address character varying(45),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.audit_logs OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 16764)
-- Name: audit_logs_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.audit_logs_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_logs_log_id_seq OWNER TO postgres;

--
-- TOC entry 4094 (class 0 OID 0)
-- Dependencies: 257
-- Name: audit_logs_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.audit_logs_log_id_seq OWNED BY public.audit_logs.log_id;


--
-- TOC entry 224 (class 1259 OID 16429)
-- Name: avatars; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.avatars (
    avatar_id integer NOT NULL,
    user_id integer,
    avatar_data jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.avatars OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16428)
-- Name: avatars_avatar_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.avatars_avatar_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.avatars_avatar_id_seq OWNER TO postgres;

--
-- TOC entry 4095 (class 0 OID 0)
-- Dependencies: 223
-- Name: avatars_avatar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.avatars_avatar_id_seq OWNED BY public.avatars.avatar_id;


--
-- TOC entry 238 (class 1259 OID 16571)
-- Name: badges; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.badges (
    badge_id integer NOT NULL,
    badge_name character varying(100) NOT NULL,
    badge_description text,
    badge_icon character varying(255),
    criteria jsonb,
    points integer DEFAULT 0
);


ALTER TABLE public.badges OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 16570)
-- Name: badges_badge_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.badges_badge_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.badges_badge_id_seq OWNER TO postgres;

--
-- TOC entry 4096 (class 0 OID 0)
-- Dependencies: 237
-- Name: badges_badge_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.badges_badge_id_seq OWNED BY public.badges.badge_id;


--
-- TOC entry 228 (class 1259 OID 16466)
-- Name: biomarker_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.biomarker_data (
    biomarker_id integer NOT NULL,
    user_id integer,
    metric_type character varying(50),
    value numeric(10,2),
    unit character varying(20),
    recorded_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    source character varying(50) DEFAULT 'manual'::character varying,
    notes text
);


ALTER TABLE public.biomarker_data OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16465)
-- Name: biomarker_data_biomarker_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.biomarker_data_biomarker_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.biomarker_data_biomarker_id_seq OWNER TO postgres;

--
-- TOC entry 4097 (class 0 OID 0)
-- Dependencies: 227
-- Name: biomarker_data_biomarker_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.biomarker_data_biomarker_id_seq OWNED BY public.biomarker_data.biomarker_id;


--
-- TOC entry 246 (class 1259 OID 16637)
-- Name: challenge_participants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.challenge_participants (
    participant_id integer NOT NULL,
    challenge_id integer,
    user_id integer,
    current_progress numeric(10,2) DEFAULT 0,
    rank integer,
    joined_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.challenge_participants OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 16636)
-- Name: challenge_participants_participant_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.challenge_participants_participant_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.challenge_participants_participant_id_seq OWNER TO postgres;

--
-- TOC entry 4098 (class 0 OID 0)
-- Dependencies: 245
-- Name: challenge_participants_participant_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.challenge_participants_participant_id_seq OWNED BY public.challenge_participants.participant_id;


--
-- TOC entry 244 (class 1259 OID 16625)
-- Name: challenges; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.challenges (
    challenge_id integer NOT NULL,
    challenge_name character varying(255) NOT NULL,
    challenge_description text,
    start_date date,
    end_date date,
    challenge_type character varying(50),
    target_value numeric(10,2),
    is_active boolean DEFAULT true
);


ALTER TABLE public.challenges OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 16624)
-- Name: challenges_challenge_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.challenges_challenge_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.challenges_challenge_id_seq OWNER TO postgres;

--
-- TOC entry 4099 (class 0 OID 0)
-- Dependencies: 243
-- Name: challenges_challenge_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.challenges_challenge_id_seq OWNED BY public.challenges.challenge_id;


--
-- TOC entry 252 (class 1259 OID 16710)
-- Name: chatbot_conversations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chatbot_conversations (
    conversation_id integer NOT NULL,
    user_id integer,
    user_message text NOT NULL,
    bot_response text NOT NULL,
    context_data jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.chatbot_conversations OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 16709)
-- Name: chatbot_conversations_conversation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chatbot_conversations_conversation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chatbot_conversations_conversation_id_seq OWNER TO postgres;

--
-- TOC entry 4100 (class 0 OID 0)
-- Dependencies: 251
-- Name: chatbot_conversations_conversation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chatbot_conversations_conversation_id_seq OWNED BY public.chatbot_conversations.conversation_id;


--
-- TOC entry 226 (class 1259 OID 16448)
-- Name: health_goals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.health_goals (
    goal_id integer NOT NULL,
    user_id integer,
    goal_type character varying(50),
    target_value numeric(10,2),
    current_value numeric(10,2) DEFAULT 0,
    unit character varying(20),
    start_date date,
    target_date date,
    is_completed boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.health_goals OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16447)
-- Name: health_goals_goal_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.health_goals_goal_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.health_goals_goal_id_seq OWNER TO postgres;

--
-- TOC entry 4101 (class 0 OID 0)
-- Dependencies: 225
-- Name: health_goals_goal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.health_goals_goal_id_seq OWNED BY public.health_goals.goal_id;


--
-- TOC entry 254 (class 1259 OID 16729)
-- Name: health_reports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.health_reports (
    report_id integer NOT NULL,
    user_id integer,
    report_type character varying(50),
    report_period_start date,
    report_period_end date,
    report_data jsonb,
    generated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.health_reports OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 16728)
-- Name: health_reports_report_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.health_reports_report_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.health_reports_report_id_seq OWNER TO postgres;

--
-- TOC entry 4102 (class 0 OID 0)
-- Dependencies: 253
-- Name: health_reports_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.health_reports_report_id_seq OWNED BY public.health_reports.report_id;


--
-- TOC entry 234 (class 1259 OID 16526)
-- Name: medications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medications (
    medication_id integer NOT NULL,
    user_id integer,
    medication_name character varying(255) NOT NULL,
    dosage character varying(100),
    frequency character varying(100),
    start_date date,
    end_date date,
    reminder_time time without time zone,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.medications OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16525)
-- Name: medications_medication_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.medications_medication_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.medications_medication_id_seq OWNER TO postgres;

--
-- TOC entry 4103 (class 0 OID 0)
-- Dependencies: 233
-- Name: medications_medication_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.medications_medication_id_seq OWNED BY public.medications.medication_id;


--
-- TOC entry 250 (class 1259 OID 16684)
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    message_id integer NOT NULL,
    sender_id integer,
    receiver_id integer,
    message_content text NOT NULL,
    is_read boolean DEFAULT false,
    sent_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    read_at timestamp without time zone
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 16683)
-- Name: messages_message_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.messages_message_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.messages_message_id_seq OWNER TO postgres;

--
-- TOC entry 4104 (class 0 OID 0)
-- Dependencies: 249
-- Name: messages_message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.messages_message_id_seq OWNED BY public.messages.message_id;


--
-- TOC entry 256 (class 1259 OID 16746)
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    notification_id integer NOT NULL,
    user_id integer,
    notification_type character varying(50),
    title character varying(255),
    message text,
    is_read boolean DEFAULT false,
    sent_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    read_at timestamp without time zone
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 16745)
-- Name: notifications_notification_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notifications_notification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_notification_id_seq OWNER TO postgres;

--
-- TOC entry 4105 (class 0 OID 0)
-- Dependencies: 255
-- Name: notifications_notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifications_notification_id_seq OWNED BY public.notifications.notification_id;


--
-- TOC entry 240 (class 1259 OID 16583)
-- Name: user_badges; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_badges (
    user_badge_id integer NOT NULL,
    user_id integer,
    badge_id integer,
    earned_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_badges OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 16582)
-- Name: user_badges_user_badge_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_badges_user_badge_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_badges_user_badge_id_seq OWNER TO postgres;

--
-- TOC entry 4106 (class 0 OID 0)
-- Dependencies: 239
-- Name: user_badges_user_badge_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_badges_user_badge_id_seq OWNED BY public.user_badges.user_badge_id;


--
-- TOC entry 248 (class 1259 OID 16660)
-- Name: user_follows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_follows (
    follow_id integer NOT NULL,
    follower_id integer,
    following_id integer,
    followed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT user_follows_check CHECK ((follower_id <> following_id))
);


ALTER TABLE public.user_follows OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 16659)
-- Name: user_follows_follow_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_follows_follow_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_follows_follow_id_seq OWNER TO postgres;

--
-- TOC entry 4107 (class 0 OID 0)
-- Dependencies: 247
-- Name: user_follows_follow_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_follows_follow_id_seq OWNED BY public.user_follows.follow_id;


--
-- TOC entry 242 (class 1259 OID 16605)
-- Name: user_gamification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_gamification (
    gamification_id integer NOT NULL,
    user_id integer,
    total_points integer DEFAULT 0,
    current_streak_days integer DEFAULT 0,
    longest_streak_days integer DEFAULT 0,
    level integer DEFAULT 1,
    last_activity_date date,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_gamification OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 16604)
-- Name: user_gamification_gamification_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_gamification_gamification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_gamification_gamification_id_seq OWNER TO postgres;

--
-- TOC entry 4108 (class 0 OID 0)
-- Dependencies: 241
-- Name: user_gamification_gamification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_gamification_gamification_id_seq OWNED BY public.user_gamification.gamification_id;


--
-- TOC entry 222 (class 1259 OID 16411)
-- Name: user_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_profiles (
    profile_id integer NOT NULL,
    user_id integer,
    full_name character varying(255),
    age integer,
    gender character varying(50),
    height_cm numeric(5,2),
    weight_kg numeric(5,2),
    date_of_birth date,
    phone_number character varying(20),
    privacy_setting character varying(30) DEFAULT 'Private'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT user_profiles_privacy_setting_check CHECK (((privacy_setting)::text = ANY (ARRAY[('Public'::character varying)::text, ('Friends'::character varying)::text, ('Private'::character varying)::text])))
);


ALTER TABLE public.user_profiles OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16410)
-- Name: user_profiles_profile_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_profiles_profile_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_profiles_profile_id_seq OWNER TO postgres;

--
-- TOC entry 4109 (class 0 OID 0)
-- Dependencies: 221
-- Name: user_profiles_profile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_profiles_profile_id_seq OWNED BY public.user_profiles.profile_id;


--
-- TOC entry 220 (class 1259 OID 16390)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    role character varying(30) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_active boolean DEFAULT true,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY (ARRAY[('User'::character varying)::text, ('Healthcare Professional'::character varying)::text, ('Admin'::character varying)::text])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16389)
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO postgres;

--
-- TOC entry 4110 (class 0 OID 0)
-- Dependencies: 219
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- TOC entry 232 (class 1259 OID 16507)
-- Name: wellness_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wellness_logs (
    log_id integer NOT NULL,
    user_id integer,
    log_type character varying(50),
    value numeric(10,2),
    unit character varying(20),
    mood_rating integer,
    notes text,
    recorded_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT wellness_logs_mood_rating_check CHECK (((mood_rating >= 1) AND (mood_rating <= 5)))
);


ALTER TABLE public.wellness_logs OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16506)
-- Name: wellness_logs_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.wellness_logs_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wellness_logs_log_id_seq OWNER TO postgres;

--
-- TOC entry 4111 (class 0 OID 0)
-- Dependencies: 231
-- Name: wellness_logs_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.wellness_logs_log_id_seq OWNED BY public.wellness_logs.log_id;


--
-- TOC entry 3785 (class 2604 OID 16489)
-- Name: activity_tracking activity_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_tracking ALTER COLUMN activity_id SET DEFAULT nextval('public.activity_tracking_activity_id_seq'::regclass);


--
-- TOC entry 3797 (class 2604 OID 16546)
-- Name: appointments appointment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments ALTER COLUMN appointment_id SET DEFAULT nextval('public.appointments_appointment_id_seq'::regclass);


--
-- TOC entry 3828 (class 2604 OID 16768)
-- Name: audit_logs log_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN log_id SET DEFAULT nextval('public.audit_logs_log_id_seq'::regclass);


--
-- TOC entry 3774 (class 2604 OID 16432)
-- Name: avatars avatar_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.avatars ALTER COLUMN avatar_id SET DEFAULT nextval('public.avatars_avatar_id_seq'::regclass);


--
-- TOC entry 3801 (class 2604 OID 16574)
-- Name: badges badge_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.badges ALTER COLUMN badge_id SET DEFAULT nextval('public.badges_badge_id_seq'::regclass);


--
-- TOC entry 3782 (class 2604 OID 16469)
-- Name: biomarker_data biomarker_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.biomarker_data ALTER COLUMN biomarker_id SET DEFAULT nextval('public.biomarker_data_biomarker_id_seq'::regclass);


--
-- TOC entry 3813 (class 2604 OID 16640)
-- Name: challenge_participants participant_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.challenge_participants ALTER COLUMN participant_id SET DEFAULT nextval('public.challenge_participants_participant_id_seq'::regclass);


--
-- TOC entry 3811 (class 2604 OID 16628)
-- Name: challenges challenge_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.challenges ALTER COLUMN challenge_id SET DEFAULT nextval('public.challenges_challenge_id_seq'::regclass);


--
-- TOC entry 3821 (class 2604 OID 16713)
-- Name: chatbot_conversations conversation_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chatbot_conversations ALTER COLUMN conversation_id SET DEFAULT nextval('public.chatbot_conversations_conversation_id_seq'::regclass);


--
-- TOC entry 3777 (class 2604 OID 16451)
-- Name: health_goals goal_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.health_goals ALTER COLUMN goal_id SET DEFAULT nextval('public.health_goals_goal_id_seq'::regclass);


--
-- TOC entry 3823 (class 2604 OID 16732)
-- Name: health_reports report_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.health_reports ALTER COLUMN report_id SET DEFAULT nextval('public.health_reports_report_id_seq'::regclass);


--
-- TOC entry 3794 (class 2604 OID 16529)
-- Name: medications medication_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medications ALTER COLUMN medication_id SET DEFAULT nextval('public.medications_medication_id_seq'::regclass);


--
-- TOC entry 3818 (class 2604 OID 16687)
-- Name: messages message_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages ALTER COLUMN message_id SET DEFAULT nextval('public.messages_message_id_seq'::regclass);


--
-- TOC entry 3825 (class 2604 OID 16749)
-- Name: notifications notification_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications ALTER COLUMN notification_id SET DEFAULT nextval('public.notifications_notification_id_seq'::regclass);


--
-- TOC entry 3803 (class 2604 OID 16586)
-- Name: user_badges user_badge_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_badges ALTER COLUMN user_badge_id SET DEFAULT nextval('public.user_badges_user_badge_id_seq'::regclass);


--
-- TOC entry 3816 (class 2604 OID 16663)
-- Name: user_follows follow_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_follows ALTER COLUMN follow_id SET DEFAULT nextval('public.user_follows_follow_id_seq'::regclass);


--
-- TOC entry 3805 (class 2604 OID 16608)
-- Name: user_gamification gamification_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_gamification ALTER COLUMN gamification_id SET DEFAULT nextval('public.user_gamification_gamification_id_seq'::regclass);


--
-- TOC entry 3770 (class 2604 OID 16414)
-- Name: user_profiles profile_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profiles ALTER COLUMN profile_id SET DEFAULT nextval('public.user_profiles_profile_id_seq'::regclass);


--
-- TOC entry 3766 (class 2604 OID 16393)
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- TOC entry 3792 (class 2604 OID 16510)
-- Name: wellness_logs log_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wellness_logs ALTER COLUMN log_id SET DEFAULT nextval('public.wellness_logs_log_id_seq'::regclass);


--
-- TOC entry 3857 (class 2606 OID 16499)
-- Name: activity_tracking activity_tracking_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_tracking
    ADD CONSTRAINT activity_tracking_pkey PRIMARY KEY (activity_id);


--
-- TOC entry 3867 (class 2606 OID 16557)
-- Name: appointments appointments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_pkey PRIMARY KEY (appointment_id);


--
-- TOC entry 3909 (class 2606 OID 16774)
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (log_id);


--
-- TOC entry 3845 (class 2606 OID 16439)
-- Name: avatars avatars_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.avatars
    ADD CONSTRAINT avatars_pkey PRIMARY KEY (avatar_id);


--
-- TOC entry 3847 (class 2606 OID 16441)
-- Name: avatars avatars_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.avatars
    ADD CONSTRAINT avatars_user_id_key UNIQUE (user_id);


--
-- TOC entry 3871 (class 2606 OID 16581)
-- Name: badges badges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.badges
    ADD CONSTRAINT badges_pkey PRIMARY KEY (badge_id);


--
-- TOC entry 3852 (class 2606 OID 16476)
-- Name: biomarker_data biomarker_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.biomarker_data
    ADD CONSTRAINT biomarker_data_pkey PRIMARY KEY (biomarker_id);


--
-- TOC entry 3884 (class 2606 OID 16647)
-- Name: challenge_participants challenge_participants_challenge_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.challenge_participants
    ADD CONSTRAINT challenge_participants_challenge_id_user_id_key UNIQUE (challenge_id, user_id);


--
-- TOC entry 3886 (class 2606 OID 16645)
-- Name: challenge_participants challenge_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.challenge_participants
    ADD CONSTRAINT challenge_participants_pkey PRIMARY KEY (participant_id);


--
-- TOC entry 3882 (class 2606 OID 16635)
-- Name: challenges challenges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.challenges
    ADD CONSTRAINT challenges_pkey PRIMARY KEY (challenge_id);


--
-- TOC entry 3899 (class 2606 OID 16721)
-- Name: chatbot_conversations chatbot_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chatbot_conversations
    ADD CONSTRAINT chatbot_conversations_pkey PRIMARY KEY (conversation_id);


--
-- TOC entry 3849 (class 2606 OID 16458)
-- Name: health_goals health_goals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.health_goals
    ADD CONSTRAINT health_goals_pkey PRIMARY KEY (goal_id);


--
-- TOC entry 3902 (class 2606 OID 16738)
-- Name: health_reports health_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.health_reports
    ADD CONSTRAINT health_reports_pkey PRIMARY KEY (report_id);


--
-- TOC entry 3865 (class 2606 OID 16535)
-- Name: medications medications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medications
    ADD CONSTRAINT medications_pkey PRIMARY KEY (medication_id);


--
-- TOC entry 3897 (class 2606 OID 16695)
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (message_id);


--
-- TOC entry 3907 (class 2606 OID 16756)
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (notification_id);


--
-- TOC entry 3874 (class 2606 OID 16590)
-- Name: user_badges user_badges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_badges
    ADD CONSTRAINT user_badges_pkey PRIMARY KEY (user_badge_id);


--
-- TOC entry 3876 (class 2606 OID 16592)
-- Name: user_badges user_badges_user_id_badge_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_badges
    ADD CONSTRAINT user_badges_user_id_badge_id_key UNIQUE (user_id, badge_id);


--
-- TOC entry 3890 (class 2606 OID 16670)
-- Name: user_follows user_follows_follower_id_following_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_follows
    ADD CONSTRAINT user_follows_follower_id_following_id_key UNIQUE (follower_id, following_id);


--
-- TOC entry 3892 (class 2606 OID 16668)
-- Name: user_follows user_follows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_follows
    ADD CONSTRAINT user_follows_pkey PRIMARY KEY (follow_id);


--
-- TOC entry 3878 (class 2606 OID 16616)
-- Name: user_gamification user_gamification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_gamification
    ADD CONSTRAINT user_gamification_pkey PRIMARY KEY (gamification_id);


--
-- TOC entry 3880 (class 2606 OID 16618)
-- Name: user_gamification user_gamification_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_gamification
    ADD CONSTRAINT user_gamification_user_id_key UNIQUE (user_id);


--
-- TOC entry 3843 (class 2606 OID 16421)
-- Name: user_profiles user_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (profile_id);


--
-- TOC entry 3838 (class 2606 OID 16407)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 3840 (class 2606 OID 16405)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- TOC entry 3862 (class 2606 OID 16517)
-- Name: wellness_logs wellness_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wellness_logs
    ADD CONSTRAINT wellness_logs_pkey PRIMARY KEY (log_id);


--
-- TOC entry 3858 (class 1259 OID 16505)
-- Name: idx_activity_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activity_user_date ON public.activity_tracking USING btree (user_id, date);


--
-- TOC entry 3868 (class 1259 OID 16569)
-- Name: idx_appointments_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_appointments_date ON public.appointments USING btree (appointment_date);


--
-- TOC entry 3869 (class 1259 OID 16568)
-- Name: idx_appointments_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_appointments_user_id ON public.appointments USING btree (user_id);


--
-- TOC entry 3910 (class 1259 OID 16781)
-- Name: idx_audit_logs_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_logs_created_at ON public.audit_logs USING btree (created_at);


--
-- TOC entry 3911 (class 1259 OID 16780)
-- Name: idx_audit_logs_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_logs_user_id ON public.audit_logs USING btree (user_id);


--
-- TOC entry 3853 (class 1259 OID 16484)
-- Name: idx_biomarker_metric_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_biomarker_metric_type ON public.biomarker_data USING btree (metric_type);


--
-- TOC entry 3854 (class 1259 OID 16483)
-- Name: idx_biomarker_recorded_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_biomarker_recorded_at ON public.biomarker_data USING btree (recorded_at);


--
-- TOC entry 3855 (class 1259 OID 16482)
-- Name: idx_biomarker_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_biomarker_user_id ON public.biomarker_data USING btree (user_id);


--
-- TOC entry 3900 (class 1259 OID 16727)
-- Name: idx_chatbot_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chatbot_user_id ON public.chatbot_conversations USING btree (user_id);


--
-- TOC entry 3887 (class 1259 OID 16681)
-- Name: idx_follows_follower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_follows_follower ON public.user_follows USING btree (follower_id);


--
-- TOC entry 3888 (class 1259 OID 16682)
-- Name: idx_follows_following; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_follows_following ON public.user_follows USING btree (following_id);


--
-- TOC entry 3850 (class 1259 OID 16464)
-- Name: idx_health_goals_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_health_goals_user_id ON public.health_goals USING btree (user_id);


--
-- TOC entry 3863 (class 1259 OID 16541)
-- Name: idx_medications_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medications_user_id ON public.medications USING btree (user_id);


--
-- TOC entry 3893 (class 1259 OID 16707)
-- Name: idx_messages_receiver; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_messages_receiver ON public.messages USING btree (receiver_id);


--
-- TOC entry 3894 (class 1259 OID 16706)
-- Name: idx_messages_sender; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_messages_sender ON public.messages USING btree (sender_id);


--
-- TOC entry 3895 (class 1259 OID 16708)
-- Name: idx_messages_sent_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_messages_sent_at ON public.messages USING btree (sent_at);


--
-- TOC entry 3904 (class 1259 OID 16763)
-- Name: idx_notifications_sent_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifications_sent_at ON public.notifications USING btree (sent_at);


--
-- TOC entry 3905 (class 1259 OID 16762)
-- Name: idx_notifications_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifications_user_id ON public.notifications USING btree (user_id);


--
-- TOC entry 3903 (class 1259 OID 16744)
-- Name: idx_reports_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reports_user_id ON public.health_reports USING btree (user_id);


--
-- TOC entry 3872 (class 1259 OID 16603)
-- Name: idx_user_badges_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_badges_user_id ON public.user_badges USING btree (user_id);


--
-- TOC entry 3841 (class 1259 OID 16427)
-- Name: idx_user_profiles_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_profiles_user_id ON public.user_profiles USING btree (user_id);


--
-- TOC entry 3835 (class 1259 OID 16408)
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- TOC entry 3836 (class 1259 OID 17033)
-- Name: idx_users_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_role ON public.users USING btree (role);


--
-- TOC entry 3859 (class 1259 OID 16524)
-- Name: idx_wellness_log_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_wellness_log_type ON public.wellness_logs USING btree (log_type);


--
-- TOC entry 3860 (class 1259 OID 16523)
-- Name: idx_wellness_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_wellness_user_id ON public.wellness_logs USING btree (user_id);


--
-- TOC entry 3938 (class 2620 OID 16786)
-- Name: appointments update_appointments_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_appointments_updated_at BEFORE UPDATE ON public.appointments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 3936 (class 2620 OID 16787)
-- Name: avatars update_avatars_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_avatars_updated_at BEFORE UPDATE ON public.avatars FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 3937 (class 2620 OID 16785)
-- Name: health_goals update_health_goals_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_health_goals_updated_at BEFORE UPDATE ON public.health_goals FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 3939 (class 2620 OID 16788)
-- Name: user_gamification update_user_gamification_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_user_gamification_updated_at BEFORE UPDATE ON public.user_gamification FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 3935 (class 2620 OID 16784)
-- Name: user_profiles update_user_profiles_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON public.user_profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 3934 (class 2620 OID 16783)
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 3916 (class 2606 OID 16500)
-- Name: activity_tracking activity_tracking_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_tracking
    ADD CONSTRAINT activity_tracking_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 3919 (class 2606 OID 16563)
-- Name: appointments appointments_healthcare_professional_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_healthcare_professional_id_fkey FOREIGN KEY (healthcare_professional_id) REFERENCES public.users(user_id);


--
-- TOC entry 3920 (class 2606 OID 16558)
-- Name: appointments appointments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 3933 (class 2606 OID 16775)
-- Name: audit_logs audit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- TOC entry 3913 (class 2606 OID 16442)
-- Name: avatars avatars_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.avatars
    ADD CONSTRAINT avatars_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 3915 (class 2606 OID 16477)
-- Name: biomarker_data biomarker_data_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.biomarker_data
    ADD CONSTRAINT biomarker_data_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 3924 (class 2606 OID 16648)
-- Name: challenge_participants challenge_participants_challenge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.challenge_participants
    ADD CONSTRAINT challenge_participants_challenge_id_fkey FOREIGN KEY (challenge_id) REFERENCES public.challenges(challenge_id);


--
-- TOC entry 3925 (class 2606 OID 16653)
-- Name: challenge_participants challenge_participants_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.challenge_participants
    ADD CONSTRAINT challenge_participants_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 3930 (class 2606 OID 16722)
-- Name: chatbot_conversations chatbot_conversations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chatbot_conversations
    ADD CONSTRAINT chatbot_conversations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 3914 (class 2606 OID 16459)
-- Name: health_goals health_goals_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.health_goals
    ADD CONSTRAINT health_goals_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 3931 (class 2606 OID 16739)
-- Name: health_reports health_reports_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.health_reports
    ADD CONSTRAINT health_reports_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 3918 (class 2606 OID 16536)
-- Name: medications medications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medications
    ADD CONSTRAINT medications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 3928 (class 2606 OID 16701)
-- Name: messages messages_receiver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 3929 (class 2606 OID 16696)
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 3932 (class 2606 OID 16757)
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 3921 (class 2606 OID 16598)
-- Name: user_badges user_badges_badge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_badges
    ADD CONSTRAINT user_badges_badge_id_fkey FOREIGN KEY (badge_id) REFERENCES public.badges(badge_id);


--
-- TOC entry 3922 (class 2606 OID 16593)
-- Name: user_badges user_badges_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_badges
    ADD CONSTRAINT user_badges_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 3926 (class 2606 OID 16671)
-- Name: user_follows user_follows_follower_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_follows
    ADD CONSTRAINT user_follows_follower_id_fkey FOREIGN KEY (follower_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 3927 (class 2606 OID 16676)
-- Name: user_follows user_follows_following_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_follows
    ADD CONSTRAINT user_follows_following_id_fkey FOREIGN KEY (following_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 3923 (class 2606 OID 16619)
-- Name: user_gamification user_gamification_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_gamification
    ADD CONSTRAINT user_gamification_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 3912 (class 2606 OID 16422)
-- Name: user_profiles user_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- TOC entry 3917 (class 2606 OID 16518)
-- Name: wellness_logs wellness_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wellness_logs
    ADD CONSTRAINT wellness_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


-- Completed on 2026-02-17 11:19:57 +04

--
-- PostgreSQL database dump complete
<<<<<<< HEAD
--
=======
--

<<<<<<< HEAD
=======
\unrestrict XdyEuzNrllcpMJw30LN4AcKbdl0f70QZxM1j2i0BOwP74uKEPKkQIlEG45gWfLd
>>>>>>> 4fba9e7a32a337633fe8e7bd08986a56ed06f786

>>>>>>> 140c8dbc1e6a2545ea4682a841393fbbcaae35ca
