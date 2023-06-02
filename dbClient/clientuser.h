#ifndef CLIENTUSER_H
#define CLIENTUSER_H

#include <QWidget>
#include <QSqlDatabase>
#include <QtSql>
#include <QString>
#include <QSqlQuery>
#include <QMap>
#include <QTableView>
#include <QMessageBox>


namespace Ui {
class ClientUser;
}

class ClientUser : public QWidget
{
    Q_OBJECT

public:
    explicit ClientUser(QWidget *parent = nullptr);
    ClientUser(QWidget *parent = nullptr, QSqlDatabase database = QSqlDatabase());
    ~ClientUser();

    QMap<QString, QTableView * > views;
    QString DEPARTMENTS_TABLE = "Department";
    QString EMPLOYEE_TABLE = "Employee";
    QString TIMETRACKING_TABLE = "TimeTracing";


    QSqlQueryModel *model = new QSqlQueryModel;
    QSqlQueryModel *model2 = new QSqlQueryModel;
    QSqlQuery *query;

    QSqlDatabase db;

    void showTables(QMap<QString, QTableView *> &views);

private slots:
    void on_comboBox_currentIndexChanged(int index);

private:
    Ui::ClientUser *ui;

    void UpdateCombo();
};

#endif // CLIENTUSER_H
