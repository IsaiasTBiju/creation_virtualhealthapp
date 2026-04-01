--
-- PostgreSQL database dump
--


-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2026-02-17 11:21:12 +04

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
-- TOC entry 4019 (class 0 OID 16390)
-- Dependencies: 220
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users VALUES (1, 'john.doe@example.com', 'hashed_pass_123', 'User', '2026-02-16 12:36:08.049495', '2026-02-16 12:36:08.049495', true);
INSERT INTO public.users VALUES (2, 'jane.smith@example.com', 'hashed_pass_456', 'User', '2026-02-16 12:36:08.049495', '2026-02-16 12:36:08.049495', true);
INSERT INTO public.users VALUES (3, 'mike.wilson@example.com', 'hashed_pass_789', 'User', '2026-02-16 12:36:08.049495', '2026-02-16 12:36:08.049495', true);
INSERT INTO public.users VALUES (4, 'dr.sarah@hospital.com', 'hashed_pass_321', 'Healthcare Professional', '2026-02-16 12:36:08.049495', '2026-02-16 12:36:08.049495', true);
INSERT INTO public.users VALUES (5, 'admin@creation.com', 'hashed_pass_654', 'Admin', '2026-02-16 12:36:08.049495', '2026-02-16 12:36:08.049495', true);


--
-- TOC entry 4029 (class 0 OID 16486)
-- Dependencies: 230
-- Data for Name: activity_tracking; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.activity_tracking VALUES (1, 1, '2026-02-16', 8500, 320.50, 6.20, 45, 'fitbit', '2026-02-16 12:36:08.049495');
INSERT INTO public.activity_tracking VALUES (2, 1, '2026-02-15', 7200, 285.00, 5.40, 38, 'fitbit', '2026-02-16 12:36:08.049495');
INSERT INTO public.activity_tracking VALUES (3, 1, '2026-02-14', 9800, 380.00, 7.10, 52, 'fitbit', '2026-02-16 12:36:08.049495');
INSERT INTO public.activity_tracking VALUES (4, 1, '2026-02-13', 6500, 250.00, 4.80, 30, 'fitbit', '2026-02-16 12:36:08.049495');
INSERT INTO public.activity_tracking VALUES (5, 2, '2026-02-16', 10200, 400.00, 7.50, 60, 'apple_health', '2026-02-16 12:36:08.049495');
INSERT INTO public.activity_tracking VALUES (6, 2, '2026-02-15', 9500, 375.00, 7.00, 55, 'apple_health', '2026-02-16 12:36:08.049495');
INSERT INTO public.activity_tracking VALUES (7, 2, '2026-02-14', 11000, 430.00, 8.20, 65, 'apple_health', '2026-02-16 12:36:08.049495');
INSERT INTO public.activity_tracking VALUES (8, 3, '2026-02-16', 5200, 280.00, 4.00, 25, 'samsung', '2026-02-16 12:36:08.049495');
INSERT INTO public.activity_tracking VALUES (9, 3, '2026-02-15', 6800, 320.00, 5.20, 35, 'samsung', '2026-02-16 12:36:08.049495');


--
-- TOC entry 4035 (class 0 OID 16543)
-- Dependencies: 236
-- Data for Name: appointments; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.appointments VALUES (1, 1, 4, '2026-02-20', '10:00:00', 'General Checkup', 'scheduled', 'Annual screening', '2026-02-16 12:36:08.049495', '2026-02-16 12:36:08.049495');
INSERT INTO public.appointments VALUES (2, 2, 4, '2026-02-18', '14:30:00', 'Follow-up', 'scheduled', 'Review results', '2026-02-16 12:36:08.049495', '2026-02-16 12:36:08.049495');
INSERT INTO public.appointments VALUES (3, 3, 4, '2026-02-17', '09:00:00', 'Consultation', 'scheduled', 'Fitness plan', '2026-02-16 12:36:08.049495', '2026-02-16 12:36:08.049495');


--
-- TOC entry 4057 (class 0 OID 16765)
-- Dependencies: 258
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.audit_logs VALUES (1, 1, 'UPDATE', 'user_profiles', 1, '{"weight_kg": 72.0}', '{"weight_kg": 70.0}', '192.168.1.100', '2026-02-16 12:36:08.049495');


