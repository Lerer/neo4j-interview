
// 2a) Find all Accounts that own MSFT stock directly through an individual account
MATCH (c:Customer)-[o:OWNS]->(a:Account)-[r:PURCHASED]->(s:Stock {ticker:'MSFT'}) 
RETURN a,r,s,c,o;


// 2b) Find all Accounts that hold MSFT through a mutual fund.
MATCH (c:Customer)-[o:OWNS]->(a:Account)-[r:PURCHASED]-(f:Fund)-[h:HOLDS]->(s:Stock {ticker:'MSFT'}) 
RETURN a,r,s,c,o,f,h;


// 2c) Return a count of the number of times a fund holds a stock, sorted in descending count order.
MATCH (f:Fund)-[h:HOLDS]->(s:Stock)
RETURN s.ticker AS Ticker,count(h) as `# of Funds Holding`  ORDER BY count(h) DESC;


// 2d) Return the value of mutual fund holdings owned by ‘Ed Chowder’ close date = 5/15/18. Calculate the
//     value of the fund holdings and order by fund name.
MATCH (c:Customer {name:"Ed Chowder"})-[]-(a:Account)-[p:PURCHASED]->(f:Fund)-[d:DAILY_CLOSE {day:date("2018-05-15")}]->(dc)
RETURN c.name as `Owner name`,f.name as `Fund name`,round(p.quantity*dc.close,1) as value;


// 3a) Return account owner name(s) and account type(s) that own MSFT stock directly through an individual
//     account or through a mutual fund. You do not have to count the number of account types a person owns
//     (e.g. owner has more than one account type “Individual”)
CALL {
    MATCH (c:Customer)-[o:OWNS]->(a:Account)-[r:PURCHASED]-(f:Fund)-[h:HOLDS]->(s:Stock {ticker:'MSFT'}) 
    RETURN c.name as `Owner Name`,a.accountType AS `Account Type`,s.ticker as Ticker
    UNION
    MATCH (c:Customer)-[o:OWNS]->(a:Account)-[r:PURCHASED]->(s:Stock {ticker:'MSFT'}) 
    RETURN c.name as `Owner Name`,a.accountType AS `Account Type`,s.ticker as Ticker
}
RETURN `Owner Name`, `Account Type`,Ticker ORDER BY `Owner Name`;


// 3b) Return account owner name(s), account type(s), the fund or stock they own and total the value for the
//     last day in the daily trading data. Do not hard code the last day in the query.
CALL {
    MATCH (n:Day)  RETURN n ORDER BY n.date DESC LIMIT 1
}
CALL {
    WITH n
    MATCH (n)--(dc:DayClose) RETURN dc
}
MATCH (c:Customer)-[]-(a:Account)-[p:PURCHASED]->(f:Fund|Stock)-[d:DAILY_CLOSE]->(dc)
RETURN 
  c.name as `Owner name`,
  a.accountType as `Account Type`,
  f.ticker as `Ticker`,
  round(p.quantity*dc.close,1) as value 
ORDER BY c.name,a.accountType,f.ticker;


// 3c) ....anything else interesting??
// 3c) i.  Show the holding distribution of the "Vanguard Dividend Growth Fund" 
MATCH (f:Fund {ticker:'VDIGX'})-[r:HOLDS]->(s:Stock)
RETURN 
    f.name as `Fund Name`,
    f.ticker AS Ticker,
    r.percentage as `Share Holding %`,
    s.holdingCompany AS `Holding Company`,
    s.ticker AS `Company Ticker` 
ORDER by r.percentage DESC;

