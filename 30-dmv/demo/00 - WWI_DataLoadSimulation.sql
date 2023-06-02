-- Эмуляция нагрузки на WideWorldImporters
-- https://docs.microsoft.com/en-us/sql/samples/wide-world-importers-generate-data?view=sql-server-2017

EXECUTE DataLoadSimulation.PopulateDataToCurrentDate
        @AverageNumberOfCustomerOrdersPerDay = 60,
        @SaturdayPercentageOfNormalWorkDay = 50,
        @SundayPercentageOfNormalWorkDay = 0,
        @IsSilentMode = 1,
        @AreDatesPrinted = 1;
