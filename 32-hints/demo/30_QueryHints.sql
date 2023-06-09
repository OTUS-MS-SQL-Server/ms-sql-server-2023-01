SET STATISTICS io, time on;

SELECT People.FullName, 
	Inv.InvoiceID, Inv.InvoiceDate
FROM Sales.Invoices AS Inv
	INNER LOOP JOIN Application.People AS People
		ON People.PersonID = Inv.SalespersonPersonID;

SELECT People.FullName, 
	Inv.InvoiceID, Inv.InvoiceDate
FROM Sales.Invoices AS Inv
	INNER LOOP JOIN Application.People AS People
		ON People.PersonID = Inv.SalespersonPersonID
OPTION (MAXDOP 1);

SELECT PayClient.CustomerID,PayClient.CustomerName AS CustomerWhoPays, Inv.CustomerID AS CustomerWhoOrded,
	Inv.InvoiceID, Inv.InvoiceDate	
FROM Sales.Invoices AS Inv	
	JOIN Sales.Customers AS PayClient 
		ON PayClient.CustomerID = Inv.BillToCustomerID
WHERE Inv.BillToCustomerID = 401;

SELECT PayClient.CustomerID,PayClient.CustomerName AS CustomerWhoPays, Inv.CustomerID AS CustomerWhoOrded,
	Inv.InvoiceID, Inv.InvoiceDate	
FROM Sales.Invoices AS Inv 
	JOIN Sales.Customers AS PayClient 
		ON PayClient.CustomerID = Inv.BillToCustomerID
WHERE Inv.BillToCustomerID = 401
OPTION (OPTIMIZE FOR UNKNOWN);

DECLARE @BillToCustomerID INT = 401;

SELECT PayClient.CustomerID,PayClient.CustomerName AS CustomerWhoPays, Inv.CustomerID AS CustomerWhoOrded,
	Inv.InvoiceID, Inv.InvoiceDate	
FROM Sales.Invoices AS Inv 
	JOIN Sales.Customers AS PayClient 
		ON PayClient.CustomerID = Inv.BillToCustomerID
WHERE Inv.BillToCustomerID = @BillToCustomerID
OPTION (OPTIMIZE FOR (@BillToCustomerID = 901));

DECLARE @BillToCustomerID INT = 401; --910 401

SELECT PayClient.CustomerID,PayClient.CustomerName AS CustomerWhoPays, Inv.CustomerID AS CustomerWhoOrded,
	Inv.InvoiceID, Inv.InvoiceDate	
FROM Sales.Invoices AS Inv 
	JOIN Sales.Customers AS PayClient 
		ON PayClient.CustomerID = Inv.BillToCustomerID
WHERE Inv.BillToCustomerID = @BillToCustomerID
OPTION (KEEPFIXED PLAN); --(RECOMPILE)

DECLARE @BillToCustomerID INT = 910;

SELECT PayClient.CustomerID,PayClient.CustomerName AS CustomerWhoPays, Inv.CustomerID AS CustomerWhoOrded,
	Inv.InvoiceID, Inv.InvoiceDate	
FROM Sales.Invoices AS Inv 
	JOIN Sales.Customers AS PayClient 
		ON PayClient.CustomerID = Inv.BillToCustomerID
WHERE Inv.BillToCustomerID = @BillToCustomerID
OPTION (OPTIMIZE FOR (@BillToCustomerID = 901), MAXDOP 1);

Declare @maxId INT = 200;

WITH GenId (Id) AS 
(	
	SELECT 1 

	UNION ALL
	
	SELECT GenId.Id + 1
	FROM GenId 
	WHERE GenId.Id < @maxId
)
Select * 
from GenId
OPTION (MAXRECURSION 20);


SELECT Client.CustomerName, 
	Inv.InvoiceID, Inv.InvoiceDate, 
	Item.StockItemName, 
	Details.Quantity, Details.UnitPrice, PayClient.CustomerName AS BillForCustomer
FROM Sales.Invoices AS Inv
	JOIN Sales.InvoiceLines AS Details
		ON Inv.InvoiceID = Details.InvoiceID
	JOIN Sales.Customers AS Client 
		ON Client.CustomerID = Inv.CustomerID
	JOIN Application.People AS People
		ON People.PersonID = Inv.SalespersonPersonID
	JOIN Sales.Customers AS PayClient 
		ON PayClient.CustomerID = Inv.BillToCustomerID
	INNER JOIN Warehouse.StockItems AS Item 
		ON Item.StockItemID = Details.StockItemID
