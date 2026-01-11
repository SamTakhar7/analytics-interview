
  
  create view "interview"."main"."raw_navigation__dbt_tmp" as (
    select * from read_csv_auto(
    'data/raw_navigation.csv',
    header = true
)
  );