--
-- TOC entry 4023 (class 0 OID 16429)
-- Dependencies: 224
-- Data for Name: avatars; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.avatars VALUES (1, 1, '{"skin_tone": "medium", "hair_color": "brown", "hair_style": "short"}', '2026-02-16 12:36:08.049495', '2026-02-16 12:36:08.049495');
INSERT INTO public.avatars VALUES (2, 2, '{"skin_tone": "light", "hair_color": "blonde", "hair_style": "long"}', '2026-02-16 12:36:08.049495', '2026-02-16 12:36:08.049495');
INSERT INTO public.avatars VALUES (3, 3, '{"skin_tone": "dark", "hair_color": "none", "hair_style": "bald"}', '2026-02-16 12:36:08.049495', '2026-02-16 12:36:08.049495');


--
-- TOC entry 4037 (class 0 OID 16571)
-- Dependencies: 238
-- Data for Name: badges; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.badges VALUES (1, 'First Steps', 'Complete 1000 steps', '🎯', '{"metric": "steps", "threshold": 1000}', 10);
INSERT INTO public.badges VALUES (2, 'Week Warrior', '7-day streak', '🔥', '{"metric": "streak", "threshold": 7}', 50);
INSERT INTO public.badges VALUES (3, 'Hydration Hero', 'Drink 2L for 3 days', '💧', '{"metric": "hydration", "threshold": 2}', 30);
INSERT INTO public.badges VALUES (4, 'Early Bird', 'Log before 8 AM', '🌅', '{"before": "08:00", "metric": "time"}', 20);
INSERT INTO public.badges VALUES (5, 'Goal Crusher', 'Complete 5 goals', '🏆', '{"metric": "goals", "threshold": 5}', 100);


--
-- TOC entry 4027 (class 0 OID 16466)
-- Dependencies: 228
-- Data for Name: biomarker_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.biomarker_data VALUES (1, 1, 'heart_rate', 72.00, 'bpm', '2026-02-16 08:00:00', 'fitbit', 'Morning reading');
INSERT INTO public.biomarker_data VALUES (2, 1, 'bp_systolic', 120.00, 'mmHg', '2026-02-16 08:05:00', 'manual', 'Feeling good');
INSERT INTO public.biomarker_data VALUES (3, 1, 'bp_diastolic', 80.00, 'mmHg', '2026-02-16 08:05:00', 'manual', NULL);
INSERT INTO public.biomarker_data VALUES (4, 1, 'glucose', 95.00, 'mg/dL', '2026-02-16 09:00:00', 'manual', 'Before breakfast');
INSERT INTO public.biomarker_data VALUES (5, 2, 'heart_rate', 68.00, 'bpm', '2026-02-16 07:30:00', 'apple_health', NULL);
INSERT INTO public.biomarker_data VALUES (6, 2, 'bp_systolic', 115.00, 'mmHg', '2026-02-16 07:35:00', 'manual', NULL);
INSERT INTO public.biomarker_data VALUES (7, 2, 'bp_diastolic', 75.00, 'mmHg', '2026-02-16 07:35:00', 'manual', NULL);
INSERT INTO public.biomarker_data VALUES (8, 3, 'heart_rate', 75.00, 'bpm', '2026-02-16 10:00:00', 'samsung', NULL);
INSERT INTO public.biomarker_data VALUES (9, 3, 'glucose', 105.00, 'mg/dL', '2026-02-16 10:30:00', 'manual', 'Post breakfast');


--
-- TOC entry 4043 (class 0 OID 16625)
-- Dependencies: 244
-- Data for Name: challenges; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.challenges VALUES (1, 'Feb Step Challenge', 'Walk 200K steps', '2026-02-01', '2026-02-28', 'steps', 200000.00, true);
INSERT INTO public.challenges VALUES (2, 'Hydration Week', 'Drink 2L daily', '2026-02-10', '2026-02-16', 'hydration', 14.00, true);
INSERT INTO public.challenges VALUES (3, 'Morning Meditation', 'Meditate 10min', '2026-02-01', '2026-02-14', 'meditation', 140.00, false);


