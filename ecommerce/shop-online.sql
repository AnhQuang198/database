CREATE SCHEMA IF NOT EXISTS users;
CREATE SCHEMA IF NOT EXISTS shops;
CREATE SCHEMA IF NOT EXISTS products;
CREATE SCHEMA IF NOT EXISTS commons;
CREATE SCHEMA IF NOT EXISTS orders;


create table public.city (
	id SERIAL PRIMARY KEY NOT NULL,
	city_name varchar(100) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

create table public.district (
	id SERIAL PRIMARY KEY NOT NULL,
	city_id int NOT NULL,
	district_name varchar(100) NOT NULL,
	full_address varchar(200),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

create table public.ward (
	id SERIAL PRIMARY KEY NOT NULL,
	district_id int NOT NULL,
	ward_name varchar(100) NOT NULL,
	full_address varchar(200),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

create table public.category (
	id SERIAL PRIMARY KEY NOT NULL,
	name varchar(100) NOT NULL,
	image_url varchar(500),
	tree_path varchar(500),
	item_level int,
	parent_id int,
	is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
comment on column public.category.tree_path is 'path level vd: 1,3,5';
comment on column public.category.item_level is 'level of category';
comment on column public.category.parent_id is 'id parent of category';


CREATE TYPE users.user_state AS ENUM ('ACTIVE', 'NOT_ACTIVE');
CREATE TYPE users.user_role AS ENUM ('ADMIN', 'MEMBER', 'STAFF', 'MANAGER');
CREATE TYPE users.user_provider AS ENUM ('LOCAL', 'GOOGLE', 'FACEBOOK');

create table users.user (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	phone varchar(15),
	email varchar(100) NOT NULL,
	password_crypt varchar(200),
	state users.user_state DEFAULT 'NOT_ACTIVE',
	role users.user_role DEFAULT 'MEMBER',
	is_locked boolean DEFAULT false,
	provider users.user_provider DEFAULT 'LOCAL',
	name varchar(45),
	gender boolean,
	dob varchar(45),
	avatar_url varchar(200),
	confirmed_by varchar(45),
	confirmed_at timestamp,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
	
	CONSTRAINT unique_user_phone UNIQUE (phone),
	CONSTRAINT unique_user_email UNIQUE (email)
);
comment on column users.user.dob is 'date of birth';
comment on column users.user.state is 'status of user';
comment on column users.user.provider is 'user login oauth or local';
comment on column users.user.confirmed_by is 'với role MEMBER thì mặc định là SYSTEM, với các role còn lại thì lưu name của người duyệt';

CREATE TYPE users.user_adress_type AS ENUM ('OFFICE', 'HOME', 'PICKUP');

create table users.user_adress (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	user_id bigint NOT NULL,
	full_name varchar(100) NOT NULL,
	phone varchar(15) NOT NULL,
	city_id int NOT NULL,
	district_id int NOT NULL,
	ward_id int NOT NULL,
	add_detail varchar(500),
	type users.user_adress_type DEFAULT 'HOME',
	is_default boolean DEFAULT false NOT NULL,
	is_shop_address boolean DEFAULT false,
	is_active boolean DEFAULT true,
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

comment on column users.user_adress.is_shop_address is 'Địa chỉ của shop chỉ được tạo bởi role ADMIN';


CREATE TYPE users.user_payment_type AS ENUM ('CARD', 'BANK');
CREATE TYPE users.user_payment_state AS ENUM ('PENDING', 'VERIFIED');

create table users.payment (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	user_id bigint NOT NULL,
	type users.user_payment_type,
	account_no varchar(50),
	account_holder varchar(100),
	bank_name varchar(100),
	bank_branch_name varchar(500),
	state users.user_payment_state DEFAULT 'PENDING',
	is_default boolean DEFAULT false,
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
	
	CONSTRAINT unique_user_payment_account UNIQUE (account_no, account_holder)
);

comment on column users.payment.type is 'CARD:Thẻ tín dụng/Ghi nợ, BANK: tài khoản ngân hàng';
comment on column users.payment.account_no is 'Số tài khoản';
comment on column users.payment.account_holder is 'Tên chủ tài khoản';
comment on column users.payment.bank_name is 'Tên ngân hàng';
comment on column users.payment.bank_branch_name is 'Chi nhánh ngân hàng';
comment on column users.payment.state is 'PENDING: chờ xác minh, VERIFIED: đã xác minh';
comment on column users.payment.is_default is 'TK thanh toán mặc định (1 tài khoản phải có 1 loại thanh toán mặc định)';

