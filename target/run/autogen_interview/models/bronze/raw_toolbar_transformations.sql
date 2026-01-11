
  
  create view "interview"."main"."raw_toolbar_transformations__dbt_tmp" as (
    select * from read_csv_auto(
    'data/raw_toolbar_transformations.csv',
    header = true
)
  );
