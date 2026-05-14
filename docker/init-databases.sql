-- Um banco por microsserviço (padrão comum em produção; localmente tudo no mesmo PostgreSQL)

CREATE DATABASE auth_db;
CREATE DATABASE user_db;
CREATE DATABASE restaurant_db;
CREATE DATABASE order_db;
CREATE DATABASE payment_db;
CREATE DATABASE notification_db;
