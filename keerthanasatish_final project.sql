/* 1.	Current_Shareholder_Shares – Two queries are provided in QueriesProvided.sql.  Both of these queries list shareholder id, shareholder type, stock id, and the total shares currently held by the shareholder.  Create a view called CURRENT_SHAREHOLDER_SHARES using the more efficient query and include the view in your script.  Please place a comment explaining why you chose the query.
This file provides two queries for the current_shareholder_shares
view.  Determine which version is more efficient and use the more efficient
version.
*/

/* 1.Query 1 for current_shareholder_shares /*I choose query 1 as more efficient than query 2
Because consistant gets of query 1 is 26 which is very much less compare to query 2 is 1156 */
/*Answer is 1st query we get this on factors like  recursive calls
 db block gets
 consistent gets
 physical reads
 redo size
 bytes sent via SQL*Net to client
 bytes received via SQL*Net from client
 SQL*Net roundtrips to/from client
 sorts (memory)
 sorts (disk)
 rows processed
 but, The basic thing we need to concentrate on is reducing Consistent Gets.
 Consistent gets shows how many times oracle must read blocks in memory in order to process query so it represents of how much work the database engine is doing.
 Displays the statistics only.
>>Query Run In:Query Result
   Statistics
-----------------------------------------------------------
              14  SQL*Net roundtrips to/from client
              12  buffer is not pinned count
              48  buffer is pinned count
            1339  bytes received via SQL*Net from client
           25499  bytes sent via SQL*Net to client
               5  calls to get snapshot scn: kcmgss
               6  calls to kcmgcs
              26  consistent gets
               1  consistent gets - examination
              26  consistent gets from cache
              24  consistent gets from cache (fastpath)
               2  cursor authentications
               3  enqueue releases
               3  enqueue requests
               5  execute count
               2  index fast full scans (full)
               2  index scans kdiixs1
              18  no work - consistent read gets
              20  non-idle wait count
               5  opened cursors cumulative
               2  opened cursors current
               4  parse count (hard)
               6  parse count (total)
               1  pinned cursors current
              21  recursive calls
              26  session logical reads
               1  shared hash latch upgrades - no wait
               3  sorts (memory)
             712  sorts (rows)
              29  table fetch by rowid
              10  table scan blocks gotten
             118  table scan rows gotten
               2  table scans (short tables)
              14  user calls
Autotrace Disabled
Autotrace Enabled
Shows the execution plan as well as statistics of the statement.
Autotrace Enabled
Displays the execution plan only.
Autotrace Enabled
Displays the statistics only.
>>Query Run In:Query Result 1
   Statistics
-----------------------------------------------------------
               1  CPU used when call started
               1  DB time
              14  SQL*Net roundtrips to/from client
               6  buffer is not pinned count
              62  buffer is pinned count
            1498  bytes received via SQL*Net from client
           24077  bytes sent via SQL*Net to client
               2  calls to get snapshot scn: kcmgss
             192  calls to kcmgcs
            1156  consistent gets
            1156  consistent gets from cache
            1154  consistent gets from cache (fastpath)
               2  execute count
               2  index scans kdiixs1
             962  no work - consistent read gets
              16  non-idle wait count
               2  opened cursors cumulative
               2  opened cursors current
               2  parse count (total)
               1  pinned cursors current
               2  session cursor cache hits
            1156  session logical reads
               2  shared hash latch upgrades - no wait
               4  sorts (memory)
             832  sorts (rows)
              33  table fetch by rowid
             960  table scan blocks gotten
           11328  table scan rows gotten
             192  table scans (short tables)
              14  user calls
*/

SET autotrace OFF;
SET autotrace ON;
SET autotrace ON EXPLAIN;
SET autotrace ON STATISTICS;
CREATE OR REPLACE VIEW CURRENT_SHAREHOLDER_SHARES
AS
SELECT 
   nvl(buy.buyer_id, sell.seller_id) AS shareholder_id,
   sh.type,
   nvl(buy.stock_id, sell.stock_id) AS  stock_id, 
   CASE nvl(buy.buyer_id, sell.seller_id)
      WHEN c.company_id THEN NULL
      ELSE nvl(buy.shares,0) - nvl(sell.shares,0)
   END AS shares
