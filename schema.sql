CREATE TABLE posts (
	id serial PRIMARY KEY,
	name text NOT NULL UNIQUE,
	period text NOT NULL,
	post text NOT NULL,
	post_date DATE NOT NULL DEFAULT CURRENT_DATE,
	post_time TIME NOT NULL DEFAULT CURRENT_TIME
);

UPDATE posts SET post_time = DATE_TRUNC('seconds', NOW());