--
-- TOC entry 4045 (class 0 OID 16637)
-- Dependencies: 246
-- Data for Name: challenge_participants; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.challenge_participants VALUES (1, 1, 1, 45000.00, 2, '2026-02-16 12:36:08.049495');
INSERT INTO public.challenge_participants VALUES (2, 1, 2, 58000.00, 1, '2026-02-16 12:36:08.049495');
INSERT INTO public.challenge_participants VALUES (3, 1, 3, 32000.00, 3, '2026-02-16 12:36:08.049495');
INSERT INTO public.challenge_participants VALUES (4, 2, 1, 10.00, 2, '2026-02-16 12:36:08.049495');
INSERT INTO public.challenge_participants VALUES (5, 2, 2, 14.00, 1, '2026-02-16 12:36:08.049495');


--
-- TOC entry 4051 (class 0 OID 16710)
-- Dependencies: 252
-- Data for Name: chatbot_conversations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.chatbot_conversations VALUES (1, 1, 'How to reach step goal?', 'You need 1500 more steps!', '{"goal": 10000, "steps": 8500}', '2026-02-16 12:36:08.049495');
INSERT INTO public.chatbot_conversations VALUES (2, 2, 'How is my hydration?', 'Great! You exceeded 2L target!', '{"hydration": 3.0}', '2026-02-16 12:36:08.049495');


--
-- TOC entry 4025 (class 0 OID 16448)
-- Dependencies: 226
-- Data for Name: health_goals; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.health_goals VALUES (1, 1, 'steps', 10000.00, 7500.00, 'steps/day', '2026-02-01', '2026-03-01', false, '2026-02-16 12:36:08.049495', '2026-02-16 12:36:08.049495');
INSERT INTO public.health_goals VALUES (2, 1, 'weight_loss', 68.00, 70.00, 'kg', '2026-02-01', '2026-04-01', false, '2026-02-16 12:36:08.049495', '2026-02-16 12:36:08.049495');
INSERT INTO public.health_goals VALUES (3, 2, 'steps', 8000.00, 9200.00, 'steps/day', '2026-01-15', '2026-02-28', false, '2026-02-16 12:36:08.049495', '2026-02-16 12:36:08.049495');
INSERT INTO public.health_goals VALUES (4, 2, 'calories', 2000.00, 1850.00, 'kcal/day', '2026-01-15', '2026-02-28', false, '2026-02-16 12:36:08.049495', '2026-02-16 12:36:08.049495');
INSERT INTO public.health_goals VALUES (5, 3, 'active_minutes', 30.00, 25.00, 'min/day', '2026-02-10', '2026-03-10', false, '2026-02-16 12:36:08.049495', '2026-02-16 12:36:08.049495');


--
-- TOC entry 4053 (class 0 OID 16729)
-- Dependencies: 254
-- Data for Name: health_reports; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.health_reports VALUES (1, 1, 'weekly', '2026-02-10', '2026-02-16', '{"avg_steps": 7800, "avg_calories": 295}', '2026-02-16 12:36:08.049495');
INSERT INTO public.health_reports VALUES (2, 2, 'weekly', '2026-02-10', '2026-02-16', '{"avg_steps": 10200, "avg_calories": 401}', '2026-02-16 12:36:08.049495');


--
-- TOC entry 4033 (class 0 OID 16526)
-- Dependencies: 234
-- Data for Name: medications; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.medications VALUES (1, 1, 'Vitamin D', '1000 IU', 'Once daily', '2026-01-01', NULL, '09:00:00', true, '2026-02-16 12:36:08.049495');
INSERT INTO public.medications VALUES (2, 2, 'Multivitamin', '1 tablet', 'Once daily', '2026-01-15', NULL, '08:00:00', true, '2026-02-16 12:36:08.049495');
INSERT INTO public.medications VALUES (3, 3, 'Fish Oil', '1000 mg', 'Twice daily', '2026-02-01', '2026-03-01', '09:00:00', true, '2026-02-16 12:36:08.049495');


--
-- TOC entry 4049 (class 0 OID 16684)
-- Dependencies: 250
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.messages VALUES (1, 1, 2, 'Great job on the challenge!', true, '2026-02-16 10:00:00', '2026-02-16 10:15:00');
INSERT INTO public.messages VALUES (2, 2, 1, 'Thanks! You too!', true, '2026-02-16 10:20:00', '2026-02-16 10:25:00');
INSERT INTO public.messages VALUES (3, 1, 3, 'Join hydration challenge?', false, '2026-02-16 14:30:00', NULL);