FROM (SELECT 
        t_sell.seller_id,
        t_sell.stock_id,
      sum(t_sell.shares) AS shares
      FROM trade t_sell
      WHERE t_sell.seller_id IS NOT NULL
      GROUP BY t_sell.seller_id, t_sell.stock_id) sell
  FULL OUTER JOIN
     (SELECT 
        t_buy.buyer_id,  
        t_buy.stock_id,
        sum(t_buy.shares) AS shares
      FROM trade t_buy
      WHERE t_buy.buyer_id IS NOT NULL
      GROUP BY t_buy.buyer_id, t_buy.stock_id) buy
   ON sell.seller_id = buy.buyer_id
   AND sell.stock_id = buy.stock_id
  JOIN shareholder sh
    ON sh.shareholder_id = nvl(buy.buyer_id, sell.seller_id)
  JOIN company c
    ON c.stock_id = nvl(buy.stock_id, sell.stock_id)
WHERE nvl(buy.shares,0) - nvl(sell.shares,0) != 0
ORDER BY 1,3
;

/* 2.Current_Stock_Stats – These queries list each stock id, the number of shares currently authorized, and the total number of shares currently outstanding. Create a view called CURRENT_STOCK_STATS using the more efficient query and include it in your script.  Please place a comment explaining why you chose the query.
This file provides two queries to use for the current_stock_stats view.
Determine which version is more efficient and use the more efficient
version.
*/
/* 2.Current_stock_stats: query 2, I choose query 2 as more efficient than query 1.
Because consistant gets of query 2 is 16 which is very less compare to query 1 is 94*/
/*Query Run In:Query Result
   Statistics
-----------------------------------------------------------
               1  DB time
              14  SQL*Net roundtrips to/from client
               7  buffer is not pinned count
              14  buffer is pinned count
             814  bytes received via SQL*Net from client
           24956  bytes sent via SQL*Net to client
               3  calls to get snapshot scn: kcmgss
              15  calls to kcmgcs
              94  consistent gets
              94  consistent gets from cache
              93  consistent gets from cache (fastpath)
               1  enqueue releases
               1  enqueue requests
               3  execute count
               1  index scans kdiixs1
              78  no work - consistent read gets
              15  non-idle wait count
               3  opened cursors cumulative
               2  opened cursors current
               1  parse count (hard)
               3  parse count (total)
               8  recursive calls
             -38  session cursor cache count
              94  session logical reads
               1  shared hash latch upgrades - no wait
               2  sorts (memory)
             619  sorts (rows)
              10  table fetch by rowid
              75  table scan blocks gotten
             834  table scan rows gotten
              15  table scans (short tables)
              14  user calls
Autotrace Disabled
Autotrace Enabled
Shows the execution plan as well as statistics of the statement.
Autotrace Enabled
Displays the execution plan only.
Autotrace Enabled
Displays the statistics only.
>>Query Run In:Query Result 1
   Statistics
-----------------------------------------------------------
              14  SQL*Net roundtrips to/from client
               7  buffer is not pinned count
              14  buffer is pinned count
             780  bytes received via SQL*Net from client
           24958  bytes sent via SQL*Net to client
               3  calls to get snapshot scn: kcmgss
               2  calls to kcmgcs
              16  consistent gets
              16  consistent gets from cache
              15  consistent gets from cache (fastpath)
               1  enqueue releases
               1  enqueue requests
               3  execute count
               1  index scans kdiixs1
              13  no work - consistent read gets
              17  non-idle wait count
               3  opened cursors cumulative
               1  opened cursors current
               1  parse count (hard)
               3  parse count (total)
               8  recursive calls
               2  session cursor cache hits
              16  session logical reads
               1  shared hash latch upgrades - no wait
               2  sorts (memory)
             671  sorts (rows)
              10  table fetch by rowid
              10  table scan blocks gotten
              67  table scan rows gotten
               2  table scans (short tables)
              15  user calls
*/ 

