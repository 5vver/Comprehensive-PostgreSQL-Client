#include "updt.h"
#include "ui_updt.h"

Updt::Updt(QWidget *parent, QSqlDatabase database) :

    ui(new Ui::Updt)
{
    ui->setupUi(this);

    db = database;
    query = new QSqlQuery(db);

    views.insert(EMPLOYEE_TABLE, ui->tableView);
    views.insert(DEPARTMENTS_TABLE, ui->tableView_2);
    views.insert(INFO_TABLE, ui->tableView_3);
    views.insert(STIME_TABLE, ui->tableView_4);
    views.insert(WTERM_TABLE, ui->tableView_5);

    ShowTable();

}

Updt::~Updt()
{
    delete ui;
}

// UPDATE

void Updt::on_pushButton_clicked()
{
    tmodel->submitAll();
}

void Updt::ShowTable()
{
    QMapIterator<QString, QTableView *> it(views);



    while (it.hasNext())
    {


        it.next();
        model = new QSqlQueryModel(this);
        if (it.key() == EMPLOYEE_TABLE)
        {
            tmodel = new QSqlTableModel(this);

            querymodel = new QSqlQueryModel(this);
            querymodel->setQuery(*query);

            query->exec("SELECT * FROM company.employee");

            tmodel->setTable("company.employee");
            tmodel->select();
            tmodel->setHeaderData(1, Qt::Horizontal, tr("Имя"));
            tmodel->setHeaderData(2, Qt::Horizontal, tr("Фамилия"));

            tmodel->setEditStrategy(QSqlTableModel::OnManualSubmit);
            ui->tableView->setModel(tmodel);

            ui->tableView->hideColumn(0);

            ui->tableView->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);


            qDebug() << query->lastError();
        }
        if (it.key() == DEPARTMENTS_TABLE)
        {
            tmodel = new QSqlTableModel(this);

            querymodel = new QSqlQueryModel(this);
            querymodel->setQuery(*query);

            query->exec("SELECT * FROM company.department");

            tmodel->setTable("company.department");
            tmodel->select();
            tmodel->setHeaderData(1, Qt::Horizontal, tr("Название отдела"));
            tmodel->setHeaderData(2, Qt::Horizontal, tr("Начальник"));
            tmodel->setHeaderData(3, Qt::Horizontal, tr("Должность"));
            tmodel->setHeaderData(4, Qt::Horizontal, tr("Всего пропусков"));

            ui->tableView_2->setModel(tmodel);

            ui->tableView_2->hideColumn(0);

            ui->tableView_2->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);

            qDebug() << query->lastError();
        }
        if (it.key() == INFO_TABLE)
        {
            tmodel = new QSqlTableModel(this);

            querymodel = new QSqlQueryModel(this);
            querymodel->setQuery(*query);

            query->exec("SELECT * FROM company.information");

            tmodel->setTable("company.information");
            tmodel->select();
            tmodel->setHeaderData(2, Qt::Horizontal, tr("Email сотрудника"));
            tmodel->setHeaderData(3, Qt::Horizontal, tr("Телефон сотрудника"));
            tmodel->setHeaderData(6, Qt::Horizontal, tr("Количество прогулов"));

            ui->tableView_3->setModel(tmodel);

            ui->tableView_3->hideColumn(0);
            ui->tableView_3->hideColumn(1);
            ui->tableView_3->hideColumn(4);
            ui->tableView_3->hideColumn(5);

            ui->tableView_3->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);

            qDebug() << query->lastError();
        }
        if (it.key() == STIME_TABLE)
        {
            tmodel = new QSqlTableModel(this);

            querymodel = new QSqlQueryModel(this);
            querymodel->setQuery(*query);

            query->exec("SELECT * FROM company.shift_time");

            tmodel->setTable("company.shift_time");
            tmodel->select();
            tmodel->setHeaderData(2, Qt::Horizontal, tr("Смена в часах"));

            ui->tableView_4->setModel(tmodel);

            ui->tableView_4->hideColumn(0);
            ui->tableView_4->hideColumn(2);

            ui->tableView_4->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);

            qDebug() << query->lastError();
        }
        if (it.key() == WTERM_TABLE)
        {
            tmodel = new QSqlTableModel(this);

            querymodel = new QSqlQueryModel(this);
            querymodel->setQuery(*query);

            query->exec("SELECT * FROM company.working_term");

            tmodel->setTable("company.working_term");
            tmodel->select();
            tmodel->setHeaderData(1, Qt::Horizontal, tr("Время прихода"));
            tmodel->setHeaderData(2, Qt::Horizontal, tr("Время ухода"));
            tmodel->setHeaderData(3, Qt::Horizontal, tr("Явка"));

            ui->tableView_5->setModel(tmodel);

            ui->tableView_5->hideColumn(0);

            ui->tableView_5->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);

            qDebug() << query->lastError();
        }
        query->clear();
    }
}