--
-- TOC entry 4055 (class 0 OID 16746)
-- Dependencies: 256
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.notifications VALUES (1, 1, 'appointment', 'Upcoming', 'Checkup on Feb 20', false, '2026-02-16 09:00:00', NULL);
INSERT INTO public.notifications VALUES (2, 2, 'achievement', 'New Badge!', 'Week Warrior earned!', true, '2026-02-16 08:00:00', '2026-02-16 08:30:00');


--
-- TOC entry 4039 (class 0 OID 16583)
-- Dependencies: 240
-- Data for Name: user_badges; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.user_badges VALUES (1, 1, 1, '2026-02-16 12:36:08.049495');
INSERT INTO public.user_badges VALUES (2, 1, 4, '2026-02-16 12:36:08.049495');
INSERT INTO public.user_badges VALUES (3, 2, 1, '2026-02-16 12:36:08.049495');
INSERT INTO public.user_badges VALUES (4, 2, 2, '2026-02-16 12:36:08.049495');
INSERT INTO public.user_badges VALUES (5, 2, 3, '2026-02-16 12:36:08.049495');


--
-- TOC entry 4047 (class 0 OID 16660)
-- Dependencies: 248
-- Data for Name: user_follows; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.user_follows VALUES (1, 1, 2, '2026-02-16 12:36:08.049495');
INSERT INTO public.user_follows VALUES (2, 1, 3, '2026-02-16 12:36:08.049495');
INSERT INTO public.user_follows VALUES (3, 2, 1, '2026-02-16 12:36:08.049495');
INSERT INTO public.user_follows VALUES (4, 3, 1, '2026-02-16 12:36:08.049495');
INSERT INTO public.user_follows VALUES (5, 3, 2, '2026-02-16 12:36:08.049495');


--
-- TOC entry 4041 (class 0 OID 16605)
-- Dependencies: 242
-- Data for Name: user_gamification; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.user_gamification VALUES (1, 1, 150, 4, 7, 2, '2026-02-16', '2026-02-16 12:36:08.049495');
INSERT INTO public.user_gamification VALUES (2, 2, 280, 9, 12, 3, '2026-02-16', '2026-02-16 12:36:08.049495');
INSERT INTO public.user_gamification VALUES (3, 3, 50, 2, 5, 1, '2026-02-16', '2026-02-16 12:36:08.049495');


--
-- TOC entry 4021 (class 0 OID 16411)
-- Dependencies: 222
-- Data for Name: user_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.user_profiles VALUES (1, 1, 'John Doe', 25, 'Male', 175.00, 70.00, '1999-03-15', '+971501234567', 'Public', '2026-02-16 12:36:08.049495', '2026-02-16 12:36:08.049495');
INSERT INTO public.user_profiles VALUES (2, 2, 'Jane Smith', 30, 'Female', 165.00, 60.00, '1994-07-22', '+971502345678', 'Friends', '2026-02-16 12:36:08.049495', '2026-02-16 12:36:08.049495');
INSERT INTO public.user_profiles VALUES (3, 3, 'Mike Wilson', 35, 'Male', 180.00, 85.00, '1989-11-10', '+971503456789', 'Private', '2026-02-16 12:36:08.049495', '2026-02-16 12:36:08.049495');
INSERT INTO public.user_profiles VALUES (4, 4, 'Dr. Sarah Ahmed', 42, 'Female', 170.00, 65.00, '1982-05-18', '+971504567890', 'Public', '2026-02-16 12:36:08.049495', '2026-02-16 12:36:08.049495');


--
-- TOC entry 4031 (class 0 OID 16507)
-- Dependencies: 232
-- Data for Name: wellness_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.wellness_logs VALUES (1, 1, 'hydration', 2.50, 'L', NULL, 'Good intake', '2026-02-16 20:00:00');
INSERT INTO public.wellness_logs VALUES (2, 2, 'hydration', 3.00, 'L', NULL, 'Staying hydrated', '2026-02-16 19:00:00');
INSERT INTO public.wellness_logs VALUES (3, 1, 'sleep', 7.50, 'hrs', NULL, 'Slept well', '2026-02-16 07:00:00');
INSERT INTO public.wellness_logs VALUES (4, 2, 'sleep', 8.00, 'hrs', NULL, 'Great sleep', '2026-02-16 07:30:00');
INSERT INTO public.wellness_logs VALUES (5, 3, 'sleep', 6.50, 'hrs', NULL, 'Could be better', '2026-02-16 08:00:00');
INSERT INTO public.wellness_logs VALUES (6, 1, 'meditation', 15.00, 'min', NULL, 'Morning session', '2026-02-16 08:30:00');
INSERT INTO public.wellness_logs VALUES (7, 2, 'meditation', 20.00, 'min', NULL, 'Evening session', '2026-02-15 20:00:00');
INSERT INTO public.wellness_logs VALUES (8, 1, 'mood', NULL, NULL, 4, 'Feeling energetic', '2026-02-16 12:00:00');
INSERT INTO public.wellness_logs VALUES (9, 2, 'mood', NULL, NULL, 5, 'Excellent day!', '2026-02-16 15:00:00');
INSERT INTO public.wellness_logs VALUES (10, 3, 'mood', NULL, NULL, 3, 'Bit tired', '2026-02-16 14:00:00');