SET autotrace OFF;
SET autotrace ON;
SET autotrace ON EXPLAIN;
SET autotrace ON STATISTICS; 
CREATE OR REPLACE VIEW CURRENT_STOCK_STATS
AS
SELECT
  co.stock_id,
  si.authorized current_authorized,
  SUM(DECODE(t.seller_id,co.company_id,t.shares)) 
    -NVL(SUM(CASE WHEN t.buyer_id = co.company_id 
             THEN t.shares END),0) AS total_outstanding
FROM company co
  INNER JOIN shares_authorized si
     ON si.stock_id = co.stock_id
    AND si.time_end IS NULL
  LEFT OUTER JOIN trade t
      ON t.stock_id = co.stock_id
GROUP BY co.stock_id, si.authorized
ORDER BY stock_id
;


/*3.	Write a query which lists the name of every company that has authorized stock, the number of shares currently authorized, the total shares currently outstanding, and % of authorized shares that are outstanding.
Shares outstanding is the number of shares owned by external share holders.  
Shares_Authorized = Shares_Outstanding + Shares_UnIssued*/

SELECT 
  co.NAME,
  css.CURRENT_AUTHORIZED,
  css.TOTAL_OUTSTANDING,
  css.stock_id,
  (css.CURRENT_AUTHORIZED-css.TOTAL_OUTSTANDING) AS shares_unissued,
 round(((100*css.TOTAL_OUTSTANDING)/ css.CURRENT_AUTHORIZED),2) AS percent_of_shares
FROM COMPANY co
  JOIN current_stock_stats css
    ON co.STOCK_ID = css.stock_id;
    
/*4.	For every direct holder: list the name of the holder, the names of the companies invested in by this direct holder, number of shares currently held, % this holder has of the shares outstanding, and % this holder has of the total authorized shares.  Sort the output by direct holder last name, first name, and company name and display the percentages to two decimal places.*/
SELECT
  dh.first_name||' '||dh.last_name AS nameoftheholder,
  co.Name AS companyname,
  ss.shares AS Noofshares,
  ROUND((100*ss.shares)/css.TOTAL_OUTSTANDING,2) AS percent_shares_outstanding,
  ROUND((100*ss.shares)/css.CURRENT_AUTHORIZED,2) AS percent_shares_authorized
FROM DIRECT_HOLDER dh
  JOIN current_shareholder_shares ss
    ON dh.DIRECT_HOLDER_ID=ss.SHAREHOLDER_ID
  JOIN COMPANY co
    ON co.STOCK_ID=ss.STOCK_ID
  JOIN current_stock_stats css
    ON css.STOCK_ID=co.STOCK_ID
order by dh.last_name, dh.first_name, co.Name;
/*5.	For every institutional holder (companies who hold stock): list the name of the holder, the names of the companies invested in by this holder, shares currently held, % this holder has of the total shares outstanding, and % this holder has of that total authorized shares.  For this report, include only the external holders (not treasury shares).  Sort the output by holder name, and company owned name and display the percentages to two decimal places.*/
SELECT
  co2.NAME AS holder,
  co1.NAME AS company_name,
  ss.SHARES AS shares_held,
  ROUND((100*ss.shares)/css.TOTAL_OUTSTANDING,2) AS percent_shares_outstanding,
  ROUND((100*ss.SHARES)/css.CURRENT_AUTHORIZED,2) AS percent_shares_authorized
FROM COMPANY co1
  JOIN current_shareholder_shares ss
    ON co1.STOCK_ID=ss.STOCK_ID
  JOIN current_stock_stats css
    ON css.STOCK_ID=co1.STOCK_ID
  JOIN company co2
    ON co2.company_id=ss.shareholder_id
  WHERE co1.company_id != co2.company_id
  ORDER BY co2.name, co1.name;

