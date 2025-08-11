DECLARE table_exists BOOL;

-- Check if the table exists in the 'gold' dataset
SET table_exists = EXISTS (
    SELECT 1
    FROM gold.INFORMATION_SCHEMA.TABLES
    WHERE table_name = 'voting_percentages_per_city'
);

-- If the table does not exist, create it with the new data
IF NOT table_exists THEN

    CREATE TABLE gold.voting_percentages_per_city
    PARTITION BY year_partition AS

    WITH t1 AS (
        SELECT 
            election_year,
            turn_number,
            election_code,
            election_description,
            election_date,
            state_code,
            election_unit_code,
            election_unit_name,
            position_code,
            position_description,
            SUM(quantity_eligible_votes) AS quantity_eligible_votes,
            SUM(quantity_abstentions_votes) AS quantity_abstentions_votes,
            SUM(quantity_turnout_votes) AS quantity_turnout_votes,
            SUM(quantity_blank_votes) AS quantity_blank_votes,
            SUM(quantity_null_votes) AS quantity_null_votes,
            SUM(quantity_party_votes) AS quantity_party_votes
        FROM silver.voting_section_details
        WHERE year_partition = DATE({year}, 1, 1)
        GROUP BY ALL
    ),

    t2 AS (
        SELECT 
            *,
            CASE 
                WHEN quantity_eligible_votes = 0 THEN NULL
                ELSE quantity_abstentions_votes / quantity_eligible_votes
            END AS abstentions_percentage,
            CASE 
                WHEN quantity_turnout_votes = 0 THEN NULL
                ELSE quantity_blank_votes / quantity_turnout_votes
            END AS blank_percentage,
            CASE 
                WHEN quantity_turnout_votes = 0 THEN NULL
                ELSE quantity_null_votes / quantity_turnout_votes
            END AS null_percentage,
            CASE 
                WHEN quantity_turnout_votes = 0 THEN NULL
                ELSE quantity_party_votes / quantity_turnout_votes
            END AS party_percentage
        FROM t1
    )

    SELECT 
        DATE({year}, 1, 1) AS year_partition,
        CURRENT_TIMESTAMP() AS insert_datetime,
        election_year,
        turn_number,
        election_code,
        election_description,
        election_date,
        state_code,
        election_unit_code,
        election_unit_name,
        ARRAY_AGG(STRUCT(
            position_code, 
            position_description,
            abstentions_percentage,
            blank_percentage,
            null_percentage,
            party_percentage
        )) AS percentages
    FROM t2
    GROUP BY ALL;

-- If the table exists, delete the existing partition and insert the updated data
ELSE

    DELETE FROM gold.voting_percentages_per_city
    WHERE year_partition = DATE({year}, 1, 1);

    INSERT INTO gold.voting_percentages_per_city
    WITH t1 AS (
        SELECT 
            election_year,
            turn_number,
            election_code,
            election_description,
            election_date,
            state_code,
            election_unit_code,
            election_unit_name,
            position_code,
            position_description,
            SUM(quantity_eligible_votes) AS quantity_eligible_votes,
            SUM(quantity_abstentions_votes) AS quantity_abstentions_votes,
            SUM(quantity_turnout_votes) AS quantity_turnout_votes,
            SUM(quantity_blank_votes) AS quantity_blank_votes,
            SUM(quantity_null_votes) AS quantity_null_votes,
            SUM(quantity_party_votes) AS quantity_party_votes
        FROM silver.voting_section_details
        WHERE year_partition = DATE({year}, 1, 1)
        GROUP BY ALL
    ),

    t2 AS (
        SELECT 
            *,
            CASE 
                WHEN quantity_eligible_votes = 0 THEN NULL
                ELSE quantity_abstentions_votes / quantity_eligible_votes
            END AS abstentions_percentage,
            CASE 
                WHEN quantity_turnout_votes = 0 THEN NULL
                ELSE quantity_blank_votes / quantity_turnout_votes
            END AS blank_percentage,
            CASE 
                WHEN quantity_turnout_votes = 0 THEN NULL
                ELSE quantity_null_votes / quantity_turnout_votes
            END AS null_percentage,
            CASE 
                WHEN quantity_turnout_votes = 0 THEN NULL
                ELSE quantity_party_votes / quantity_turnout_votes
            END AS party_percentage
        FROM t1
    )

    SELECT 
        DATE({year}, 1, 1) AS year_partition,
        CURRENT_TIMESTAMP() AS insert_datetime,
        election_year,
        turn_number,
        election_code,
        election_description,
        election_date,
        state_code,
        election_unit_code,
        election_unit_name,
        ARRAY_AGG(STRUCT(
            position_code, 
            position_description,
            abstentions_percentage,
            blank_percentage,
            null_percentage,
            party_percentage
        )) AS percentages
    FROM t2
    GROUP BY ALL;

END IF;
