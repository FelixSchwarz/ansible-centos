CREATE TABLE aliases(
    id integer PRIMARY KEY,
    local_part varchar(200) NOT NULL,
    domain varchar(200) NOT NULL,
    target_address varchar(200) NOT NULL,
    memo TEXT,
    unique ('local_part', 'domain')
);

CREATE TABLE users(
    id integer PRIMARY KEY,
    local_part varchar(200) NOT NULL,
    domain varchar(200) NOT NULL,
    password varchar(200) NOT NULL,
    memo TEXT,
    unique ('local_part', 'domain')
);

