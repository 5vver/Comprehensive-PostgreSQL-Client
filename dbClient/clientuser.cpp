#include "clientuser.h"
#include "ui_clientuser.h"

ClientUser::ClientUser(QWidget *parent, QSqlDatabase database) :

    ui(new Ui::ClientUser)
{
    ui->setupUi(this);

    db = database;

    query = new QSqlQuery(database);
    views.insert(DEPARTMENTS_TABLE, ui->departmentTView);
    views.insert(EMPLOYEE_TABLE, ui->employeeTView);
    views.insert(TIMETRACKING_TABLE, ui->ttrackingTView);

    showTables(views);
    UpdateCombo();


}

ClientUser::~ClientUser()
{
    delete ui;
}

void ClientUser::showTables(QMap<QString, QTableView *> &views)
{
    QMapIterator<QString, QTableView *> it(views);

    while (it.hasNext())
    {
        it.next();
        model = new QSqlQueryModel(this);

        //qDebug() << it.key();

        if (it.key() == DEPARTMENTS_TABLE)
        {

            model->setQuery("SELECT DISTINCT d.departmentname, d.supervisorname, d.postname "
                            "FROM company.department as d", db);

            model->setHeaderData(0, Qt::Horizontal, tr("Название отдела"));
            model->setHeaderData(1, Qt::Horizontal, tr("Начальник отдела"));
            model->setHeaderData(2, Qt::Horizontal, tr("Должность"));
        }

        if (it.key() == EMPLOYEE_TABLE)
        {
            model->setQuery("SELECT e.name, e.surname, i.email, i.cellnumber "
                            "FROM company.employee AS e "
                            "LEFT JOIN company.information AS i "
                            "ON e.e_id=i.e_id ORDER BY e.surname", db);

            model->setHeaderData(0, Qt::Horizontal, tr("Имя сотрудника"));
            model->setHeaderData(1, Qt::Horizontal, tr("Фамилия сотрудника"));
            model->setHeaderData(2, Qt::Horizontal, tr("Email сотрудника"));
            model->setHeaderData(3, Qt::Horizontal, tr("Телефон сотрудника"));
        }

        if (it.key() == TIMETRACKING_TABLE)
        {
            model->setQuery("SELECT e.name, e.surname, s.shifttime, w.arrivaltime, w.leavingtime "
                            "FROM company.employee AS e "
                            "LEFT JOIN company.information AS i "
                            "ON e.e_id=i.e_id "
                            "LEFT JOIN company.shift_time AS s "
                            "ON i.stime_id=s.stime_id "
                            "LEFT JOIN company.working_term AS w "
                            "ON s.wterm_id=w.wterm_id ORDER BY e.surname", db);


            model->setHeaderData(0, Qt::Horizontal, tr("Имя сотрудника"));
            model->setHeaderData(1, Qt::Horizontal, tr("Фамилия сотрудника"));
            model->setHeaderData(2, Qt::Horizontal, tr("Смена в часах"));
            model->setHeaderData(3, Qt::Horizontal, tr("Время и дата прибытия"));
            model->setHeaderData(4, Qt::Horizontal, tr("Время и дата ухода"));
        }

        it.value()->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
        it.value()->setModel(model);
        query->clear();

    }
}

void ClientUser::UpdateCombo()
{
    int index = ui->comboBox->currentIndex();
}

// second assign combo box

