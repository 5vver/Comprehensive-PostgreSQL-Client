#include "Add.h"
#include "ui_add.h"

Add::Add(QWidget *parent, QSqlDatabase database) :

    ui(new Ui::Add)
{
    ui->setupUi(this);

    db = database;
    query = new QSqlQuery(database);
    model = new QSqlQueryModel(this);

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



    ui->tableView->setSelectionMode(QAbstractItemView::SingleSelection);

    ui->tableView->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    ui->tableView->setModel(model);

}

Add::~Add()
{
    delete ui;
}

// CLICK ADD

void Add::on_pushButton_clicked()
{

}