/* 6.	Write a query which displays all trades where more than 50000 shares were traded on the secondary markets.  Please include the trade id, stock symbol, name of the company being traded, stock exchange symbol, number of shares traded, price total (including broker fees) and currency symbol. */
SELECT
  t.trade_id,
  ss.stock_symbol,
  t.shares,
  co.name as nameofthecompanybeingtraded,
  se.symbol as stockexchangesymbol,
  t.price_total,
  cu.symbol as currencysymbol
FROM trade t
    JOIN stock_exchange se
    ON se.stock_ex_id = t.stock_ex_id
    JOIN company co
    ON co.stock_id = t.stock_id
   JOIN stock_listing ss
    ON t.stock_id = ss.stock_id
    AND t.stock_ex_id = ss.stock_ex_id
  JOIN currency cu
    ON cu.currency_id = se.currency_id
WHERE t.shares > 50000 AND t.buy_broker_id IS NOT NULL AND t.stock_ex_id IS NOT NULL;
  
/*7.	For each stock listed on each stock exchange, display the exchange name, stock symbol and the date and time when that the stock was last traded. Sort the output by stock exchange name, stock symbol.  If a stock has not been traded show NULL for the date last traded.*/

SELECT
  ss.stock_id,
  se.name AS exchangename,
  ss.stock_symbol,
 TO_CHAR(MAX(t.transaction_time),'YYYY-MM-DD HH:MI:SSAM') AS last_traded_dateandtime 
FROM stock_listing ss
 JOIN stock_exchange se
    ON se.stock_ex_id = ss.stock_ex_id
  LEFT JOIN trade t
    ON ss.stock_id = t.stock_id 
group by ss.stock_id, se.name, ss.stock_symbol
ORDER BY  se.name, ss.stock_symbol;

/*8.	Display the trade_id, name of the company and number of shares for the single largest trade made on any secondary market (in terms of the number of shares traded).  Unless there are multiple trades with the same number of shares traded, only one record should be returned.*/
 SELECT *
 From ( SELECT trade_id,
       MAX(t.shares) as max_share,
       co.name as name_of_the_company 
      FROM trade t
        JOIN company co
          ON co.stock_id=t.stock_id
      WHERE t.stock_ex_id IS NOT NULL   
      GROUP BY co.name, trade_id
      ORDER BY max_share desc)
      WHERE ROWNUM=1
;
--Method 2
SELECT
 trade_id,
       MAX(t.shares) as max_share,
       co.name as name_of_the_company 

 FROM trade t
        JOIN company co
          ON co.stock_id=t.stock_id
      WHERE (t.shares) = (Select MAX(t.shares) from trade t  where t.stock_ex_id IS NOT NULL ) and t.stock_ex_id IS NOT NULL
      GROUP BY co.name, trade_id;
/*9.	Add “Jeff Adams” as a new direct holder.  You will have to insert a record into the shareholder table and make a separate statement to insert into the direct_holder table.*/
CREATE SEQUENCE shareholder_id_seq
   INCREMENT BY 1
   START WITH 26
;
INSERT 
  INTO shareholder 
  VALUES(shareholder_id_seq.NEXTVAL,'Direct_Holder');
  
INSERT 
  INTO direct_holder 
  VALUES((SELECT MAX(shareholder_id) FROM shareholder),'Jeff','Adams');

  /*select * from shareholder;
  select * from direct_holder;*/
  
  --Method 2
  INSERT 
  INTO shareholder 
  VALUES((SELECT MAX(shareholder_id+1) FROM shareholder),'Direct_Holder');
  
INSERT 
  INTO direct_holder 
  VALUES((SELECT MAX(shareholder_id) FROM shareholder),'Jeff','Adams');
  COMMIT;
  
/*  10.	Add “Makoto Investing” as a new institutional holder that has its head office in Tokyo, Japan.  Makoto does not currently have a stock id.  A record must be inserted into the shareholder table and a corresponding record must be inserted into the company table.*/
  INSERT 
  INTO shareholder 
  VALUES((SELECT MAX(shareholder_id+1) FROM shareholder),'Company');
  
INSERT 
  INTO company 
  VALUES((SELECT MAX(shareholder_id) FROM shareholder),'Makoto Investing',(SELECT place_id FROM place WHERE city='Tokyo' AND country='Japan'),'','','');
