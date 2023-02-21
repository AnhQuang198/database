CREATE SCHEMA IF NOT EXISTS users;
CREATE SCHEMA IF NOT EXISTS shops;
CREATE SCHEMA IF NOT EXISTS products;
CREATE SCHEMA IF NOT EXISTS commons;

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
	name varchar(45) NOT NULL,
	image_url varchar(100),
	item_level int,
	parent_id int,
	tree_path varchar(50),
	is_active boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
comment on column public.category.tree_path is 'path level vd: 1,3,5';
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
CREATE TYPE shops.shop_type AS ENUM ('NORMAL', 'FAVORITE', 'MALL');

create table shops.shop (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	shop_name varchar(45) NOT NULL,
	avatar_url varchar(100),
	cover_url varchar(100),
	category_id bigint NOT NULL,
	industry_name varchar(100),
	type shops.shop_type DEFAULT 'NORMAL',
	description text,
	is_locked boolean DEFAULT false,
	state shops.shop_state DEFAULT 'PENDING',
	confirmed_at timestamp,
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
comment on column shops.shop.id is 'map 1-1 with userId (1 user - 1 shop)';
comment on column shops.shop.category_id is 'id trong bảng danh mục (Id ngành hàng)';
comment on column shops.shop.industry_name is 'tên ngành hàng của shop';
comment on column shops.shop.type is 'các loại Shop, mặc định tạo nếu ko có giấy tờ là NORMAL';


CREATE TYPE shops.shop_license_state AS ENUM ('PENDING', 'APPROVED', 'REJECTED');
create table shops.shop_license (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	shop_id bigint NOT NULL,
	front_identity_card_url varchar(100),
	back_identity_card_url varchar(100),
	owner_name varchar(100) NOT NULL,
	identity_number varchar(50) NOT NULL,
	identity_release_date varchar(100) NOT NULL,
	business_license_url varchar(100),
	tax_code varchar(50),
	company_name varchar(100),
	state shops.shop_license_state DEFAULT 'PENDING',
	reject_reason text,
	confirmed_at timestamp,
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
comment on column shops.shop_license.owner_name is 'Tên chủ đăng ký kinh doanh';
comment on column shops.shop_license.identity_number is 'số CCCD chủ đăng ký';
comment on column shops.shop_license.identity_release_date is 'ngày cấp CCCD';
comment on column shops.shop_license.business_license_url is 'giấy phép đăng ký kinh doanh';
comment on column shops.shop_license.tax_code is 'mã số thuế';
comment on column shops.shop_license.company_name is 'tên công ty đăng ký kinh doanh';
comment on column shops.shop_license.reject_reason is 'lý do từ chối (nếu có)';



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


create table commons.rating (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	shop_id bigint NOT NULL,
	product_id bigint NOT NULL,
	user_id bigint NOT NULL,
	rate_star int NOT NULL,
	is_reported boolean DEFAULT false,
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
comment on column commons.rating.shop_id is 'id của shop chứa sản phẩm';
comment on column commons.rating.product_id is 'id của sản phẩm được rate';
comment on column commons.rating.user_id is 'id người dánh giá';
comment on column commons.rating.rate_star is 'số sao rate cho sản phẩm';
comment on column commons.rating.is_reported is 'đánh giá bị báo cáo';


create table commons.rating_detail (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	rating_id bigint NOT NULL,
	comment_content text,
	image_urls text,
	parent_id int,
	level int,
	tree_path varchar(50),
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
comment on column commons.rating_detail.rating_id is 'id rating';
comment on column commons.rating_detail.comment_content is 'đánh giá chi tiết';
comment on column commons.rating_detail.image_urls is 'danh sách ảnh';
comment on column commons.rating_detail.parent_id is 'id comment của rating_detail cha';


CREATE TYPE commons.rating_report_state AS ENUM ('PENDING', 'VERIFIED');
create table commons.rating_report (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	rating_id bigint NOT NULL,
	message_config_id int,
	message_content varchar(200),
	state commons.rating_report_state DEFAULT 'PENDING',
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

create table commons.rating_total (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	shop_id bigint NOT NULL,
	product_id bigint NOT NULL,
	rate_star_avg float NOT NULL,
	total_five_star int DEFAULT 0,
	total_four_star int DEFAULT 0,
	total_three_star int DEFAULT 0,
	total_two_star int DEFAULT 0,
	total_one_star int DEFAULT 0,
	total_comment int DEFAULT 0,
	total_comment_with_img int DEFAULT 0,
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TYPE commons.message_config_type AS ENUM ('RATING_REPORT');
create table commons.message_config (
	id SERIAL PRIMARY KEY NOT NULL,
	message_content varchar(200) NOT NULL,
	type commons.message_config_type,
	is_active boolean DEFAULT true,
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

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