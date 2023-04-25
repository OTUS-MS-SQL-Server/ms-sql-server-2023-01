using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

public class StoredProcedures
{
    // Возврат значения через OUT-параметр
    [SqlProcedure]
    public static void Add(
        SqlInt32 a, SqlInt32 b, out SqlInt32 result)
    {
        result = a + b;
    }

    // Аналог PRINT
    // Что получили, то и отправили назад
    [SqlProcedure]
    public static void MyPrint(SqlString message)
    {
        var pipe = SqlContext.Pipe;
        pipe.Send(message.Value);
    }

    /// <summary>
    /// Пример возврата табличного значения. 
    /// Генерация последовательности Фибонначи
    /// (каждое последующее число равно сумме двух предыдущих чисел).    
    /// </summary>
    /// <param name="firstNumber">Первое число в последовательности</param>
    /// <param name="secondNumber">Второе число в последовательности</param>
    /// <param name="length">Сколько чисел генерировать</param>
    [SqlProcedure]
    public static void Fibonacci(
        SqlInt32 firstNumber, 
        SqlInt32 secondNumber, 
        SqlInt32 length)
    {
        // Описываем структуру таблицы 
        // из двух колонок
        var columns = new SqlMetaData[2];
        columns[0] = new SqlMetaData("position", SqlDbType.Int);
        columns[1] = new SqlMetaData("value", SqlDbType.Int);

        // SqlDataRecord описывает строку
        var row = new SqlDataRecord(columns);
        var pipe = SqlContext.Pipe;
        pipe.SendResultsStart(row);

        // Первая строка (первое число)
        var i = 1; // i - номер числа (номер строки)
        row.SetSqlInt32(0, i);           // первая колонка
        row.SetSqlInt32(1, firstNumber); // вторая колонка
        pipe.SendResultsRow(row);

        // Вторая строка (второе число)
        i += 1;
        row.SetSqlInt32(0, i);
        row.SetSqlInt32(1, secondNumber);
        pipe.SendResultsRow(row);

        // Последующие числа
        var prevNumber1 = secondNumber;
        var prevNumber2 = firstNumber;
        while (i < length)
        {
            i += 1;
            var number = prevNumber2 + prevNumber1;

            row.SetSqlInt32(0, i);
            row.SetSqlInt32(1, number);
            pipe.SendResultsRow(row);

            prevNumber2 = prevNumber1;
            prevNumber1 = number;
        }

        pipe.SendResultsEnd();
    }

    // Количество заказов по заказчикам 
    // в городе @deliveryCityID
    private const string sqlOrdersByCity = @"
SELECT 
  city.CityName,
  city.CityID,
  cust.CustomerID,
  cust.CustomerName,
  count(*) as OrdersCount
FROM Sales.Customers cust
JOIN Application.Cities city ON city.CityID = cust.DeliveryCityID
JOIN Sales.Orders o ON o.CustomerID = cust.CustomerID
WHERE DeliveryCityID = @deliveryCityID
GROUP BY city.CityName, city.CityID, cust.CustomerID, cust.CustomerName";

    // Вариант 1 -- ExecuteAndSend()
    [SqlProcedure(
        Name = "usp_CountOrdersFoDeliveryCity_ExecuteAndSend")]
    public static void CountOrdersFoDeliveryCity_ExecuteAndSend(SqlInt32 deliveryCityID)
    {
        using (SqlConnection connection = new SqlConnection("context connection=true"))
        using (SqlCommand cmd = new SqlCommand(sqlOrdersByCity, connection))
        {
            cmd.Parameters.AddWithValue("deliveryCityID", deliveryCityID);
            connection.Open();
            SqlContext.Pipe.ExecuteAndSend(cmd);
        }
    }

    // Вариант 2 -- SqlDataReader, Send
    [SqlProcedure(
        Name = "usp_CountOrdersFoDeliveryCity_ExecuteReader")]
    public static void CountOrdersFoDeliveryCity_ExecuteReader(SqlInt32 deliveryCityID)
    {
        using (SqlConnection connection = new SqlConnection("context connection=true"))
        using (SqlCommand cmd = new SqlCommand(sqlOrdersByCity, connection))
        {
            cmd.Parameters.AddWithValue("deliveryCityID", deliveryCityID);

            connection.Open();
            SqlDataReader reader = cmd.ExecuteReader();
            SqlContext.Pipe.Send(reader);
        }
    }
}