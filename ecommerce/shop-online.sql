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


CREATE TYPE users.user_status AS ENUM ('ACTIVE', 'NOT_ACTIVE');
CREATE TYPE users.user_role AS ENUM ('ADMIN', 'MEMBER', 'STAFF', 'MANAGER');
CREATE TYPE users.user_provider AS ENUM ('LOCAL', 'GOOGLE', 'FACEBOOK');

create table users.user (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	phone varchar(15),
	email varchar(100) NOT NULL,
	password_crypt varchar(200),
	status users.user_status DEFAULT 'NOT_ACTIVE',
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
comment on column users.user.status is 'status of user';
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
CREATE TYPE users.user_payment_status AS ENUM ('PENDING', 'VERIFIED');

create table users.payment (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	user_id bigint NOT NULL,
	type users.user_payment_type,
	account_no varchar(50),
	account_holder varchar(100),
	bank_name varchar(100),
	bank_branch_name varchar(500),
	status users.user_payment_status DEFAULT 'PENDING',
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
comment on column users.payment.status is 'PENDING: chờ xác minh, VERIFIED: đã xác minh';
comment on column users.payment.is_default is 'TK thanh toán mặc định (1 tài khoản phải có 1 loại thanh toán mặc định)';

create table commons.rating (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	product_id bigint NOT NULL,
	user_id bigint NOT NULL,
	rate_star int NOT NULL,
	is_reported boolean DEFAULT false,
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

comment on column commons.rating.product_id is 'id của sản phẩm được rate';
comment on column commons.rating.user_id is 'id người dánh giá';
comment on column commons.rating.rate_star is 'số sao rate cho sản phẩm';
comment on column commons.rating.is_reported is 'đánh giá bị báo cáo';

create table commons.rating_detail (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	rating_id bigint NOT NULL,
	comment_content text,
	image_urls text,
	parent_id bigint,
	level bigint,
	tree_path varchar(500),
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

comment on column commons.rating_detail.rating_id is 'id rating';
comment on column commons.rating_detail.comment_content is 'đánh giá chi tiết';
comment on column commons.rating_detail.image_urls is 'danh sách ảnh';
comment on column commons.rating_detail.parent_id is 'id comment của rating_detail cha';
comment on column commons.rating_detail.level is 'cấp của comment';
comment on column commons.rating_detail.tree_path is 'path level';

create table commons.rating_total (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	product_id bigint NOT NULL,
	rate_star_avg numeric(5,0),
	total_five_star int,
	total_four_star int,
	total_three_star int,
	total_two_star int,
	total_one_star int,
	total_comment int,
	total_comment_with_img int,
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TYPE commons.rating_report_status AS ENUM ('PENDING', 'VERIFIED');

create table commons.rating_report (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	rating_id bigint NOT NULL,
	message_config_id bigint,
	message_content varchar(500),
	status commons.rating_report_status DEFAULT 'PENDING',
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

create table commons.config (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	config_name varchar(500) NOT NULL,
	config_code varchar(500) NOT NULL,
	config_parent_id bigint,
	tree_path varchar(500),
	is_active boolean DEFAULT true,
	description varchar(500),
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

comment on column commons.config.config_name is 'Tên cấu hình';
comment on column commons.config.config_code is 'Code của cấu hình';
comment on column commons.config.config_parent_id is 'id danh mục cha';
comment on column commons.config.tree_path is 'path level vd: 1,3,5';


create table commons.item_config (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	config_id bigint NOT NULL,
	item_name varchar(500),
	item_code varchar(500),
	item_value varchar(500),
	tree_path varchar(500),
	item_parent_id bigint,
	is_active boolean DEFAULT true,
	description varchar(500),
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

comment on column commons.item_config.config_id is 'Lưu id cấu hình';


create table commons.event (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	event_name varchar(500),
	start_time timestamp,
	end_time timestamp,
	is_active boolean DEFAULT true,
	description text,
	create_by varchar(45),
	updated_by varchar(45),
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

comment on column commons.event.event_name is 'Tên sự kiện';
comment on column commons.event.start_time is 'Thời gian bắt đầu sự kiện';
comment on column commons.event.end_time is 'Thời gian kết thúc sự kiện';
comment on column commons.event.description is 'Mô tả chi tiết sự kiện';
comment on column commons.event.create_by is 'Lưu name trong bảng user';
comment on column commons.event.updated_by is 'Lưu name trong bảng user';


CREATE TYPE commons.banner_type AS ENUM ('EVENT', 'HEADER', 'FOOTER', 'OTHER');
create table commons.banner (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	event_id bigint,
	image_url varchar(500),
	position int,
	type commons.banner_type,
	is_active boolean DEFAULT true,
	create_by varchar(45),
	updated_by varchar(45),
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
comment on column commons.banner.event_id is 'Id của event';
comment on column commons.banner.position is 'vị trí hiển thị';

CREATE TYPE commons.voucher_type AS ENUM ('EVENT', 'NORMAL', 'DELIVERY', 'SPECIAL', 'OLD_MEMBER', 'NEW_MEMBER');
create table commons.voucher (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	voucher_name varchar(500) NOT NULL,
	voucher_code varchar(500) NOT NULL,
	description text,
	image_url varchar(500),
	price_discount numeric(10,0),
	percent_discount int,
	price_min_condition numeric(10,0),
	price_max_condition numeric(10,0),
	quantity int NOT NULL,
	event_id bigint,
	type commons.voucher_type,
	start_time timestamp NOT NULL,
	end_time timestamp NOT NULL,
	is_active boolean DEFAULT true,
	create_by varchar(45),
	updated_by varchar(45),
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
comment on column commons.voucher.voucher_name is 'Tên voucher';
comment on column commons.voucher.voucher_code is 'Mã code để nhập vào';
comment on column commons.voucher.price_discount is 'giá tiền đc giảm';
comment on column commons.voucher.percent_discount is '% tiền đc giảm';
comment on column commons.voucher.price_min_condition is 'giá tối thiểu để sử dụng voucher';
comment on column commons.voucher.price_max_condition is 'giá tối đa để sử dụng voucher';
comment on column commons.voucher.quantity is 'số lượng voucher';
comment on column commons.voucher.event_id is 'Id của event';
comment on column commons.voucher.start_time is 'thời gian bắt đầu có thể dùng (nếu voucher theo sự kiện thì sẽ mặc định bằng thời gian bắt đầu sự kiện)';
comment on column commons.voucher.end_time is 'thời gian kết thúc có thể dùng (nếu voucher theo sự kiện thì sẽ mặc định bằng thời gian kết thúc sự kiện)';

create table commons.voucher_log (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	voucher_id bigint NOT NULL,
	voucher_name varchar(500) NOT NULL,
	voucher_code varchar(500) NOT NULL,
	user_id bigint NOT NULL,
	order_id bigint NOT NULL,
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

comment on column commons.voucher_log.voucher_id is 'Id của voucher';
comment on column commons.voucher_log.voucher_name is 'Tên voucher';
comment on column commons.voucher_log.voucher_code is 'Mã code để nhập vào';
comment on column commons.voucher_log.user_id is 'id người sử dụng voucher';
comment on column commons.voucher_log.order_id is 'đơn hàng sử dụng voucher';


CREATE TYPE products.product_type AS ENUM ('NORMAL', 'SALE', 'SPECIAL', 'OTHER');
create table products.product (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	category_id bigint NOT NULL,
	name varchar(500) NOT NULL,
	code varchar(500) NOT NULL,
	image_urls text,
	tags bigint,
	brand bigint,
	original_price numeric(10,0) NOT NULL,
	variants varchar(500),
	description text,
	is_active boolean DEFAULT true,
	type products.product_type DEFAULT 'NORMAL',
	create_by varchar(45),
	updated_by varchar(45),
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

comment on column products.product.category_id is 'Danh mục của sản phẩm';
comment on column products.product.name is 'Tên sản phẩm';
comment on column products.product.code is 'Mã sản phẩm';
comment on column products.product.image_urls is 'danh sách ảnh sản phẩm (tối đa 3 ảnh)';
comment on column products.product.tags is 'lưu item_config_id với các tag được cấu hình trước';
comment on column products.product.brand is 'lưu item_config_id với các brand được cấu hình trước';
comment on column products.product.original_price is 'giá gốc của sản phẩm';
comment on column products.product.variants is 'lưu id trong bảng commons.config (id của phân loại ở dạng id1, id2)';
comment on column products.product.description is 'mô tả sản phẩm (lưu dạng html)';


create table products.product_variant (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	product_id bigint NOT NULL,
	image_url varchar(200) NOT NULL,
	weight numeric(5,0),
	width numeric(5,0),
	height numeric(5,0),
	length numeric(5,0),
	first_attribute_id bigint,
	first_attribute_value_id bigint,
	second_attribute_id bigint,
	second_attribute_value_id bigint,
	quantity bigint NOT NULL DEFAULT 0,
	sale_price numeric(10,0) NOT NULL,
	is_active boolean DEFAULT true,
	create_by varchar(45),
	updated_by varchar(45),
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

comment on column products.product_variant.product_id is 'id sản phẩm';
comment on column products.product_variant.image_url is 'lưu ảnh của phân loại sản phẩm';
comment on column products.product_variant.weight is 'cân nặng (sử dụng khi vận chuyển)';
comment on column products.product_variant.width is 'chiều rộng (sử dụng khi vận chuyển)';
comment on column products.product_variant.height is 'chiều cao (sử dụng khi vận chuyển)';
comment on column products.product_variant.length is 'chiều dài (sử dụng khi vận chuyển)';
comment on column products.product_variant.first_attribute_id is 'lưu id phân loại thứ 1 được cấu hình trong bảng commons.config';
comment on column products.product_variant.first_attribute_value_id is 'lưu id phân loại thứ 1 được cấu hình trong bảng commons.item_config';
comment on column products.product_variant.second_attribute_id is 'lưu id phân loại thứ 2 được cấu hình trong bảng commons.config';
comment on column products.product_variant.second_attribute_value_id is 'lưu id phân loại thứ 2 được cấu hình trong bảng commons.item_config';
comment on column products.product_variant.quantity is 'số lượng sản phẩm còn trong kho';
comment on column products.product_variant.sale_price is 'giá bán ra của sản phẩm theo phâm loại';

create table products.product_log (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	product_id bigint NOT NULL,
	total_rate bigint DEFAULT 0,
	total_sold bigint DEFAULT 0,
	avg_rate_star numeric(5, 0) DEFAULT 0.0,
	log text,
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

comment on column products.product_log.product_id is 'id sản phẩm';
comment on column products.product_log.total_rate is 'số lượng đánh giá (chạy schedule tổng hợp)';
comment on column products.product_log.total_sold is 'số lượng đã bán (đơn hàng ở trạng thái hoàn thành) (chạy schedule tổng hợp)';
comment on column products.product_log.avg_rate_star is 'số sao đánh giá trung bình (chạy schedule tổng hợp)';
comment on column products.product_log.log is 'lưu log cập nhật sản phẩm trong 30 ngày';



CREATE TYPE orders.order_status AS ENUM ('WAITING_FOR_CONFIRM', 'CONFIRMED', 'DELIVERY', 'WAITING_FOR_REVIEW', 'FINISH', 'CANCEL', 'RETURN');
CREATE TYPE orders.order_payment_status AS ENUM ('PAID', 'UNPAID');

create table orders.order (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	user_id bigint NOT NULL,
	detail_items text NOT NULL,
	detail_discount text NOT NULL,
	total_item int NOT NULL,
	total_amount_original numeric(10, 0) NOT NULL,
	total_amount_discount numeric(10, 0) NOT NULL,
	total_amount_paid numeric(10, 0) NOT NULL,
	status orders.order_status DEFAULT 'WAITING_FOR_CONFIRM',
	payment_status orders.order_payment_status DEFAULT 'UNPAID',
	payment_at timestamp,
	confirmed_at timestamp,
	confirmed_by varchar(45),
	delivery_at timestamp,
	finish_at timestamp,
	cancel_at timestamp,
	cancel_by varchar(45),
	cancel_reason varchar(500),
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
comment on column orders.order.user_id is 'lưu log cập nhật sản phẩm trong 30 ngày';
comment on column orders.order.detail_items is 'lưu chi tiết sản phẩm của đơn hàng, vd: [{id: 1, name: Áo mưa, code: 123, image_url: ..., original_price: 10000, sale_price: 8000, quantity: 1}]';
comment on column orders.order.detail_discount is 'lưu chi tiết khuyến mãi đã sử dụng cho đơn hàng này dạng json';
comment on column orders.order.total_item is 'lưu số lượng sản phẩm của đơn hàng';
comment on column orders.order.total_amount_original is 'tổng tiền của đơn hàng';
comment on column orders.order.total_amount_discount is 'tổng tiền đã được trừ khuyến mãi';
comment on column orders.order.total_amount_paid is 'tổng tiền user thanh toán';
comment on column orders.order.confirmed_at is 'thời gian xác nhận đơn từ trạng thái WAITING_FOR_CONFIRM -> CONFIRMED đối với những đơn hàng chưa thành toán (UNPAID)';
comment on column orders.order.confirmed_by is 'lưu name trong bảng user';
comment on column orders.order.delivery_at is 'thời gian giao hàng cho bên vận chuyển';
comment on column orders.order.finish_at is 'thời gian hoàn thành đơn hàng';
comment on column orders.order.cancel_at is 'thời gian xác nhận huỷ đơn hàng (chỉ huỷ được khi đơn đang ở 2 trạng thái (WAITING_FOR_CONFIRM, CONFIRMED) -> CANCEL';
comment on column orders.order.cancel_by is 'lưu name trong bảng user, nếu người dùng huỷ thì mặc định là CUSTOMER';
comment on column orders.order.cancel_reason is 'lưu giá trị được cấu hình sẵn cho lý do huỷ bỏ trong bảng commons.config';


CREATE TYPE orders.order_return_type AS ENUM ('RENEW', 'REFUND');
CREATE TYPE orders.order_return_status AS ENUM ('WAITING_FOR_CONFIRM', 'CONFIRMED');
CREATE TYPE orders.order_refund_status AS ENUM ('WAITING', 'NOTREFUND', 'REFUNDED');

create table orders.order_return (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	order_id bigint NOT NULL,
	image_urls text,
	return_type orders.order_return_type,
	return_reason varchar(500),
	return_reason_detail text,
	status orders.order_return_status,
	total_amount_refund numeric(10, 0),
	refund_status orders.order_refund_status,
	reason_not_refund varchar(500),
	confirmed_at timestamp,
	confirmed_by varchar(45),
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

comment on column orders.order_return.order_id is 'id chi tiết đơn hàng trả lại';
comment on column orders.order_return.image_urls is 'danh sách ảnh sản phẩm (tối đa 5 ảnh)';
comment on column orders.order_return.return_type is 'loại trả hàng Đổi mới - Hoàn tiền';
comment on column orders.order_return.return_reason is 'lưu giá trị được cấu hình sẵn cho lý do huỷ bỏ trong bảng commons.config';
comment on column orders.order_return.return_reason_detail is 'chi tiết lý do trả hàng';
comment on column orders.order_return.total_amount_refund is 'Số tiền hoàn lại nếu ở trạng thái REFUND';
comment on column orders.order_return.refund_status is 'Trạng thái hoàn tiền';
comment on column orders.order_return.reason_not_refund is 'Lý do không hoàn tiền cho đơn hàng khi đã được xác nhận';
comment on column orders.order_return.confirmed_at is 'thời gian xác nhận đơn từ trạng thái WAITING_FOR_CONFIRM -> CONFIRMED';


CREATE TYPE orders.order_log_old_status AS ENUM ('WAITING_FOR_CONFIRM', 'CONFIRMED', 'DELIVERY', 'WAITING_FOR_REVIEW', 'FINISH', 'CANCEL', 'RETURN');
CREATE TYPE orders.order_log_new_status AS ENUM ('CONFIRMED', 'DELIVERY', 'WAITING_FOR_REVIEW', 'FINISH', 'CANCEL', 'RETURN');
create table orders.order_log (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	order_id bigint NOT NULL,
	old_status orders.order_log_old_status,
	new_status orders.order_log_new_status,
	log text,
	create_by varchar(45),
	updated_by varchar(45),
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

comment on column orders.order_log.order_id is 'Id đơn hàng';
comment on column orders.order_log.old_status is 'Trạng thái trước của đơn hàng';
comment on column orders.order_log.new_status is 'Trạng thái sau của đơn hàng';
comment on column orders.order_log.log is 'lưu log cập nhật đơn hàng trong 30 ngày';


create table orders.shipping (
	id BIGSERIAL PRIMARY KEY NOT NULL,
	order_id bigint NOT NULL,
	log text,
	note text,
	delivery_unit bigint NOT NULL,
	status_delivery_unit varchar(500),
	status bigint NOT NULL,
	total_item int NOT NULL DEFAULT 0,
	total_weight numeric(5, 0) NOT NULL DEFAULT 0.0,
	pick_address varchar(1000),
	pick_province int NOT NULL,
	pick_district int NOT NULL,
	pick_ward int NOT NULL,
	pick_tel varchar(20) NOT NULL,
	destination_address varchar(1000),
	destination_province int NOT NULL,
	destination_district int NOT NULL,
	destination_ward int NOT NULL,
	destination_tel varchar(20) NOT NULL,
	fee numeric(10, 0) NOT NULL,
	tags bigint,
	create_by varchar(45),
	updated_by varchar(45),
	created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

comment on column orders.shipping.order_id is 'Id đơn hàng';
comment on column orders.shipping.log is 'lưu log cập nhật trạng thái vận chuyển';
comment on column orders.shipping.delivery_unit is 'Đơn vị vận chuyển được cấu hình trong config';
comment on column orders.shipping.status_delivery_unit is 'Trạng thái của bên ĐVVC (cập nhật qua schedule)';
comment on column orders.shipping.status is 'Trạng thái được cấu hình trên hệ thống config';
comment on column orders.shipping.total_item is 'Số sản phẩm gửi bên ĐVVC';
comment on column orders.shipping.total_weight is 'Tổng trọng lượng đơn hàng vận chuyển';
comment on column orders.shipping.pick_address is 'địa chỉ chi tiết (số nhà..., ngõ ngách) lấy hàng';
comment on column orders.shipping.pick_province is 'id tỉnh của địa chỉ lấy hàng';
comment on column orders.shipping.pick_district is 'id quận/huyện của địa chỉ lấy hàng';
comment on column orders.shipping.pick_ward is 'id phường/xã của địa chỉ lấy hàng';
comment on column orders.shipping.pick_tel is 'Số điện thoại lấy hàng';
comment on column orders.shipping.destination_address is 'địa chỉ chi tiết (số nhà..., ngõ ngách) nhận hàng';
comment on column orders.shipping.destination_province is 'id tỉnh của địa chỉ giao hàng';
comment on column orders.shipping.destination_district is 'id quận/huyện của địa chỉ giao hàng';
comment on column orders.shipping.destination_ward is 'id phường/xã của địa chỉ giao hàng';
comment on column orders.shipping.destination_tel is 'Số điện thoại nhận hàng';
comment on column orders.shipping.fee is 'Phí vận chuyển';
comment on column orders.shipping.tags is 'lưu item_config_id với các tag được cấu hình trước';
