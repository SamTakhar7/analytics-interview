# AutogenAI – Analytics Engineering Exercise

## Overview

This is a time-boxed analytics engineering exercise designed to reflect the kind of work you would do at AutogenAI. The dbt project and data stack are already scaffolded; your task is to model raw product activity data into an analytics layer that would support reliable KPI reporting in a BI tool (we use Power BI).

You do **not** need to build dashboards. Instead, focus on designing data models that make the KPIs below easy and robust to compute in a visualisation layer.

This exercise is intentionally open-ended. We care about your modelling choices, assumptions, and how you communicate them.

* **Expected time:** ~2–3 hours
* **Submission:** Link to git repository (or emailed zip) with your changes

## Prerequisites

You will need a python environment or docker installed.

Some basic DBT knowledge. In short, You contribute to the project by adding SQL files to the models/gold folder, and assert that they run by running the dbt commands documented at end of this README.

## Context

You are given raw datasets representing usage of a B2B SaaS platform:

* Organisations and users
* Navigation events (clicking around the platform)
* Two types of “transformations” (toolbar and research), where a 'transformation' means a user has received a response from our AI

For the purposes of this exercise:

* All activity tables together represent *all* user activity on the platform
* A user is considered **active** if they have activity in **any** of the activity tables
* Usage KPIs should generally exclude AutogenAI employees and unlicensed users, unless you explicitly justify otherwise
* The tables have been stripped of most fields, to keep them as simple as possible and relevant to the exercise.

The included dbt project:

We wanted to make it as simple as possible to run DBT on your machine and start building your model. 
A DBT project is therefore already provided that can be run via docker or by creating a local python env (example commands at end of README). 
If you have any issues getting this running, please get in touch and we'd be keen to help. 
The point of this exercise is not to test how well you can set up an environment!


Included in the project are:
* bronze models that load the raw CSVs
* silver models that clean and type the raw data
* empty gold folder to put your SQL in
* Docker and local (venv) run commands

---

## KPIs the business wants to support

Your models should enable a BI tool to compute the following KPIs. You do not need to calculate the KPIs, but solely build a data model to support their calculation.

* **Active Users (DAU/WAU/MAU)**
* **Number of sessions per user**
* **Session length**
* **Number of transformations over time**
* **Licence utilisation %**

These KPIs must be computable:

* over arbitrary time ranges
* as totals and averages
* sliced by organisation and by user

### Definitions and constraints

* **Active Users**
  Anyone with a recorded activity in any of the activity tables within a time period.

* **Sessions**
  You should derive sessions from looking across all the activity data, using an inactivity threshold of 30 minutes.

* **Session length**
  Should be derived from observed activity timestamps.
  If you make assumptions (e.g. max–min vs capped gaps), document them.

* **Number Of Transformations**
  Each entry from either the toolbar_transformations and research_transformations tables counts as a single transformation

* **Licence utilisation %**
  Percentage of an organisation’s contracted licences that are used by active users in a given period (i.e. number of active users / contracted licences)


Again, your gold tables do not need to contain these KPIs directly, but should be structured so that you can explain clearly how to compute them in the visualisation layer.

---

## Your tasks

### 1. Model the data

We follow the medallion architecture in our data:

In this bronze acts as a raw data layer, silver is a cleaned and conformed layer, and gold is the analytics layer.
We have already provided the silver and bronze layers for you.

Your task:

* Use dbt to build **gold** models from the provided silver layer (feel free to create more silver layer tables if you see fit)
* Decide what gold tables to create and at what grain(s)
* Your goal is to make gold tables that could be used in a BI tool to compute the KPIs easily and reliably


### 2. Sessionise activity

* Combine activity sources
* Implement sessionisation logic in SQL
* Ensure the logic is deterministic and well explained

### 3. Union transformations

* Combine transformation tables appropriately, making sure that transformation KPIs can be sliced by transformation type
* The transformation type of the research_transformations can have a value of 'research'


### 4. Discussion

You don't need to document the below, but this is what we will discuss with you after your submission.

* Most crucially: how would you compute each KPI in a BI tool from your gold models?
* Did you manage to test the code for your models by inspecting the outputs? If so, how? If not, how would you approach testing them?
* DBT has lots of testing functionality, what tests would you add to ensure data quality and why? 
* As the data scales, what challenges do you foresee and how would you address them (thinking about memory space and processing time)?
* The users and orgs tables only show if they are currently active. This has issues for historical reporting. How would you address this (assume here you have full control over historic orgs and user data and can remodel them as you wish)?
* We have emails in the user data, some of our reports need emails in them, others should be anonymised, how would you handle this?
* Look at the silver tables, is there anything you would improve/change in the code at that layer?


### 5. Bonus points (optional)

You are able to explore the data you created in this project using a jupyter notebook (or equivalent). 
You can either submit a notebook with some example code or just let us know in discussion how you'd do it.
Ideally you'd use this to validate your models and perform some sanity checks on the outputs, and initial probing of results.

---

## What we’re looking for

Here are the three things we want to know about you:

* Can you think about modelling data effectively for analytics purposes?
* Can you execute a brief?
* Can you write SQL?

Things we don't mind:

* If your SQL isn't perfectly formatted and linted
* If your DBT project runs with any warnings, we just want to see that your model runs successfully
* About the exact naming conventions for your tables/fields - don't sweat over this stuff too much!


There is no single “correct” solution. We care about whether your solution would be trustworthy, maintainable, and useful in a real product environment.

---

## How to run the project

### With Docker (recommended)


In your terminal, in the root of this project, run:


```bash
docker-compose up --build
```

### Locally with Python venv (optional)

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

dbt run --profiles-dir .
```
---

## Final note

Please keep the exercise time-boxed. If something feels underspecified, make a reasonable assumption and document it. We value judgement and clarity over completeness.
