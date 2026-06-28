
	WITH MaritalStats AS (
    SELECT 
        c.Marital_Status AS MaritalStatus,
        COUNT(c.CustomerID) AS CustomerCount,
        AVG(c.Income) AS AvgIncome,  -- ? הכנסה ממוצעת לכל קבוצת סטטוס משפחתי
        SUM(p.MntWines + p.MntMeatProducts + p.MntFishProducts + p.MntSweetProducts + p.MntGoldProducts) AS TotalRevenue,
        CAST(ROUND(AVG(p.MntWines + p.MntMeatProducts + p.MntFishProducts + p.MntSweetProducts + p.MntGoldProducts), 1) AS DECIMAL(10,1)) AS AvgSpendingPerCustomer,
        CAST(ROUND(STDEV(p.MntWines + p.MntMeatProducts + p.MntFishProducts + p.MntSweetProducts + p.MntGoldProducts), 1) AS DECIMAL(10,1)) AS SpendingStdDev,

        -- ? פילוח הוצאות לפי קטגוריות מוצרים
        SUM(p.MntWines) AS TotalWineSpending,
        SUM(p.MntMeatProducts) AS TotalMeatSpending,
        SUM(p.MntFishProducts) AS TotalFishSpending,
        SUM(p.MntSweetProducts) AS TotalSweetSpending,
        SUM(p.MntGoldProducts) AS TotalGoldSpending
    FROM 
        Customers c
    JOIN 
        Purchases p ON c.CustomerID = p.CustomerID
    GROUP BY 
        c.Marital_Status
)

SELECT 
    MaritalStatus,
    CustomerCount,
    FORMAT(AvgIncome, 'N0') AS AvgIncome,
    FORMAT(TotalRevenue, 'N0') AS TotalRevenue,  
    CONCAT(CAST(ROUND((TotalRevenue / NULLIF(SUM(TotalRevenue) OVER(), 0)) * 100, 2) AS DECIMAL(5,2)), '%') AS SpendingPercentage,  

    -- ? פילוח רכישות כאחוז מסך הרכישות לכל סטטוס משפחתי
    CONCAT(CAST(ROUND((TotalWineSpending * 100.0 / NULLIF(TotalRevenue, 0)), 2) AS DECIMAL(5,2)), '%') AS WinePercentage,
    CONCAT(CAST(ROUND((TotalMeatSpending * 100.0 / NULLIF(TotalRevenue, 0)), 2) AS DECIMAL(5,2)), '%') AS MeatPercentage,
    CONCAT(CAST(ROUND((TotalFishSpending * 100.0 / NULLIF(TotalRevenue, 0)), 2) AS DECIMAL(5,2)), '%') AS FishPercentage,
    CONCAT(CAST(ROUND((TotalSweetSpending * 100.0 / NULLIF(TotalRevenue, 0)), 2) AS DECIMAL(5,2)), '%') AS SweetPercentage,
    CONCAT(CAST(ROUND((TotalGoldSpending * 100.0 / NULLIF(TotalRevenue, 0)), 2) AS DECIMAL(5,2)), '%') AS GoldPercentage,

    AvgSpendingPerCustomer,
    SpendingStdDev

FROM 
    MaritalStats
ORDER BY 
    TotalRevenue DESC;





