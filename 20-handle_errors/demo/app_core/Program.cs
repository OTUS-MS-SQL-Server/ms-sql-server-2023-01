using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;

namespace HelloWorld
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.OutputEncoding = Encoding.UTF8;

            // При необходимости измените строку подключения
            var connectionString =
                "Server=localhost;Database=WideWorldImporters;Integrated Security=true;";

            try
            {
                using (var connection = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand("Warehouse.ChangeStockItemUnitPrice", connection))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    // StockItemID 10 - существует, 1000 - НЕ существует
                    cmd.Parameters.Add(new SqlParameter("@StockItemID", 1000));
                    cmd.Parameters.Add(new SqlParameter("@UnitPrice", 99));

                    connection.Open();
                    cmd.ExecuteNonQuery();
                }
                Console.WriteLine("OK");
            }
            catch (SqlException ex)
            {
                Console.WriteLine(ex.Message);
                Console.WriteLine("Код ошибки: " + ex.Number);

            }
        }
    }
}