COMMIT;
 /* select * from shareholder;
  select * from company;*/
  
/*11.	“Makoto Investing” would like to declare stock.  As of today’s date, they are authorizing 100,000 shares at a starting price of 50 yen.  
To complete the work, you will need to update the company table to give Makoto its own stock id, and insert a new entry in the shares_authorized table.*/
UPDATE company
  SET
    
    stock_id = (SELECT MAX(stock_id+1)From company),
    currency_id = (SELECT
                      currency_id
                    FROM currency
                    WHERE Name='Yen' OR currency_id='5'),
    starting_price = 50
     WHERE name='Makoto Investing'
;

INSERT 
  INTO shares_authorized 
  VALUES ((SELECT MAX(stock_id) FROM company), SYSDATE, '', 100000);
COMMIT;
 /* select * from shares_authorized;
  select * from company;*/
  
/* 12.	 “Makoto Investing” would like to list on the Tokyo Stock Exchange under the stock symbol “Makoto”.  You will need to insert into the stock_listing table and the stock_price table.*/
INSERT
  INTO stock_listing (stock_id, stock_ex_id, stock_symbol)
  SELECT 
    9,
    stock_ex_id,
    'MAKOTO'
  FROM stock_exchange 
  WHERE name='Tokyo Stock Exchange';
  
INSERT
  INTO stock_price
  VALUES((SELECT stock_id 
            FROM stock_listing 
            WHERE stock_symbol='MAKOTO'),
            
          (SELECT stock_ex_id 
            FROM stock_listing 
            WHERE stock_symbol='MAKOTO'),
            
          (SELECT co.starting_price 
            FROM company co 
              JOIN stock_listing ss 
                ON co.stock_id=ss.stock_id 
            WHERE ss.stock_symbol='MAKOTO'),
            
          SYSDATE, '');
 /* select * from stock_listing ;
  select * from stock_price;*/
  COMMIT;
/*13.	Write a PL/SQL procedure called INSERT_DIRECT_HOLDER which will be used to insert new direct holders.  Create a sequence object on the database to automatically generate shareholder_ids.  Use this sequence in your procedure.
-Input parameters: first_name, last_name*/
CREATE SEQUENCE shareholder_id_seq
   INCREMENT BY 1
   START WITH 35
;
CREATE OR REPLACE PROCEDURE INSERT_DIRECT_HOLDER (
  p_first_name IN DIRECT_HOLDER.first_name%type,
  p_last_name IN DIRECT_HOLDER.last_name%type)
AS
BEGIN
INSERT 
  INTO shareholder 
  VALUES(shareholder_id_seq.NEXTVAL,'Direct_Holder');
  
INSERT 
  INTO direct_holder 
  VALUES(shareholder_id_seq.CURRVAL,p_first_name,p_last_name);
  
commit;
END;
/

show errors procedure insert_DIRECT_HOLDER; 

SELECT * FROM DIRECT_HOLDER;

-- Ampersand Variables - Lets you write what you want into the query.
EXEC insert_DIRECT_HOLDER('&first_name','&last_name');

-- Check on the new brokers
SELECT 
   DIRECT_HOLDER_id,
   first_name,
   last_name
FROM DIRECT_HOLDER;
/*14.	Write a PL/SQL procedure called INSERT_COMPANY which will be used to insert new companies. The stock_id for new companies will be null.  Use the sequence object that you created in problem 13 to get new shareholder_ids. 
-Input parameters: company_name, city, country*/

CREATE OR REPLACE PROCEDURE INSERT_COMPANY(
  p_company_name IN company.name%type,
  p_city IN place.CITY%type,
  p_country IN place.COUNTRY%type)
AS
 l_place_id NUMBER(6,2) NULL;
BEGIN
SELECT place_id
  INTO l_place_id
  FROM PLACE WHERE place.CITY =p_city AND place.Country = p_country ;
  
INSERT 
  INTO shareholder(Shareholder_id,Type)
  VALUES(shareholder_id_seq.NEXTVAL,'Company');
  
