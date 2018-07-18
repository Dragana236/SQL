install.packages("RMySQL")
library(DBI) # library(RMySQL) not required

con <- dbConnect(RMySQL::MySQL(),
                 dbname = "financial",
                 host = "relational.fit.cvut.cz",
                 port = 3306,
                 user = "guest",
                 password = "relational")


# List table in a database
dbListTables(con)

#### Inner Join  ####

# Inner join the account table on the left to the loan table on the right, on the account_id field in both tables, keeping only the date field from loan table
dbGetQuery(con,'SELECT p2.date
           FROM account AS p1
           INNER JOIN loan AS p2
           ON p1.account_id = p2.account_id
           LIMIT 10')
 
# Get date from account and loan table as well A9 from district table
dbGetQuery(con, 'SELECT c.date, p.date, A9
           FROM account AS c
           INNER JOIN loan AS p
           ON c.account_id = p.account_id
           INNER JOIN district AS e
           ON c.district_id = e.district_id
           LIMIT 10')

# Inner join account on the left and district on the right using USING shortcut
# Select the fields corresponding to frequency AS freq and A10
dbGetQuery(con,'SELECT frequency AS freq, A10
           FROM account AS p
           INNER JOIN district AS e
           USING(district_id)
           LIMIT 10')

####Case when and then####

dbGetQuery(con, 'SELECT *,
           CASE WHEN district_id > 40 THEN "large"
                WHEN district_id >  70 THEN "medium"
                ELSE "small" END AS district_groups
            FROM account
            ORDER BY district_groups
            LIMIT 10')


####Outer joins####
# Left Join
# Left join tables account and loan on account_id selecting date from both tables, amount and duration
dbGetQuery(con,'SELECT p.date, e.date, amount, duration
           FROM account AS p
           LEFT JOIN loan AS e
           ON p.account_id = e.account_id
           LIMIT 10')

# Left join tables account and loan on account_id selecting date, amount and duration, focusing only on district_id that is 23 and order by date
dbGetQuery(con,'SELECT p.date, amount, duration
           FROM account AS p
           LEFT JOIN loan AS e
           ON p.account_id = e.account_id
           WHERE district_id = 25
           ORDER BY date
           LIMIT 10')
# Right join account and loan tables on account_id, selecting all columns that are ordered according account_id in descending order
dbGetQuery(con,'SELECT *
           FROM account AS p
           RIGHT JOIN loan AS e
           ON p.account_id = e.account_id
           ORDER BY e.account_id DESC
           LIMIT 10')
# Check the number of records
dbGetQuery(con,'SELECT COUNT(*)
           FROM account')

dbGetQuery(con,'SELECT COUNT(*)
           FROM loan')

# Full join
dbGetQuery(con,'SELECT left_table.val, right_table.val
             FROM left_table
             FULL JOIN right_table
             USING(id)')

# MySQL does not support full join, instead we can use UNION ALL
dbGetQuery(con,'SELECT account.date, loan.date
           FROM account
           LEFT JOIN loan
           USING(account_id)
           UNION ALL
           SELECT COUNT(*)
           FROM account
           RIGHT JOIN loan
           USING(account_id)')


# Cross Joins
dbGetQuery(con,'SELECT *
           FROM account
           CROSS JOIN loan
           WHERE account.date IN ("1997-01-08", "1997-02-08")
           LIMIT 10')


dbDisconnect(con)