--
-- TOC entry 4063 (class 0 OID 0)
-- Dependencies: 229
-- Name: activity_tracking_activity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.activity_tracking_activity_id_seq', 9, true);


--
-- TOC entry 4064 (class 0 OID 0)
-- Dependencies: 235
-- Name: appointments_appointment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.appointments_appointment_id_seq', 3, true);


--
-- TOC entry 4065 (class 0 OID 0)
-- Dependencies: 257
-- Name: audit_logs_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.audit_logs_log_id_seq', 1, true);


--
-- TOC entry 4066 (class 0 OID 0)
-- Dependencies: 223
-- Name: avatars_avatar_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.avatars_avatar_id_seq', 3, true);


--
-- TOC entry 4067 (class 0 OID 0)
-- Dependencies: 237
-- Name: badges_badge_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.badges_badge_id_seq', 5, true);


--
-- TOC entry 4068 (class 0 OID 0)
-- Dependencies: 227
-- Name: biomarker_data_biomarker_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.biomarker_data_biomarker_id_seq', 9, true);


--
-- TOC entry 4069 (class 0 OID 0)
-- Dependencies: 245
-- Name: challenge_participants_participant_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.challenge_participants_participant_id_seq', 5, true);


--
-- TOC entry 4070 (class 0 OID 0)
-- Dependencies: 243
-- Name: challenges_challenge_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.challenges_challenge_id_seq', 3, true);


--
-- TOC entry 4071 (class 0 OID 0)
-- Dependencies: 251
-- Name: chatbot_conversations_conversation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chatbot_conversations_conversation_id_seq', 2, true);


--
-- TOC entry 4072 (class 0 OID 0)
-- Dependencies: 225
-- Name: health_goals_goal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.health_goals_goal_id_seq', 5, true);


--
-- TOC entry 4073 (class 0 OID 0)
-- Dependencies: 253
-- Name: health_reports_report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.health_reports_report_id_seq', 2, true);


--
-- TOC entry 4074 (class 0 OID 0)
-- Dependencies: 233
-- Name: medications_medication_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.medications_medication_id_seq', 3, true);


--
-- TOC entry 4075 (class 0 OID 0)
-- Dependencies: 249
-- Name: messages_message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.messages_message_id_seq', 3, true);


--
-- TOC entry 4076 (class 0 OID 0)
-- Dependencies: 255
-- Name: notifications_notification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notifications_notification_id_seq', 2, true);


--
-- TOC entry 4077 (class 0 OID 0)
-- Dependencies: 239
-- Name: user_badges_user_badge_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_badges_user_badge_id_seq', 5, true);


--
-- TOC entry 4078 (class 0 OID 0)
-- Dependencies: 247
-- Name: user_follows_follow_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_follows_follow_id_seq', 5, true);


--
-- TOC entry 4079 (class 0 OID 0)
-- Dependencies: 241
-- Name: user_gamification_gamification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_gamification_gamification_id_seq', 3, true);


--
-- TOC entry 4080 (class 0 OID 0)
-- Dependencies: 221
-- Name: user_profiles_profile_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_profiles_profile_id_seq', 4, true);


--
-- TOC entry 4081 (class 0 OID 0)
-- Dependencies: 219
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 5, true);


--
-- TOC entry 4082 (class 0 OID 0)
-- Dependencies: 231
-- Name: wellness_logs_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.wellness_logs_log_id_seq', 10, true);


-- Completed on 2026-02-17 11:21:12 +04

--
-- PostgreSQL database dump complete
--


