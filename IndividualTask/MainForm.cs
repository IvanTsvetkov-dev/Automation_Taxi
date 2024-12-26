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

namespace IndividualTask
{
    public partial class MainForm : Form
    {
        //Data Source - указывает на название сервера. Initial Catalog указывает на название бд.
        private string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;
        public MainForm()
        {
            InitializeComponent();
        }
        private void MainForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            Application.Exit();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            AddOrder addOrder = new AddOrder();
            addOrder.Show();
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            SqlConnection connection = new SqlConnection(connectionString);
            this.Hide();
            MainForm newForm = new MainForm();
            try
            {
                // Открываем подключение
                connection.Open();
                //SqlCommand command = new SqlCommand("SELECT * FROM Order;", connection);
                //SqlDataReader reader = command.ExecuteReader();
                SqlDataAdapter adapter = new SqlDataAdapter("SELECT * FROM Order;", connection);
                DataSet ds = new DataSet();
                // Заполняем Dataset
                adapter.Fill(ds);
                // Отображаем данные
                dataGridView1.DataSource = ds.Tables[0];
            }
            catch (SqlException ex)
            {
                Console.WriteLine(ex.Message);
            }
            finally
            {
                // закрываем подключение
                connection.Close();
            }
        }
    }

}
