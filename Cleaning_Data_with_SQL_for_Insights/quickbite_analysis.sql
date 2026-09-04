
-- *******************************************************************************************************************************
-- *******************************************************************************************************************************

-- For products Table 

SELECT * FROM dbo.products;

-- SQL Query to categorize products based on their price

SELECT ProductID, ProductName, Price,
	CASE -- Categorizes the products into price categories: Low, Medium, or High
		WHEN (Price < 50) THEN 'Low'
		WHEN (Price BETWEEN 50 AND 200) THEN 'Medium'
		ELSE 'High'
	END AS Price_Category
FROM dbo.products;


-- *******************************************************************************************************************************
-- *******************************************************************************************************************************

-- For geography and customers Tables

SELECT * FROM dbo.geography;
SELECT * FROM dbo.customers;

-- SQL statement to join dim_customers with dim_geography to enrich customer data with geographic information

SELECT c.CustomerID, c.CustomerName, c.Email, c.Gender, c.Age, g.Country, g.City
FROM customers c 
LEFT JOIN geography g 
ON c.GeographyID = g.GeographyID; -- Joins the two tables on the GeographyID field to match customers with their geographic information


-- *******************************************************************************************************************************
-- *******************************************************************************************************************************

-- For customer_reviews Table

SELECT * FROM customer_reviews;

-- Query to clean whitespace issues in the ReviewText column

SELECT 
    ReviewID, CustomerID, ProductID, ReviewDate, Rating,  

    -- Cleans up the ReviewText by replacing double spaces with single spaces to ensure the text is more readable and standardized

     REPLACE(ReviewText, '  ', ' ') AS ReviewText -- REPLACE(string, old_value, new_value)
FROM 
    dbo.customer_reviews;  -- Specifies the source table from which to select the data


-- *******************************************************************************************************************************
-- *******************************************************************************************************************************


-- For engagement_data Table

SELECT * FROM engagement_data;

-- Query to clean and normalize the engagement_data table

SELECT EngagementID, ContentID, CampaignID, ProductID, 

	UPPER(REPLACE(ContentType, 'Socialmedia', 'Social Media')) AS ContentType,

	-- LEFT(Text, How many Values(CHARINDEX('txt', Text)))

	LEFT(ViewsClicksCombined,  -- 1. txt (1234-567)
	CHARINDEX('-', ViewsClicksCombined) - 1) AS Views,  -- 2. 5 - 1 = 4

	-- SUBSTRING(txt, where to start(CHARINDEX('txt', Text)), how many characters(LEN))

	SUBSTRING(ViewsClicksCombined,  -- 1. txt (1234-567)
	CHARINDEX('-', ViewsClicksCombined) + 1, -- 2. where to start: 5 + 1 = 6
	LEN(ViewsClicksCombined)) As Clicks,  -- 3. How many char: Total lenth(8) 6-8 values will take 

	Likes, 
	FORMAT(EngagementDate, 'dd.MM.yyyy') AS EngagementDate

FROM engagement_data WHERE ContentType != 'Newsletter';


-- *******************************************************************************************************************************
-- *******************************************************************************************************************************


-- FOR customer_journey Table

SELECT * FROM customer_journey;

-- Select all records from the CTE where row_num > 1 which indicates duplicate entries and 
-- Calculates the average Duration from that same VisitDate. 

SELECT 
    JourneyID, CustomerID, ProductID, VisitDate,
    UPPER(Stage) AS Stage, Action,
	-- If Duration exists → use Duration, If Duration is NULL → use average Duration
	-- COALESCE(Duration, 0) we put the logic instead of 0
	-- If Duration is NULL, use the average Duration from that same VisitDate.
	COALESCE(Duration, ROUND(AVG(Duration) OVER (PARTITION BY VisitDate), 2)) AS Duration 
FROM ( 
		SELECT * ,
		ROW_NUMBER() OVER (PARTITION BY  CustomerID, ProductID, VisitDate, UPPER(Stage), Action ORDER BY JourneyID) AS row_num
		FROM customer_journey) AS clean_data
WHERE row_num = 1
ORDER BY JourneyID;


-- *******************************************************************************************************************************
-- *******************************************************************************************************************************


