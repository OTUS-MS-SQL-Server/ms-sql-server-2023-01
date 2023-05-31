use AdventureWorks2017

SELECT OrganizationNode, OrganizationLevel, *
FROM HumanResources.Employee

SELECT TOP 10 
  JobTitle, 
  LoginId, 
  OrganizationNode,
  OrganizationNode.ToString() OrganizationNode_ToString, 
  OrganizationNode.GetLevel() OrganizationNode_Level
FROM HumanResources.Employee
GO

DECLARE @EmployeeNode HierarchyId;

SELECT @EmployeeNode = OrganizationNode
FROM HumanResources.Employee
WHERE LoginId = 'adventure-works\terri0' 

-- Получаем потомки
SELECT OrganizationNode.ToString(),* 
FROM HumanResources.Employee
WHERE OrganizationNode.GetAncestor(3) = @EmployeeNode;


-------
USE test2

DROP TABLE IF EXISTS Company;
GO

CREATE TABLE Company  
(  
  HierarchyLevel hierarchyid,
  PersonName nvarchar(50) NOT NULL  
) ;  
GO
  
CREATE UNIQUE INDEX IX_Company_HierarchyLevel   
ON Company(HierarchyLevel); 

INSERT INTO Company  
(HierarchyLevel, PersonName)
VALUES (hierarchyid::GetRoot(), 'Andrew');

SELECT 
  HierarchyLevel.ToString() as [HierarchyLevel], 
  HierarchyLevel.GetLevel() as [Level], 
  PersonName
FROM Company
WHERE PersonName = 'Andrew';
GO

DECLARE @H hierarchyid;

SELECT @H = HierarchyLevel
FROM Company
WHERE PersonName = 'Andrew';

INSERT INTO Company  
(HierarchyLevel, PersonName)
VALUES (@H.GetDescendant(NULL, NULL), 'Bob');
GO

select * from company;

DECLARE @H hierarchyid;

SELECT @H = HierarchyLevel
FROM Company
WHERE PersonName = 'Bob';

INSERT INTO Company  
(HierarchyLevel, PersonName)
VALUES (@H.GetDescendant(NULL, NULL), 'Alice');
GO