WHERE PayClient.CustomerID = 1;

SELECT 
	Inv.CustomerID AS CustomerWhoOrded,
	Inv.InvoiceID, Inv.InvoiceDate	
FROM Sales.Invoices AS Inv 
WHERE Inv.BillToCustomerID = 910
OPTION (Use PLAN N'<ShowPlanXML xmlns="http://schemas.microsoft.com/sqlserver/2004/07/showplan" Version="1.6" Build="14.0.2027.2">
  <BatchSequence>
    <Batch>
      <Statements>
        <StmtSimple StatementText="SELECT &#xD;&#xA;	Inv.CustomerID AS CustomerWhoOrded,&#xD;&#xA;	Inv.InvoiceID, Inv.InvoiceDate	&#xD;&#xA;FROM Sales.Invoices AS Inv &#xD;&#xA;WHERE Inv.BillToCustomerID = 910" StatementId="1" StatementCompId="1" StatementType="SELECT" RetrievedFromCache="true" StatementSubTreeCost="0.444898" StatementEstRows="136" SecurityPolicyApplied="false" StatementOptmLevel="FULL" QueryHash="0xAD0F6EAB9D8BE7B5" QueryPlanHash="0x894C6362280B97A3" StatementOptmEarlyAbortReason="GoodEnoughPlanFound" CardinalityEstimationModelVersion="130" ParameterizedText="(@1 smallint)SELECT [Inv].[CustomerID] [CustomerWhoOrded],[Inv].[InvoiceID],[Inv].[InvoiceDate] FROM [Sales].[Invoices] [Inv] WHERE [Inv].[BillToCustomerID]=@1">
          <StatementSetOptions QUOTED_IDENTIFIER="true" ARITHABORT="true" CONCAT_NULL_YIELDS_NULL="true" ANSI_NULLS="true" ANSI_PADDING="true" ANSI_WARNINGS="true" NUMERIC_ROUNDABORT="false" />
          <QueryPlan CachedPlanSize="32" CompileTime="1" CompileCPU="1" CompileMemory="296">
            <MemoryGrantInfo SerialRequiredMemory="0" SerialDesiredMemory="0" />
            <OptimizerHardwareDependentProperties EstimatedAvailableMemoryGrant="312382" EstimatedPagesCached="78095" EstimatedAvailableDegreeOfParallelism="2" MaxCompileMemory="1339832" />
            <OptimizerStatsUsage>
              <StatisticsInfo LastUpdate="2019-05-23T21:25:20.34" ModificationCount="0" SamplingPercent="100" Statistics="[FK_Sales_Invoices_BillToCustomerID]" Table="[Invoices]" Schema="[Sales]" Database="[WideWorldImporters]" />
            </OptimizerStatsUsage>
            <RelOp NodeId="0" PhysicalOp="Nested Loops" LogicalOp="Inner Join" EstimateRows="136" EstimateIO="0" EstimateCPU="0.00056848" AvgRowSize="18" EstimatedTotalSubtreeCost="0.444898" Parallel="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row">
              <OutputList>
                <ColumnReference Database="[WideWorldImporters]" Schema="[Sales]" Table="[Invoices]" Alias="[Inv]" Column="InvoiceID" />
                <ColumnReference Database="[WideWorldImporters]" Schema="[Sales]" Table="[Invoices]" Alias="[Inv]" Column="CustomerID" />
                <ColumnReference Database="[WideWorldImporters]" Schema="[Sales]" Table="[Invoices]" Alias="[Inv]" Column="InvoiceDate" />
              </OutputList>
              <NestedLoops Optimized="0" WithUnorderedPrefetch="1">
                <OuterReferences>
                  <ColumnReference Database="[WideWorldImporters]" Schema="[Sales]" Table="[Invoices]" Alias="[Inv]" Column="InvoiceID" />
                  <ColumnReference Column="Expr1002" />
                </OuterReferences>
                <RelOp NodeId="2" PhysicalOp="Index Seek" LogicalOp="Index Seek" EstimateRows="136" EstimatedRowsRead="136" EstimateIO="0.003125" EstimateCPU="0.0003066" AvgRowSize="11" EstimatedTotalSubtreeCost="0.0034316" TableCardinality="70510" Parallel="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row">
                  <OutputList>
                    <ColumnReference Database="[WideWorldImporters]" Schema="[Sales]" Table="[Invoices]" Alias="[Inv]" Column="InvoiceID" />
                  </OutputList>
                  <IndexScan Ordered="1" ScanDirection="FORWARD" ForcedIndex="0" ForceSeek="0" ForceScan="0" NoExpandHint="0" Storage="RowStore">
                    <DefinedValues>
                      <DefinedValue>
                        <ColumnReference Database="[WideWorldImporters]" Schema="[Sales]" Table="[Invoices]" Alias="[Inv]" Column="InvoiceID" />
                      </DefinedValue>
                    </DefinedValues>
                    <Object Database="[WideWorldImporters]" Schema="[Sales]" Table="[Invoices]" Index="[FK_Sales_Invoices_BillToCustomerID]" Alias="[Inv]" IndexKind="NonClustered" Storage="RowStore" />
                    <SeekPredicates>
                      <SeekPredicateNew>
                        <SeekKeys>
                          <Prefix ScanType="EQ">
                            <RangeColumns>
                              <ColumnReference Database="[WideWorldImporters]" Schema="[Sales]" Table="[Invoices]" Alias="[Inv]" Column="BillToCustomerID" />
                            </RangeColumns>
                            <RangeExpressions>
                              <ScalarOperator ScalarString="(910)">
                                <Const ConstValue="(910)" />
                              </ScalarOperator>
                            </RangeExpressions>
                          </Prefix>
                        </SeekKeys>
                      </SeekPredicateNew>
                    </SeekPredicates>
                  </IndexScan>
                </RelOp>
                <RelOp NodeId="4" PhysicalOp="Clustered Index Seek" LogicalOp="Clustered Index Seek" EstimateRows="1" EstimateIO="0.003125" EstimateCPU="0.0001581" AvgRowSize="14" EstimatedTotalSubtreeCost="0.440897" TableCardinality="70510" Parallel="0" EstimateRebinds="135" EstimateRewinds="0" EstimatedExecutionMode="Row">
                  <OutputList>
                    <ColumnReference Database="[WideWorldImporters]" Schema="[Sales]" Table="[Invoices]" Alias="[Inv]" Column="CustomerID" />
                    <ColumnReference Database="[WideWorldImporters]" Schema="[Sales]" Table="[Invoices]" Alias="[Inv]" Column="InvoiceDate" />
                  </OutputList>
                  <IndexScan Lookup="1" Ordered="1" ScanDirection="FORWARD" ForcedIndex="0" ForceSeek="0" ForceScan="0" NoExpandHint="0" Storage="RowStore">
                    <DefinedValues>
                      <DefinedValue>
                        <ColumnReference Database="[WideWorldImporters]" Schema="[Sales]" Table="[Invoices]" Alias="[Inv]" Column="CustomerID" />
                      </DefinedValue>
                      <DefinedValue>
                        <ColumnReference Database="[WideWorldImporters]" Schema="[Sales]" Table="[Invoices]" Alias="[Inv]" Column="InvoiceDate" />
                      </DefinedValue>
                    </DefinedValues>
                    <Object Database="[WideWorldImporters]" Schema="[Sales]" Table="[Invoices]" Index="[PK_Sales_Invoices]" Alias="[Inv]" TableReferenceId="-1" IndexKind="Clustered" Storage="RowStore" />
                    <SeekPredicates>
                      <SeekPredicateNew>
                        <SeekKeys>
                          <Prefix ScanType="EQ">
                            <RangeColumns>
                              <ColumnReference Database="[WideWorldImporters]" Schema="[Sales]" Table="[Invoices]" Alias="[Inv]" Column="InvoiceID" />
                            </RangeColumns>
                            <RangeExpressions>
                              <ScalarOperator ScalarString="[WideWorldImporters].[Sales].[Invoices].[InvoiceID] as [Inv].[InvoiceID]">
                                <Identifier>
                                  <ColumnReference Database="[WideWorldImporters]" Schema="[Sales]" Table="[Invoices]" Alias="[Inv]" Column="InvoiceID" />
                                </Identifier>
                              </ScalarOperator>
                            </RangeExpressions>
                          </Prefix>
                        </SeekKeys>
                      </SeekPredicateNew>
                    </SeekPredicates>
                  </IndexScan>
                </RelOp>
              </NestedLoops>
            </RelOp>
            <ParameterList>
              <ColumnReference Column="@1" ParameterDataType="smallint" ParameterCompiledValue="(910)" />
            </ParameterList>
          </QueryPlan>
        </StmtSimple>
      </Statements>
    </Batch>
  </BatchSequence>
</ShowPlanXML>'); --(RECOMPILE)