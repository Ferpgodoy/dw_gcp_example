delete from gold.sales
where year = year('{data_agendamento}')
and month = month('{data_agendamento}');

INSERT INTO gold.sales_per_month (date, client, product, qntd, value,status)
SELECT
    year('{data_agendamento}'),
    month('{data_agendamento}'),
    sum(qntd) as qntd,
    sum(value) as value
FROM silver.sales
where year(date) = year('{data_agendamento}')
and month(date) = month('{data_agendamento}');