INSERT 
  INTO COMPANY (COMPANY_ID,Name,PLACE_ID)
  VALUES(shareholder_id_seq.CURRVAL,p_company_name ,l_place_id);
  
Commit;
END;
/

show errors procedure insert_COMPANY; 

SELECT * FROM COMPANY;

-- Ampersand Variables - Lets you write what you want into the query.
EXEC INSERT_COMPANY('&name','&city','&country');


/*SELECT 
   COMPANY_ID,
   Name,
   PLACE_ID
FROM COMPANY;
SELECT * FROM PLACE;*/

/*15.	Write a PL/SQL procedure called DECLARE_STOCK which will be used when a company declares it is issuing shares.
-Input parameters: company name, number of shares authorized, starting price (in the designated currency), and currency name. 
-Check to ensure the company has not already been given a stock id.
-If the company already has a stock id then do not perform any data changes.
-Otherwise, the company must be assigned a stock id (create a sequence object to generate new stock_ids) and the date of issue (current system date), number of shares authorized, the starting price and currency id must be recorded.*/
CREATE SEQUENCE stock_id_seq
   INCREMENT BY 1
   START WITH 40
;
create or replace PROCEDURE DECLARE_STOCK(
  p_company_name IN company.name%type,
  p_STARTING_price IN company.STARTING_price%type,
  p_currency_name IN currency.name%type,
  p_number_of_shares_authorized IN shares_authorized.authorized%type)
AS
 l_stock_id NUMBER(6);
 l_currency_id NUMBER(6);
 BEGIN
SELECT currency_id
  INTO  l_currency_id
  FROM currency where currency.name =  p_currency_name; 
SELECT stock_id
  INTO  l_stock_id
  FROM company where company.name =  p_company_name; 

  IF l_stock_id IS NULL then
      l_stock_id := stock_id_seq.NEXTVAL;

  END IF;

  UPDATE company
  SET
    
    stock_id = stock_id_seq.NEXTVAL,
    currency_id = l_currency_id,
   starting_price = p_STARTING_price
     WHERE name= p_company_name 
;

INSERT 
  INTO shares_authorized (Stock_id,Time_start,Authorized)
   VALUES (stock_id_seq.CURRVAL, SYSDATE, p_number_of_shares_authorized);
  

END;
/

show errors procedure DECLARE_STOCK; 

SELECT * FROM shares_authorized;
SELECT * FROM COMPANY;

-- Ampersand Variables - Lets you write what you want into the query.
EXEC DECLARE_STOCK('&name','&starting_price','&currency_name','&Authorized');

SELECT * FROM COMPANY;
SELECT * FROM shares_authorized;

/*16.	Write a PL/SQL procedure called LIST_STOCK which will be used when stock is listed on a stock exchange.
-Input parameters: stock_id, stock_ex_id, stock_symbol.
-The stock_id, stock_ex_id and stock_symbol must be recorded in the stock_listing table.
-The starting price from company must be copied to the stock price list for the stock exchange.  The current system time will be used for the time_start and the time_end will be null.  The procedure must be able to convert currencies as needed.*/
create or replace PROCEDURE LIST_STOCK(
  p_stock_ex_id IN stock_Listing.stock_ex_id%type,
  p_stock_id IN stock_Listing.stock_id%type,
  p_stock_symbol IN stock_Listing.stock_symbol%type)
AS
l_curry1 NUMBER(10,2)NULL;
l_curry2 NUMBER(10,2)NULL;
l_p_STARTING_price NUMBER(10,2)NULL;
l_ex_rate NUMBER(10,2)NULL;
 
