CREATE SCHEMA IF NOT EXISTS users;
CREATE SCHEMA IF NOT EXISTS shops;
CREATE SCHEMA IF NOT EXISTS products;

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
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

create table public.ward (
	id SERIAL PRIMARY KEY NOT NULL,
	district_id int NOT NULL,
	ward_name varchar(100) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

create table public.category (
	id SERIAL PRIMARY KEY NOT NULL,
	name varchar(45) NOT NULL,
	image_url varchar(100),
	item_level int,
	parent_id int,
	is_active boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

comment on column public.category.item_level is 'level of category';
comment on column public.category.parent_id is 'id parent of category';

CREATE TYPE users.user_state AS ENUM ('ACTIVE', 'NOT_ACTIVE');
CREATE TYPE users.user_role AS ENUM ('ADMIN', 'MEMBER', 'SELLER');
CREATE TYPE users.user_provider AS ENUM ('LOCAL', 'GOOGLE', 'FACEBOOK', 'GITHUB');

create table users.user (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	phone varchar(15),
	email varchar(50) NOT NULL,
	password_crypt varchar(100),
	is_locked boolean DEFAULT false,
	name varchar(45),
	gender boolean,
	dob varchar(45),
	avatar_url varchar(100),
	state users.user_state DEFAULT 'NOT_ACTIVE',
	role users.user_role DEFAULT 'MEMBER',
	provider users.user_provider DEFAULT 'LOCAL',
	confirmed_at timestamp,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
comment on column users.user.dob is 'date of birth';


CREATE TYPE users.user_adress_type AS ENUM ('OFFICE', 'HOME');

create table users.user_adress (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	user_id bigint NOT NULL,
	full_name varchar(100) NOT NULL,
	phone varchar(15) NOT NULL,
	city_id int NOT NULL,
	district_id int NOT NULL,
	ward_id int NOT NULL,
	add_detail varchar(300),
	type users.user_adress_type DEFAULT 'HOME',
	is_default boolean DEFAULT false,
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


CREATE TYPE shops.shop_state AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

create table shops.shop (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	shop_name varchar(45) NOT NULL,
	avatar_url varchar(100),
	cover_url varchar(100),
	description text,
	is_locked boolean DEFAULT false,
	state shops.shop_state DEFAULT 'PENDING',
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
comment on column shops.shop.shop.id is 'map 1-1 with userId (1 user - 1 shop)';


CREATE TYPE shops.shop_address_type AS ENUM ('WAREHOUSE', 'STORE');

create table shops.shop_address (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	shop_id bigint NOT NULL,
	city_id int NOT NULL,
	district_id int NOT NULL,
	ward_id int NOT NULL,
	add_detail varchar(300),
	type shops.shop_address_type DEFAULT 'STORE',
	is_pickup boolean DEFAULT false,
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
comment on column shops.shop_address.is_pickup is 'là địa chỉ lấy hàng (1 shop phải có 1 địa chỉ lấy hàng)';


CREATE TYPE users.payment_type AS ENUM ('CARD', 'BANK');
CREATE TYPE users.payment_state AS ENUM ('PENDING', 'VERIFIED');
create table users.payment (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	object_id bigint NOT NULL,
	type users.payment_type,
	account_no varchar(20),
	account_holder varchar(50),
	bank_name varchar(50),
	bank_branch_name varchar(200),
	state users.payment_state DEFAULT 'PENDING',
	is_default boolean DEFAULT false,
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
comment on column users.payment.object_id is 'user_id or shop_id';
comment on column users.payment.type is 'CARD:Thẻ tín dụng/Ghi nợ, BANK: tài khoản ngân hàng';
comment on column users.payment.account_no is 'Số tài khoản';
comment on column users.payment.account_holder is 'Tên chủ tài khoản';
comment on column users.payment.bank_name is 'Tên ngân hàng';
comment on column users.payment.bank_branch_name is 'Chi nhánh ngân hàng';
comment on column users.payment.state is 'PENDING: chờ xác minh, VERIFIED: đã xác minh';
comment on column users.payment.is_default is 'TK thanh toán mặc định (1 tài khoản phải có 1 loại thanh toán mặc định)';


INSERT INTO public.city (city_name) VALUES
('An Giang'),
('Vũng Tàu'),
('Bắc Giang'),
('Bắc Kạn'),
('Bạc Liêu'),
('Bắc Ninh'),
('Bến Tre'),
('Bình Định'),
('Bình Dương'),
('Bình Phước'),
('Bình Thuận'),
('Cà Mau'),
('Cần Thơ'),
('Cao Bằng'),
('Đà Nẵng'),
('Đắk Lắk'),
('Đắk Nông'),
('Điện Biên'),
('Đồng Nai'),
('Đồng Tháp'),
('Gia Lai'),
('Hà Giang'),
('Hà Nam'),
('Hà Nội'),
('Hà Tĩnh'),
('Hải Dương'),
('Hải Phòng'),
('Hậu Giang'),
('Hoà Bình'),
('Hưng Yên'),
('Khánh Hòa'),
('Kiên Giang'),
('Kon Tum'),
('Lai Châu'),
('Lâm Đồng'),
('Lạng Sơn'),
('Lào Cai'),
('Long An'),
('Nam Định'),
('Nghệ An'),
('Ninh Bình'),
('Ninh Thuận'),
('Phú Thọ'),
('Phú Yên'),
('Quảng Bình'),
('Quảng Nam'),
('Quảng Ngãi'),
('Quảng Ninh'),
('Quảng Trị'),
('Sóc Trăng'),
('Sơn La'),
('Tây Ninh'),
('Thái Bình'),
('Thái Nguyên'),
('Thanh Hóa'),
('Huế'),
('Tiền Giang'),
('Hồ Chí Minh'),
('Trà Vinh'),
('Tuyên Quang'),
('Vĩnh Long'),
('Vĩnh Phúc'),
('Yên Bái');