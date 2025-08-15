from airflow.decorators import dag, task
from airflow.operators.python import get_current_context
import pendulum
from dags.tasks.execute_sql import execute_sql
from datetime import datetime

@dag(
    schedule="@yearly",
    start_date=pendulum.datetime(2024, 1, 1, tz="America/Sao_Paulo"),
    catchup=False,
    doc_md="""
    ### DAG: Sales Update
    Executes transformation in Brazilian Election Datasets in three layers on BigQuery (Medallion Architecture):
    - **Bronze**
    - **Silver**
    - **Gold**
    """
)
def dag_elections():

    @task()
    def get_year():
        context = get_current_context()
        schedule_date = context['ds']
        return datetime.strptime(schedule_date, "%Y-%m-%d").year

    year = get_year()

    def make_tasks(layer, files):
        """Dynamic creates layer's tasks."""
        tasks = {}
        for name, sql_file in files.items():
            tasks[name] = execute_sql.override(task_id=f"{layer}_{name}")(
                sql_path=f"../../include/transformation/{layer}/{sql_file}.sql",
                parameters={"year": year}
            )
        return tasks

    # Queries Definition
    bronze_files = {
        "candidate_assets": "candidate_assets",
        "candidates": "candidates",
        "candidate_social_media": "candidate_social_media",
        "revocation_reason": "revocation_reason",
        "electorate_profile": "electorate_profile",
        "positions": "positions",
        "voting_section_details": "voting_section_details"
    }

    silver_files = {
        "candidate_assets": "candidate_assets",
        "candidates": "candidates",
        "candidate_social_media": "candidate_social_media",
        "revocation_reason": "revocation_reason",
        "electorate_profile": "electorate_profile",
        "positions": "positions",
        "voting_section_details": "voting_section_details"
    }

    gold_files = {
        "voting_percentages_per_city": "voting_percentages_per_city",
        "candidates_scd": "candidates_scd",
        "candidates_unified": "candidates_unified",
        "electorate_profile_aggregated": "electorate_profile_aggregated",
        "positions": "positions",
        "voting_percentages_per_city": "voting_percentages_per_city"
    }

    # Tasks creation
    bronze_tasks = make_tasks("bronze", bronze_files)
    silver_tasks = make_tasks("silver", silver_files)
    gold_tasks = make_tasks("gold", gold_files)

    # Dependencies
    year >> list(bronze_tasks.values())

    bronze_tasks["candidate_assets"] >> silver_tasks["candidate_assets"]
    bronze_tasks["candidate_social_media"] >> silver_tasks["candidate_social_media"]
    bronze_tasks["revocation_reason"] >> silver_tasks["revocation_reason"]
    bronze_tasks["electorate_profile"] >> silver_tasks["electorate_profile"]
    bronze_tasks["positions"] >> silver_tasks["positions"]
    bronze_tasks["voting_section_details"] >> silver_tasks["voting_section_details"]
    bronze_tasks["candidates"] >> silver_tasks["candidates"]

    silver_tasks["candidate_assets"] >> gold_tasks["candidates_scd"]
    silver_tasks["candidates"] >> gold_tasks["candidates_scd"]
    silver_tasks["candidate_social_media"] >> gold_tasks["candidates_scd"]
    silver_tasks["revocation_reason"] >> gold_tasks["candidates_scd"]
    silver_tasks["electorate_profile"] >> gold_tasks["electorate_profile_aggregated"]
    silver_tasks["positions"] >> gold_tasks["positions"]
    silver_tasks["voting_section_details"] >> gold_tasks["voting_percentages_per_city"]

    gold_tasks["candidates_scd"] >> gold_tasks["candidates_unified"]

dag_elections()