void ClientUser::on_comboBox_currentIndexChanged(int index)
{
    if (index == 0)
    {
        model2->setQuery("SELECT surname,"
                        " CASE "
                        "WHEN shifttime < 8 "
                        "THEN 'Смена < 8 часов' "
                        "ELSE CAST(shifttime AS CHAR(20)) "
                        "END shifttime "
                        "FROM company.employee "
                        "LEFT JOIN company.information "
                        "ON company.employee.e_id=company.information.e_id "
                        "LEFT JOIN company.shift_time ON company.information.stime_id=company.shift_time.stime_id", db);


        model2->setHeaderData(0, Qt::Horizontal, tr("Фамилия сотрудника"));
        model2->setHeaderData(1, Qt::Horizontal, tr("Смена"));
        ui->resultsTView->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
        ui->resultsTView->setModel(model2);
        query->clear();

    }
    else if (index == 1)
    {
        model2->setQuery("SELECT e.name, e.surname, i.cellnumber, i.email "
                        "FROM company.employee AS e "
                        "LEFT JOIN company.information AS i ON e.e_id=i.e_id", db);

        //qDebug() << query->lastQuery();

        model2->setHeaderData(0, Qt::Horizontal, tr("Имя сотрудника"));
        model2->setHeaderData(1, Qt::Horizontal, tr("Фамилия сотрудника"));
        model2->setHeaderData(2, Qt::Horizontal, tr("Смена в часах"));
        model2->setHeaderData(3, Qt::Horizontal, tr("Приход"));
        model2->setHeaderData(4, Qt::Horizontal, tr("Уход"));

        ui->resultsTView->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
        ui->resultsTView->setModel(model2);
        query->clear();
    }
    else if (index == 2)
    {
        model2->setQuery("SELECT e.name, e.surname, "
        "(SELECT cellnumber FROM company.information WHERE e_id=e.e_id) AS cell, "
        "(SELECT s.shifttime FROM (SELECT shifttime, stime_id FROM company.shift_time "
        "WHERE stime_id=(SELECT stime_id FROM company.information WHERE e_id=e.e_id)) AS s) "
        "FROM (SELECT name, surname, e_id FROM company.employee) AS e "
        "WHERE (SELECT s.shifttime FROM (SELECT shifttime, stime_id FROM company.shift_time "
        "WHERE stime_id=(SELECT stime_id FROM company.information WHERE e_id=e.e_id)) AS s) > (SELECT AVG(shifttime) FROM company.shift_time)", db);

        //qDebug() << query->lastQuery();

        model2->setHeaderData(0, Qt::Horizontal, tr("Имя сотрудника"));
        model2->setHeaderData(1, Qt::Horizontal, tr("Фамилия сотрудника"));
        model2->setHeaderData(2, Qt::Horizontal, tr("Телефон"));
        model2->setHeaderData(3, Qt::Horizontal, tr("Смена в часах"));

        ui->resultsTView->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
        ui->resultsTView->setModel(model2);
        query->clear();
    }
    else if (index == 3)
    {
        model2->setQuery("SELECT i.email, i.cellnumber, i.truancies "
                        "FROM company.information AS i "
                        "WHERE (SELECT i.truancies) > 0 "
                        "ORDER BY i.email", db);

        //qDebug() << query->lastQuery();

        model2->setHeaderData(0, Qt::Horizontal, tr("Почта сотрудника"));
        model2->setHeaderData(1, Qt::Horizontal, tr("Телефон"));
        model2->setHeaderData(2, Qt::Horizontal, tr("Количество прогулов"));

        ui->resultsTView->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
        ui->resultsTView->setModel(model2);
        query->clear();
    }
    else if (index == 4)
    {
        model2->setQuery("SELECT email, cellnumber, (SELECT i.truancies<1) "
                        "FROM company.information AS i", db);

        //qDebug() << query->lastQuery();

        model2->setHeaderData(0, Qt::Horizontal, tr("Почта сотрудника"));
        model2->setHeaderData(1, Qt::Horizontal, tr("Телефон"));
        model2->setHeaderData(2, Qt::Horizontal, tr("Были ли прогулы"));

        ui->resultsTView->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
        ui->resultsTView->setModel(model2);
        query->clear();
    }
    else if (index == 5)
    {
        model2->setQuery("SELECT d.departmentname, SUM(t.truancies) "
                        "FROM company.department AS d, (SELECT truancies, department_id FROM company.information) AS t "
                        "WHERE d.department_id=t.department_id "
                        "GROUP BY d.departmentname", db);

        //qDebug() << query->lastQuery();

        model2->setHeaderData(0, Qt::Horizontal, tr("Название отдела"));
        model2->setHeaderData(1, Qt::Horizontal, tr("Количество прогулов"));

        ui->resultsTView->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
        ui->resultsTView->setModel(model2);
        query->clear();
    }
    else if (index == 6)
    {

        model2->setQuery("SELECT name, surname, cellnumber, truancies "
                        "FROM company.employee, company.information, company.shift_time, company.department "
                        "WHERE employee.e_id=information.e_id AND information.stime_id=shift_time.stime_id "
                        "AND information.department_id=company.department.department_id "
                        "GROUP BY surname, name, cellnumber, truancies, total_truancies "
                        "HAVING (SELECT AVG(truancies) FROM company.information) > (SUM(total_truancies))", db);



        model2->setHeaderData(0, Qt::Horizontal, tr("Имя сотрудника"));
        model2->setHeaderData(1, Qt::Horizontal, tr("Фамилия сотрудника"));
        model2->setHeaderData(2, Qt::Horizontal, tr("Телефон"));
        model2->setHeaderData(3, Qt::Horizontal, tr("Количество прогулов"));
        model2->setHeaderData(4, Qt::Horizontal, tr("Прогулов всего в отделе"));

        ui->resultsTView->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
        ui->resultsTView->setModel(model2);
        // qDebug() << query->lastError();
        query->clear();

    }
    else if (index == 7)
    {
        QString dep = ui->secondLine->text();
        if (!dep.isEmpty())
        {
            model2->setQuery("SELECT e.name, e.surname, d.departmentname "
                            "FROM company.employee AS e "
                            "LEFT JOIN company.information AS i "
                            "ON e.e_id=i.e_id "
                            "LEFT JOIN company.department AS d "
                            "ON i.department_id=d.department_id "
                            "LEFT JOIN company.shift_time AS s "
                            "ON i.stime_id=s.stime_id "
                            "LEFT JOIN company.working_term AS w "
                            "ON s.wterm_id=w.wterm_id "
                            "WHERE (SELECT ALL(d.departmentname='" + dep + "' AND w.appeared = false))", db);

            //qDebug() << query->lastQuery();

            model2->setHeaderData(0, Qt::Horizontal, tr("Имя сотрудника"));
            model2->setHeaderData(1, Qt::Horizontal, tr("Фамилия сотрудника"));
            model2->setHeaderData(2, Qt::Horizontal, tr("Название отдела"));

            ui->resultsTView->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
            ui->resultsTView->setModel(model2);
            query->clear();
        }
        else
        {
            QMessageBox msg;
            msg.setText("Input should not be empty(name of department)");
            msg.exec();
        }
    }
}

