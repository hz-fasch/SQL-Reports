WITH HorzeInternational_Postings AS (
    SELECT
        LedgerAccountNum
        ,TransDate
        ,AmountMST
        ,NULL AS DE01_Account
        ,HZI2DATEV.ToLedgerAccountNum AS DATEV_LedgerAccountNum
    FROM [DWH_prod].[Finance].[LedgerTrans]
    LEFT JOIN Finance.ChartOfAccountsTransition AS HZI2DATEV ON
        HZI2DATEV.FromChartOfAccountsCode = 'HZI' AND
        HZI2DATEV.FromLedgerAccountNum = LedgerTrans.LedgerAccountNum AND
        HZI2DATEV.ToChartOfAccountsCode = 'DATEV-HZI'
    WHERE CompanyNum = 'hzi'
    AND YEAR(TransDate) = 2020
    UNION ALL
    SELECT
        FT2HZI.ToLedgerAccountNum AS LedgerAccountNum
        ,TransDate
        ,AmountMST
        ,LedgerAccountNum AS DE01_Account
        ,FT2DATEV.ToLedgerAccountNum AS DATEV_LedgerAccountNum
    FROM [DWH_prod].[Finance].LedgerTrans
    LEFT JOIN Finance.ChartOfAccountsTransition AS FT2HZI ON
        FT2HZI.FromChartOfAccountsCode = 'AX12-FT' AND
        FT2HZI.FromLedgerAccountNum = LedgerTrans.LedgerAccountNum AND
        FT2HZI.ToChartOfAccountsCode = 'HZI'
    LEFT JOIN Finance.ChartOfAccountsTransition AS FT2DATEV ON
        FT2DATEV.FromChartOfAccountsCode = 'AX12-FT' AND
        FT2DATEV.FromLedgerAccountNum = LedgerTrans.LedgerAccountNum AND
        FT2DATEV.ToChartOfAccountsCode = 'DATEV-HZI'
    WHERE CompanyNum = 'de01'
    AND YEAR(TransDate) = 2020
)
SELECT
    LedgerAccountNum,
    DATEV_LedgerAccountNum,
    DE01_Account AS AX12_Account,
    SUM(AmountMST) AS AmountMST
FROM HorzeInternational_Postings
GROUP BY
    LedgerAccountNum,
    DATEV_LedgerAccountNum,
    DE01_Account