WITH CustomerSegmentation AS (
    SELECT 
        c.CustomerID,
        CASE 
            WHEN (ca.AcceptedCmp1 = 1 OR ca.AcceptedCmp2 = 1 OR ca.AcceptedCmp3 = 1 OR ca.AcceptedCmp4 = 1 OR ca.AcceptedCmp5 = 1) 
                 AND  (ca.Response = 1) THEN 'נחשף ונענה לקמפיין'
            WHEN (ca.AcceptedCmp1 = 1 OR ca.AcceptedCmp2 = 1 OR ca.AcceptedCmp3 = 1 OR ca.AcceptedCmp4 = 1 OR ca.AcceptedCmp5 = 1) 
                 AND  (ca.Response = 0) THEN 'נחשף ולא נענה לקמפיין'
            WHEN (ca.AcceptedCmp1 = 0 AND ca.AcceptedCmp2 = 0 AND ca.AcceptedCmp3 = 0 AND ca.AcceptedCmp4 = 0 AND ca.AcceptedCmp5 = 0) 
                 AND  (ca.Response = 0) THEN 'לא נחשף ולא נענה לקמפיין'
            WHEN (ca.AcceptedCmp1 = 0 AND ca.AcceptedCmp2 = 0 AND ca.AcceptedCmp3 = 0 AND ca.AcceptedCmp4 = 0 AND ca.AcceptedCmp5 = 0) 
                 AND  (ca.Response = 1) THEN 'לא נחשף וכן נענה לקמפיין לא בצורה דיגיטלית'
        END AS CustomerCategory,
        p.MntWines,
        p.MntMeatProducts,
        p.MntFishProducts,
        p.MntSweetProducts,
        p.MntFruits,
        p.MntGoldProducts,
        COALESCE(A.totalDealsPurchases, 0) AS NumDealsPurchases,
        COALESCE(A.totalWebPurchases, 0) AS NumWebPurchases,
        COALESCE(A.totalCatalogPurchases, 0) AS NumCatalogPurchases,
        COALESCE(A.totalStorePurchases, 0) AS NumStorePurchases
    FROM Customers c
    LEFT JOIN Campaign_Accepted ca ON c.CustomerID = ca.CustomerID
    LEFT JOIN Purchases p ON c.CustomerID = p.CustomerID
    LEFT JOIN Activity A ON A.CustomerID = C.CustomerID
)

SELECT 
    CustomerCategory,
    COUNT(CustomerID) AS CustomerCount,
    FORMAT(SUM(MntWines + MntMeatProducts + MntFishProducts + MntSweetProducts + MntFruits + MntGoldProducts), 'N0') AS TotalRevenue,  
    CAST(ROUND(AVG(MntWines + MntMeatProducts + MntFishProducts + MntSweetProducts + MntFruits + MntGoldProducts), 1) AS DECIMAL(10,1)) AS AvgSpendingPerCustomer,
    CAST(ROUND(STDEV(MntWines + MntMeatProducts + MntFishProducts + MntSweetProducts + MntFruits + MntGoldProducts), 1) AS DECIMAL(10,1)) AS SpendingStdDev,
	

    -- ? סך כל הרכישות לכל קבוצה
    SUM(NumDealsPurchases + NumWebPurchases + NumCatalogPurchases + NumStorePurchases) AS TotalPurchases,

    -- ? הצגת אחוזי הרכישות בכל ערוץ מתוך סך הרכישות של הקבוצה
    CONCAT(CAST(ROUND((SUM(NumDealsPurchases) * 100.0 / NULLIF(CAST(SUM(NumDealsPurchases + NumWebPurchases + NumCatalogPurchases + NumStorePurchases) AS DECIMAL(10,2)), 0)), 2) AS DECIMAL(5,2)), '%') AS DiscountPurchasesPercentage,
    
    CONCAT(CAST(ROUND((SUM(NumWebPurchases) * 100.0 / NULLIF(CAST(SUM(NumDealsPurchases + NumWebPurchases + NumCatalogPurchases + NumStorePurchases) AS DECIMAL(10,2)), 0)), 2) AS DECIMAL(5,2)), '%') AS WebPurchasesPercentage,
    
    CONCAT(CAST(ROUND((SUM(NumCatalogPurchases) * 100.0 / NULLIF(CAST(SUM(NumDealsPurchases + NumWebPurchases + NumCatalogPurchases + NumStorePurchases) AS DECIMAL(10,2)), 0)), 2) AS DECIMAL(5,2)), '%') AS CatalogPurchasesPercentage,
    
    CONCAT(CAST(ROUND((SUM(NumStorePurchases) * 100.0 / NULLIF(CAST(SUM(NumDealsPurchases + NumWebPurchases + NumCatalogPurchases + NumStorePurchases) AS DECIMAL(10,2)), 0)), 2) AS DECIMAL(5,2)), '%') AS StorePurchasesPercentage,

    -- ? הוצאה ממוצעת לעסקה
    FORMAT(
        (SUM(MntWines + MntMeatProducts + MntFishProducts + MntSweetProducts + MntFruits + MntGoldProducts) / NULLIF(SUM(NumDealsPurchases + NumWebPurchases + NumCatalogPurchases + NumStorePurchases), 0)), 
        'N2'
    ) AS AvgSpendingPerTransaction

