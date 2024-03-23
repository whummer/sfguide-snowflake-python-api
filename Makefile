VENV_BIN = python3 -m venv
VENV_DIR ?= .venv
VENV_ACTIVATE = $(VENV_DIR)/bin/activate
VENV_RUN = . $(VENV_ACTIVATE)

usage:				## Shows usage for this Makefile
	@cat Makefile | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

venv: $(VENV_ACTIVATE)

$(VENV_ACTIVATE): setup.py setup.cfg
	test -d .venv || $(VENV_BIN) .venv
	$(VENV_RUN); pip install --upgrade pip setuptools plux
	$(VENV_RUN); pip install -e .
	touch $(VENV_DIR)/bin/activate

install:		## Install dependencies
	# $(VENV_RUN); pflake8 --show-source snowflake_local tests
	npm i -g serverless

deploy:			## Deploy the app to LocalStack
	sls deploy --stage local

seed:			## Seed test data into LocalStack Snowflake
# Use these seeds for this quickstart: https://quickstarts.snowflake.com/guide/getting_started_with_snowflake
# 	snow sql -c local --query "create stage citibike_trips url='s3://snowflake-workshop-lab/citibike-trips/'"
# 	snow sql -c local --query 'create or replace table trips(tripduration integer,starttime timestamp,stoptime timestamp,start_station_id integer,start_station_name string,start_station_latitude float,start_station_longitude float,end_station_id integer,end_station_name string,end_station_latitude float,end_station_longitude float,bikeid integer,membership_type string,usertype string,birth_year integer,gender integer);'
# 	snow sql -c local --query 'copy into trips from @citibike_trips file_format=csv PATTERN = '"'"'.*csv.*'"'"

    # see: https://quickstarts.snowflake.com/guide/data_app/index.html#3
	snow sql -c local --query "create stage demo_data url='s3://demo-citibike-data'"
    # create 'trips' table and import data from public CSV files
	snow sql -c local --query 'create or replace table trips(tripduration integer,starttime timestamp,stoptime timestamp,start_station_id integer,end_station_id integer,bikeid integer,usertype string,birth_year integer,gender integer);'
	snow sql -c local --query 'copy into trips from @demo_data file_format=(type=csv skip_header=1) PATTERN = '"'"'trips__0_0_0.*csv.*'"'"
    # create 'weather' table and import data from public CSV files
	snow sql -c local --query 'create or replace table weather(STATE TEXT,OBSERVATION_DATE DATE,DAY_OF_YEAR NUMBER,TEMP_MIN_F NUMBER,TEMP_MAX_F NUMBER,TEMP_AVG_F NUMBER,TEMP_MIN_C FLOAT,TEMP_MAX_C FLOAT,TEMP_AVG_C FLOAT,TOT_PRECIP_IN NUMBER,TOT_SNOWFALL_IN NUMBER,TOT_SNOWDEPTH_IN NUMBER,TOT_PRECIP_MM NUMBER,TOT_SNOWFALL_MM NUMBER,TOT_SNOWDEPTH_MM NUMBER);'
	snow sql -c local --query 'copy into weather from @demo_data file_format=(type=csv skip_header=1) PATTERN = '"'"'weather__0_2_0.*csv.*'"'"


.PHONY: usage venv install deploy seed