BEGIN
SELECT currency_id INTO l_curry1 FROM Company  WHERE stock_id = p_stock_id;
SELECT STARTING_price INTO l_p_STARTING_price FROM Company WHERE stock_id = p_stock_id;
SELECT currency_id INTO l_curry2 FROM stock_exchange  WHERE stock_ex_id = p_stock_ex_id;
Insert into stock_Listing(stock_id,stock_ex_id,stock_symbol) values (p_stock_id,p_stock_ex_id,p_stock_symbol);
if l_curry1!= l_curry2
Then 
select exchange_rate into l_ex_rate from conversion where from_currency_id = l_curry1 and to_currency_id = l_curry2;
insert into stock_price(stock_id,stock_ex_id,Price,time_start) values(p_stock_id,p_stock_ex_id,l_ex_rate * l_p_starting_Price,sysdate);
else 
insert into stock_price(stock_id,stock_ex_id,Price,time_start) values(p_stock_id,p_stock_ex_id,l_p_starting_Price,sysdate);
end if;
END;
/

show errors procedure LIST_STOCK; 

SELECT * FROM Stock_listing;

-- Ampersand Variables - Lets you write what you want into the query.
EXEC LIST_STOCK('&p_stock_ex_id', '&p_stock_id','&p_stock_symbol');
 

SELECT * FROM Stock_listing;
/*17.	Write a PL/SQL procedure called SPLIT_STOCK.
-input parameters:  stock id, split_factor
-The split_factor must be greater than 1 and can be fractional.  (The number of shares will be multiplied by the split_factor.)
-The total shares outstanding cannot exceed the authorized amount.  Your procedure should raise an application error if the split would cause the shares outstanding to exceed the shares authorized.
-Every shareholder must receive (is buyer of) an additional "trade" equal to the additional shares to which they are entitled.  For example, if the split_factor is 2 then each shareholder will be entitled to an additional “trade” that is equal to the number of shares that they owned before the split.  (Use the Current_Shareholder_Shares view to determine the number of shares owned).  These "trades" will not take place at a stock exchange, the price total will be null, and there will be no brokers involved.*/
create or replace PROCEDURE SPLIT_STOCK(
  p_stock_id IN company.stock_id%type,
  p_split_factor IN number )
AS

l_p_CURRENT_AUTHORIZED NUMBER(10,2);
l_p_TOTAL_OUTSTANDING NUMBER(10,2);

 
BEGIN

SELECT TOTAL_OUTSTANDING,CURRENT_AUTHORIZED INTO l_p_TOTAL_OUTSTANDING,l_p_CURRENT_AUTHORIZED FROM current_stock_stats WHERE stock_id = p_stock_id;


if (p_split_factor* l_p_TOTAL_OUTSTANDING) > l_p_CURRENT_AUTHORIZED
Then 
RAISE_APPLICATION_ERROR(-20000, 'split will cause the shares outstanding to exceed the shares authorized'); 
else
 insert into Trade(trade_id,stock_id,transaction_time,shares,buyer_id,seller_id)
 select trade_id_seq.NEXTVAL ,css.stock_id,
 sysdate,
 css.shares *(p_split_factor -1), css.shareholder_id, co.company_id 
 from current_shareholder_shares css
 join company co
 on co.stock_id = css.stock_id 
 where css.stock_id = p_stock_id
 And css.shares is not null;

end if;
END;
/

show errors procedure SPLIT_STOCK; 

SELECT * FROM current_shareholder_shares;

-- Ampersand Variables - Lets you write what you want into the query.
EXEC SPLIT_STOCK('&p_stock_id','&p_split_factor');
 
SELECT * FROM current_shareholder_shares;
/*rollback;*/
/*18.	Write a PL/SQL procedure called REVERSE_SPLIT.
-input parameters: stock id, merge_factor
-The merge_factor must be greater than 0 and less than 1.  (The number of shares will be multiplied by the merge_factor.)
-Every shareholder must "sell" some of the stock it currently owns.  (Use the Current_Shareholder_Shares view to determine the number of shares owned).  If the merge_factor is 1/3 then adjustments must be made to indicate the 2/3 of each shareholder’s stock has been removed. (The database can handle fractions of a share.)  These "trades" will not take place at a stock exchange, the price total will be null, and there will be no brokers involved.*/
create or replace PROCEDURE REVERSE_SPLIT(
  p_stock_id IN company.stock_id%type,
  p_merge_factor IN float)
