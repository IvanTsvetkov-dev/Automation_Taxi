using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace IndividualTask
{
    public partial class AddOrder : Form
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        MainForm form;
        public AddOrder(MainForm form)
        {
            InitializeComponent();

            this.form = form;

            LoadComboBoxs();
        }

        private void LoadItemsInDispatcherComboBox()
        {
            string sqlQuery = "SELECT d.Dispatcher_ID, (h.Last_name + ' ' + h.First_name) AS 'Name' FROM Dispatcher d JOIN Human h ON (d.Human_ID = h.Human_ID);";
            LoadDataInComboBox(dispatcherComboBox, sqlQuery, "Dispatcher_ID", "Name", "Выберите диспетчера");
        }

        private void LoadItemInClientComboBox()
        {
            string sqlQuery = "SELECT Client_ID, Username FROM Client;";
            LoadDataInComboBox(clientComboBox, sqlQuery, "Client_ID", "Username", "Выберите клиента");
        }

        private void LoadItemInTariffComboBox()
        {
            string sqlQuery = "SELECT Tariff_ID, Class_car FROM Tariff;";
            LoadDataInComboBox(tariffComboBox, sqlQuery, "Tariff_ID", "Class_car", "Выберите тариф");
        }

        private void LoadItemInAddressDepartureComboBox()
        {
            string sqlQuery = "SELECT Address_ID, (Street + CASE WHEN Entertance_door IS NOT NULL THEN ', Подъезд ' + CAST(Entertance_door AS VARCHAR) ELSE '' END) AS Full_Address FROM Address";
            LoadDataInComboBox(addressDepartureComboBox, sqlQuery, "Address_ID", "Full_Address", "Выберите адрес назначения");
        }

        private void LoadItemInAddressDistanationComboBox()
        {
            string sqlQuery = "SELECT Address_ID, (Street + CASE WHEN Entertance_door IS NOT NULL THEN ', Подъезд ' + CAST(Entertance_door AS VARCHAR) ELSE '' END) AS Full_Address FROM Address";
            LoadDataInComboBox(addressDistanationComboBox, sqlQuery, "Address_ID", "Full_Address", "Выберите адрес отправления");

        }

        private void LoadItemInStatusOrder()
        {
            string sqlQuery = "SELECT * FROM OrderStatus;";
            LoadDataInComboBox(statusComboBox, sqlQuery, "OrderStatus_ID", "Status_name", "Статус заказа");
        }

        private void LoadComboBoxs()
        {
            LoadItemsInDispatcherComboBox();
            LoadItemInClientComboBox();
            LoadItemInTariffComboBox();
            LoadItemInAddressDepartureComboBox();
            LoadItemInAddressDistanationComboBox();
            LoadItemInStatusOrder();
        }

        private void LoadDataInComboBox(ComboBox nameOfcomboBox, string sqlQuery, string nameIdAttribute, string nameBodyComboBox, string startingValue)
        {
            SqlConnection connection = new SqlConnection(connectionString);
            try
            {
                connection.Open();

                SqlDataAdapter adapter = new SqlDataAdapter(sqlQuery, connection);

                DataSet ds = new DataSet();
                adapter.Fill(ds);

                DataTable dataTable = ds.Tables[0];

                DataRow row = dataTable.NewRow();
                row[nameIdAttribute] = 0;
                row[nameBodyComboBox] = startingValue;
                dataTable.Rows.InsertAt(row, 0);

                nameOfcomboBox.DataSource = dataTable; // Привязка к ComboBox
                nameOfcomboBox.DisplayMember = nameBodyComboBox; // Название, которое отображается
                nameOfcomboBox.ValueMember = nameIdAttribute; // Значение элемента

            }
            catch (SqlException ex)
            {
                MessageBox.Show(ex.Message);
            }
            finally
            {
                connection.Close();
            }
        }

        private void addOrderButton_Click(object sender, EventArgs e)
        {
            SqlConnection connection = new SqlConnection(connectionString);
            string sqlQuery = "SELECT * FROM [Order];";
            try
            {
                int order_status = (int)statusComboBox.SelectedValue;
                float distantion = float.Parse(distantionTextBox.Text);
                int ride_time_minutes = int.Parse(rideTimeBox.Text);
                DateTime datetime = DateTime.Now;

                connection.Open();

                SqlDataAdapter adapter = new SqlDataAdapter(sqlQuery, connection);
                DataSet ds = new DataSet();
                adapter.Fill(ds);

                DataTable dataTable = ds.Tables[0];
                DataRow newRow = dataTable.NewRow();

                newRow["Client_ID"] = (int)clientComboBox.SelectedValue;
                newRow["Tariff_ID"] = (int)tariffComboBox.SelectedValue;
                newRow["Date_create"] = datetime;
                newRow["Distantion_km"] = distantion;
                newRow["Dispatcher_ID"] = (int)dispatcherComboBox.SelectedValue;
                newRow["Address_distanation_ID"] = (int)addressDistanationComboBox.SelectedValue;
                newRow["Address_departure_ID"] = (int)addressDepartureComboBox.SelectedValue;
                newRow["Ride_time_minutes"] = ride_time_minutes;
                newRow["OrderStatus_ID"] = order_status;
                if (order_status == 4)
                {
                    int waiting_time_minutes = int.Parse(waitingTimeBox.Text);
                    newRow["Driver_ID"] = int.Parse(driverTextBox.Text);
                    newRow["Waiting_time_minutes"] = waiting_time_minutes;

                    SqlCommand command = new SqlCommand($"SELECT * FROM Tariff WHERE Tariff_ID={tariffComboBox.SelectedValue};", connection);
                    SqlDataReader reader = command.ExecuteReader();
                    reader.Read();
                    newRow["Cost"] = int.Parse(reader.GetValue(3).ToString()) + int.Parse(reader.GetValue(2).ToString()) * distantion + int.Parse(reader.GetValue(4).ToString()) * waiting_time_minutes; //стоимость подачи + километры пути * стоимость километра + время ожидания * стоимость ожидания
                    reader.Close();

                    newRow["Start_Ride"] = datetime.AddMinutes(waiting_time_minutes);
                    newRow["End_Ride"] = datetime.AddMinutes(waiting_time_minutes + ride_time_minutes);
                }
                else if (order_status == 2)
                {
                    MessageBox.Show("Заказ не может быть сразу завершён!");
                    return;
                }

                dataTable.Rows.Add(newRow);

                SqlCommandBuilder commandBuilder = new SqlCommandBuilder(adapter);
                int rowsAffected = adapter.Update(ds);

                if (rowsAffected > 0)
                {
                    form.refreshDataInOrderList();
                    MessageBox.Show($"Заказ был успешно добавлен!");
                }
                else
                {
                    MessageBox.Show("Заказ не был добавлен.");
                }

            }
            catch (SqlException ex)
            {
                MessageBox.Show($"Ошибка SQL: {ex.Message}\n{ex.StackTrace}");
            }
            catch (FormatException ex)
            {
                MessageBox.Show("Неверный формат введённых данных: " + ex.Message);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Произошла ошибка: " + ex.Message);
            }
            finally
            {
                connection.Close();
            }
        }
        private void getDataFromDriverLiveQueue()
        {
            SqlConnection connection = new SqlConnection(connectionString);
            try
            {
                connection.Open();
                string sqlQuery = "SELECT * FROM vw_DriverLiveQueue;";
                SqlDataAdapter adapter = new SqlDataAdapter(sqlQuery, connection);
                DataSet ds = new DataSet();
                adapter.Fill(ds);
                dataGridQueue.DataSource = ds.Tables[0];
            }
            catch (SqlException ex)
            {
                MessageBox.Show(ex.Message );
            }
            finally
            {
                // закрываем подключение
                connection.Close();
            }
        }

        private void AddOrder_Load(object sender, EventArgs e)
        {
            getDataFromDriverLiveQueue();
        }

        private void regionQueryComboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            string regionInfo = regionQueryComboBox.Text;
            string classAuto = classAutoComboBox.Text;
            SqlConnection connection = new SqlConnection(connectionString);
            try
            {
                string sqlQuery;
                if (classAuto != "" && regionInfo != "")
                {
                    sqlQuery = $"SELECT * FROM vw_DriverLiveQueue WHERE [Текущий район]='{regionInfo}' AND [Тариф]='{classAuto}'";
                }
                else if(classAuto != "" && regionInfo == "") {
                    sqlQuery = $"SELECT * FROM vw_DriverLiveQueue WHERE [Тариф]='{classAuto}'";
                }
                else if(classAuto == "" && regionInfo != "")
                {
                    sqlQuery = $"SELECT * FROM vw_DriverLiveQueue WHERE [Текущий район]='{regionInfo}'";
                }
                else
                {
                    getDataFromDriverLiveQueue();
                    return;
                }
                connection.Open();
                SqlDataAdapter adapter = new SqlDataAdapter(sqlQuery, connection);
                DataSet ds = new DataSet();
                adapter.Fill(ds);
                dataGridQueue.DataSource = ds.Tables[0];
            }
            catch (SqlException ex)
            {
                MessageBox.Show(ex.Message);
            }
            finally
            {
                connection.Close();
            }
        }
    }
}
