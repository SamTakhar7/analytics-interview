
  
  create view "interview"."main"."raw_organisations__dbt_tmp" as (
    select * from read_csv_auto(
    'data/raw_organisations.csv',
    header = true
)
  );