AS

l_p_CURRENT_AUTHORIZED NUMBER(10,2);
l_p_TOTAL_OUTSTANDING NUMBER(10,2);


 
BEGIN

SELECT TOTAL_OUTSTANDING,CURRENT_AUTHORIZED INTO l_p_TOTAL_OUTSTANDING,l_p_CURRENT_AUTHORIZED FROM current_stock_stats WHERE stock_id = p_stock_id;


--if (p_merge_factor* l_p_TOTAL_OUTSTANDING) > l_p_CURRENT_AUTHORIZED
--Then 
--RAISE_APPLICATION_ERROR(-20000, 'split will cause the shares outstanding to exceed the shares authorized'); 
--else
 insert into Trade(trade_id,stock_id,transaction_time,shares,buyer_id,seller_id)
 select trade_id_seq.NEXTVAL ,css.stock_id,
 sysdate,
 ( (p_merge_factor -1)/css.shares), css.shareholder_id, co.company_id 
 from current_shareholder_shares css
 join company co
 on co.stock_id = css.stock_id 
 where css.stock_id = p_stock_id
 And css.shares is not null;

--end if;
END;
/

show errors procedure REVERSE_SPLIT; 

SELECT * FROM current_shareholder_shares;

-- Ampersand Variables - Lets you write what you want into the query.
EXEC REVERSE_SPLIT('&p_stock_id','&p_merge_factor');
 
SELECT * FROM current_shareholder_shares;
/*Rollback;*/
/*19.	Display the trade id, the stock id and the total price (in US dollars) for the secondary market trade with the highest total price.  Convert all prices to US dollars.*/
 SELECT *
 From ( SELECT trade_id,T.STOCK_ID,t.stock_ex_id,co.currency_id,
       MAX(t.Price_total)*(select exchange_rate from conversion where from_currency_id = co.currency_id and to_currency_id = 1) as max_Price,
       co.name as name_of_the_company 
      FROM trade t
        JOIN company co
          ON co.stock_id=t.stock_id
           JOIN stock_exchange se
          ON se.stock_ex_id=t.stock_id
      WHERE t.stock_ex_id IS NOT NULL   
      GROUP BY co.name, trade_id,t.stock_id,t.stock_ex_id,co.currency_id
      ORDER BY max_Price desc)
      WHERE ROWNUM=1
;

/*20.	Display the name of the company and trade volume for the company whose stock has the largest total volume of shareholder trades worldwide. [Example calculation: A company declares 20000 shares, and issues 10000 on the new issue market (primary market), and 1000 shares is sold to a stockholder on the secondary market. Later that stockholder sells 500 shares to another stockholder (or back to the company itself).  The number of shareholder trades is 2 and the total volume of shareholder trades is 1500*/
With total_volume_of_trades as(
  Select t.Stock_id,company.name,sum(shares) as shares from trade t
    join company on company.stock_id = t.stock_id 
    where t.Stock_ex_id is not null
    group by t.stock_ID,company.name)
    
  Select total_volume_of_trades.Stock_id,total_volume_of_trades.name,total_volume_of_trades.shares from total_volume_of_trades where total_volume_of_trades.shares = (Select max(shares)from total_volume_of_trades);
  
/*21.	For each stock exchange, display the symbol of the stock with the highest total trade volume. Show the stock exchange name, stock symbol and total trade volume.  Sort the output by the name of the stock exchange and stock symbol.*/
With total_volume_of_trades as(
  Select t.Stock_ex_id,stock_exchange.name,sum(shares) as shares from trade t
    join stock_exchange on stock_exchange.stock_ex_id = t.stock_ex_id 
     join stock_listing on stock_listing.stock_ex_id = t.stock_ex_id 
    where t.Stock_ex_id is not null
    group by t.stock_ex_ID,stock_exchange.name)
    
  Select total_volume_of_trades.Stock_ex_id,total_volume_of_trades.name,total_volume_of_trades.shares from total_volume_of_trades where total_volume_of_trades.shares = (Select max(shares)from total_volume_of_trades);


