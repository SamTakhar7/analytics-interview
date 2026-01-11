
  
  create view "interview"."main"."raw_users__dbt_tmp" as (
    select * from read_csv_auto(
    'data/raw_users.csv',
    header = true
)
  );
