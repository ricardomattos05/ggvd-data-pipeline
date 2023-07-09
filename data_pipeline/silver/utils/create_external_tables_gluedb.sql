CREATE EXTERNAL TABLE IF NOT EXISTS `uffic_silver_db`.`metadata_delta_table`
LOCATION 's3://uffic-silver-eucentral1-473178649040-dev/imdb/metadata/'
TBLPROPERTIES ('table_type' = 'DELTA');

CREATE EXTERNAL TABLE IF NOT EXISTS `uffic_silver_db`.`reviews_delta_table`
LOCATION 's3://uffic-silver-eucentral1-473178649040-dev/imdb/reviews/'
TBLPROPERTIES ('table_type' = 'DELTA');

CREATE EXTERNAL TABLE IF NOT EXISTS `uffic_silver_db`.`tags_delta_table`
LOCATION 's3://uffic-silver-eucentral1-473178649040-dev/movielens/tags/'
TBLPROPERTIES ('table_type' = 'DELTA');

CREATE EXTERNAL TABLE IF NOT EXISTS `uffic_silver_db`.`tag_count_delta_table`
LOCATION 's3://uffic-silver-eucentral1-473178649040-dev/movielens/tag_count/'
TBLPROPERTIES ('table_type' = 'DELTA');

CREATE EXTERNAL TABLE IF NOT EXISTS `uffic_silver_db`.`ratings_delta_table`
LOCATION 's3://uffic-silver-eucentral1-473178649040-dev/movielens/ratings/'
TBLPROPERTIES ('table_type' = 'DELTA');
