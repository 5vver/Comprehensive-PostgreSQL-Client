#include "clientadmin.h"
#include "ui_clientadmin.h"

ClientAdmin::ClientAdmin(QWidget *parent, QSqlDatabase database) :

    ui(new Ui::ClientAdmin)
{
    ui->setupUi(this);
    setlocale(LC_ALL,"Russian");


    db = database;
    query = new QSqlQuery(database);

    views.insert(EMPLOYEE_TABLE, ui->mainTView);
    views.insert(DEPARTMENTS_TABLE, ui->mainDTView);

    ShowTable(views);
}

ClientAdmin::~ClientAdmin()
{
    delete ui;
}

void ClientAdmin::ShowTable(QMap<QString, QTableView *> &views)
{
    QMapIterator<QString, QTableView *> it(views);

    while (it.hasNext())
    {
        it.next();
        model = new QSqlQueryModel(this);
        if (it.key() == EMPLOYEE_TABLE)
        {
            model->setQuery("SELECT name, surname, departmentname, cellnumber, email, truancies, shifttime, arrivaltime, leavingtime "
                            "FROM company.employee, company.information, company.shift_time, company.department, company.working_term "
                            "WHERE employee.e_id=information.e_id AND information.stime_id=shift_time.stime_id "
                            "AND department.department_id=information.department_id "
                            "AND shift_time.wterm_id=working_term.wterm_id "
                            "GROUP BY name, surname, departmentname, cellnumber, email, truancies, shifttime, arrivaltime, leavingtime", db);

            model->setHeaderData(0, Qt::Horizontal, tr("Имя"));
            model->setHeaderData(1, Qt::Horizontal, tr("Фамилия"));
            model->setHeaderData(2, Qt::Horizontal, tr("Отдел"));
            model->setHeaderData(3, Qt::Horizontal, tr("Номер"));
            model->setHeaderData(4, Qt::Horizontal, tr("Почта"));
            model->setHeaderData(5, Qt::Horizontal, tr("Прогулы"));
            model->setHeaderData(6, Qt::Horizontal, tr("Смена"));
            model->setHeaderData(7, Qt::Horizontal, tr("Прибыл"));
            model->setHeaderData(8, Qt::Horizontal, tr("Ушел"));
        }
        if (it.key() == DEPARTMENTS_TABLE)
        {
            model->setQuery("SELECT departmentname, supervisorname, postname, total_truancies "
                            "FROM company.department", db);

            model->setHeaderData(0, Qt::Horizontal, tr("Название отдела"));
            model->setHeaderData(1, Qt::Horizontal, tr("Начальник"));
            model->setHeaderData(2, Qt::Horizontal, tr("Должность сотрудника"));
            model->setHeaderData(3, Qt::Horizontal, tr("Всего прогулов"));
        }
        it.value()->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
        it.value()->setModel(model);
        query->clear();
    }
}

// EMPLOYEEES

void ClientAdmin::on_mainTView_clicked(const QModelIndex &index)
{
    const QAbstractItemModel *model = index.model();
    rowvals.clear();
    for (int i = 0; i < model->columnCount(); i++)
    {
        rowval = (index.model()->data(index.model()->index(index.row(), i)).toString());
        rowvals.append(rowval);
    }
    slotSelected = true;
    dslotSelected = false;
    qDebug() << rowvals;
}

// DEPARTMENTS

void ClientAdmin::on_mainDTView_clicked(const QModelIndex &index)
{
    const QAbstractItemModel *model = index.model();
    rowvals.clear();
    for (int i = 0; i < model->columnCount(); i++)
    {
        rowval = (index.model()->data(index.model()->index(index.row(), i)).toString());
        rowvals.append(rowval);
    }
    qDebug() << rowvals;

    dslotSelected = true;
    slotSelected = false;
}

// DELETE

void ClientAdmin::on_pushButton_2_clicked()
{
    if (slotSelected)
    {
        QString cell = rowvals[3];
        QString email = rowvals[4];
        //qDebug() << cell << email;
        query = new QSqlQuery(db);

        query->prepare("SELECT company.delete_data_cell_email(:cell, :email);");
        query->bindValue(":cell", cell);
        query->bindValue(":email", email);

        query->exec();
        qDebug() << query->lastQuery();
        qDebug() << query->lastError();

    }
    if (dslotSelected)
    {
        QString dname = rowvals[0];
        QString pname = rowvals[2];

        qDebug() << dname << pname;

        query = new QSqlQuery(db);

        query->prepare("SELECT company.delete_department_name_post(:dname, :pname);");
        query->bindValue(":dname", dname);
        query->bindValue(":pname", pname);

        query->exec();

        // qDebug() << query->lastQuery();
        // qDebug() << query->lastError();
    }
    ShowTable(views);
}

// ADD

void ClientAdmin::on_pushButton_3_clicked()
{
    addpage = new addt(this, db);
    addpage->show();
}

// UPDATE

void ClientAdmin::on_pushButton_clicked()
{
    updatepage = new Updt(this, db);
    updatepage->show();
}

// UPDATE TABLE VIEW

void ClientAdmin::on_pushButton_4_clicked()
{
    ShowTable(views);
}


// add prepared

void ClientAdmin::on_pushButton_5_clicked()
{
    query = new QSqlQuery(db);
    query->exec("SELECT company.insert_data('Антон','Печенов', 3,'shrekmegakek35@gmail.com', '+79023441312', '2012-07-18 18:00:00', '2012-06-21 2:00:00', 8)");

    qDebug() << query->lastError();
    query->clear();
}

