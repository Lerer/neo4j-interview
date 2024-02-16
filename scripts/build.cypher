// Create a constraint to avoid duplicate Customers
CREATE CONSTRAINT Customer_Id IF NOT EXISTS
FOR (c:Customer) 
REQUIRE c.id IS UNIQUE;

// Create a constraint to avoid duplicate Stocks
CREATE CONSTRAINT Stock_ticker IF NOT EXISTS
FOR (s:Stock) 
REQUIRE s.ticker IS UNIQUE;

// Create a constraint to avoid duplicate Funds
CREATE CONSTRAINT Fund_ticker IF NOT EXISTS
FOR (f:Fund) 
REQUIRE f.ticker IS UNIQUE;

// Create a constraint to avoid duplicate Day
CREATE CONSTRAINT Day_date IF NOT EXISTS
FOR (d:Day) 
REQUIRE d.date IS UNIQUE;

// Create a constraint to avoid multiple DayClose for the same ticker in the same date
CREATE CONSTRAINT DayClose_id IF NOT EXISTS
FOR (d:DayClose) 
REQUIRE d.id IS UNIQUE;


// 1a – Load customers - with the relevant information
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/Lerer/neo4j-interview/main/NEO4J_EXERCISE_FILES/customers.csv' AS row
MERGE (c:Customer {id:row.customer_id})
SET c.name=row.owner_name;

// 1b,1c – Load and link accounts
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/Lerer/neo4j-interview/main/NEO4J_EXERCISE_FILES/accounts.csv' AS row
MATCH (c:Customer {id:row.customer_id})
MERGE (a:Account {
accountId : toInteger(row.account_id),
accountType : row.account_type,
channel:row.channel })
MERGE (c)-[:OWNS]->(a);

// Load Stock Tickers
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/Lerer/neo4j-interview/main/NEO4J_EXERCISE_FILES/stock_ticker.csv' AS row
MERGE (s:Stock {
ticker : row.ticker,
holdingCompany : row.holding_company});

// Load Funds with their tickers id
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/Lerer/neo4j-interview/main/NEO4J_EXERCISE_FILES/funds.csv' AS row
MERGE (f:Fund {
ticker : row.ticker,
name: row.fund_name,
assets : toInteger(row.assets),
manager: row.manager,
inception_date: date(row.inception_date),
company: row.company,
expense_ratio: toFloat(row.expense_ratio)
});

// Load Funds holdings
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/Lerer/neo4j-interview/main/NEO4J_EXERCISE_FILES/fund_holdings.csv' AS row
MATCH (f:Fund {ticker:row.fund_ticker})
MATCH (s:Stock {ticker:row.holding_ticker})
MERGE (f)-[:HOLDS {percentage:toFloat(row.percentage)}]->(s);

// Load Account purchases
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/Lerer/neo4j-interview/main/NEO4J_EXERCISE_FILES/account_purchases.csv' AS row
MATCH (t:Fund|Stock) WHERE t.ticker=row.ticker
MATCH (a:Account) WHERE a.accountId=toInteger(row.account_id)
MERGE (a)-[:PURCHASED {quantity:toInteger(row.number_of_shares),purchaseDate:date(row.purchase_date)}]->(t);

// Load Daily close values
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/Lerer/neo4j-interview/main/NEO4J_EXERCISE_FILES/daily_close.csv' AS row
CALL {
  WITH row
  MATCH (t:Fund|Stock) WHERE t.ticker=row.ticker
  MERGE (d:Day {date:date(row.date)})
  MERGE (c:DayClose {id: row.ticker+'-'+row.date})
  ON CREATE
    SET
      c.open= toFloat(row.open),
      c.close= toFloat(row.close),
      c.high= toFloat(row.high),
      c.low= toFloat(row.low),
      c.day=date(row.date)
  MERGE (t)-[:DAILY_CLOSE {day:date(row.date)}]->(c)
  MERGE (d)-[:DATE_CLOSE]->(c)
} IN TRANSACTIONS;