FROM CustomerSegmentation
GROUP BY CustomerCategory
ORDER BY SUM(MntWines + MntMeatProducts + MntFishProducts + MntSweetProducts + MntFruits + MntGoldProducts) DESC;

WITH IncomePurchases AS (
    SELECT 
        c.Incomecategory,
        COUNT(c.CustomerID) AS CustomerCount,
        SUM(p.MntWines) AS TotalWineRevenue,
        SUM(p.MntMeatProducts) AS TotalMeatRevenue,
        SUM(p.MntFishProducts) AS TotalFishRevenue,
        SUM(p.MntSweetProducts) AS TotalSweetRevenue,
        SUM(p.MntGoldProducts) AS TotalGoldRevenue,
        SUM(p.MntWines + p.MntMeatProducts + p.MntFishProducts + p.MntSweetProducts + p.MntGoldProducts) AS TotalRevenue,
        CAST(ROUND(AVG(p.MntWines + p.MntMeatProducts + p.MntFishProducts + p.MntSweetProducts + p.MntGoldProducts), 1) AS DECIMAL(10,1)) AS AvgSpendingPerCustomer,
        CAST(ROUND(STDEV(p.MntWines + p.MntMeatProducts + p.MntFishProducts + p.MntSweetProducts + p.MntGoldProducts), 1) AS DECIMAL(10,1)) AS SpendingStdDev
    FROM 
        Customers c
    JOIN 
        Purchases p ON c.CustomerID = p.CustomerID
    GROUP BY 
        c.Incomecategory
)
SELECT 
    Incomecategory,
    CustomerCount,
    FORMAT(TotalRevenue, 'N0') AS TotalRevenue,

    -- ? חישוב אחוזים מתוך סך כל הרכישות של כל סוגי המוצרים
    CONCAT(CAST(ROUND((TotalWineRevenue * 100.0 / NULLIF(TotalRevenue, 0)), 2) AS DECIMAL(5,2)), '%') AS WinePercentage,
    CONCAT(CAST(ROUND((TotalMeatRevenue * 100.0 / NULLIF(TotalRevenue, 0)), 2) AS DECIMAL(5,2)), '%') AS MeatPercentage,
    CONCAT(CAST(ROUND((TotalFishRevenue * 100.0 / NULLIF(TotalRevenue, 0)), 2) AS DECIMAL(5,2)), '%') AS FishPercentage,
    CONCAT(CAST(ROUND((TotalSweetRevenue * 100.0 / NULLIF(TotalRevenue, 0)), 2) AS DECIMAL(5,2)), '%') AS SweetPercentage,
    CONCAT(CAST(ROUND((TotalGoldRevenue * 100.0 / NULLIF(TotalRevenue, 0)), 2) AS DECIMAL(5,2)), '%') AS GoldPercentage,

    AvgSpendingPerCustomer,
    SpendingStdDev
FROM 
    IncomePurchases
ORDER BY 
    TotalRevenue DESC;



WITH CatalogAnalysis AS (
    SELECT 
        c.CustomerID,
        c.Agecategory,
        SUM(a.totalCatalogPurchases) AS TotalCatalogPurchases,
        SUM(a.totalWebPurchases + a.totalStorePurchases + a.totalCatalogPurchases+a.totalDealsPurchases) AS TotalPurchases
    FROM 
        Customers c
    JOIN 
        Activity a ON c.CustomerID = a.CustomerID
    GROUP BY 
        c.CustomerID, c.Agecategory
)
SELECT 
    Agecategory,
    CASE 
        WHEN TotalPurchases <= 10 THEN 'Low Purchases (<= 10)'
        WHEN TotalPurchases BETWEEN 11 AND 20 THEN 'Medium Purchases (11-20)'
        ELSE 'High Purchases (> 20)'
    END AS PurchaseLevel,
    COUNT(DISTINCT CustomerID) AS NumberOfCustomers,
    SUM(TotalCatalogPurchases) AS TotalCatalogPurchases,
    CAST(SUM(TotalCatalogPurchases) * 1.0 / COUNT(DISTINCT CustomerID) AS DECIMAL(10,2)) AS AvgCatalogPurchasesPerCustomer,
    CAST(ROUND(STDEV(TotalCatalogPurchases), 1) AS DECIMAL(10,1)) AS StdDevCatalogPurchases,
    CAST(ROUND(AVG(TotalCatalogPurchases * 1.0 / NULLIF(TotalPurchases, 0)), 2) AS DECIMAL(10,2)) AS CatalogPurchaseRatio
