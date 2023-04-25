using System.Collections;
using System.Collections.Generic;
using System.Data.SqlClient;
using Microsoft.SqlServer.Server;

// Публичный класс
// SQL-функция - публичный статический метод
public class ScalarFunctions
{
    // Функции в public static - методах
    
    // Атрибут - SqlFunctionAttribute:
    // Name - имя функции в SQL Server
    // IsDeterministic - детерменированная функция или нет.
    //
    // Детерминированные функции каждый раз возвращают один и тот же результат, 
    // если предоставлять им один и тот же набор входных значений
    // и использовать одно и то же состояние базы данных.
    // Недетерминированные функции могут возвращать каждый раз разные результаты.
    // 
    // Влияет на то, где можно использовать функцию
    // (индексированные представления, persisted-колоники и др).
    // Например, AVG - детерменированная, GETDATE - недетерменированная.
    // https://docs.microsoft.com/ru-ru/sql/relational-databases/user-defined-functions/deterministic-and-nondeterministic-functions

    // Скалярная функция
    [SqlFunction(
        Name = "SumDeterministic",
        IsDeterministic = true)]
    public static int Add(int a1, int a2)
    {
        return a1 + a2;
    }

    // Скалярная функция
    [SqlFunction(IsDeterministic = false)]
    public static int SumNondeterministic(int a1, int a2)
    {
        return a1 + a2;
    }

    // Пример обращения к данным БД внутри функции
    [SqlFunction(DataAccess = DataAccessKind.Read)]
    public static int CountOrdersForCustomer(int customerID)
    {
        // Обычный ADO.NET, но connection string - "context connection=true"

        using (SqlConnection connection = new SqlConnection("context connection=true"))
        using (SqlCommand cmd = new SqlCommand(
            "SELECT count(*) FROM Sales.Orders WHERE CustomerID = @customerID;", connection))
        {
            cmd.Parameters.AddWithValue("customerID", customerID);
            connection.Open();
            var count = (int)cmd.ExecuteScalar();
            return count;
        }
    }

    // -----------------------------------------
    // Табличная функция
    // Split -> MakeRow
    // -----------------------------------------    
    [SqlFunction(
        TableDefinition = "item nvarchar(100), num int",
        FillRowMethodName = "MakeRow")]
    public static IEnumerable Split(
        string str, 
        string separator)
    {
        var items = str.Split(separator.ToCharArray());

        // В result будет итоговое значение (вся "таблица")
        // object[] - одна строка
        // Можно сделать и по другому - список списков, двумерный массив и др.
        var result = new List<object[]>();

        for (int i = 0; i < items.Length; i++)
        {
            var row = new object[2];
            row[0] = items[i];
            row[1] = i + 1;
            result.Add(row);
        }

        return result;
    }

    public static void MakeRow(
        object obj, out string item, out int num)
    {
        var row = obj as object[];
        item = (string)row[0];
        num = (int)row[1];
    }
}
