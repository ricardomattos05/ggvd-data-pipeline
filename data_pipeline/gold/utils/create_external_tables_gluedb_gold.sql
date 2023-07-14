CREATE EXTERNAL TABLE IF NOT EXISTS `uffic_gold_db`.`movies_analytics`
LOCATION 's3://uffic-gold-eucentral1-473178649040-dev/movie_analysis/movie_analytics/'
TBLPROPERTIES ('table_type' = 'DELTA');