FROM 
    CatalogAnalysis
GROUP BY 
    Agecategory,
    CASE 
        WHEN TotalPurchases <= 10 THEN 'Low Purchases (<= 10)'
        WHEN TotalPurchases BETWEEN 11 AND 20 THEN 'Medium Purchases (11-20)'
        ELSE 'High Purchases (> 20)'
    END
ORDER BY 
    Agecategory, PurchaseLevel

;WITH CustomerAgeAnalysis AS (
    SELECT 
       
        c.Kidhome,
        c.Teenhome,
        COUNT(c.CustomerID) AS CustomerCount,
        SUM(a.totalWebPurchases) AS TotalWebPurchases,
        SUM(a.totalStorePurchases) AS TotalStorePurchases,
        SUM(a.totalCatalogPurchases) AS TotalCatalogPurchases,
        SUM(a.totalDealsPurchases) AS TotalDealsPurchases,
        AVG(c.Income) AS AvgIncome,
        SUM(p.MntWines + p.MntMeatProducts + p.MntFishProducts + p.MntSweetProducts + p.MntGoldProducts + p.MntFruits) AS TotalRevenue,
        CAST(ROUND(SUM(p.MntWines + p.MntMeatProducts + p.MntFishProducts + p.MntSweetProducts + p.MntGoldProducts + p.MntFruits) / 
        NULLIF(COUNT(c.CustomerID), 0), 2) AS DECIMAL(18,2)) AS AvgSpendingPerCustomer
    FROM 
        Customers c
    JOIN 
        Activity a ON c.CustomerID = a.CustomerID
    JOIN 
        Purchases p ON c.CustomerID = p.CustomerID
    GROUP BY 
        c.Agecategory, c.Kidhome, c.Teenhome
)
SELECT 
    
    CASE 
        WHEN Kidhome + Teenhome = 0 THEN 'No Kids'
        WHEN Kidhome + Teenhome = 1 THEN 'One Child'
        ELSE 'Multiple Kids'
    END AS HouseholdType,
    SUM(CustomerCount) AS CustomerCount,
    FORMAT(SUM(TotalRevenue), 'N0') AS TotalRevenue,
    FORMAT(AVG(AvgIncome), 'N0') AS AvgIncome,
    CONCAT(CAST(ROUND((AVG(AvgSpendingPerCustomer) / NULLIF(AVG(AvgIncome), 0)) * 100, 2) AS DECIMAL(18,2)), '%') AS SpendingPercentagePerCustomer,
    CONCAT(CAST(ROUND((SUM(TotalWebPurchases) * 100.0 / NULLIF(SUM(TotalWebPurchases + TotalStorePurchases + TotalCatalogPurchases + TotalDealsPurchases), 0)), 2) AS DECIMAL(5,2)), '%') AS WebPurchasesPercentage,
    CONCAT(CAST(ROUND((SUM(TotalStorePurchases) * 100.0 / NULLIF(SUM(TotalWebPurchases + TotalStorePurchases + TotalCatalogPurchases + TotalDealsPurchases), 0)), 2) AS DECIMAL(5,2)), '%') AS StorePurchasesPercentage,
    CONCAT(CAST(ROUND((SUM(TotalCatalogPurchases) * 100.0 / NULLIF(SUM(TotalWebPurchases + TotalStorePurchases + TotalCatalogPurchases + TotalDealsPurchases), 0)), 2) AS DECIMAL(5,2)), '%') AS CatalogPurchasesPercentage,
    CONCAT(CAST(ROUND((SUM(TotalDealsPurchases) * 100.0 / NULLIF(SUM(TotalWebPurchases + TotalStorePurchases + TotalCatalogPurchases + TotalDealsPurchases), 0)), 2) AS DECIMAL(5,2)), '%') AS DealsPurchasesPercentage
FROM 
    CustomerAgeAnalysis
GROUP BY 

    CASE 
        WHEN Kidhome + Teenhome = 0 THEN 'No Kids'
        WHEN Kidhome + Teenhome = 1 THEN 'One Child'
        ELSE 'Multiple Kids'
    END
ORDER BY 
     HouseholdType;

