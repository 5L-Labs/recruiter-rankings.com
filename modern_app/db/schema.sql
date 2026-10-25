-- Baseline schema for the Next.js app, generated from the Rails app (web/db/schema.rb,
-- latest migration 20260309013150) via 'rails db:schema:load' + 'pg_dump --schema-only'.
-- Rails remains the owner of production migrations until cutover; regenerate this file
-- whenever web/db/schema.rb changes (see modern_app/AGENTS.md).

--
-- PostgreSQL database dump
--



SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companies (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    industry character varying,
    name character varying NOT NULL,
    region character varying,
    sector character varying,
    size_bucket character varying,
    updated_at timestamp(6) without time zone NOT NULL,
    website_url character varying
);


--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.companies_id_seq OWNED BY public.companies.id;


--
-- Name: experiences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.experiences (
    id bigint NOT NULL,
    body text,
    created_at timestamp(6) without time zone NOT NULL,
    interaction_id bigint NOT NULL,
    outcome character varying,
    rating integer NOT NULL,
    status character varying DEFAULT 'pending'::character varying,
    updated_at timestamp(6) without time zone NOT NULL,
    would_recommend boolean,
    CONSTRAINT check_experiences_outcome CHECK (((outcome IS NULL) OR ((outcome)::text = ANY (ARRAY[('hired'::character varying)::text, ('declined_offer'::character varying)::text, ('ghosted'::character varying)::text, ('still_interviewing'::character varying)::text])))),
    CONSTRAINT check_experiences_rating_range CHECK (((rating >= 1) AND (rating <= 5)))
);


--
-- Name: experiences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.experiences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: experiences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.experiences_id_seq OWNED BY public.experiences.id;


--
-- Name: identity_challenges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.identity_challenges (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    expires_at timestamp(6) without time zone NOT NULL,
    last_verification_error text,
    subject_id bigint NOT NULL,
    subject_type character varying NOT NULL,
    token character varying,
    token_hash character varying NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    verified_at timestamp(6) without time zone
);


--
-- Name: identity_challenges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.identity_challenges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: identity_challenges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.identity_challenges_id_seq OWNED BY public.identity_challenges.id;


