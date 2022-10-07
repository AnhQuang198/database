CREATE TABLE `user` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `first_name` varchar(255),
  `last_name` varchar(255),
  `gender` boolean,
  `phone_number` varchar(255),
  `email` varchar(255),
  `avatar_url` varchar(255),
  `role` varchar(255),
  `status` varchar(255),
  `created_at` timestamp,
  `updated_at` timestamp
);

CREATE TABLE `city` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(255),
  `description` varchar(255),
  `created_at` timestamp,
  `updated_at` timestamp
);

CREATE TABLE `district` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `district_name` varchar(255),
  `city_id` int,
  `created_at` timestamp,
  `updated_at` timestamp
);

CREATE TABLE `voucher` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(255),
  `code` varchar(255),
  `description` varchar(255),
  `image_url` varchar(255),
  `price_discount` int,
  `percent_discount` int,
  `price_min_condition` int,
  `price_max_condition` int,
  `quantity` int,
  `time_start` timestamp,
  `time_end` timestamp,
  `created_at` timestamp,
  `updated_at` timestamp
);

CREATE TABLE `voucher_log` (
  `id` bigint PRIMARY KEY AUTO_INCREMENT,
  `voucher_id` int,
  `user_id` int,
  `order_tour_id` int,
  `created_at` timestamp
);

CREATE TABLE `tour` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(255),
  `description` text,
  `price` int,
  `images` [varchar],
  `city_id` int,
  `district_id` int,
  `total_day` int,
  `created_by` int,
  `status` varchar(255),
  `is_disable` boolean,
  `created_at` timestamp,
  `updated_at` timestamp
);

CREATE TABLE `tour_schedule` (
  `id` bigint PRIMARY KEY AUTO_INCREMENT,
  `tour_id` int,
  `detail` json
);

CREATE TABLE `hotel` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(255),
  `images` [varchar],
  `detail_address` varchar(255),
  `description` text,
  `type` varchar(255),
  `city_id` int,
  `district_id` int,
  `rate` float,
  `created_at` timestamp,
  `updated_at` timestamp
);

CREATE TABLE `room` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `hotel_id` int,
  `room_number` int,
  `floor` int,
  `price` int,
  `capacity` int,
  `is_available` boolean
);

CREATE TABLE `restaurant` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(255),
  `detail_address` varchar(255),
  `city_id` int,
  `district_id` int,
  `open_time` timestamp,
  `close_time` timestamp,
  `images` [varchar],
  `price` int,
  `rate` float,
  `created_at` timestamp,
  `updated_at` timestamp
);

CREATE TABLE `review` (
  `id` bigint PRIMARY KEY AUTO_INCREMENT,
  `user_id` int,
  `content` text,
  `images` [varchar],
  `rate_star` int,
  `type` varchar(255),
  `target_id` int,
  `created_at` timestamp,
  `updated_at` timestamp
);

CREATE TABLE `order_tour` (
  `id` bigint PRIMARY KEY AUTO_INCREMENT,
  `user_id` int,
  `tour_id` int,
  `restaurant_id` int,
  `hotel_id` int,
  `voucher_id` int,
  `total_person` int,
  `total_price` int,
  `status` varchar(255),
  `payment_state` varchar(255),
  `date_start` timestamp,
  `date_end` timestamp,
  `created_at` timestamp,
  `updated_at` timestamp
);

ALTER TABLE `room` ADD FOREIGN KEY (`hotel_id`) REFERENCES `hotel` (`id`);

ALTER TABLE `district` ADD FOREIGN KEY (`city_id`) REFERENCES `city` (`id`);

ALTER TABLE `hotel` ADD FOREIGN KEY (`district_id`) REFERENCES `district` (`id`);

ALTER TABLE `tour` ADD FOREIGN KEY (`district_id`) REFERENCES `district` (`id`);

ALTER TABLE `restaurant` ADD FOREIGN KEY (`district_id`) REFERENCES `district` (`id`);

ALTER TABLE `review` ADD FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE `tour_schedule` ADD FOREIGN KEY (`tour_id`) REFERENCES `tour` (`id`);

ALTER TABLE `voucher_log` ADD FOREIGN KEY (`voucher_id`) REFERENCES `voucher` (`id`);

ALTER TABLE `order_tour` ADD FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);
