CREATE TABLE posts (
	id serial PRIMARY KEY,
	name text NOT NULL UNIQUE,
	period text NOT NULL,
	post text NOT NULL,
	post_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE users (
id serial PRIMARY KEY,
username text NOT NULL UNIQUE,
password text NOT NULL
);