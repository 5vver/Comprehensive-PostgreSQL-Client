#ifndef UPDT_H
#define UPDT_H

#include <QWidget>
#include <QSqlDatabase>
#include <QtSql>
#include <QString>
#include <QMap>
#include <QSqlQuery>
#include <QTableView>
#include <QMessageBox>

namespace Ui {
class Updt;
}

class Updt : public QWidget
{
    Q_OBJECT
    QSqlQueryModel *model = new QSqlQueryModel;

    QSqlTableModel *tmodel;

    QSqlQueryModel *querymodel = new QSqlQueryModel;
    QSqlQuery *query;

    QString EMPLOYEE_TABLE = "Employee";
    QString DEPARTMENTS_TABLE = "Department";
    QString INFO_TABLE = "Information";
    QString STIME_TABLE = "Shifttime";
    QString WTERM_TABLE = "Workingterm";

    QMap<QString, QTableView * > views;

    QSqlDatabase db;

public:
    explicit Updt(QWidget *parent = nullptr, QSqlDatabase database = QSqlDatabase());
    ~Updt();

private slots:
    void on_pushButton_clicked();

private:
    Ui::Updt *ui;
    void ShowTable();
};

#endif // UPDT_H