--
-- Name: interactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.interactions (
    id bigint NOT NULL,
    clerk_user_id character varying,
    created_at timestamp(6) without time zone NOT NULL,
    occurred_at timestamp(6) without time zone,
    recruiter_id bigint NOT NULL,
    role_id bigint,
    status character varying DEFAULT 'pending'::character varying,
    target_id bigint NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: interactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.interactions_id_seq OWNED BY public.interactions.id;


--
-- Name: moderation_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.moderation_actions (
    id bigint NOT NULL,
    action character varying NOT NULL,
    actor_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    notes text,
    subject_id bigint NOT NULL,
    subject_type character varying NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: moderation_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.moderation_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: moderation_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.moderation_actions_id_seq OWNED BY public.moderation_actions.id;


--
-- Name: pay_charges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pay_charges (
    id bigint NOT NULL,
    amount integer NOT NULL,
    amount_refunded integer,
    application_fee_amount integer,
    created_at timestamp(6) without time zone NOT NULL,
    currency character varying,
    customer_id bigint NOT NULL,
    data jsonb,
    metadata jsonb,
    processor_id character varying NOT NULL,
    stripe_account character varying,
    subscription_id bigint,
    type character varying,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: pay_charges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pay_charges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pay_charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pay_charges_id_seq OWNED BY public.pay_charges.id;


--
-- Name: pay_customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pay_customers (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    data jsonb,
    "default" boolean,
    deleted_at timestamp without time zone,
    owner_id bigint,
    owner_type character varying,
    processor character varying NOT NULL,
    processor_id character varying,
    stripe_account character varying,
    type character varying,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: pay_customers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pay_customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pay_customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pay_customers_id_seq OWNED BY public.pay_customers.id;


--
-- Name: pay_merchants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pay_merchants (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    data jsonb,
    "default" boolean,
    owner_id bigint,
    owner_type character varying,
    processor character varying NOT NULL,
    processor_id character varying,
    type character varying,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: pay_merchants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pay_merchants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pay_merchants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pay_merchants_id_seq OWNED BY public.pay_merchants.id;


--
-- Name: pay_payment_methods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pay_payment_methods (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    customer_id bigint NOT NULL,
    data jsonb,
    "default" boolean,
    payment_method_type character varying,
    processor_id character varying NOT NULL,
    stripe_account character varying,
    type character varying,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: pay_payment_methods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pay_payment_methods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pay_payment_methods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pay_payment_methods_id_seq OWNED BY public.pay_payment_methods.id;


--
-- Name: pay_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pay_subscriptions (
    id bigint NOT NULL,
    application_fee_percent numeric(8,2),
    created_at timestamp(6) without time zone NOT NULL,
    current_period_end timestamp without time zone,
    current_period_start timestamp without time zone,
    customer_id bigint NOT NULL,
    data jsonb,
    ends_at timestamp without time zone,
    metadata jsonb,
    metered boolean,
    name character varying NOT NULL,
    pause_behavior character varying,
    pause_resumes_at timestamp without time zone,
    pause_starts_at timestamp without time zone,
    payment_method_id character varying,
    processor_id character varying NOT NULL,
    processor_plan character varying NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    status character varying NOT NULL,
    stripe_account character varying,
    trial_ends_at timestamp without time zone,
    type character varying,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: pay_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pay_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pay_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pay_subscriptions_id_seq OWNED BY public.pay_subscriptions.id;


--
-- Name: pay_webhooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pay_webhooks (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    event jsonb,
    event_type character varying,
    processor character varying,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: pay_webhooks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pay_webhooks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pay_webhooks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pay_webhooks_id_seq OWNED BY public.pay_webhooks.id;


--
-- Name: profile_claims; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profile_claims (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    recruiter_id bigint NOT NULL,
    revoked_at timestamp(6) without time zone,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint NOT NULL,
    verification_method character varying NOT NULL,
    verified_at timestamp(6) without time zone,
    CONSTRAINT check_profile_claims_verification_method CHECK (((verification_method)::text = ANY (ARRAY[('li'::character varying)::text, ('email'::character varying)::text])))
);


--
-- Name: profile_claims_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.profile_claims_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profile_claims_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.profile_claims_id_seq OWNED BY public.profile_claims.id;


--
-- Name: recruiters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recruiters (
    id bigint NOT NULL,
    company_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    email_ciphertext text,
    email_hmac character varying,
    email_kek_id character varying,
    linkedin_url character varying,
    name character varying NOT NULL,
    public_slug character varying NOT NULL,
    region character varying,
    updated_at timestamp(6) without time zone NOT NULL,
    verified_at timestamp(6) without time zone
);


--
-- Name: recruiters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recruiters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recruiters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recruiters_id_seq OWNED BY public.recruiters.id;


--
-- Name: review_metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.review_metrics (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    dimension character varying NOT NULL,
    experience_id bigint NOT NULL,
    score integer NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT check_review_metrics_score_range CHECK (((score >= 1) AND (score <= 5)))
);


--
-- Name: review_metrics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.review_metrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: review_metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.review_metrics_id_seq OWNED BY public.review_metrics.id;


--
-- Name: review_responses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.review_responses (
    id bigint NOT NULL,
    body text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    review_id bigint NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint,
    visible boolean DEFAULT true NOT NULL
);


--
-- Name: review_responses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.review_responses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: review_responses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.review_responses_id_seq OWNED BY public.review_responses.id;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reviews (
    id bigint NOT NULL,
    company_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    overall_score integer NOT NULL,
    recruiter_id bigint,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    text text,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint NOT NULL,
    CONSTRAINT check_reviews_overall_score_range CHECK (((overall_score >= 1) AND (overall_score <= 5))),
    CONSTRAINT check_reviews_status CHECK (((status)::text = ANY (ARRAY[('pending'::character varying)::text, ('approved'::character varying)::text, ('removed'::character varying)::text, ('flagged'::character varying)::text])))
);


--
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reviews_id_seq OWNED BY public.reviews.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    description text,
    max_compensation integer,
    min_compensation integer,
    posted_date date,
    recruiter_take text,
    recruiting_company_id bigint NOT NULL,
    target_company_id bigint,
    title character varying,
    updated_at timestamp(6) without time zone NOT NULL,
    url character varying
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: takedown_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.takedown_requests (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    reason_code character varying,
    requested_by character varying,
    resolved_at timestamp(6) without time zone,
    sla_due_at timestamp(6) without time zone,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    subject_id bigint NOT NULL,
    subject_type character varying NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT check_takedown_requests_status CHECK (((status)::text = ANY (ARRAY[('pending'::character varying)::text, ('in_review'::character varying)::text, ('resolved'::character varying)::text, ('rejected'::character varying)::text])))
);


--
-- Name: takedown_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.takedown_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: takedown_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.takedown_requests_id_seq OWNED BY public.takedown_requests.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    clerk_user_id character varying,
    created_at timestamp(6) without time zone NOT NULL,
    email_ciphertext text,
    email_hmac character varying NOT NULL,
    email_kek_id character varying,
    linked_in_url character varying,
    paid boolean DEFAULT false NOT NULL,
    public_slug character varying,
    role character varying DEFAULT 'candidate'::character varying NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    verification_status character varying,
    verified_at timestamp(6) without time zone,
    CONSTRAINT check_users_role CHECK (((role)::text = ANY (ARRAY[('candidate'::character varying)::text, ('recruiter'::character varying)::text, ('moderator'::character varying)::text, ('admin'::character varying)::text])))
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies ALTER COLUMN id SET DEFAULT nextval('public.companies_id_seq'::regclass);


--
-- Name: experiences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.experiences ALTER COLUMN id SET DEFAULT nextval('public.experiences_id_seq'::regclass);


--
-- Name: identity_challenges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identity_challenges ALTER COLUMN id SET DEFAULT nextval('public.identity_challenges_id_seq'::regclass);


--
-- Name: interactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interactions ALTER COLUMN id SET DEFAULT nextval('public.interactions_id_seq'::regclass);


--
-- Name: moderation_actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_actions ALTER COLUMN id SET DEFAULT nextval('public.moderation_actions_id_seq'::regclass);


--
-- Name: pay_charges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pay_charges ALTER COLUMN id SET DEFAULT nextval('public.pay_charges_id_seq'::regclass);


--
-- Name: pay_customers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pay_customers ALTER COLUMN id SET DEFAULT nextval('public.pay_customers_id_seq'::regclass);


--
-- Name: pay_merchants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pay_merchants ALTER COLUMN id SET DEFAULT nextval('public.pay_merchants_id_seq'::regclass);


--
-- Name: pay_payment_methods id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pay_payment_methods ALTER COLUMN id SET DEFAULT nextval('public.pay_payment_methods_id_seq'::regclass);


--
-- Name: pay_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pay_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.pay_subscriptions_id_seq'::regclass);


--
-- Name: pay_webhooks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pay_webhooks ALTER COLUMN id SET DEFAULT nextval('public.pay_webhooks_id_seq'::regclass);


--
-- Name: profile_claims id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_claims ALTER COLUMN id SET DEFAULT nextval('public.profile_claims_id_seq'::regclass);


--
-- Name: recruiters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recruiters ALTER COLUMN id SET DEFAULT nextval('public.recruiters_id_seq'::regclass);


--
-- Name: review_metrics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_metrics ALTER COLUMN id SET DEFAULT nextval('public.review_metrics_id_seq'::regclass);


--
-- Name: review_responses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_responses ALTER COLUMN id SET DEFAULT nextval('public.review_responses_id_seq'::regclass);


--
-- Name: reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews ALTER COLUMN id SET DEFAULT nextval('public.reviews_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: takedown_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.takedown_requests ALTER COLUMN id SET DEFAULT nextval('public.takedown_requests_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: experiences experiences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.experiences
    ADD CONSTRAINT experiences_pkey PRIMARY KEY (id);


--
-- Name: identity_challenges identity_challenges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identity_challenges
    ADD CONSTRAINT identity_challenges_pkey PRIMARY KEY (id);


--
-- Name: interactions interactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interactions
    ADD CONSTRAINT interactions_pkey PRIMARY KEY (id);


--
-- Name: moderation_actions moderation_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_actions
    ADD CONSTRAINT moderation_actions_pkey PRIMARY KEY (id);


--
-- Name: pay_charges pay_charges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pay_charges
    ADD CONSTRAINT pay_charges_pkey PRIMARY KEY (id);


--
-- Name: pay_customers pay_customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pay_customers
    ADD CONSTRAINT pay_customers_pkey PRIMARY KEY (id);


--
-- Name: pay_merchants pay_merchants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pay_merchants
    ADD CONSTRAINT pay_merchants_pkey PRIMARY KEY (id);


--
-- Name: pay_payment_methods pay_payment_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pay_payment_methods
    ADD CONSTRAINT pay_payment_methods_pkey PRIMARY KEY (id);


--
-- Name: pay_subscriptions pay_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pay_subscriptions
    ADD CONSTRAINT pay_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: pay_webhooks pay_webhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pay_webhooks
    ADD CONSTRAINT pay_webhooks_pkey PRIMARY KEY (id);


--
-- Name: profile_claims profile_claims_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_claims
    ADD CONSTRAINT profile_claims_pkey PRIMARY KEY (id);


--
-- Name: recruiters recruiters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recruiters
    ADD CONSTRAINT recruiters_pkey PRIMARY KEY (id);


--
-- Name: review_metrics review_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_metrics
    ADD CONSTRAINT review_metrics_pkey PRIMARY KEY (id);


--
-- Name: review_responses review_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_responses
    ADD CONSTRAINT review_responses_pkey PRIMARY KEY (id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: takedown_requests takedown_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.takedown_requests
    ADD CONSTRAINT takedown_requests_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_companies_on_region; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_on_region ON public.companies USING btree (region);


--
-- Name: index_experiences_on_interaction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_experiences_on_interaction_id ON public.experiences USING btree (interaction_id);


--
-- Name: index_identity_challenges_on_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_identity_challenges_on_expires_at ON public.identity_challenges USING btree (expires_at);


--
-- Name: index_identity_challenges_on_subject_type_and_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_identity_challenges_on_subject_type_and_subject_id ON public.identity_challenges USING btree (subject_type, subject_id);


--
-- Name: index_identity_challenges_on_token_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_identity_challenges_on_token_hash ON public.identity_challenges USING btree (token_hash);


--
-- Name: index_interactions_on_clerk_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_interactions_on_clerk_user_id ON public.interactions USING btree (clerk_user_id);


--
-- Name: index_interactions_on_recruiter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_interactions_on_recruiter_id ON public.interactions USING btree (recruiter_id);


--
-- Name: index_interactions_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_interactions_on_role_id ON public.interactions USING btree (role_id);


--
-- Name: index_interactions_on_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_interactions_on_target_id ON public.interactions USING btree (target_id);


--
-- Name: index_moderation_actions_on_actor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_moderation_actions_on_actor_id ON public.moderation_actions USING btree (actor_id);


--
-- Name: index_moderation_actions_on_subject_type_and_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_moderation_actions_on_subject_type_and_subject_id ON public.moderation_actions USING btree (subject_type, subject_id);


--
-- Name: index_pay_charges_on_customer_id_and_processor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pay_charges_on_customer_id_and_processor_id ON public.pay_charges USING btree (customer_id, processor_id);


--
-- Name: index_pay_charges_on_subscription_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pay_charges_on_subscription_id ON public.pay_charges USING btree (subscription_id);


--
-- Name: index_pay_customers_on_processor_and_processor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pay_customers_on_processor_and_processor_id ON public.pay_customers USING btree (processor, processor_id);


--
-- Name: index_pay_merchants_on_owner_type_and_owner_id_and_processor; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pay_merchants_on_owner_type_and_owner_id_and_processor ON public.pay_merchants USING btree (owner_type, owner_id, processor);


--
-- Name: index_pay_payment_methods_on_customer_id_and_processor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pay_payment_methods_on_customer_id_and_processor_id ON public.pay_payment_methods USING btree (customer_id, processor_id);


--
-- Name: index_pay_subscriptions_on_customer_id_and_processor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pay_subscriptions_on_customer_id_and_processor_id ON public.pay_subscriptions USING btree (customer_id, processor_id);


--
-- Name: index_pay_subscriptions_on_metered; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pay_subscriptions_on_metered ON public.pay_subscriptions USING btree (metered);


--
-- Name: index_pay_subscriptions_on_pause_starts_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pay_subscriptions_on_pause_starts_at ON public.pay_subscriptions USING btree (pause_starts_at);


--
-- Name: index_profile_claims_on_recruiter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_profile_claims_on_recruiter_id ON public.profile_claims USING btree (recruiter_id);


--
-- Name: index_profile_claims_on_recruiter_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_profile_claims_on_recruiter_id_and_user_id ON public.profile_claims USING btree (recruiter_id, user_id);


--
-- Name: index_profile_claims_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_profile_claims_on_user_id ON public.profile_claims USING btree (user_id);


--
-- Name: index_recruiters_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recruiters_on_company_id ON public.recruiters USING btree (company_id);


--
-- Name: index_recruiters_on_email_hmac; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_recruiters_on_email_hmac ON public.recruiters USING btree (email_hmac);


--
-- Name: index_recruiters_on_linkedin_url; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recruiters_on_linkedin_url ON public.recruiters USING btree (linkedin_url);


--
-- Name: index_recruiters_on_public_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_recruiters_on_public_slug ON public.recruiters USING btree (public_slug);


--
-- Name: index_recruiters_on_region; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recruiters_on_region ON public.recruiters USING btree (region);


--
-- Name: index_review_metrics_on_dimension; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_review_metrics_on_dimension ON public.review_metrics USING btree (dimension);


--
-- Name: index_review_metrics_on_experience_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_review_metrics_on_experience_id ON public.review_metrics USING btree (experience_id);


--
-- Name: index_review_responses_on_review_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_review_responses_on_review_id ON public.review_responses USING btree (review_id);


--
-- Name: index_review_responses_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_review_responses_on_user_id ON public.review_responses USING btree (user_id);


--
-- Name: index_review_responses_on_visible; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_review_responses_on_visible ON public.review_responses USING btree (visible);


--
-- Name: index_reviews_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reviews_on_company_id ON public.reviews USING btree (company_id);


--
-- Name: index_reviews_on_recruiter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reviews_on_recruiter_id ON public.reviews USING btree (recruiter_id);


--
-- Name: index_reviews_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reviews_on_status ON public.reviews USING btree (status);


--
-- Name: index_reviews_on_status_company_overall; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reviews_on_status_company_overall ON public.reviews USING btree (status, company_id, overall_score);


--
-- Name: index_reviews_on_status_recruiter_overall; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reviews_on_status_recruiter_overall ON public.reviews USING btree (status, recruiter_id, overall_score);


--
-- Name: index_reviews_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reviews_on_user_id ON public.reviews USING btree (user_id);


--
-- Name: index_roles_on_recruiting_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_recruiting_company_id ON public.roles USING btree (recruiting_company_id);


--
-- Name: index_roles_on_target_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_target_company_id ON public.roles USING btree (target_company_id);


--
-- Name: index_takedown_requests_on_sla_due_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_takedown_requests_on_sla_due_at ON public.takedown_requests USING btree (sla_due_at);


--
-- Name: index_takedown_requests_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_takedown_requests_on_status ON public.takedown_requests USING btree (status);


--
-- Name: index_takedown_requests_on_subject_type_and_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_takedown_requests_on_subject_type_and_subject_id ON public.takedown_requests USING btree (subject_type, subject_id);


--
-- Name: index_users_on_clerk_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_clerk_user_id ON public.users USING btree (clerk_user_id);


--
-- Name: index_users_on_email_hmac; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email_hmac ON public.users USING btree (email_hmac);


--
-- Name: index_users_on_public_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_public_slug ON public.users USING btree (public_slug);


--
-- Name: index_users_on_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_role ON public.users USING btree (role);


--
-- Name: index_users_on_verification_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_verification_status ON public.users USING btree (verification_status);


--
-- Name: pay_customer_owner_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX pay_customer_owner_index ON public.pay_customers USING btree (owner_type, owner_id, deleted_at);


--
-- Name: review_responses fk_rails_103f070a26; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_responses
    ADD CONSTRAINT fk_rails_103f070a26 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: moderation_actions fk_rails_260a5585ad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_actions
    ADD CONSTRAINT fk_rails_260a5585ad FOREIGN KEY (actor_id) REFERENCES public.users(id);


--
-- Name: review_metrics fk_rails_3323ae3117; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_metrics
    ADD CONSTRAINT fk_rails_3323ae3117 FOREIGN KEY (experience_id) REFERENCES public.experiences(id);


--
-- Name: interactions fk_rails_33d417dc5d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interactions
    ADD CONSTRAINT fk_rails_33d417dc5d FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: pay_charges fk_rails_44a2c276fa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pay_charges
    ADD CONSTRAINT fk_rails_44a2c276fa FOREIGN KEY (subscription_id) REFERENCES public.pay_subscriptions(id);


--
-- Name: interactions fk_rails_517fac3e2c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interactions
    ADD CONSTRAINT fk_rails_517fac3e2c FOREIGN KEY (recruiter_id) REFERENCES public.recruiters(id);


--
-- Name: reviews fk_rails_74a66bd6c5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT fk_rails_74a66bd6c5 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: profile_claims fk_rails_7ec76bebe2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_claims
    ADD CONSTRAINT fk_rails_7ec76bebe2 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: roles fk_rails_97546d643c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT fk_rails_97546d643c FOREIGN KEY (target_company_id) REFERENCES public.companies(id);


--
-- Name: roles fk_rails_9809557c32; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT fk_rails_9809557c32 FOREIGN KEY (recruiting_company_id) REFERENCES public.companies(id);


--
-- Name: recruiters fk_rails_990ecb7b39; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recruiters
    ADD CONSTRAINT fk_rails_990ecb7b39 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: reviews fk_rails_a42e03c480; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT fk_rails_a42e03c480 FOREIGN KEY (recruiter_id) REFERENCES public.recruiters(id);


--
-- Name: pay_charges fk_rails_b19d32f835; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pay_charges
    ADD CONSTRAINT fk_rails_b19d32f835 FOREIGN KEY (customer_id) REFERENCES public.pay_customers(id);


--
-- Name: profile_claims fk_rails_b1a030660d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_claims
    ADD CONSTRAINT fk_rails_b1a030660d FOREIGN KEY (recruiter_id) REFERENCES public.recruiters(id);


--
-- Name: pay_subscriptions fk_rails_b7cd64d378; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pay_subscriptions
    ADD CONSTRAINT fk_rails_b7cd64d378 FOREIGN KEY (customer_id) REFERENCES public.pay_customers(id);


--
-- Name: review_responses fk_rails_bc51f601d8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_responses
    ADD CONSTRAINT fk_rails_bc51f601d8 FOREIGN KEY (review_id) REFERENCES public.reviews(id);


--
-- Name: reviews fk_rails_c1a13c42e3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT fk_rails_c1a13c42e3 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: pay_payment_methods fk_rails_c78c6cb84d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pay_payment_methods
    ADD CONSTRAINT fk_rails_c78c6cb84d FOREIGN KEY (customer_id) REFERENCES public.pay_customers(id);


--
-- Name: interactions fk_rails_d5a1fbbd40; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interactions
    ADD CONSTRAINT fk_rails_d5a1fbbd40 FOREIGN KEY (target_id) REFERENCES public.users(id);


--
-- Name: experiences fk_rails_fa6b1c629d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.experiences
    ADD CONSTRAINT fk_rails_fa6b1c629d FOREIGN KEY (interaction_id) REFERENCES public.interactions(id);


--
-- PostgreSQL database dump complete
--


