using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace IndividualTask
{
    public static class Utils
    {
        public static void LoadDataInComboBox(ComboBox nameOfcomboBox, string sqlQuery, string nameIdAttribute, string nameBodyComboBox, string startingValue, string connectionString)
        {
            SqlConnection connection = new SqlConnection(connectionString);
            try
            {
                // Открываем подключение к базе данных
                connection.Open();

                // Создание адаптера с SQL-запросом
                SqlDataAdapter adapter = new SqlDataAdapter(sqlQuery, connection);

                // Заполнение DataSet
                DataSet ds = new DataSet();
                adapter.Fill(ds);

                // Создаем новый DataTable для добавления пустого элемента в ComboBox
                DataTable dataTable = ds.Tables[0];

                // Добавляем пустой элемент
                DataRow row = dataTable.NewRow();
                row[nameIdAttribute] = 0;
                row[nameBodyComboBox] = startingValue;
                dataTable.Rows.InsertAt(row, 0);

                // Настройка ComboBox
                nameOfcomboBox.DataSource = dataTable; // Привязка к ComboBox
                nameOfcomboBox.DisplayMember = nameBodyComboBox; // Название, которое отображается
                nameOfcomboBox.ValueMember = nameIdAttribute; // Значение элемента

            }
            catch (SqlException ex)
            {
                Console.WriteLine(ex.Message);
            }
            finally
            {
                connection.Close();
            }
        }
    }
}
