using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace IndividualTask
{
    public partial class MainForm : Form
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;
        public MainForm()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            AddOrder addOrder = new AddOrder(this);
            addOrder.Show();
        }
        public void refreshDataInOrderList()
        {
            SqlConnection connection = new SqlConnection(connectionString);
            try
            {
                connection.Open();
                string sqlQuery = "SELECT * FROM vw_Orders;";
                SqlDataAdapter adapter = new SqlDataAdapter(sqlQuery, connection);
                DataSet ds = new DataSet();
                adapter.Fill(ds);
                dataGridView1.DataSource = ds.Tables[0];
                dataGridView1.Columns[0].Width = 95;
                dataGridView1.Columns[1].Width = 60;
                dataGridView1.Columns[2].Width = 85;
                dataGridView1.Columns[3].Width = 75;
                dataGridView1.Columns[6].Width = 90;
                dataGridView1.Columns[7].Width = 65;
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
        private void MainForm_Load(object sender, EventArgs e)
        {
            refreshDataInOrderList();

        }

        private void MainForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            Application.Exit();
        }
        private void LoadComboBoxesInDriversTab()
        {
            string sqlQuery = "SELECT Driver_ID, (h.First_name + ' ' + h.Last_name) AS 'Fullname' FROM Driver d JOIN Human h ON (d.Human_ID = h.Human_ID);";
            Utils.LoadDataInComboBox(driverComboBox, sqlQuery, "Driver_ID", "Fullname", "Выберите водителя", connectionString);

            sqlQuery = "SELECT * FROM Region;";
            Utils.LoadDataInComboBox(regionStartComboBox, sqlQuery, "Region_ID", "Name", "Район старта", connectionString);

            startWorkDay.Text = DateTime.Now.ToString();

            endWorkDay.Text = DateTime.Now.ToString();

            sqlQuery = "SELECT * FROM Tariff";
            Utils.LoadDataInComboBox(tariffComboBox, sqlQuery, "Tariff_ID", "Class_car", "Тариф", connectionString);

        }

        private void LoadDataDriverWorkLog()
        {
            SqlConnection connection = new SqlConnection(connectionString);
            try
            {
                connection.Open();
                string sqlQuery = "SELECT * FROM vw_DriverWorkLog;";
                SqlDataAdapter adapter = new SqlDataAdapter(sqlQuery, connection);
                DataSet ds = new DataSet();
                adapter.Fill(ds);
                driverWorkLog.DataSource = ds.Tables[0];
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

        private void addRecordButton_Click(object sender, EventArgs e)
        {
            DateTime start;
            DateTime end;
            if (!DateTime.TryParse(startWorkDay.Text, out start) || !DateTime.TryParse(endWorkDay.Text, out end))
            {
                MessageBox.Show("Ошибка! Были переданы не объекты DateTime");
                return;
            }
            SqlConnection connection = new SqlConnection(connectionString);
            string sqlQuery = "SELECT * FROM DriverWorkLog;";
            try
            {
                connection.Open();

                SqlDataAdapter adapter = new SqlDataAdapter(sqlQuery, connection);

                DataSet ds = new DataSet();
                adapter.Fill(ds);

                DataTable dataTable = ds.Tables[0];
                DataRow newRow = dataTable.NewRow();

                newRow["Start_date"] = start.ToString();
                newRow["End_date"] = end.ToString();
                newRow["Driver_ID"] = (int)driverComboBox.SelectedValue;
                newRow["Region_ID"] = (int)regionStartComboBox.SelectedValue;


                dataTable.Rows.Add(newRow);
                SqlCommandBuilder commandBuilder = new SqlCommandBuilder(adapter);
                int rowsAffected = adapter.Update(ds);
                if (rowsAffected == 0)
                {
                    MessageBox.Show("Запись не была добавлена.");
                }
                else
                {
                    LoadDataDriverWorkLog();
                    MessageBox.Show($"Запись была успешна добавлена!");
                }
                adapter.Fill(ds);
            }
            catch (SqlException ex)
            {
                MessageBox.Show($"{ex.Message}");
            }
            finally
            {
                connection.Close();
            }
        }

        private void label8_Click(object sender, EventArgs e)
        {

        }

        private void registartionDriverButton_Click(object sender, EventArgs e)
        {
            string firstName = firstNameDriverTextBox.Text;
            string lastName = lastNameDriverTextBox.Text;
            float percentTaxiRider = int.Parse(perentRiderDriverTextBox.Text);
            string governmentNumber = governmentNumberCarTextBox.Text;
            string carBrand = carBrandDriverTextBox.Text;
            int tariffId = (int)tariffComboBox.SelectedValue;

            SqlConnection connection = new SqlConnection(connectionString);
            try
            {
                connection.Open();

                DataTable humansTable = new DataTable();
                humansTable.Columns.Add("First_Name");
                humansTable.Columns.Add("Last_Name");

                DataRow newHumanRow = humansTable.NewRow();
                newHumanRow["First_Name"] = firstName;
                newHumanRow["Last_Name"] = lastName;
                humansTable.Rows.Add(newHumanRow);

                SqlDataAdapter humanAdapter = new SqlDataAdapter("SELECT * FROM Human", connection);
                SqlCommandBuilder humanBuilder = new SqlCommandBuilder(humanAdapter);

                humanAdapter.Update(humansTable);

                int humanId = GetLastInsertedId(connection, "Human", "Human_ID");

                DataTable driversTable = new DataTable();
                driversTable.Columns.Add("Human_ID");
                driversTable.Columns.Add("Percent_Taxi_Rider");
                driversTable.Columns.Add("Car_ID");

                DataRow newDriverRow = driversTable.NewRow();
                newDriverRow["Human_Id"] = humanId;
                newDriverRow["Percent_Taxi_Rider"] = percentTaxiRider;
                newDriverRow["Car_ID"] = GetLastInsertedId(connection, "Car", "Car_ID") + 1;
                driversTable.Rows.Add(newDriverRow);

                SqlDataAdapter driverAdapter = new SqlDataAdapter("SELECT * FROM Driver", connection);
                SqlCommandBuilder driverBuilder = new SqlCommandBuilder(driverAdapter);

                //// Вставляем запись
                driverAdapter.Update(driversTable);

                //// Получаем Id вновь созданной записи
                int driverId = GetLastInsertedId(connection, "Driver", "Driver_ID"); // Вызов метода

                //// 3. Вставка в таблицу Car
                DataTable carsTable = new DataTable();
                carsTable.Columns.Add("Driver_ID");
                carsTable.Columns.Add("Government_Number");
                carsTable.Columns.Add("Car_Brand");
                carsTable.Columns.Add("Tariff_ID");

                DataRow newCarRow = carsTable.NewRow();
                newCarRow["Driver_ID"] = driverId;
                newCarRow["Government_Number"] = governmentNumber;
                newCarRow["Car_Brand"] = carBrand;
                newCarRow["Tariff_ID"] = tariffId;
                carsTable.Rows.Add(newCarRow);

                SqlDataAdapter carAdapter = new SqlDataAdapter("SELECT * FROM Car", connection);
                SqlCommandBuilder carBuilder = new SqlCommandBuilder(carAdapter);

                // Вставляем запись
                int carAdapterEffect = carAdapter.Update(carsTable);
                if (carAdapterEffect == 0)
                {
                    MessageBox.Show("Запись не была добавлена.");
                }
                else
                {
                    LoadComboBoxesInDriversTab();
                    LoadDataDriverList();
                    MessageBox.Show($"Запись была успешна добавлена!");
                }

            }
            catch (SqlException ex)
            {
                MessageBox.Show($"{ex.Message}");
            }
            finally
            {
                connection.Close();
            }
        }
        private int GetLastInsertedId(SqlConnection connection, string tableName, string column)
        {
            using (SqlCommand command = new SqlCommand($"SELECT MAX({column}) FROM {tableName}", connection))
            {
                return (int)(command.ExecuteScalar() ?? 0);
            }
        }
        private void LoadDataDriverList()
        {
            SqlConnection connection = new SqlConnection(connectionString);
            try
            {
                connection.Open();
                string sqlQuery = "SELECT * FROM vw_DriverList;";
                SqlDataAdapter adapter = new SqlDataAdapter(sqlQuery, connection);
                DataSet ds = new DataSet();
                adapter.Fill(ds);
                driverList.DataSource = ds.Tables[0];
                driverList.Columns[0].Width = 100;
                driverList.Columns[1].Width = 70;
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

        private void button2_Click(object sender, EventArgs e)
        {
            SqlConnection connection = new SqlConnection(connectionString);
            try
            {
                connection.Open();
                SqlCommand command = new SqlCommand("UpdateOrderStatus", connection);
                command.CommandType = CommandType.StoredProcedure;
                command.ExecuteNonQuery();
                refreshDataInOrderList();
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

        private void tabPage2_Click(object sender, EventArgs e)
        {
            MessageBox.Show("Тест");
        }

        private void tabControl3_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (tabControl3.SelectedTab == tabPage3)
            {
                LoadComboBoxesInDriversTab();

                LoadDataDriverList();

                LoadDataDriverWorkLog();

                return;
            }
            if (tabControl3.SelectedTab == tabPage2)
            {
                SqlConnection connection = new SqlConnection(connectionString);
                try
                {
                    connection.Open();
                    string sqlQuery = "SELECT * FROM vw_dispatcherOrderStatistics;";
                    SqlDataAdapter adapter = new SqlDataAdapter(sqlQuery, connection);
                    DataSet ds = new DataSet();
                    adapter.Fill(ds);
                    dataGridView2.DataSource = ds.Tables[0];
                }
                catch (SqlException ex)
                {
                    MessageBox.Show(ex.Message);
                }
                finally
                {
                    connection.Close();
                }
                return;
            }
        }
    }

}
