
  
  create view "interview"."main"."raw_research_transformations__dbt_tmp" as (
    select * from read_csv_auto(
    'data/raw_research_transformations.csv',
    header = true
)
  );
